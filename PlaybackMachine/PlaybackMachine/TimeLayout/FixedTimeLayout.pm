package Video::PlaybackMachine::TimeLayout::FixedTimeLayout;

####
#### Video::PlaybackMachine::TimeLayout::FixedTimeLayout
####
#### $Revision$
####
#### A TimeLayout that indicates that a certain FillProducer only
#### wants to generate content for a fixed amount of time. 
####

use strict;
use warnings;
use Carp;

############################# Class Constants #############################

############################## Class Methods ##############################

##
## new()
##
## Arguments:
##   TIME: int -- Amount of time for fixed layout to return
##
## Creates a new FixedTimeLayout that returns TIME.
##
sub new {
  my $type = shift;
  my ($time) = @_;

  my $self = { time => $time };
  bless $self, $type;
}

############################# Object Methods ##############################

##
## min_time()
##
## Returns the minimum amount of time the fill can take. In this case,
## returns the fixed time.
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
## Returns the fixed time.
##
sub preferred_time { 
  return $_[0]->{time};
}

1;
