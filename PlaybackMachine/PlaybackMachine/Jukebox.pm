package Video::PlaybackMachine::Jukebox;

####
#### Video::PlaybackMachine::Jukebox
####
#### $Revision$
####
#### Plays songs. Selects the songs more or less randomly.
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

## Time we take to fade in or out (ms)
our $Fade_Ms = 250;

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

  my $music = SDL::Music->new( $self->get_music() );
  $self->{'mixer'}->fade_in_music($music, 1, $Fade_Ms);
  
  $heap->{'music'} = $music;

}

sub check_music {

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

##
## Returns a list of music files.
##
sub get_music_files {
	my $self = shift;
	
  my $dh = IO::Dir->new($self->{'directory'});
  my @music_files = ();
  while ( my $file = $dh->read() ) {
    $file =~ /\.^/ and next;
    -f $file or next;
    $file =~ /\.(mp3|wav|ogg)$/ or next;
    push(@music_files, "$self->{'directory'}/$file");
  }
  return @music_files;
  
}

sub get_music {
	my $self = shift;
	my @music_files = $self->get_music_files();
	return $music_files[ rand @music_files ];	
}	


1;
