package Video::PlaybackMachine::Schema::Result::ScheduleEntry;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("schedule_entry");

__PACKAGE__->add_columns(
  "schedule_entry_id" => { data_type => "integer", is_nullable => 0 },
  "mrl"               => { data_type => "text", is_nullable => 0 },
  "schedule_id"       => { data_type => "text", is_nullable => 0 },
  "start_time"        => { data_type => "integer", is_nullable => 0 },
  "listed"            => { data_type => "boolean", is_nullable => 1, default => 1 }
);

__PACKAGE__->set_primary_key('schedule_entry_id');

__PACKAGE__->might_have(
  "movie_info",
  "Video::PlaybackMachine::Schema::Result::MovieInfo",
  { mrl => "mrl" },
  { is_deferrable => 0 },
);

__PACKAGE__->might_have(
  "schedule_entry_end",
  "Video::PlaybackMachine::Schema::Result::ScheduleEntryEnd",
  { schedule_entry_id => "schedule_entry_id" },
  { is_deferrable => 0 },
);


__PACKAGE__->belongs_to(
  "schedule",
  "Video::PlaybackMachine::Schema::Result::Schedule",
  { 'schedule_id' => "schedule_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

1;
