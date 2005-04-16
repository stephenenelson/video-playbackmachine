package Video::PlaybackMachine::FillProducer::NextSchedule;

####
#### Video::PlaybackMachine::FillProducer::NextSchedule
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
  return $type->SUPER::new(@_);
}



############################# Object Methods ##############################

##
## add_text()
##
sub add_text {
  my $self = shift;
  my ($image) = @_;

  my $entries = $poe_kernel->call('Scheduler', 'query_next_scheduled', 5)
    or return;
  my $text = '';
  foreach my $entry (@$entries) {
    my $next_time = strftime '%l:%M', localtime ($entry->get_start_time());
    $text .= "$next_time   " . $entry->getTitle() . "\n";
  }

  $self->write_centered($image, $text);


}

1;
