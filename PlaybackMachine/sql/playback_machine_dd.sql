CREATE TABLE content_types (
	type		text primary key
);

CREATE TABLE av_file_component (
	order		int NOT NULL DEFAULT(0),
	file		text NOT NULL,
	title		text REFERENCES av_files,
	duration	interval NOT NULL,
	PRIMARY KEY (file, order)
);

CREATE TABLE av_files (
	title		text primary key,
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
	title 		text not null references contents
	schedule	text not null references schedules (name) ON DELETE CASCADE,
	listed		boolean not null,
	name		text not null,	
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

CREATE FUNCTION check_overlap() RETURNS TRIGGER AS '
BEGIN
	IF EXISTS( SELECT id FROM content_schedule
		WHERE schedule = NEW.schedule
			AND (
				-- Conflicts with something starting after
				( NEW.stop_time >= start_time and NEW.stop_time <= stop_time ) or

				-- Conflicts with something starting before
				( NEW.start_time >= start_time and NEW.start_time <= stop_time ) or

				-- Something would be entirely contained or equal
				( NEW.start_time <= start_time and NEW.stop_time >= stop_time )

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

CREATE FUNCTION content_schedule_fix_name() RETURNS TRIGGER AS '
BEGIN
	IF NEW.name ISNULL THEN
		NEW.name := NEW.title;
	END IF;
	RETURN NEW;
END;
' LANGUAGE 'plpgsql';

CREATE TRIGGER content_schedule_fix_name BEFORE INSERT OR UPDATE ON content_schedule
	FOR EACH ROW EXECUTE PROCEDURE content_schedule_fix_name();

