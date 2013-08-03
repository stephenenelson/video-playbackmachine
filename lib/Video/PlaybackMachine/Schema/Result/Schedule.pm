package Video::PlaybackMachine::Schema::Result::Schedule;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table('schedule');

__PACKAGE__->add_columns(
	'schedule_id' => { data_type => 'integer', is_nullable => 0},
	'name'        => { data_type => 'text', is_nullable => 0 }
);

__PACKAGE__->set_primary_key('schedule_id');

__PACKAGE__->add_unique_constraint(['name']);

__PACKAGE__->has_many(
  'schedule_entries',
  'Video::PlaybackMachine::Schema::Result::ScheduleEntry',
  { 'foreign.schedule_id' => 'self.schedule_id' },
  { cascade_copy => 1, cascade_delete => 1 },
);

sub schedule_entries_in_order {
	my $self = shift;
	
	return $self->search_related('schedule_entries', {}, { 'order_by' => 'start_time' });
}

1;
