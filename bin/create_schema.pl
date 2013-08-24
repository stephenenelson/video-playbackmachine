#!/usr/bin/env perl

use strict;
use warnings;

# VERSION

use Video::PlaybackMachine::DB;

my $schema = Video::PlaybackMachine::DB->schema();

$schema->create_ddl_dir(['SQLite'], '0.01', './', undef, { 'add_drop_table' => 0 });
