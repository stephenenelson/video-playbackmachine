#!/bin/bash

CREATEUSER_BIN=/usr/bin/createuser
CREATEDB_BIN=/usr/bin/createdb
PSQL_BIN=/usr/bin/psql

PM_DB_USER=playbackmachine
PM_DB_NAME=playbackmachine
PM_DB_DESCRIPTION="Playback Machine"

# Create a user
$CREATEUSER $PM_DB_USER

# Create a database
$CREATEDB_BIN $PM_DB_NAME "$PM_DB_DESCRIPTION"

# Load table structure into database
$PSQL_BIN -U $PM_DB_NAME < playback_machine_dd.sql

