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
  my ($time) = @_;
  defined $time or croak($type, "::new() called incorrectly");

  my $self = { time => $time };
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
## TIME_LEFT.
##
sub preferred_time { 
  return int($_[0]->{time} / $_[1]) * $_[0]->{time};
}

1;
