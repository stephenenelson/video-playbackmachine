package Video::PlaybackMachine::FillSegment;

####
#### Video::PlaybackMachine::FillSegment
####
#### $Revision$
####
#### The Filler fills up time in the schedule using an ordered set of
#### FillSegments. For example, an average break sequence might
#### consist of a 'Start Identification' segment played at the
#### beginning, followed by 'Announcements', followed by 'Short
#### Subject', followed by 'End Identification'.
####

use strict;
use warnings;
use Carp;

############################# Class Constants #############################

############################## Class Methods ##############################

##
## new()
##
## Arguments: hash
##   name => string -- Name of the segment
##   sequence_order => int -- Where this segment will be played in break
##   priority_order => int -- Priority for segment if not enough time for all
##   producer => FillProducer
##
sub new {
  my $type = shift;
  my %in = @_;

  my $self = {
	      name => $in{name},
	      sequence_order => $in{sequence_order},
	      priority_order => $in{priority_order},
	      producer => $in{producer}
	     };

  bless $self, $type;

}


############################# Object Methods ##############################

##
## get_name()
##
## Returns the name of the segment.
##
sub get_name { 
  $_[0]->{name};
}

##
## get_sequence_order()
##
## Returns the sequence order of the segment.
##
sub get_sequence_order { 
  $_[0]->{sequence_order};
}

##
## get_priority_order()
##
## Returns the priority order of the segment.
##
sub get_priority_order { 
  $_[0]->{priority_order};
}

##
## get_producer()
##
## Returns a FillProducer which we will use to produce
## the content of this segment.
##
sub get_producer {
  $_[0]->{producer};
}

1;