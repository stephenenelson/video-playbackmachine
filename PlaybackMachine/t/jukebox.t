# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 5;
BEGIN { use_ok('Video::PlaybackMachine::Jukebox') };

use strict;

use Test::MockObject;
use POE;

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

TODO: {
  local $TODO = "Unimplemented";

  my $play_status = 0;

  # Mock up a fake SongPlayer
  my $mock_player = Test::MockObject->new();
  $mock_player->mock('play_music', sub { $play_status = 1 });
  $mock_player->set_true('fadeout_music', sub { $play_status = 0 });
  $mock_player->set_bound('is_playing', \$play_status);

  # Mock up a fake NeophileChooser
  my $mock_chooser = Test::MockObject->new();
  $mock_chooser->set_series('get_next', 'alpha', 'beta', 'gamma');


  # Mock up a fake Filler with a Jukebox
  my $filler = POE::Session->create(
				    inline_states => {
						      _start => sub {
							$_[HEAP]->{'jukebox'} = Video::PlaybackMachine::Jukebox->new( song_chooser => $mock_chooser, song_player => $mock_player, check_interval => 1 );
							$_[HEAP]->{'jukebox'}->spawn();
							$_[KERNEL]->delay('check_start', 1);
							$_[KERNEL]->post($_[HEAP]->{jukebox}, 'start_jukebox');
						      },
						      'check_start' => sub {
							# Check that the NeophileChooser was called
							$mock_chooser->called_ok('get_next');
							
							# Check that the SongPlayer got called with the appropriate title
							$mock_player->called_pos_ok(1, 'play_music');
							$mock_player->called_args_pos_is(1, 0, 'alpha');
							$mock_player->clear();

							# Check that the music being stopped results in another call
							$play_status = 0;
							$_[KERNEL]->delay(2, 'check_next');
						      },
						      check_next => sub {

							# Make sure we got called again
							$mock_player->called_pos_ok(1, 'play_music');
							$mock_player->called_args_pos_is(1, 0, 'beta');

							# Fire a "fadeout" message at the jukebox
							$_[KERNEL]->post($_[HEAP]->{jukebox}, 'stop_jukebox');
							$_[KERNEL]->delay(1, 'check_fadeout');


						      },
						      check_fadeout => sub {

							# Check that the SongPlayer got told to fade out and stop
							$mock_player->called_ok('fadeout_music');


						      }

						     }
				    );

  POE::Kernel->run();

}
