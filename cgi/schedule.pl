#!/usr/bin/perl

use strict;
use warnings;

use Date::Manip;

use Video::PlaybackMachine::ScheduleTable::DB;

use POSIX qw/ceil/;
use CGI;

################################## Constants ##################################

our $Step_Interval = 5 * 60;

our $Start_Time = UnixDate(ParseDate("20060526140000"), '%s');

our $End_Time = UnixDate(ParseDate("200605292359"), '%s');

################################# Main Program ################################

MAIN: {

	
	my $table = Video::PlaybackMachine::ScheduleTable::DB->new( schedule_name => "BayCon 2006" );

	my @entries = $table->get_entries_after($Start_Time - 1, 100000);

	my $curr_time = $Start_Time;

	my $entry = shift @entries or exit;

print <<EOF;

<html>
<head>
<meta http-equiv="Content-Language" content="en" />
<meta name="GENERATOR" content="PHPEclipse 1.0" />
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Schedule</title>
</head>
<body bgcolor="#FFFFFF" text="#000000" link="#FF9966" vlink="#FF9966" alink="#FFCC99">
<h1>Schedule</h1>
<table border="1">
	<tr><th>Time</th>
		<th>Friday</th>
	</tr>
EOF

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
print <<EOF;	
			
</table>
</body>
</html>
 
EOF

}

sub starttime {
  my ($time) = @_;

  return UnixDate(ParseDateString('epoch ' . $time), '%a %T');
}
