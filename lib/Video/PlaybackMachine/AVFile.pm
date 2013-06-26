package Video::PlaybackMachine::AVFile;

####
#### Video::PlaybackMachine::AVFile
####
#### $Revision$
####
####

use Moose;

has 'file' => (
	'is' => 'ro',
	'isa' => 'Str',
	'required' => 1,
	'reader' => 'get_file'
);

has 'length' => (
	'is' => 'ro',
	'isa' => 'Int',
	'required' => 1,
	'reader' => 'get_length'
);

around 'BUILDARGS' => sub {
	my ($orig) = shift;
	my ($class) = shift;
	
	if (@_ == 2 && ! ref $_[0]) {
		my ($file, $length) = @_;
		return $class->$orig('file' => $file, 'length' => $length);
	}
	else {
		return $class->$orig(@_);
	}
};

__PACKAGE__->meta()->make_immutable();

no Moose;

1;

__END__

=head1 NAME

Video::PlaybackMachine::AVFile - An MPEG, PNG, OGG, or other file which can be played

=head1 SYNOPSIS

  use Video::PlaybackMachine::AVFile;

  my $avfile = Video::PlaybackMachine::AVFile->new($file, $duration);

  my $filename = $avfile->get_file();
  my $length = $avfile->get_length();

=head1 DESCRIPTION

Simple object representing a playable file.

=head1 METHODS

=head2 CLASS METHODS

=head3 new()

  new({file => $file, length => $length_secs });

Constructor. The C<$file> parameter should be a filename. The
C<$length> parameter should be the duration of the file in seconds.

=head2 OBJECT METHODS

=head3 get_length()

Returns the duration of the AV file in seconds.

=head3 get_file()

Returns the filename.

=cut

