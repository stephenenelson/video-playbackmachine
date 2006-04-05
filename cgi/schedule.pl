#!/usr/bin/perl

use strict;
use warnings;

use CGI;
use Date::Manip;

use Video::PlaybackMachine::ScheduleTable::DB;

################################## Constants ##################################

################################# Main Program ################################

MAIN: {

	my $query = CGI->new();

	print $query->header();
	
	my $table = Video::PlaybackMachine::ScheduleTable::DB->new( schedule => "BayCon 2006" );
	
	my $start_time = 
	
	my @entries = $table->get_entries_after(0);
	
	foreach my $entry ( @entries ) {
			print $entry->get_title();
	}
	
	
}


