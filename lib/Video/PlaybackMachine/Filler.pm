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

use POE;
use POE::Session;

use Time::Duration;
use Log::Log4perl;

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

  if ( defined $in{'segments'} ) {
	  (ref $in{'segments'} eq 'ARRAY')
		or croak($type, "::new() called improperly");

	  foreach my $segment (@{ $in{'segments'} }) {
		ref $segment eq 'Video::PlaybackMachine::FillSegment'
		  or croak($type, "::new: option 'segments' contains '$segment')");
	  }
  }
  else {
  	$in{'segments'} = [];
  }

  my $self = {
	      segments => $in{segments},
	      logger => Log::Log4perl->get_logger('Video::PlaybackMachine::Filler')
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
					 qw(start_fill fill_done next_fill short_ready stop)
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
  $_[HEAP]{'time_manager'} = Video::PlaybackMachine::TimeManager->new( @{ $_[OBJECT]{'segments'} } );

  # Store the current schedule in the heap
  $_[HEAP]{'view'} = $_[ARG0]
        or $_[OBJECT]->{'logger'}->logconfess('ARG0 required');

  $_[OBJECT]->{'logger'}->debug("Filling, ttn=", duration($_[ARG0]->get_time_to_next()),"\n");

  # View the first segment
  $_[KERNEL]->yield('next_fill');

}

sub stop {
  $_[KERNEL]->alarm_remove_all();
  foreach (keys %{$_[HEAP]}) {
    delete $_[HEAP]->{$_};
  }
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
  delete $_[HEAP]->{'time_manager'};
  delete $_[HEAP]->{'view'};
  $_[KERNEL]->post('Scheduler', 'wait_for_scheduled');
}

##
## next_fill()
##
## Starts the next fill segment. If there are no more segments to be
## played, we're done.
##
sub next_fill {
	my ($self, $heap, $kernel) = @_[OBJECT, HEAP, KERNEL];
	
  $heap->{'view'} 
    or $self->{'logger'}->logconfess("Somehow called next_fill on us without calling start_fill");
    
  my $time_to_next = $heap->{'view'}->get_time_to_next();
  
  if (! defined $time_to_next ) {
  	$kernel->yield('fill_done');
  	return;
  }
  
  $self->{'logger'}->debug("Time to next: $time_to_next");

  my ($segment, $time) = $heap->{'time_manager'}->get_segment( $time_to_next  )
    or do {
      $kernel->yield('fill_done');
      return;
    };

  $self->{'logger'}->debug("Starting fill segment name: ", $segment->get_name());

  $segment->get_producer()->start($time);

}

##
## short_ready()
##
## Is called when one of the producers wants the Filler to display
## moving pictures.
##
sub short_ready {
  $_[KERNEL]->post('Player', 
		   'play',
		   $_[SESSION]->postback('next_fill'),
		   0,
		   @_[ARG0 .. $#_]);

}


1;
