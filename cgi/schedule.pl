#!/usr/bin/perl

use strict;
use warnings;

use CGI;
use Time::Duration;

use Video::PlaybackMachine::ScheduleTable::DB;

################################## Constants ##################################

################################# Main Program ################################

MAIN: {

	my $query = CGI->new();

	print $query->header();
	
	my $table = Video::PlaybackMachine::ScheduleTable::DB->new( schedule => "BayCon 2006" );
	
	my @entries = $table->get_entries_after("2005-05-26 14:00:00");
	
	foreach my $entry ( @entries ) {
			print $entry->get_title();
	}
	
	
}


