use strict;

use POE;
use POE::Session;
use POE::Kernel;

use Video::PlaybackMachine::Player;

my $player = Video::PlaybackMachine::Player->new();
$player->spawn();


POE::Session->create(

		     inline_states => {
				       _start => sub {
					 $_[KERNEL]->post('Player',
							  'play_music',
							  $_[SESSION]->postback('finished'),
							  '/home/steven/ogg/scifigreatest_hits_vol1/scifis_greatest_hits_vol_1__final_frontiers/jerry_goldsmith__total_recall.oggls
'
							 );
				       },
				       finished => sub {
					 print STDERR "All done! Status was $_[ARG0]\n";
				       }

				      }

);

$poe_kernel->run();
