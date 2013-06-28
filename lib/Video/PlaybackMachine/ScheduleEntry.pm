package Video::PlaybackMachine::ScheduleEntry;

####
#### Video::PlaybackMachine::ScheduleEntry
####
#### Represents a single listing in the schedule.
####

use Moose;
use Carp;

has 'start_time' => (
	'is' => 'ro',
	'isa' => 'Int',
	'reader' => 'get_start_time',
	'required' => 1,
);

has 'listing' => (
	'is' => 'ro',
	'isa' => 'Video::PlaybackMachine::Movie',
	'reader' => 'get_listing',
	'handles' => [ 'get_title' ],
	'required' => 1,
);

around 'BUILDARGS' => sub {
	my $orig = shift;
	my $class = shift;

	if ( @_ == 2 ) {
		return $class->$orig( 'start_time' => $_[0],
					    'listing' => $_[1]
		);
	}
	else {
		return $class->$orig(@_);
	}
};

use overload '""' => sub { $_[0]->as_string() };

########################### Class Methods #################################


########################## Object Methods #################################


##
## get_finish_time()
##
## Returns the time that the entry is scheduled to end.
##
sub get_finish_time {
  my $self = shift;

  return $self->get_start_time() + $self->get_listing()->get_length();
}

sub as_string {
    return $_[0]->get_title();
}

__PACKAGE__->meta()->make_immutable();

no Moose;

1;
