

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
	type		text not null references content_types,
	director	text not null,
	description	text not null
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

CREATE TABLE fill_slide_categories (
	category	text primary key
);

CREATE TABLE fill_base (
	name		text primary key
);

CREATE TABLE fill_played (
	fill_name	text references fill_base (name),
	schedule	text references schedules (name),
	last_played	timestamp not null
);

CREATE TABLE fill_shorts (
	title		text references av_files
) INHERITS (fill_base);

CREATE TABLE fill_slides (
	file		text not null,
	category	text references fill_slide_categories,
	frequency	interval not null
) INHERITS (fill_base);

CREATE FUNCTION stop_time(text,timestamp) RETURNS timestamp AS '
DECLARE
total_length INTERVAL;
BEGIN
	select sum(duration) into total_length from av_file_component 
		where title = $1;
	RETURN $2 + total_length;
END
' LANGUAGE 'plpgsql';

CREATE FUNCTION check_overlap() RETURNS TRIGGER AS '
BEGIN
	IF EXISTS( SELECT id FROM content_schedule
		WHERE schedule = NEW.schedule
			AND (
				-- Conflicts with something starting after
				( stop_time(NEW.title,NEW.start_time) >= start_time and stop_time(NEW.title,NEW.start_time) <= stop_time(title,start_time) ) or

				-- Conflicts with something starting before
				( NEW.start_time >= start_time and NEW.start_time <= stop_time(title,start_time) ) or

				-- Something would be entirely contained or equal
				( NEW.start_time <= start_time and stop_time(NEW.title, NEW.start_time) >= stop_time(title, start_time) )

				) 
		)
	THEN
		RAISE EXCEPTION ''Schedule entry conflicts with existing entry'';
	END IF;

	RETURN NEW;
END;
' LANGUAGE 'plpgsql';

CREATE TRIGGER content_check_overlap BEFORE INSERT OR UPDATE ON content_schedule
	FOR EACH ROW EXECUTE PROCEDURE check_overlap();



