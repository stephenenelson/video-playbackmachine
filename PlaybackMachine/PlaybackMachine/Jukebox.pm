package Video::PlaybackMachine::Jukebox;

####
#### Video::PlaybackMachine::Jukebox
####
#### $Revision$
####
#### Plays songs. Selects the songs more or less randomly,
#### but will avoid playing songs that it has played recently.
####

use strict;
use warnings;
use Carp;

use POE;

############################# Class Constants #############################

############################## Class Methods ##############################

##
## new()
##
## Arguments: (hash)
##   song_chooser => Video::PlaybackMachine::NeophileChooser
##   song_player => Video::PlaybackMachine::MusicPlayer
##   check_interval => int -- Number of seconds between checks on whether 
##                            we're playing
sub new {
  my $type = shift;
  my (%in) = @_;

  my $self = {
	      song_chooser => $in{song_chooser},
	      song_player => $in{song_player},
	      check_interval => $in{check_interval}
	     };

  bless $self, $type;

}

############################# Object Methods ##############################

sub spawn {
  my $self = shift;

  POE::Session->create(
		       inline_states => {
					 _start => sub { }
					},
		       object_states => [
					 
					]
		      );

}


1;
