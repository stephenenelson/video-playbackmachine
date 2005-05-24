package Video::PlaybackMachine::ContentManager;

use strict;
use warnings;
use diagnostics;

use Video::Xine;
use File::Basename;
use POSIX 'ceil';
use Carp;

use DBI;

use base 'Exporter';
our @EXPORT_OK = qw(get_title get_length add_movie add_fill get_missing);


####################### Module Constants #########################

our $Database_Name = 'playback_machine';

######################## Subroutines ############################

##
## Returns any avi entries which do not exist on the
## local file system. Note: will not decode MRLs; assumes
## straight filenames.
sub get_missing {
  my ($filename) = @_;

  my $dbh = get_dbh();
  my $sth = $dbh->prepare('SELECT title,file FROM av_file_component');
  $sth->execute()
    or die "Couldn't execute: '$DBI::errstr'; stopped";
  
  my @missing = ();
  while ( my ($title, $file) = $sth->fetchrow_array() ) {
    -f $file and next;
    push(@missing, [$title, $file]);
  }
  
  return @missing;
}

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

  my $xine = Video::Xine->new(config_file => '/dev/null');
  my $null_ao_driver = Video::Xine::Driver::Audio->new($xine, 'none')
      or die "Couldn't open audio driver\n";
  my $stream = $xine->stream_new($null_ao_driver);
  $stream->open($filename)
    or croak "Couldn't open '$filename'";
  my (undef, undef, $length_millis) = $stream->get_pos_length();

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
