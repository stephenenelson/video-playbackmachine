package Video::PlaybackMachine::Player;

####
#### Video::PlaybackMachine::Player
####
#### A POE::Session which displays movies and still frames onscreen
#### based on events.
####

use strict;
use base 'Exporter';
our @EXPORT_OK = qw(PLAYER_STATUS_STOP PLAYER_STATUS_PLAY PLAYER_STATUS_STILL
                    PLAYBACK_OK PLAYBACK_ERROR PLAYBACK_STOPPED);

use POE;
use X11::FullScreen;
use Video::Xine;
use Log::Log4perl;
use Carp;

############################# Class Constants ################################

## Status codes Xine will report
use constant PLAYER_STATUS_STOP => 0;
use constant PLAYER_STATUS_PLAY => 1;

## How-the-movie-played status codes

# OK == played through and stopped at the end
use constant PLAYBACK_OK => 1;

# ERROR == problem in trying to play
use constant PLAYBACK_ERROR => 2;

use constant X_DISPLAY => ':0.0';

## Types of playback
use constant PLAYBACK_TYPE_MUSIC => 0;
use constant PLAYBACK_TYPE_MOVIE => 1;

############################## Class Methods #################################

##
## new()
##
## Returns a new instance of Player. Note that the session is not created
## until you call spawn().
##
sub new {
  my $type = shift;

  my $self = {
	      logger => Log::Log4perl->get_logger('Video.PlaybackMachine.Player'),
	     };


  bless $self, $type;
}

############################## Session Methods ###############################

##
## On session start, initializes Xine and prepares it to start playing.
## The Xine screen will not appear until the first 'play' request.
##
sub _start {
  my $kernel = $_[KERNEL];

  $kernel->alias_set('Player');
  my $display = X11::FullScreen::Display->new(X_DISPLAY);
  $_[HEAP]->{'display'} = $display;
  $_[HEAP]->{'window'} = $display->createWindow();
  $display->sync();
  my $xine = Video::Xine->new();
  $_[HEAP]->{'xine'} = $xine;
  my $x11_visual = Video::Xine::Util::make_x11_visual($display,
						      $display->getDefaultScreen(),
						      $_[HEAP]->{'window'},
						      $display->getWidth(),
						      $display->getHeight(),
						      $display->getPixelAspect()
						     );
  my $driver = Video::Xine::Driver::Video->new($xine,"auto",1,$x11_visual);
  $_[HEAP]->{'stream'} = $xine->stream_new(undef, $driver)
    or croak "Unable to open video stream";
  $_[HEAP]->{'stream_queue'} =
    Video::PlaybackMachine::Player::EventWheel->new($_[HEAP]{'stream'});
}

##
## Responds to a 'play' request by playing a movie on Xine.
## Arguments:
##   ARG0: $postback -- what to call after the play is completed
##   ARG1: $offset -- number of seconds after the movie's start to begin
##   ARG2: @filenames -- ARG1 onward contains the files to play, in order.
##
## After Xine is started, we'll check on it every $XINE_CHECK_INTERVAL
## seconds to see if it has stopped.
##
sub play {
  my ($kernel, $self, $heap, $postback, $offset, @files) = @_[KERNEL, OBJECT, HEAP, ARG0, ARG1, ARG2 .. $#_ ];

  defined $offset or $offset = 0;

  my $log = $_[OBJECT]{'logger'};

  @files or die "No files specified! stopped";

  # Stop if we're playing
  if ( $heap->{'stream'}->get_status() == XINE_STATUS_PLAY ) {
    $heap->{'stream'}->stop();
    $heap->{'stream'}->close();
  }

  $log->info("Playing ($offset): $files[0]");

  my $s = $_[HEAP]->{'stream'};
  $s->open($files[0])
    or do {
      $log->error("Unable to open '$files[0]': Error " . $s->get_error());
      $postback->(PLAYBACK_ERROR);
      return;
    };
  $s->play(0,$offset * 1000)
    or do {
      $log->error("Unable to play '$files[0]': Error " . $s->get_error());
      $postback->(PLAYBACK_ERROR);
      return;
    };

  # Spawn a watcher to call the postback after the fact
  $heap->{'stream_queue'}->set_stop_handler($postback);
  $heap->{'stream_queue'}->spawn();

}

##
## play_still()
##
## Arguments:
##   STILL_FILE: Filename of our stillstore.
## 
## Responds to a 'play_still' request by playing a still frame
## on Xine. The stillframe will remain there until something
## replaces it.
##
sub play_still {
    $_[OBJECT]{'logger'}->debug("Showing '$_[ARG0]'");
    eval {
      $_[HEAP]{'display'}->displayStill($_[HEAP]{'window'}, $_[ARG0]);
    }
}

##
## play_music()
##
## Arguments:
##  ARG0 -- callback. What to call when the music's over.
##  ARG1 -- song file. Filename of the song to play.
##
## Responds to a 'play_music' request by playing a particular song.
## Logs a warning and does nothing if we tried to play music during a
## movie. If a song was already playing, lets it play, but substitutes
## the current callback.
##
sub play_music {
  my ($self, $heap, $kernel, $callback, $song_file) = @_[OBJECT,HEAP,KERNEL,ARG0,ARG1];
  defined $callback or die "Must define callback!\n";

  defined $song_file or die "Must define song file!\n";

  # If there's a movie running, let it play
  if ($self->get_status() == PLAYER_STATUS_PLAY) {
    $self->{'logger'}->warn("Attempted to play '$song_file' while a movie is playing");
    $callback->(PLAYBACK_ERROR);
    return;
  }
  else {
    
    $heap->{'stream'}->open($song_file)
      or do {
	$self->{'logger'}->warn("Unable to play '$song_file'");
	$callback->(PLAYBACK_ERROR);
	return;
      };
    $heap->{'stream'}->play(0,0);
    $heap->{'stream_queue'}->set_stop_handler($callback);
    $heap->{'stream_queue'}->spawn();
  }

}




############################## Object Methods ################################

##
## spawn()
##
## Creates the appropriate Player session.
##
sub spawn {
  my $self = shift;
  my ($finish_callback) = @_;

  POE::Session->create(
		       object_states => 
		       [
			$self => [
				  qw(_start
                                     play
                                     play_still
				     play_music
                                  )
				 ] ,
		       ],
		     );
}

##
## get_status()
##
## Returns one of:
##   PLAYER_STATUS_PLAY if a movie (or music) is playing
##   PLAYER_STATUS_STOP if nothing is playing.
##
sub get_status {
  my $self = shift;

  my $heap = $poe_kernel->get_active_session()->get_heap();

  $heap->{'stream'}->get_status() == XINE_STATUS_PLAY
    and return PLAYER_STATUS_PLAY;

  return PLAYER_STATUS_STOP;
}


package Video::PlaybackMachine::Player::EventWheel;

###
### When spawned, these will pass along events from the given
### streams to the appropriate callbacks.
###

use strict;
use POE;
use Video::Xine;

## How often to check to see if Xine has stopped, in seconds
use constant XINE_CHECK_INTERVAL_SECS => 2;

sub new {
  my $type = shift;
  my ($stream, %handlers) = @_;

  my $self = {
	      stream => $stream,
	      handlers => { %handlers }
	     };

  bless $self, $type;
}

sub spawn {
  my $self = shift;
  my ($callback) = @_;

  POE::Session->create(
		       object_states => [$self=>[qw(_start get_events)]]
		      );
}

sub _start {
  my ($self, $heap, $kernel) = @_[OBJECT, HEAP, KERNEL];

  $heap->{queue} = Video::Xine::Event::Queue->new($self->{'stream'})
    or die "Couldn't create Xine::Event::Queue";

  $kernel->yield('get_events');
}

sub get_events {
  my ($self, $heap, $kernel) = @_[OBJECT, HEAP, KERNEL];

  # Translate all events into callbacks
  while ( my $event = $heap->{queue}->get_event() ) {
    if ( $event->get_type() == XINE_EVENT_UI_PLAYBACK_FINISHED ) {
      $self->{'stream'}->close();
    }
    if ( exists $self->{'handlers'}{$event->get_type()} ) {
      $self->{'handlers'}{$event->get_type()}->($self->{'stream'}, $event);
    }
  }

  # Keep checking so long as we're playing
  if ( $self->{'stream'}->get_status() == XINE_STATUS_PLAY ) {
    $kernel->delay('get_events', XINE_CHECK_INTERVAL_SECS);
  }
  else {
    delete $heap->{queue};
  }
}

sub set_handler {
  my $self = shift;
  my ($event, $callback) = @_;
  $self->{'handlers'}{$event} = $callback;
}


# Convenience method
sub set_stop_handler {
  $_[0]->set_handler(XINE_EVENT_UI_PLAYBACK_FINISHED, $_[1]);
}

