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


use IO::Handle;

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
	my $self = {
		    dbh => $in{'dbh'},
		    table_name => $in{'table_name'},
		    session => $in{'session'},
                    event => $in{'event'}
		   };
}

###################### Session Methods ##########################

sub _start {
  my ($self, $kernel, $heap) = @_[OBJECT, KERNEL, HEAP];

  # Watch for incoming messages from the database
  my $fd = $self->{'dbh'}->func('getfd');
  my $fh = IO::Handle->new();
  $fh->fdopen($fd)
    or die "Couldn't open file descriptor '$fd': $!";
  $kernel->select_read($fh, 'changed');
  $heap->{'fh'} = $fh;
}

sub _stop {
  my ($self, $kernel, $heap) = @_[OBJECT, KERNEL, HEAP];
  my $fh = $heap->{'fh'};
  $kernel->select_read($fh);
  delete $heap->{'fh'};
  $fh->close();
}

sub changed {
  my ($self, $kernel, $heap) = @_[OBJECT, KERNEL, HEAP];

  my $ret = $self->{'dbh'}->func('pg_notifies')
    or return;
  $ret->[0] eq $self->{'table_name'} or return;
  
}

###################### Object Methods ###########################

sub spawn {
  my $self = shift;

  POE::Session->create(
		       object_states => [
					 $self => [ qw(_start _stop changed) ]
					]
		      );
}


