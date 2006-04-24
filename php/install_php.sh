#!/bin/bash

PHP_USER=apache
PHP_GROUP=apache
CP_BIN=/bin/cp
CHOWN_BIN=/bin/chown
PHP_DEST=/var/www/html
PHP_FILES="schedule_js.html schedule_xml.php playback_add.php playback_delete.php playback_fills.php  playback_schedule.php playback_titles_add.php playback_titles.php playback_update_finish.php playback_update.php"


$CP_BIN --target-directory $PHP_DEST $PHP_FILES

(cd $PHP_DEST && chown $PHP_USER:$PHP_GROUP $PHP_FILES)
