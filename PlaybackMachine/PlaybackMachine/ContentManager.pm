package Video::PlaybackMachine::ContentManager;

use strict;
use warnings;
use diagnostics;

use Xine_simple 'xine_simple_get_length';
use File::Basename;
use POSIX 'ceil';

use DBI;

use base 'Exporter';
our @EXPORT_OK = qw(get_title get_length add_movie add_fill);


####################### Module Constants #########################

our $Database_Name = 'playback_machine';

######################## Subroutines ############################

sub get_title {
  my ($filename) = @_;

  my $name = basename($filename, '.avi', '.mov', '.dv', '.vob');
  $name =~ s/^(?:movie|music|short|fill)_//;
  my @words = split(/_/, $name);
  my $title = join(' ', map { ucfirst( lc($_)  )} @words);
}

BEGIN: {

my $dbh;

sub get_dbh {
  if (! defined($dbh) ) {

    $dbh = DBI->connect( "dbi:Pg:dbname=$Database_Name", '', '', 
			 {
			  RaiseError => 1,
			  AutoCommit => 1
			 }
		       )
      or croak("Couldn't open database '$Database_Name' for reading: ",
	       DBI->errstr(), ", stopped");
  }
  return $dbh;

}

}

sub get_length {
  my ($filename) = @_;

  my $length_millis = xine_simple_get_length($filename);
  return ceil($length_millis / 1000);
}

sub add_movie {
  my ($filename, $title, $length) = @_;

  my $dbh = get_dbh();

  $dbh->begin_work();

  _add_av_file($dbh, $filename, $title, $length);

  $dbh->do('INSERT INTO contents (title) VALUES (?)',
	  {},
	  $title);

  $dbh->commit();

}

sub add_fill {
  my ($filename, $title, $length) = @_;

  my $dbh = get_dbh();

  $dbh->begin_work();

  _add_av_file($dbh, $filename, $title, $length);

  $dbh->do('INSERT INTO fill_shorts (title) VALUES (?)',
	   {},
	   $title);

  $dbh->commit();
}

sub _add_av_file {
  my ($dbh, $filename, $title, $length) = @_;

  $dbh->do('INSERT INTO av_files(title) VALUES(?)',{},$title);
  $dbh->do('INSERT INTO av_file_component (title, file, duration) VALUES(?,?,?)', 
	   {},
	   $title, $filename, "$length seconds");


}

1;
