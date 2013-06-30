use utf8;
package Video::PlaybackMachine::Schema::Result::ScheduleEntry;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Video::PlaybackMachine::Schema::Result::ScheduleEntry

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<schedule_times_raw>

=cut

__PACKAGE__->table("schedule_times_raw");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 0

=head2 title

  data_type: 'text'
  is_nullable: 0

=head2 schedule

  data_type: 'text'
  is_nullable: 0

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 start_time

  data_type: 'double precision'
  is_nullable: 0

=head2 stop_time

  data_type: 'double precision'
  is_nullable: 0

=head2 listed

  data_type: 'boolean'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "title",
  { data_type => "text", is_nullable => 0 },
  "schedule",
  { data_type => "text", is_nullable => 0 },
  "description",
  { data_type => "text", is_nullable => 0 },
  "start_time",
  { data_type => "double precision", is_nullable => 0 },
  "stop_time",
  { data_type => "double precision", is_nullable => 0 },
  "listed",
  { data_type => "boolean", is_nullable => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2013-06-29 09:04:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2EXhrMUh1LATb2QFutCQdQ

=head1 RELATIONS

=head2 movie

Type: belongs_to

Related object: L<Video::PlaybackMachine::Schema::Result::Movie>

=cut

__PACKAGE__->belongs_to(
  "movie",
  "Video::PlaybackMachine::Schema::Result::Movie",
  { title => "title" },
  { is_deferrable => 0, on_delete => "CASCADE,", on_update => "CASCADE," },
);

=head2 schedule

Type: belongs_to

Related object: L<Video::PlaybackMachine::Schema::Result::Schedule>

=cut

__PACKAGE__->belongs_to(
  "schedule",
  "Video::PlaybackMachine::Schema::Result::Schedule",
  { name => "schedule" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "CASCADE,",
    on_update     => "CASCADE,",
  },
);

=head2 content_schedule

type: has_one

Related object: L<Video::PlaybackMachine::Schema::Result::ContentSchedule>

=cut

__PACKAGE__->has_one(
  "content_schedule",



# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
