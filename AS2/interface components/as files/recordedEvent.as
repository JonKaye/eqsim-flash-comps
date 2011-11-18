/**
   This class stores an individual    
   @class  recordedEvent
   @package mx.fmxis
   @author Jonathan Kaye
*/

class mx.fmxis.recordedEvent {
	
	// Timestamp (in milliseconds)
	var ts;
	// Mouse position x and y, relative to target movie clip
	var mx, my;
	// Pointer to movie clip that generated event
	var who;
	// String name of the event recorded
	var ev;
	// Value of the event recorded
	var ev_val;
	
	function recordedEvent(timeStamp, mousex, mousey, whoSent, eventStr, evVal) {
		ts = timeStamp;
		mx = mousex;
		my = mousey;
		who = whoSent;
		ev = eventStr;
		ev_val = evVal;
	}
}
