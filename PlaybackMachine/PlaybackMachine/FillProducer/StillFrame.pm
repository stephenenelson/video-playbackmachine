package Video::PlaybackMachine::FillProducer::StillFrame;

####
#### Video::PlaybackMachine::FillProducer::StillFrame
####
#### $Revision$
####
#### 
####

use strict;
use warnings;
use Carp;

use base 'Video::PlaybackMachine::FillProducer::AbstractStill';
use POE;

############################# Class Constants #############################

############################## Class Methods ##############################

##
## new()
##
## Arguments: (hash)
##  image => string -- filename of image
##  time => int -- time in seconds image should be displayed
##
sub new {
  my $type = shift;
  my %in = @_;

  my $self = $type->SUPER::new(@_);

  $self->{image} = $in{image};

  return $self;
}

############################# Object Methods ##############################



##
## start()
##
## Displays the StillFrame for the appropriate time. Assumes that
## it's being called within a POE session.
##
sub start {
  my $self = shift;

  $poe_kernel->yield('still_ready', $self->{image}, $self->get_time_layout()->min_time());
}

1;
