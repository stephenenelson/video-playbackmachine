package Video::PlaybackMachine::MockScheduleTable;

####
#### MockScheduleTable
####
#### $Revision$
####
#### Exports a single function letting us make a mock schedule table.
####

use strict;
use warnings;

use Test::MockObject;

use Video::PlaybackMachine::AVFile;
use Video::PlaybackMachine::ScheduleEntry;
use Video::PlaybackMachine::TestMovie;


use base 'Exporter';

our @EXPORT_OK = qw(mock_schedule_table);

##
## mock_schedule_table()
##
##  Arguments: 
##    NOW: Time we want all these things to start
##
## Creates a MockObject that matches the ScheduleTable interface
## and automatically returns the following ScheduleEntries
## when called:
##     1. An entry starting NOW lasting 10 seconds.
##     2. An entry starting NOW + 20 claiming to last 4 seconds but lasting 7 seconds
##     3. An entry starting NOW + 25 lasting 8 seconds
##     4. An entry starting NOW + 40 claiming to last 5 seconds but lasting 15 seconds
##     5. An entry starting NOW + 46 lasting 10 seconds
##     6. An entry starting NOW + 57 lasting 5 seconds
##
## Predicted results (slack of 2 seconds):
##     * First entry will start NOW
##     * We will enter fill mode at NOW+11
##     * Entry 2 will start NOW+20
##     * Entry 3 will start NOW+28
##     * Entry 4 will start NOW+40
##     * Entry 5 will be skipped
##     * Entry 6 will start NOW+57
##
sub mock_schedule_table {
  my ($now) = @_;

  my $mock = Test::MockObject->new();
  my %entries_cache = ();

  my $make_entry_func = sub {
    my ($num, $start_off,  $expected_off, $duration, $real_duration) = @_;
    defined $entries_cache{$num} && return $entries_cache{$num};
    defined($real_duration) or $real_duration = $duration;
    defined($expected_off) or $expected_off =  $start_off;
    my $listing = Video::PlaybackMachine::TestMovie->new(
							 av_files => [ Video::PlaybackMachine::AVFile->new(
													   '/dev/null',
													   $duration
													  )
								     ],
							 title => "Test $num $duration ($real_duration)",
							 description => "Test item $num claiming to last $duration seconds and really lasting $real_duration seconds.",
							 'real_length' => $real_duration,
							 expected_start => $now + $expected_off,
							 name => "Movie $num ($expected_off)"

							);

    my $entry = Video::PlaybackMachine::ScheduleEntry->new($now + $start_off, $listing);
    $entries_cache{$num} = $entry;
    return $entry;
  };

  my @entries = (
		 # First one starts NOW and lasts 10 seconds till NOW+10
		 [0,  0, 10],

		 # Then we fill for 10 seconds

		 # Second one starts NOW + 20 and lasts 7 seconds
		 [20, 20,  4, 7],

		 # Third one wants to start at 25 seconds, but starts at 28, and lasts 9 seconds till NOW+37
		 [25, 28,  9, 9],

		 # 3 seconds is beneath fill threshold

		 # Fourth one starts at 40 seconds and lasts till 20 seconds
		 [40, 40,  5, 20],

		 # Fifth one wants to start at 46 seconds, but is skipped
		 [46, -1, 15],

		 # Sixth one starts at 65 seconds
		 [65, 65,  5]
		 );

  $mock->mock('get_entries_after', sub {
		my ($time) = $_[1];

		foreach my $idx (0 .. $#entries) {
		  my $sched_time = $entries[$idx][0] + $now;
		  if ( $sched_time > $time) {
		    return &$make_entry_func($idx + 1, @{ $entries[$idx] });
		  }
		}
		return;
	      }
	     );

  $mock->mock( 'get_entry_during', sub {
		       my ($time) = $_[1];

		       foreach my $idx (0 .. $#entries) {
			 my $sched_start = $entries[$idx][0] + $now;
			 my $sched_end = $entries[$idx][2] + $sched_start;
			 if ( ( $sched_start <= $time ) && ( $sched_end > $time ) ) {
			   return &$make_entry_func($idx + 1, @{ $entries[$idx] });
			 }
		       }

		       return;
		     });

  return $mock;

}

1;
