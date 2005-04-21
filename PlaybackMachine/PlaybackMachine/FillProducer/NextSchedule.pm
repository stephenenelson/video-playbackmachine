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
use Video::PlaybackMachine::FillProducer::TextFrame::TextTable;
use POE;

use POSIX qw(strftime);

############################# Class Constants #############################

our $Max_Entries = 5;

our $Border = 20;

############################## Class Methods ##############################

##
## new()
##
## Arguments: (hash)
##  time => int -- time in seconds image should be displayed
##
sub new {
  my $type = shift;
  my $self =  $type->SUPER::new(@_);
  return $self;
}



############################# Object Methods ##############################

##
## add_text()
##
sub add_text {
  my $self = shift;
  my ($image) = @_;

  my $entries = $poe_kernel->call('Scheduler', 'query_next_scheduled', $Max_Entries)
    or return;
  my $table = 
    Video::PlaybackMachine::FillProducer::TextFrame::TextTable->new(
								    image => $image,
								    border => $Border,
								   );
  foreach my $entry (@$entries) {
    my $next_time = strftime '%l:%M', localtime ($entry->get_start_time());
    $table->add_row($next_time, $entry->getTitle())
      or last;
  }

  $table->draw();

}

1;
