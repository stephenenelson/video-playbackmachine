package Video::PlaybackMachine::ScheduleTable::DB;

####
#### Video::PlaybackMachine::ScheduleTable::DB
####
#### This module is used to access the ScheduleTable.
####

use strict;
use warnings;

use Carp;

use Video::PlaybackMachine::Config;
use Video::PlaybackMachine::DB;

############################## Class Methods #######################################

##
## new()
##
## Creates a new ScheduleTable::DB object.
##
sub new {
    my $type = shift;
    my $self = {
        schedule_name => Video::PlaybackMachine::Config->config->schedule(),
        dbh           => undef,
        logger        => Log::Log4perl->get_logger('Video.PlaybackMachine.DB'),
    };
    bless $self, $type;
}

############################## Object Methods ######################################

sub getDbh { return Video::PlaybackMachine::DB->db(); }

sub schema { return Video::PlaybackMachine::DB->schema(); }

sub schedule_name {
	my $self = shift;
	
	return $self->{'schedule_name'};
}

##
## get_entries_between()
##
## Arguments:
##    BEGIN_TIME: scalar -- UNIX raw time
##    END_TIME: scalar -- UNIX raw time
##
## Returns all entries which start or end between BEGIN_TIME and END_TIME.
##
sub get_entries_between {
    my $self = shift;
    my ( $begin_time, $end_time ) = @_;

    my $schema = Video::PlaybackMachine::DB->schema();

    my $entries_rs = $schema->resultset('ScheduleEntry')->search(
        {
            [
                { 'start_time' => { '>', $begin_time } },
                { 'stop_time'  => { '>', $begin_time } },
            ],
            'start_time' => { '<', $end_time },
            'schedule'   => $self->{'schedule_name'}
        },
        {
            'order_by' => 'start_time',
            join => 'schedule_entry_end'
        }
    );

    return $entries_rs->all();

}

##
## get_entries_after()
##
## Arguments:
##    TIME: scalar -- UNIX raw time
##    NUM_ENTRIES: int -- number of entries afterwards
##
## Returns all entries which start after a given time. In scalar context,
## returns the first entry after the given time. Returns undef if nothing left.
##
sub get_entries_after {
    my $self = shift;
    my ( $time, $num_entries ) = @_;

    defined $num_entries
      or $num_entries = 1;

    # Get next content_schedule entry
    
 	my $schema = Video::PlaybackMachine::DB->schema();   
 
	my $entries_rs = $schema->resultset('ScheduleEntry')->search(
		{
			'start_time' => { '>', $time },
			'schedule'   => $schedule,
		},
		{
			'limit' => $num_entries,
			'order_by' => 'start_time'
		}
	);

    if (wantarray) {
        return $entries_rs->all();
    }
    else {
        return $entries_rs->first();
    }
}

##
## get_entry_during()
##
## Arguments:
##    TIME: scalar -- UNIX raw time
##
## Returns the schedule entry in which TIME takes place.
## Returns an empty list / undef if there is no scheduled program taking place
## at the given time.
##
sub get_entry_during {
    my $self = shift;
    my ($time) = @_;
    
    return $self->schema()->resultset('ScheduleEntry')
    	->find(
    		{
				'schedule.name' => $self->schedule_name(),
				'start_time'    => { '>=', $time },
				'end_time'      => { '<', $time }
    		},
			{
				'join' => ['schedule_entry_end', 'schedule']
			}
    	);

}

1;

__END__
