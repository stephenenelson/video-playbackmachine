package Video::PlaybackMachine::TimeManager;

####
#### Video::PlaybackMachine::TimeManager
####
#### $Revision$
####
#### Tells us what FillSegment to play next in a particular break.
#### Keeps track of what has been played.
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
##   SEGMENTS: list -- All available fill segments
##
## We assume that segments have unique sequential sequence numbers.
##
sub new {
  my $type = shift;
  my (@segments) = @_;

  my $self = { };
  $self->{seq_order} = [ sort { $a->get_sequence() <=> $b->get_sequence() } @segments ];
  $self->{current_seq} = 0;

  bless $self, $type;
}

############################# Object Methods ##############################

##
## get_segment()
##
## Arguments:
##   TIME_LEFT: int -- Amount of time before next scheduled content
##
## Returns: (list)
##   FillSegment -- Next FillSegment to use
##   int -- unreserved time remaining in seconds
##
## Returns the FillSegment to use to fill up time right now. Returns
## undef if no more fill can be played.
##
sub get_segment {
  my $self = shift;
  my ($time_left) = @_;

  # For each segment starting from current in display order
  foreach my $segment ( $self->_segments_left() ) {

    # Move to next segment if we don't have time to play it
    my $time_remaining = $self->_seconds_remaining($segment, $time_left);
    $segment->is_available($time_remaining) or next;

    # Update whatever we should play next
    $self->{current_seq} = $segment->get_next();

    # Return the segment and time remaining
    return ($segment, $time_remaining);

  } # End for each unfinished segment

  # All's finished or no time; return undef
  return;
}

##
## Returns the segments still to play, in sequence order.
##
sub _segments_left {
  my $self = shift;
  return @{$self->{seq_order}}[ $self->{current_seq} ... $#{ $self->{seq_order} } ];
}

##
## _seconds_remaining()
##
## Arguments:
##   CURRENT_SEGMENT: FillSegment
##   TIME_LEFT: int -- seconds
##
## Returns the amount of time in seconds remaining after
## time has been reserved for all of the segments with
## higher priorities than this.
##
sub _seconds_remaining {
  my $self = shift;
  my ($current_segment, $time_left_in_break) = @_;

  my $time_remaining = $time_left_in_break;
  foreach my $segment (
			   sort {$a->get_priority() <=> $b->get_priority()}
			   grep { $_->get_priority() < $current_segment->get_priority() }
			   $self->_segments_left()
			  ) 
    {
      $time_remaining > 0 or return 0;
      $segment->is_available($time_remaining) or next;
      $time_remaining -= $segment->get_producer()->get_time_layout()->preferred_time($time_remaining);
    }

  return $time_remaining;

}


1;
