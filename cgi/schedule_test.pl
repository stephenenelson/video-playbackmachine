#!/usr/bin/perl

use strict;
use warnings;

use Video::PlaybackMachine::ScheduleTable::DB;
use Template;

use POSIX qw/ceil/;
use CGI;

################################## Constants ##################################

our $Step_Interval = 5 * 60;

our @Days = UnixDate(ParseDate("20060526"), '%s');

################################# Main Program ################################

MAIN: {


	
	my $table = Video::PlaybackMachine::ScheduleTable::DB->new( schedule_name => "BayCon 2006" );
		
	my @entries = ();

	foreach my $day (@Days) {
		push(@entries, [ $table->get_entries_between($day - 1, $day + (24 * 60 * 60)) ]);
	}

	my $curr_time = 0;

	

	DURING: while (1) {
		print "	<tr>\n";
	  	print "     <td>", starttime($curr_time), "</td>\n";
	  if ( abs( $curr_time - $entry->get_start_time() ) < $Step_Interval ) {
	    print "     <td rowspan=\"", ceil($entry->get_listing()->get_length() / $Step_Interval), "\">", $entry->getTitle(), "</td>\n";
	    $entry = shift @entries or last DURING;
	  }
	  print "</tr>\n";
	  $curr_time += $Step_Interval;
	}

	print "</tr>\n";

	while ($curr_time < $end_time) {
		print "	<tr>\n";
	  	print "     <td>", starttime($curr_time), "</td>\n  </tr>";
	    $curr_time += $Step_Interval;
	}

	
}
