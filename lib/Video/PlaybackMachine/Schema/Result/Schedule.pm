use utf8;
package Video::PlaybackMachine::Schema::Result::Schedule;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Video::PlaybackMachine::Schema::Result::Schedule

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<schedules>

=cut

__PACKAGE__->table("schedules");

=head1 ACCESSORS

=head2 name

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns("name", { data_type => "text", is_nullable => 0 });

=head1 PRIMARY KEY

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->set_primary_key("name");

=head1 RELATIONS

=head2 content_schedules

Type: has_many

Related object: L<Video::PlaybackMachine::Schema::Result::ContentSchedule>

=cut

__PACKAGE__->has_many(
  "content_schedules",
  "Video::PlaybackMachine::Schema::Result::ContentSchedule",
  { "foreign.schedule" => "self.name" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2013-06-29 09:04:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7RMImvr10WhJg84IN1CEAw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
