

CREATE TABLE content_types (
	type		text primary key
);


CREATE TABLE av_files (
	title		text primary key
);



CREATE TABLE av_file_component (
	file		text NOT NULL,
	title		text REFERENCES av_files,
	duration	interval NOT NULL,
	sequence_no	int DEFAULT (0),
	PRIMARY KEY (file,sequence_no)
);


CREATE TABLE contents (
	title		text primary key references av_files,
	type		text,
	director	text,
	description	text
);

CREATE TABLE schedules (
	name		text primary key
);

CREATE SEQUENCE schedule_id_seq;

CREATE TABLE content_schedule (
	id			int primary key DEFAULT nextval('schedule_id_seq'),
	title 		text not null references contents,
	schedule	text not null references schedules (name) ON DELETE CASCADE,
	listed		boolean not null,
	start_time	timestamp not null
);

CREATE FUNCTION avfile_duration(text) RETURNS interval AS '
DECLARE
total_length INTERVAL;
stitle ALIAS FOR $1;
BEGIN
	select sum(duration) into total_length from av_file_component 
		where title = stitle;
	RETURN total_length;
END
' LANGUAGE 'plpgsql';

CREATE FUNCTION stop_time(text,timestamp) RETURNS timestamp AS '
DECLARE
stitle ALIAS FOR $1;
start_time ALIAS FOR $2;
BEGIN
	RETURN start_time + avfile_duration(stitle);
END
' LANGUAGE 'plpgsql';


CREATE FUNCTION check_overlap() RETURNS TRIGGER AS '
BEGIN
	IF EXISTS( SELECT id FROM content_schedule
		WHERE schedule = NEW.schedule
			AND overlaps(NEW.start_time, avfile_duration(NEW.title), start_time, avfile_duration(title))
	)
	THEN
		RAISE EXCEPTION ''Schedule entry conflicts with existing entry'';
	END IF;
	RETURN NEW;
END;
' LANGUAGE 'plpgsql';

CREATE TRIGGER content_check_overlap BEFORE INSERT OR UPDATE ON content_schedule
	FOR EACH ROW EXECUTE PROCEDURE check_overlap();



