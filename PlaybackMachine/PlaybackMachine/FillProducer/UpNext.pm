package Video::PlaybackMachine::FillProducer::UpNext;

####
#### Video::PlaybackMachine::FillProducer::UpNext
####
#### $Revision$
####

use strict;
use warnings;
use Carp;

use base 'Video::PlaybackMachine::FillProducer::TextFrame';
use POE;

use POSIX qw(strftime);

############################# Class Constants #############################

############################## Class Methods ##############################

##
## new()
##
## Arguments: (hash)
##  time => int -- time in seconds image should be displayed
##
sub new {
  my $type = shift;

  my $self = $type->SUPER::new(@_);

  return $self;

}


############################# Object Methods ##############################

##
## add_text()
##
sub add_text {
  my $self = shift;
  my ($image) = @_;

  my $entry = $poe_kernel->call('Scheduler', 'query_next_scheduled')
    or return;
  my $next_time = strftime '%l:%M', localtime ($entry->get_start_time());

  $self->write_centered($image, "Up Next:\n\n" . $entry->getTitle()  ."\n\n$next_time");


}

1;
