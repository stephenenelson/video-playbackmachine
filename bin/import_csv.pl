#!/usr/bin/env perl

use strict;
use warnings;

use autodie;

use Video::PlaybackMachine::Schema;
use Text::CSV;
use DateTime;
use DateTime::Format::Strptime;
use DateTime::TimeZone::UTC;

my ($schedule_name, $csv_file, $db_file) = @ARGV;

MAIN: {

	my $csv = Text::CSV->new( { 'binary' => 1 } )
		or die 'Cannot use CSV: ' . Text::CSV->error_diag();

	open(my $fh, '<:encoding(utf8)', $csv_file);
	
	my $strp_spreadsheet = DateTime::Format::Strptime->new(
		pattern => '%m/%d/%Y %T',
		time_zone => DateTime::TimeZone::UTC->new(),
		on_error => 'croak'
	);
	
	my $strp_epoch = DateTime::Format::Strptime->new(
		pattern => '%s',
		time_zone => DateTime::TimeZone::UTC->new(),
		on_error => 'croak'
	);
	
	my $schema = Video::PlaybackMachine::Schema->connect(
		"dbi:SQLite:dbname=$db_file", 
		'', 
		''
	);
	
	my $schedule = $schema->resultset('Schedule')->create({ 'name' => $schedule_name });
	
	# Skip header line
	my $header = $csv->getline( $fh );
	
	my $entry_rs = $schema->resultset('ScheduleEntry');
	
	while ( my $row = $csv->getline( $fh ) ) {
		my ($start_str, $mrl) = @$row;
		
		my $start_dt = $strp_spreadsheet->parse_datetime( $start_str );
				
		my $start_epoch = $strp_epoch->format_datetime( $start_dt );
		
		$entry_rs->create({ 'schedule_id' => $schedule->schedule_id, 
							'mrl' => $mrl,
							'start_time' => $start_epoch
							});
	}
}
