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
use SDL;
use SDL::Music;
use SDL::Mixer;

use IO::Dir;

############################# Class Constants #############################

############################## Class Methods ##############################

##
## new()
##
## Arguments: (hash)
##   directory => string -- Directory which holds songs
##   check_interval => int -- Number of seconds between checks on whether 
##                            we're playing
sub new {
  my $type = shift;
  my (%in) = @_;

  my $self = {
	      directory => $in{song_dir},
	      check_interval => 2
	     };

  $self->{'mixer'} = SDL::Mixer->new(
				     -frequency => MIX_DEFAULT_FREQUENCY,
				     -format => MIX_DEFAULT_FORMAT,
				     -channels => MIX_DEFAULT_CHANNELS,
				     -size => 4096
				    );

  bless $self, $type;

}

############################## Event Handlers #############################

sub start_music {
  my ($self, $kernel, $heap) = @_[OBJECT, KERNEL, HEAP];

  my @music_files = $self->get_music_files();

  $heap->{'music'} = SDL::Music->new( $self->get_music() );

}


############################# Object Methods ##############################

sub spawn {
  my $self = shift;

  POE::Session->create(
		       inline_states => {
					 _start => sub { }
					},
		       object_states => [
					 $self => [ qw(start_music stop_music check_music) ]
					]
		      );

}

sub get_music_files {

  my $dh = IO::Dir->new($self->{'directory'});
  my @music_files = ();
  while ( my $file = $dh->read() ) {
    $file =~ /\.^/ and next;
    -f $file or next;
    $file =~ /\.(mp3|wav)$/ or next;
    push(@music_files, "$self->{'directory'}/$file");
  }
  return @music_files;
  
}


1;
