INSERT INTO schedules (name) VALUES ('Test Schedule');

INSERT INTO content_types VALUES ('short');
INSERT INTO content_types VALUES ('movie');
INSERT INTO content_types VALUES ('trailer');

INSERT INTO av_files(title) VALUES('MIB Music video');
INSERT INTO av_file_component (title, file, duration) VALUES('MIB Music video', 'music_MIB.vob', '00:03:43');
INSERT INTO av_files (title) VALUES('Dr. Who: The Crystal Of Achillon');
INSERT INTO av_file_component (title, file, duration) VALUES('Dr. Who: The Crystal Of Achillon', 'movie_drwho_crystal_of_achillon.mpg', '00:59:00');

INSERT INTO contents (title, type, director, description) VALUES ('MIB Music video', 'short', 'Unknown', 'Music video for the song "Men In Black".');
INSERT INTO contents (title, type, director, description) VALUES ('Dr. Who: The Crystal Of Achillon', 'movie', 'Chris Hoyle', 'In this fan-produced episode, The Doctor and his companion Leia must defeat the Master before he uses the dreaded Crystal of Achillon to take over the universe.');

INSERT INTO content_schedule (id, schedule, listed, start_time, title)
	VALUES (1, 'Test Schedule', TRUE,  'June 8, 2003 11:32:00 AM' , 'Dr. Who: The Crystal Of Achillon');
INSERT INTO content_schedule (id, schedule, listed, start_time, title)
	VALUES (2, 'Test Schedule', FALSE, 'June 8, 2003 12:35:00 PM', 'MIB Music video');
