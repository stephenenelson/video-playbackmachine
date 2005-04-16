package Video::PlaybackMachine::FillProducer::TextFrame;

####
#### Video::PlaybackMachine::FillProducer::TextFrame
####
#### $Revision$
####

use strict;
use warnings;
use Carp;

use base 'Video::PlaybackMachine::FillProducer::AbstractStill';
use POE;

use Image::Imlib2;
use File::Temp qw(tempfile);
use POSIX qw(strftime);

############################# Class Constants #############################

our $Width = 800;
our $Height = 600;

our @Background_Color = (0,0,100,255);

our @Text_Color = (0,255,255,255);

our @Font_Path = qw(/usr/share/fonts/bitstream-vera);

our $Font = "Vera/40";

############################## Class Methods ##############################

##
## start()
##
sub start {
  my $self = shift;

  my $image = $self->create_image()
    or die "Couldn't create image for some reason";
  
  $self->add_text($image);

  my ($fh, $filename) = tempfile( SUFFIX => '.png');
  $image->save($filename);

  # Scurvy trick-- passing the filehandle as an unused argument so that 
  # it will survive as long as the event does.
  $poe_kernel->post('Player', 'play_still', $filename, undef, undef, $fh);
  $poe_kernel->delay('next_fill', , $self->get_time_layout()->preferred_time());

}


##
## create_image()
##
sub create_image {
  my $self = shift;

  my $image = Image::Imlib2->new($Width, $Height);
  
  $image->set_color(@Background_Color);
  $image->fill_rectangle(0,0,$Width,$Height);
  
  $image->set_color(@Text_Color);

  $image->add_font_path(@Font_Path);
  $image->load_font($Font);

  return $image;
}

sub write_centered {
  my $self = shift;
  my ($image, $text) = @_;

  my ($words_height, @lines) = wrap_words($image, $text);
  my $start_height = ( $Height - $words_height ) / 2;
  draw_centered($image, $start_height, @lines);

}

sub wrap_words {
  my ($image, $in_text) = @_;

  my @lines = ();
  my $total_height = 0;

  foreach my $text ( split(/\n/, $in_text) ) {

    my @atoms = split(/(\s+)/, $text);
    
    my $curr_line = shift @atoms;
    defined $curr_line or $curr_line = '';
    my ($line_width, $line_height) = $image->get_text_size($curr_line);
    $total_height += $line_height;

    foreach my $atom (@atoms) {
      my ($width, $height) = $image->get_text_size($atom);
      if ( ( $line_width + $width ) > $image->get_width() ) {
	push(@lines, $curr_line);
	$curr_line = $atom;
	$line_width = $width;
	$total_height += $height;
      }
      else {
	$curr_line .= $atom;
	$line_width += $width;
      }
    }
    push(@lines, $curr_line);
  }
  return $total_height, @lines;

}

sub draw_centered {
  my ($image, $starty, @lines) = @_;

  my $y = $starty;

  foreach my $line (@lines) {
    my @words = split(/(\s+)/, $line);
    my ($width, $height) = $image->get_text_size($line, TEXT_TO_RIGHT, 0);
    my $x = ($image->get_width() - $width) / 2;
    $image->draw_text($x, $y, $line);
    $y += $height;
  }

  return $y;
}


1;
