package Video::PlaybackMachine::DatabaseWatcher;

##
## Video::PlaybackMachine::DatabaseWatcher
##
## $Revision$
##
## Signals the Scheduler when the database has been updated.
##

use strict;
use warnings;
use diagnostics;

use POE;
use POE::Session;
use POE::Kernel;

######################## Class Constants ########################


######################## Class Methods ##########################

##
## new()
##
## Arguments: (hash)
##   dbh => DBI handle (DBD::Pg connection)
## 
sub new {
	my $type = shift;
	my %in = @_;
	
	
}