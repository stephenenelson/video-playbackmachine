package Video::PlaybackMachine::FillProducer::SlideShow;

####
#### Video::PlaybackMachine::FillProducer::SlideShow
####
#### $Revision$
####
#### Plays a bunch of random photos. Since we need to do things
#### at particular delay times, launches its own POE session.
####

use strict;
use warnings;

use Carp;
use POE;
use IO::Dir;

use base 'Video::PlaybackMachine::FillProducer';

use Video::PlaybackMachine::TimeLayout::GranularTimeLayout;

############################# Class Constants #############################

# Maximum number of slides to play in a row
our $Max_Slides = 3;

############################## Class Methods ##############################

##
## new()
##
## Arguments: (hash)
##  TIME: int -- Time in seconds that we want to display a still
##  DIRECTORY: string -- Directory containing stills we want to display
##
sub new {
  my $type = shift;
  my %in = @_;

  defined $in{time} or croak($type, "::new() called incorrectly");

  my $self = {

	      time_layout => 
	      Video::PlaybackMachine::TimeLayout::GranularTimeLayout->new($in{time}),
	      directory => $in{'directory'},
	      time => $in{time}
	     };

  bless $self, $type;
}

############################# Object Methods ##############################

##
## get_time_layout()
##
## Returns the FixedTimeLayout for the appropriate time.
##
sub get_time_layout {
  $_[0]->{time_layout};
}

##
## has_audio()
##
## Stills don't have an audio track.
##
sub has_audio { return; }

##
## Slideshow is available if the directory exists
## and there are images in it.
##
sub is_available {
  my $self = shift;

  -d $self->{'directory'} or return;
  $self->getFrames() >= 1 or return;
  return 1;

}

sub getFrames {
  my $self = shift;

  my $dh = IO::Dir->new($self->{'directory'});
  my @frames = ();
  while ( my $file = $dh->read() ) {
    next if $file =~ /^\./;
    next unless -f "$self->{'directory'}/$file";
    push(@frames, "$self->{'directory'}/$file");
  }
  return @frames;
}

##
## show_slide()
##
## Displays a set of random still frames.
##
sub show_slide {
  my ($self, $kernel, $heap) = @_[OBJECT,KERNEL,HEAP];


  # If we have enough time to play another slide, call the player
  # to play it.
  my $time_played = ( time() - $heap->{'slide_start_time'} );
  if ( $heap->{planned_time} >  $time_played) {
    my @frames = $self->getFrames();
    my $frame = $frames[ rand( scalar @frames ) ];
    $kernel->post('Player', 'play_still', $frame);
    $kernel->delay('show_slide', $self->{'time'});
  }
  # Otherwise, cancel all slides and shut things down.
  # (The alarm cancel should be redundant.)
  else {
    print STDERR "Shutting down slideshow (time left=$time_played, $heap->{planned_time})\n";
    $kernel->alarm('show_slide');
    $kernel->state('show_slide');
    delete $heap->{'slide_start_time'};
    delete $heap->{'planned_time'};

    $kernel->yield('next_fill');
  }

}


##
## start()
##
## Starts the display of random still frames. Adds event handlers to
## the current session to show slides. Assumes that we're being called
## in a POE Filler session.
##
sub start {
  my $self = shift;
  my ($planned_time) = @_;

  my $heap = $poe_kernel->get_active_session->get_heap();
  $heap->{'slide_start_time'} = time();
  $heap->{'planned_time'} = $planned_time;
  $poe_kernel->state('show_slide', $self);
  $poe_kernel->yield('show_slide');
}

1;

