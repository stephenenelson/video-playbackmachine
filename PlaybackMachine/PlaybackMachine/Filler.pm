package Video::PlaybackMachine::Filler;

####
#### Video::PlaybackMachine::Filler
####
#### $Revision$
####
#### POE session for the Filler.
####

use strict;
use warnings;
use Carp;
use UNIVERSAL 'isa';

use POE;
use POE::Session;

use Time::Duration;

use Video::PlaybackMachine::TimeManager;

############################# Class Constants #############################

############################## Class Methods ##############################

##
## new()
##
## Arguments: hash
##   segments => arrayref of FillSegment
##
sub new {
  my $type = shift;
  my (%in) = @_;

  isa($in{segments}, 'ARRAY')
    or croak($type, "::new() called improperly");

  foreach my $segment (@{ $in{segments} }) {
    isa($segment, 'Video::PlaybackMachine::FillSegment')
      or croak($type, "::new: option 'segments' contains '$segment')");
  }

  my $self = {
	      segments => $in{segments}
	     };

  bless $self, $type;
}

############################# Object Methods ##############################

sub spawn {
  my $self = shift;

  POE::Session->create(
		       inline_states => {
					 _start => sub {
					   $_[KERNEL]->alias_set('Filler');
					 }
					},
		       object_states => [ $self => [
					 qw(start_fill fill_done next_fill still_ready stop)
					] ],
		       );

}


############################# Session Methods #############################

##
## start_fill()
##
## POE state.
##
## Called to start the Filler filling.
##
sub start_fill {

  # Initialize a TimeManager with our FillSegments
  $_[HEAP]{time_manager} = Video::PlaybackMachine::TimeManager->new( @{ $_[OBJECT]{segments} } );

  # Store the current schedule in the heap
  $_[HEAP]{view} = $_[ARG0]
        or confess('ARG0 required');

  print STDERR scalar localtime(), ": Filling, ttn=", duration($_[ARG0]->get_time_to_next()),"\n";

  # View the first segment
  $_[KERNEL]->yield('next_fill');

}

sub stop {
  $_[KERNEL]->alarm_set('next_fill');
}

##
## fill_done()
##
## Called when the Filler has nothing else to play.
## Posts a call over to the Scheduler telling it
## that we're idle.
##
sub fill_done {
  $_[KERNEL]->alarm_set('next_fill');
  delete $_[HEAP]->{time_manager};
  delete $_[HEAP]->{view};
  $_[KERNEL]->post('Scheduler', 'wait_for_scheduled');
}

##
## next_fill()
##
## Starts the next fill segment. If there are no more segments to be
## played, we're done.
##
sub next_fill {

  $_[HEAP]{view} or confess("Somehow called next_fill on us without calling start_fill");

  my ($segment, $time) = $_[HEAP]{time_manager}->get_segment(
							     $_[HEAP]{view}->get_time_to_next(time())
							    )
    or do {
      $_[KERNEL]->yield('fill_done');
      return;
    };

  $segment->get_producer()->start();

}

##
## still_ready()
##
## Is called when one of the producers wants the Filler to display
## a still. 
##
sub still_ready {
  $_[KERNEL]->post('Player', 'play_still', $_[ARG0]);
  $_[KERNEL]->delay('next_fill', $_[ARG1]);
}

1;
