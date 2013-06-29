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

=head1 TABLE: C<content_schedule>

=cut

__PACKAGE__->table("content_schedule");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'content_schedule_id_seq'

=head2 title

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 schedule

  data_type: 'text'
  default_value: 'Baycon 2005'
  is_foreign_key: 1
  is_nullable: 1

=head2 listed

  data_type: 'boolean'
  default_value: true
  is_nullable: 1

=head2 start_time

  data_type: 'timestamp with time zone'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "content_schedule_id_seq",
  },
  "title",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "schedule",
  {
    data_type      => "text",
    default_value  => "Baycon 2005",
    is_foreign_key => 1,
    is_nullable    => 1,
  },
  "listed",
  { data_type => "boolean", default_value => \"true", is_nullable => 1 },
  "start_time",
  { data_type => "timestamp with time zone", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<content_schedule_start_time_schedule_key>

=over 4

=item * L</start_time>

=item * L</schedule>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "content_schedule_start_time_schedule_key",
  ["start_time", "schedule"],
);

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


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2013-06-29 08:39:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:D2ohRKq2labma9K7hvqULA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
