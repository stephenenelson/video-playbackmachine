package Video::PlaybackMachine::ScheduleView;

####
#### Video::PlaybackMachine::ScheduleView
####
#### $Revision$
####
#### Translates between the times listed in a schedule
#### and the current time.
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
##
##  SCHEDULE_TABLE: Video::PlaybackMachine::ScheduleTable
##  OFFSET: int -- Difference between schedule time and real ( s - r )
##
sub new {
  my $type = shift;

  @_ == 2 or croak "${type}::new(): arguments are SCHEDULE_TABLE and OFFSET; stopped";

  my ($schedule_table, $offset) = @_;

  defined $offset or $offset = 0;

  my $self = {
	      schedule_table => $schedule_table,
	      offset => $offset
	     };

  bless $self, $type;
}

############################# Object Methods ##############################

##
## Returns the given time corrected with the schedule
## offset. If no arguments, returns the current time
## corrected for schedule offset.
##
sub stime {
  my $self = shift;
  my ($time) = @_;

  defined $time or $time = CORE::time();
  return $time + $self->{offset};

}

##
## Returns the offset value.
##
sub get_offset {
  return $_[0]->{offset};
}

##
## Returns the schedule table.
##
sub get_schedule_table {
  return $_[0]->{schedule_table};
}

##
## get_next_entry()
##
## Returns the next entry appearing on our Schedule Table.
##
sub get_next_entry {
  my $self = shift;

  return $self->_do_get_next_entry($self->stime(@_));
}

sub _do_get_next_entry {
  my $self = shift;
  my ($time) = @_;

  return scalar($self->{schedule_table}->get_entries_after($time) );
}

##
## Returns the amount of time until the next scheduled entry.
## Returns empty if no scheduled entry remains.
##
sub get_time_to_next {
  my $self = shift;
  my $time = $self->stime(@_);

  print STDERR scalar localtime $time, "\n";

  my $next_entry = $self->_do_get_next_entry($time)
    or return;

  return $next_entry->get_start_time() - $time;

}

##
## Returns the seek time for a given schedule entry.
##
sub get_seek {
  my $self = shift;
  my $entry = shift;

  my $seek = $entry->get_listing()->get_length() - $self->get_time_to_next();
  return ($seek > 0) ? $seek : 0;

}


1;
