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
                    PLAYBACK_STATUS_OK PLAYBACK_STATUS_ERROR);

use POE;
use Xine_simple qw(:all);

############################# Class Constants ################################

## How often to check to see if Xine has stopped, in seconds
use constant XINE_CHECK_INTERVAL_SECS => 2;

## Status codes Xine will report
use constant PLAYER_STATUS_STOP => 0;
use constant PLAYER_STATUS_PLAY => 1;
use constant PLAYER_STATUS_STILL => 2;

## How-the-movie-played status codes
use constant PLAYBACK_OK => 1;
use constant PLAYBACK_ERROR => 2;


############################## Class Methods #################################

##
## new()
##
## Returns a new instance of Player. Note that the session is not created
## until you call spawn().
##
sub new {
  my $type = shift;

  bless {}, $type;
}

############################## Session Methods ###############################

##
## On session start, initializes Xine and prepares it to start playing.
## The Xine screen will not appear until the first 'play' request.
##
sub _start {
  my $kernel = $_[KERNEL];

  $kernel->alias_set('Player');
  xine_simple_init();

}

##
## Clean up after Xine.
##
sub _stop {
  if ( $_[OBJECT]->get_status() != PLAYER_STATUS_STOP ) {
    xine_simple_stop();
  }
}

##
## Responds to a 'play' request by playing a movie on Xine.
## Arguments:
##   ARG0: $offset -- number of seconds after the movie's start to begin
##   ARG1: @filenames -- ARG1 onward contains the files to play, in order.
##
## After Xine is started, we'll check on it every $XINE_CHECK_INTERVAL
## seconds to see if it has stopped.
##
## Currently Xine_simple doesn't report errors, but if it did we'd send
## an 'Error' event to Logger with what had happened.
##
## TODO: We should add a check to see if Xine is already running and report
##       an error if so.
##
sub play {
  my ($kernel, $heap, $postback, $offset, @files) = @_[KERNEL, HEAP, ARG0, ARG1, ARG2 .. $#_ ];

  $heap->{postback} = $postback;

  defined $offset or $offset = 0;

  @files or die "No files specified! stopped";

  print STDERR scalar localtime(), ": Playing ($offset):", join(' ', @files), "\n";

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
  $_[OBJECT]->get_status() == PLAYER_STATUS_STOP
    or xine_simple_stop();
  xine_simple_play_still($_[ARG0]);
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
    $postback->(PLAYBACK_OK);
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
		       object_states => [ $self => [ qw(_start _stop play play_still check_finished) ] ],
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
