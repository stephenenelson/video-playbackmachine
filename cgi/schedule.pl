#!/usr/bin/perl

use strict;
use warnings;

use Date::Manip;

use Video::PlaybackMachine::ScheduleTable::DB;

use POSIX qw/ceil/;

################################## Constants ##################################

our $Step_Interval = 5 * 60;

################################# Main Program ################################

MAIN: {

	
	my $table = Video::PlaybackMachine::ScheduleTable::DB->new( schedule_name => "BayCon 2006" );
	
	my $start_time = UnixDate(ParseDate("20060526140000"), '%s')
	  or die;

	my $end_time = UnixDate(ParseDate("200605292359"), '%s');

	my @entries = $table->get_entries_after($start_time - 1, 100000);

	my $curr_time = $start_time;

	my $entry = shift @entries or exit;

	DURING: while (1) {
	  print starttime($curr_time), "\t";
	  if ( abs( $curr_time - $entry->get_start_time() ) < $Step_Interval ) {
	    print $entry->getTitle(), "\t", ceil($entry->get_listing()->get_length() / $Step_Interval);
	    $entry = shift @entries or last DURING;
	  }
	  print "\n";
	  $curr_time += $Step_Interval;
	}

	print "\n";

	while ($curr_time < $end_time) {
	    print starttime($curr_time), "\n";
	    $curr_time += $Step_Interval;
	}

	print "\n";
}

sub starttime {
  my ($time) = @_;

  return UnixDate(ParseDateString('epoch ' . $time), '%a %T');
}
