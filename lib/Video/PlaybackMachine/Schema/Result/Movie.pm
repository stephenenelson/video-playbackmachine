use utf8;
package Video::PlaybackMachine::Schema::Result::Movie;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Video::PlaybackMachine::Schema::Result::Movie

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<av_files>

=cut

__PACKAGE__->table("av_files");

=head1 ACCESSORS

=head2 title

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns("title", { data_type => "text", is_nullable => 0 });

=head1 PRIMARY KEY

=over 4

=item * L</title>

=back

=cut

__PACKAGE__->set_primary_key("title");

=head1 RELATIONS

=head2 av_file_components

Type: has_many

Related object: L<Video::PlaybackMachine::Schema::Result::AVFile>

=cut

__PACKAGE__->has_many(
  "av_file_components",
  "Video::PlaybackMachine::Schema::Result::AVFile",
  { "foreign.title" => "self.title" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 content

Type: might_have

Related object: L<Video::PlaybackMachine::Schema::Result::Content>

=cut

__PACKAGE__->might_have(
  "content",
  "Video::PlaybackMachine::Schema::Result::Content",
  { "foreign.title" => "self.title" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 content_schedules

Type: has_many

Related object: L<Video::PlaybackMachine::Schema::Result::ContentSchedule>

=cut

__PACKAGE__->has_many(
  "content_schedules",
  "Video::PlaybackMachine::Schema::Result::ContentSchedule",
  { "foreign.title" => "self.title" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 fill_shorts

Type: has_many

Related object: L<Video::PlaybackMachine::Schema::Result::FillShort>

=cut

__PACKAGE__->has_many(
  "fill_shorts",
  "Video::PlaybackMachine::Schema::Result::FillShort",
  { "foreign.title" => "self.title" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2013-06-29 09:04:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/JD/wTJ6tgINjHmshO0ITA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
