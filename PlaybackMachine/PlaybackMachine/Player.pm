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
use Xine_simple qw(:all);

use SDL;
use SDL::Music;
use SDL::Mixer;

############################# Class Constants ################################

## How often to check to see if Xine has stopped, in seconds
use constant XINE_CHECK_INTERVAL_SECS => 2;

## How often to check if music has stopped, in seconds
use constant MUSIC_CHECK_INTERVAL => 10;

## How long, in milliseconds, to fade out music
use constant MUSIC_FADE_MILLIS => 250;

## Status codes Xine will report
use constant PLAYER_STATUS_STOP => 0;
use constant PLAYER_STATUS_PLAY => 1;
use constant PLAYER_STATUS_STILL => 2;

## How-the-movie-played status codes

# OK == played through and stopped at the end
use constant PLAYBACK_OK => 1;

# ERROR == problem in trying to play
use constant PLAYBACK_ERROR => 2;

# STOPPED == manually stopped or preempted by something else. Don't
# try to play anything else. (Mostly for music or slides.)
use constant PLAYBACK_STOPPED => 3;

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
	      music_check_interval => MUSIC_CHECK_INTERVAL,
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
  xwindows_init();
  my $mixer = SDL::Mixer->new(
			      -frequency => MIX_DEFAULT_FREQUENCY,
			      -format => MIX_DEFAULT_FORMAT,
			      -channels => MIX_DEFAULT_CHANNELS,
			      -size => 4096
			      );
  $_[HEAP]->{'mixer'} = $mixer;

 
}

##
## Clean up after Xine.
##
sub _stop {
  if ( $_[OBJECT]->get_status() == PLAYER_STATUS_PLAY ) {
    xine_simple_stop();
  }
  delete $_[HEAP]->{'mixer'};
  xwindows_cleanup();
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
  my ($kernel, $heap, $postback, $offset, @files) = @_[KERNEL, HEAP, ARG0, ARG1, ARG2 .. $#_ ];

  $heap->{postback} = $postback;

  defined $offset or $offset = 0;

  @files or die "No files specified! stopped";

  # Fade out music before playing a movie
  $_[OBJECT]->stop_music($heap, $kernel);

  print STDERR scalar localtime(), ": Playing ($offset):", join(' ', @files), "\n";

  xine_simple_init();

  xine_simple_play(\@files, $offset * 1000);

  $kernel->delay( 'check_finished', XINE_CHECK_INTERVAL_SECS );

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
    print STDERR "Showing '$_[ARG0]'\n";
    xine_simple_play_still($_[ARG0]);
}

##
## play_music()
##
## Arguments:
##  ARG0 -- callback. What to call when the music's over.
##  ARG1 -- song file. Filename of the song to play.
##
## Responds to a 'play_music' request by playing a particular
## song using the SDL libraries. SDL can play mp3 or ogg files.
## Prints a warning and does nothing if we tried to play music
## during a movie.
##
sub play_music {
  my ($self, $heap, $kernel, $callback, $song_file) = @_[OBJECT,HEAP,KERNEL,ARG0,ARG1];
  defined $callback or die "Must define callback!\n";

  defined $song_file or die "Must define song file!\n";

  if ($self->get_status() == PLAYER_STATUS_PLAY) {
    print STDERR "Attempted to play '$song_file' while a movie is playing\n";
    $callback->(PLAYBACK_ERROR);
    return;
  }
  elsif ($heap->{'music_postback'}) {
    print STDERR "Attempted to start song '$song_file' over previously-playing one\n";
    my $callback = delete $heap->{'music_postback'};
    $kernel->alarm_remove('check_music_finished');
    $callback->(PLAYBACK_ERROR);
    return;
  }
  else {

    $heap->{'music_postback'} = $callback;

    print STDERR "Starting song '$song_file'\n";

    my $music = SDL::Music->new( $song_file )
      or die "Couldn't open '$song_file' for some reason";
    $heap->{'mixer'}->play_music($music,1);


    $kernel->delay( 'check_music_finished', MUSIC_CHECK_INTERVAL );
  }
}

sub stop_music {
  my $self = shift;
  my ($heap, $kernel) = @_;

  $kernel->alarm_remove('check_music_finished');

  defined ($heap->{'mixer'}) or return;

  my $postback = delete $heap->{'music_postback'};

  $postback->(PLAYBACK_STOPPED) if defined $postback;

  $heap->{'mixer'}->playing_music() or return;

  $heap->{'mixer'}->fade_out_music();


}

##
## Responds to a 'check_finished' request by checking to see if
## Xine is playing a movie. If not, fires a 'finished' event at the scheduler.
## If so, tells itself to check again in XINE_CHECK_INTERVAL_SECS seconds.
##
sub check_finished {
  my ($self, $kernel, $heap) = @_[OBJECT, KERNEL, HEAP];

  if ( $self->get_status() == PLAYER_STATUS_PLAY ) {
    $kernel->delay( 'check_finished', XINE_CHECK_INTERVAL_SECS );
  }
  else {
    my $postback = delete $heap->{postback};
    xine_simple_cleanup();
    $postback->(PLAYBACK_OK);
  }
}

##
## Responds to a 'check_music_finished' event by checking to see if
## the music's still going. If the music's over, hits the callback
## with an "OK" message. Otherwise, continues the checking.
##
# NOTE Tempting to abstract the start/run/check/signal pattern to a bunch
# of child sessions with adapter objects for SDL, Xine, and Imlib2.
sub check_music_finished {
  my ($self, $heap, $kernel) = @_[OBJECT,HEAP,KERNEL];

  if ($heap->{'mixer'}->playing_music()) {
    $kernel->delay( 'check_music_finished', MUSIC_CHECK_INTERVAL );
  }
  else {
    print STDERR "Music finished\n";
    my $postback = delete $heap->{music_postback};
    $postback->(PLAYBACK_OK) if defined $postback;
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

  POE::Session->create(
		       object_states => 
		       [ 
			$self => [
				  qw(_start
                                     _stop
                                     play
                                     play_still
                                     check_finished
				     play_music
				     check_music_finished
                                  ) 
				 ] 
		       ],
		     );
}

##
## get_status()
##
## Returns one of:
##   PLAYER_STATUS_PLAY if a movie is playing
##   PLAYER_STATUS_STILL if a still image is on the screen
##   PLAYER_STATUS_STOP if nothing is playing.
##
sub get_status {
  my $self = shift;

  return xine_simple_get_status();
}
