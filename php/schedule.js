function updatePage()
{
	addTimeNodes();
	var schedule_node = document.getElementById("schedule");
	var schedule_entries = getScheduleEntries();

	for (var idx=0; idx < 4; idx++) {
		var schedule_day_node = document.createElement('div');
		schedule_day_node.className = 'schedule-day';
		addScheduleNodes(idx, schedule_day_node, schedule_entries);
		schedule_node.appendChild(schedule_day_node);
	}

}

function addTimeNodes()
{
	var hour_px = (2800  / 24);

	var time_node = document.getElementById('times');
	for (var hour=0; hour <= 23; hour++) {
		var hour_node = document.createElement('p');
		hour_node.className = 'schedule-time';
		hour_node.style.top = (hour * hour_px) + 'px';
		hour_node.style.height = hour_px + 'px';
		hour_node.appendChild( document.createTextNode( hour + ':00' ) );
		time_node.appendChild( hour_node );
	}
}

function addScheduleNodes(idx, schedule_day_node, schedule_entries)
{
	var day_start_time = 1148626800 + ( 60 * 60 * 24 * idx);
	var day_end_time = day_start_time + (60 * 60 * 24);
		
	for (var idx in schedule_entries) {
		var entry = schedule_entries[idx];
		var end_time = entry.start_time + entry.duration;
		if ( (entry.start_time >= day_start_time && entry.start_time < day_end_time)
			|| (end_time >= day_start_time && end_time <= day_end_time)
		 ) {
			addScheduleNode(entry, day_start_time, day_end_time, schedule_day_node);
		}
	}
	
}

function addScheduleNode(entry, day_start_time, day_end_time, schedule_day_node)
{
	var scale = (2800  / (24 * 60 * 60) );
	var time_diff = entry.start_time - day_start_time;
	var duration = entry.duration;
	if (time_diff < 0) {
		duration += time_diff;
		time_diff = 0;
	}
	if ( ( time_diff + duration ) > day_end_time ) {
		duration = (day_end_time - entry.start_time);
	}
	var top = time_diff * scale;
	var height = entry.duration * scale;
	schedule_day_node.appendChild(makeScheduleDaySlot(top, height, entry.title));

}

function makeScheduleDaySlot(top, height, title)
{
	var schedule_day_slot = document.createElement('p');
	schedule_day_slot.className = 'schedule-slot';
	schedule_day_slot.style.top = top + 'px';
	schedule_day_slot.style.height = height + 'px';
	schedule_day_slot.appendChild( document.createTextNode(title) );
	schedule_day_slot.onclick=editTitle;
	return schedule_day_slot;
}

function getScheduleEntries()
{
	var schedule_entries = new Array;

	var xmlhttp = new XMLHttpRequest();
	xmlhttp.open("GET", "http://theluggage/schedule_xml.php?schedule=BayCon+2006", false);
	xmlhttp.send(null);
	if (xmlhttp.status == 200) {
	       var doc = xmlhttp.responseXML;
	       var elements = doc.getElementsByTagName("entry");
	       for (var i = 0; i < elements.length; i++) {
		   var entry = elements[i];
		   var sched_id = entry.getAttribute("id");
		   var start_time = entry.getAttribute("start_time");
		   var duration = entry.getAttribute("duration");
		   var title = entry.childNodes[0].nodeValue;
		   
		   sched_entry = new ScheduleEntry(sched_id, title, start_time, duration);
		   schedule_entries.push( sched_entry );
	       }
	}
	else {
		alert("Failed! Status was " + xmlhttp.status);
	}
		
	return schedule_entries;
}

function ScheduleEntry(id, title, start_time, duration)
{
	this.id = id;
	this.title = title;
	this.start_time = start_time;
	this.duration = duration;
	this.toString = function() { return "ID: " + id + " Title: " + title + " Start time: " + start_time + " Duration: " + duration; };
}
function editTitle(event)
{
	alert("Editing title unimplemented");
}