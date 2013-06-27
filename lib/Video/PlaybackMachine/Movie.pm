package Video::PlaybackMachine::Movie;

####
#### Video::PlaybackMachine::Movie
####
#### $Revision$
####
#### Represents a movie on the schedule.
####

use Moose;

use POE;
use Carp;

has 'title' => (
    'is'       => 'ro',
    'isa'      => 'Str',
    'required' => 1,
    'reader'   => 'get_title',
);

has 'description' => (
    'is'       => 'ro',
    'isa'      => 'Str',
    'required' => 1,
    'reader'   => 'get_description',
);

has 'av_files' => (
    'is'       => 'rw',
    'traits'   => ['Array'],
    'isa'      => 'ArrayRef[Video::PlaybackMachine::AVFile]',
    'required' => 1,
    'handles'  => {
        'get_av_files' => 'elements'
    },
);

############################## Object Methods ##############################

##
## get_length()
##
## Returns the length of the item in seconds. Items with no
## set length return 0.
##
sub get_length {
    my $self = shift;

    my $length = 0;

    foreach my $av_file ( $self->get_av_files() ) {
        $length += $av_file->length();
    }

    return $length;
}

##
## prepare()
##
## Does whatever is necessary to make this item ready to play. Called
## when the item is scheduled. Returns true if the item was successfully
## prepared and should be scheduled, false otherwise.
##
sub prepare {
    my $self = shift;

    foreach ( $self->get_av_files() ) {
        -e $_->get_file() or do {
            warn "Attempt to use nonexistent file '@{[ $_->get_file() ]}'\n";
            return;
        };
    }

    return 1;

}

##
## play()
##
## Arguments:
##   OFFSET: integer -- amount of time to skip before beginning.
##
## Issues whatever command is necessary to play this item.
##
sub play {
    my $self = shift;
    my ($offset) = @_;

    my $session = $poe_kernel->get_active_session();

    $poe_kernel->post( 'Player', 'play',
        $session->postback( 'finished', $self, time() ),
        $offset, map { $_->get_file() } $self->get_av_files() );
}

__PACKAGE__->meta()->make_immutable();

no Moose;

1;
