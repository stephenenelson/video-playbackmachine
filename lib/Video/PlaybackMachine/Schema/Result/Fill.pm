use utf8;
package Video::PlaybackMachine::Schema::Result::Fill;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Video::PlaybackMachine::Schema::Result::Fill

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<fills>

=cut

__PACKAGE__->table("fills");

=head1 ACCESSORS

=head2 title

  data_type: 'text'
  is_nullable: 1

=head2 duration

  data_type: 'interval'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "title",
  { data_type => "text", is_nullable => 1 },
  "duration",
  { data_type => "interval", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2013-07-15 23:29:01
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:X8Y4P7rZtawke6mCWVtcMg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
