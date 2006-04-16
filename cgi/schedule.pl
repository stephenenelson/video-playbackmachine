#!/usr/bin/perl

use strict;
use warnings;

use Template;
use Date::Manip;

use POSIX qw/ceil/;
use CGI;

################################## Constants ##################################

our $Step_Interval = 5 * 60;

our @Days = ( UnixDate(ParseDate("20060526"), '%s'),
			 UnixDate(ParseDate("20060527"), '%s'),
			 UnixDate(ParseDate("20060528"), '%s'),
			 UnixDate(ParseDate("20060529"), '%s')	 
			 );

################################# Main Program ################################

MAIN: {

	my $tt = Template->new({INCLUDE_PATH => './'});
	my $start_time = UnixDate(ParseDate("20060526000000"), '%s');
	$tt->process('sched_template.html', 
		{
			SLOTS => [ 
				{
					time => $start_time + ($Step_Interval * 0), 
					cells => [ 
				    		{}, 
					    	{title => "Mystery Fandom Theater: Little Red Riding Hood", rows => 19 },
						{title => "Night of the Living Dead",  rows => 19 } 
					]
				},

			],
			DAYS => \@Days,
		}
	)
	    or die $tt->error();
	
}
