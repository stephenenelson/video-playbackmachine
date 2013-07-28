package Video::PlaybackMachine::FillProducer::StaticFrame;

use Moo;

extends 'Video::PlaybackMachine::FillProducer::TextFrame';

has 'static_text' => ( 'is' => 'ro' );

##
## add_text()
##
## Write our static text on the frame.
##
sub add_text {
  my ($self) = @_;

  $self->write_centered( $self->{'static_text'} );
}

no Moo;

1;