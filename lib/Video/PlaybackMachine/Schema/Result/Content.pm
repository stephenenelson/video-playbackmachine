use utf8;
package Video::PlaybackMachine::Schema::Result::Content;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Video::PlaybackMachine::Schema::Result::Content

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<contents>

=cut

__PACKAGE__->table("contents");

=head1 ACCESSORS

=head2 title

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 type

  data_type: 'text'
  is_nullable: 1

=head2 director

  data_type: 'text'
  is_nullable: 1

=head2 description

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "title",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "type",
  { data_type => "text", is_nullable => 1 },
  "director",
  { data_type => "text", is_nullable => 1 },
  "description",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</title>

=back

=cut

__PACKAGE__->set_primary_key("title");

=head1 RELATIONS

=head2 title

Type: belongs_to

Related object: L<Video::PlaybackMachine::Schema::Result::Movie>

=cut

__PACKAGE__->belongs_to(
  "title",
  "Video::PlaybackMachine::Schema::Result::Movie",
  { title => "title" },
  { is_deferrable => 0, on_delete => "CASCADE,", on_update => "CASCADE," },
);


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2013-06-28 23:00:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qIKRWMXm8fgCiJ2ofHb+YQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
