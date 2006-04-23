<?php
/*
 * Created on Apr 23, 2006
 *
 */
 
 header('Content-type: text/xml');
 
 $database = pg_pconnect("dbname=playback_machine");
 if (!$database) {
  echo "Error: " . pg_last_error();
  exit;
}

$result = pg_query($database, "SELECT ID, TITLE, EXTRACT(EPOCH FROM start_time) AS START_TIME, EXTRACT(EPOCH FROM AVFILE_DURATION(TITLE)) AS DURATION FROM schedule_times where schedule='$_REQUEST[schedule]' ORDER BY START_TIME");
if (!$result) {
  echo "Error: " . pg_last_error();
  exit;
}

?>
<schedule>
<?php
while ($arr = pg_fetch_array($result)) {	
?>
	<entry id="<?php echo $arr['ID'] ?>" start_time="<?php echo $arr['START_TIME']?>" duration="<?php echo $arr['DURATION'] ?>"><?php echo $arr['TITLE'] ?></entry>
<?php
}
?>
</schedule>