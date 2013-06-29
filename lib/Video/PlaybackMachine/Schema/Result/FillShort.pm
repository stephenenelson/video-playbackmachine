use utf8;
package Video::PlaybackMachine::Schema::Result::FillShort;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Video::PlaybackMachine::Schema::Result::FillShort

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<fill_shorts>

=cut

__PACKAGE__->table("fill_shorts");

=head1 ACCESSORS

=head2 title

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 1

=head2 group_name

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "title",
  { data_type => "text", is_foreign_key => 1, is_nullable => 1 },
  "group_name",
  { data_type => "text", is_nullable => 1 },
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
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "CASCADE,",
    on_update     => "CASCADE,",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2013-06-29 08:39:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hWBKTGvmjAasuz6SoOS6gQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
