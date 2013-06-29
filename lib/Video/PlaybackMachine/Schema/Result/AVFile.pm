use utf8;
package Video::PlaybackMachine::Schema::Result::AVFile;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Video::PlaybackMachine::Schema::Result::AVFile

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<av_file_component>

=cut

__PACKAGE__->table("av_file_component");

=head1 ACCESSORS

=head2 file

  data_type: 'text'
  is_nullable: 0

=head2 title

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 1

=head2 duration

  data_type: 'interval'
  is_nullable: 0

=head2 sequence_no

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "file",
  { data_type => "text", is_nullable => 0 },
  "title",
  { data_type => "text", is_foreign_key => 1, is_nullable => 1 },
  "duration",
  { data_type => "interval", is_nullable => 0 },
  "sequence_no",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</file>

=item * L</sequence_no>

=back

=cut

__PACKAGE__->set_primary_key("file", "sequence_no");

=head1 RELATIONS

=head2 title

Type: belongs_to

Related object: L<Video::PlaybackMachine::Schema::Result::Movie>

=cut

__PACKAGE__->belongs_to(
  "title",
  "Video::PlaybackMachine::Schema::Result::Movie",
  { title => "title" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "CASCADE,",
    on_update     => "CASCADE,",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2013-06-28 23:00:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:G3sebjUmAWBIudV2cBjVaQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
