DELETE FROM schedules WHERE name='Test Schedule';
DELETE FROM av_files WHERE title='Test Pattern';
DELETE FROM av_files WHERE title='False Alarms';

INSERT INTO schedules (name) VALUES ('Test Schedule');

INSERT INTO av_files(title) VALUES('Test Pattern');
INSERT INTO av_file_component (title, file, duration) VALUES('Test Pattern', '/home/steven/Video/PlaybackMachine/test_movies/time_015.avi', '00:00:15');

INSERT INTO av_files(title) VALUES('False Alarms');
INSERT INTO av_file_component (title, file, duration) VALUES('False Alarms', '/home/steven/Video/PlaybackMachine/test_movies/music_falsealarms2.avi', '00:06:22');


INSERT INTO content_schedule (id, schedule, listed, start_time, title)
	VALUES (1, 'Test Schedule', TRUE,  'Feb 18, 2005 11:32:00 AM' , 'Test Pattern');


INSERT INTO content_schedule (id, schedule, listed, start_time, title)
	VALUES (2, 'Test Schedule', TRUE,  'Feb 18, 2005 11:34:00 AM' , 'False Alarms');

