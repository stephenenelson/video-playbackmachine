package Video::PlaybackMachine::EventWheel::FullScreen;

use Moo;

use X11::FullScreen;

with 'Video::PlaybackMachine::EventWheel';

has 'window' => (
	'is' => 'ro',
	'required' => 1
);

######################### Class Methods #########################


######################### Object Methods ########################

sub get_event {
  my $self = shift;
  my ($heap) = @_;

  return $self->source()->checkWindowEvent($self->{'window'});
}


# Expose is 12
sub set_expose_handler {
	my ($self, $handler) = @_;

  $self->set_handler(12, $handler);
}

# TODO: Make is_running check the display handle

no Moo;

1;
