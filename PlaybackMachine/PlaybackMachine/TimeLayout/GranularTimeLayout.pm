package Video::PlaybackMachine::TimeLayout::GranularTimeLayout;

####
#### Video::PlaybackMachine::TimeLayout::GranularTimeLayout
####
#### $Revision$
####
#### A granular time layout is for producers like slide shows. A slide
#### show that shows a slide for 5 seconds can fill 5, 10, 15
#### etc. seconds, but can't fill 12.
####

use strict;
use warnings;
use diagnostics;

use Carp;
use POSIX 'floor';

############################# Class Constants #############################

############################## Class Methods ##############################

##
## new()
##
## Arguments:
##   TIME: int -- Time per repeating event
##
sub new {
  my $type = shift;
  my ($time, $max_iterations) = @_;
  defined $time or croak($type, "::new() called incorrectly");

  my $self = { 
      time => $time,
      max_iterations => $max_iterations
	   };
  bless $self, $type;
  
}


############################# Object Methods ##############################

##
## min_time()
##
## Returns the minimum amount of time the fill can take. In this case,
## returns the grain.
##
sub min_time { 
  return $_[0]->{time};
}

##
## preferred_time()
##
## Arguments:
##  TIME_LEFT
##
## Returns time for the number of granular events which can fit into
## TIME_LEFT. If max_iterations was defined, returns the time for that
## number of granular events.
##
sub preferred_time {
  my $self = shift;
  my ($time_left) = @_;

  my $req_events  = floor($time_left / $self->{'time'});

  return $self->get_num_events($req_events) * $self->{time};
}

sub get_num_events {
  my $self = shift;
  my ($events) = @_;

  if (defined $self->{'max_iterations'} &&
      $events > $self->{'max_iterations'}) {
    return $self->{'max_iterations'};
  }
  else {
    return $events;
  }

}

1;
