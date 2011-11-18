import mx.core.UIObject;
import mx.fmxis.recordedEvent;

/**
   FMXISEventRecorder - Record and playback events for components that have ExecEvent() defined.
   
   @class FMXISEventRecorder
   @package mx.fmxis
   @author Jonathan Kaye 
*/

[IconFile("evRec.png")]

class mx.fmxis.FMXISEventRecorder extends mx.core.UIComponent {
	
	var className:String = "FMXISEventRecorder";
	static var symbolOwner:Object = FMXISEventRecorder;
	static var symbolName:String = "FMXISEventRecorder";
	
	
	// A pointer to the movie clip to use as the coordinate reference for the simulator.  We
	// retrieve the _xmouse and _ymouse positions relative to this so that if the developer
	// moves the sim, we can correctly move the simulated cursor to the right spot.
	[Inspectable(name="Movie clip instance", type=String, defaultValue="")]
	public var targClipName:MovieClip;
	private var targClip:MovieClip;
	
	[Inspectable(name="Display this panel", type=Boolean, defaultValue=true)]
	public var dispPanel:Boolean;

	[Inspectable(name="Cursor linkage ID", type=String, defaultValue="defPbackCursor")]
	public var cursID:String;
	
	[Inspectable(name="Cursor start X", type=String, defaultValue="mouse")]
	public var cursX:String;
	
	[Inspectable(name="Cursor start Y", type=String, defaultValue="mouse")]
	public var cursY:String;
		
	// True or false depending on whether the recording is currently occurring.  Record
	// and playback cannot occur simultaneously.
	var active:Boolean;
	// True or false depending on whether playback is currently occurring.  Record
	// and playback cannot occur simultaneously.
	var playing:Boolean;

	// List of the events recorded (as recordedEvent's)
	public var recObjs:Array;
	
	// The moment in milliseconds (according to getTimer()) that the last event was received
	private var lastEventTime:Number;
	// True if the first event being recorded has not been seen yet, false otherwise
	private var firstEvent:Boolean;
	
	
	// Current record we're playing (during playback)
	private var curPlayStep:Number;
	
	// When playback started (according to getTimer)
	private var playStart:Number;
	
	
	var cursorX, cursorY;
	var myAnimClip:MovieClip;
	var boundingBox_mc:MovieClip;
	var panel:MovieClip;
	var demoCursor:MovieClip;
		
	var playID:Number;
	
	
	// clipParameters - for backward compatibility with Flash 6 player
	var clipParameters:Object = { dispPanel:true, targClip:1, cursID:"defPbackCursor",
								  cursX:"mouse", cursY:"mouse" };
	private static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(FMXISEventRecorder.prototype.clipParameters, 
                               UIObject.prototype.clipParameters);
                               
	/**
	 * Initializes the recording mechanism.
	*/
	function FMXISEventRecorder() {
		recObjs = new Array();
		lastEventTime = 0;
		active = false;
		firstEvent = true;
		
		if (targClipName == "") {
			targClip = _parent;
		} else {
			targClip = _parent[targClipName];
		}
		demoCursor._visible = false;
		panel._visible = this.dispPanel;
	}
	
	private function init () {
		super.init();
		boundingBox_mc._visible = false;
	}
	
	private function createChildren () {
		attachMovie("eventRecorderPanel", "panel", 1);
		attachMovie(cursID, "demoCursor", 2);
	}

	// Call this to reset the recording mechanism and discard any recorded events.
	function resetRec () {
		if (recObjs.length > 0) {
			for (var i=0; i<recObjs.length; i++) {
				delete recObjs[i];
			}
			delete recObjs;
			recObjs = new Array();
		}
		lastEventTime = 0;
		firstEvent = true;
	}

	// Called to start (or re-start, if paused) the recording mechanism.
	function startRec () {
		lastEventTime = getTimer();
		active = true;
	}
	
	// Call this to pause the recording mechanism.
	function pauseRec () {
		lastEventTime = getTimer();
		active = false;
		firstEvent = true;
	}
	
	// Call this routine to halt the recording process.
	function stopRec () {
		lastEventTime = 0;
		active = false;
		firstEvent = true;
	}
	
	// Trap and record the events that come into the recorder
	function handleEvent (ev) {
		recEvent(ev.type, ev.val, ev.target);
	}
	
	// Record the incoming event
	private function recEvent(ev, evVal, whoSent) {
		var copyObj;
		
		// Don't record during playback or if not actively recording
		if (playing || !active)
			return;
			
		// If this is the first event, start at 0, otherwise use elapsed time since last
		var timeInt = (firstEvent ? 0 : getTimer() - lastEventTime);
		firstEvent = false;
		
		// If the value is an object, copy all the properties in case values disappear
		// from return value object
		if (typeof(evVal) == "object") {
			copyObj = new Object();
			for (var i in evVal) {
				copyObj[i] = evVal[i];
			}
			evVal = copyObj;
		}
	
		recObjs.push(new recordedEvent(timeInt, targClip._xmouse, targClip._ymouse, whoSent, ev, evVal));
		lastEventTime = getTimer();
	}
	
	function outputActs () {
		panel.outText.text = serialize();
	}
	
	// Return the list of recorded events in text.
	function serialize () {
		var actVar, val, i, j, pathStr, outText, tcs, tc;
		
		if (recObjs.length == 0) {
			return "[No recorded events]";
		}
		
		tcs = String(targClip);
		tc = tcs.substr(String(_parent).length+1);
		
		if (tc == "") {
			outText = "// Make sure movie instance clip prop of recorder panel is empty\n";
		} else {
			outText = "// Make sure movie instance clip prop of recorder panel is set to \"" + tc + "\"\n";
		}
		outText += "var ra = " + this + ";\nra.resetRec();\n";
		for (i=0; i<recObjs.length; i++) {
			actVar = recObjs[i];
	
			// determine the event value to pass
			switch (typeof(actVar.ev_val)) {
				case "object":
					val = "";
					for (j in actVar.ev_val) {
						val += ", " + j + ": ";
						// if element's value is a string, add quotes
						if (typeof(actVar.ev_val[j]) == "string")
							val += "\"" + actVar.ev_val[j] + "\"";
						else
							val += actVar.ev_val[j];
					}
					val = "{" + val.substr(1) + "}";
					break;
					
				case "string":
					val = "\"" + actVar.ev_val + "\"";
					break;
					
				default:
					val = actVar.ev_val;
			}
		
		pathStr = String(actVar.who).substr(String(targClip).length + 1);
			outText += "ra.recObjs.push(new mx.fmxis.recordedEvent(" + actVar.ts +
					", " + actVar.mx +
					", " + actVar.my +
					", ra.targClip." + pathStr +
					", \"" + actVar.ev + "\"" + 
					(val != "" && val != undefined ? ", " + val : "") +  "));\n";
		}
		
		outText += "ra.playRec();\n";
		
		return outText;
	}
	
	
	
	private function playingMonitor () {
		var timeNow = getTimer(), px, py, ro;
		
		ro = recObjs[curPlayStep]; // action for next step we're waiting for

		if (timeNow - playStart > ro.ts) {
			// Do the action
			if (ro.who != undefined) {
				ro.who.execEvent(ro.ev, ro.ev_val);
			}
	
			// Start motion towards next action
			if (curPlayStep < recObjs.length - 1) {
				playStart = timeNow;
				if (ro.who == undefined) {
					cursorX = demoCursor._x;
					cursorY = demoCursor._y;
				} else {
					demoCursor._x = cursorX = ro.mx + targClip._x - this._x;
					demoCursor._y = cursorY = ro.my + targClip._y - this._y;
				}
	
				curPlayStep++;
			} else {
				stopPlay(true);
			}
		}
		// Update cursor position
		if (ro.who != undefined) {
			demoCursor._x = easeInOutSine(timeNow - playStart, cursorX,
											   ro.mx - (cursorX - targClip._x) - this._x,
											   ro.ts);
			demoCursor._y = easeInOutSine(timeNow - playStart, cursorY,
											   ro.my - (cursorY - targClip._y) - this._y,
										   		ro.ts);
		}
	}
	
	function playRec () {
		var px:Number, py:Number;
		
		if (recObjs.length == 0) {
			return;
		}
		
		// Set all begin events to take 1500 milliseconds
		for (var i=0; i<recObjs.length; i++) {
			if (recObjs[i].ts == 0) {
				recObjs[i].ts = 1500;
			}
		}
		
		curPlayStep = 0;
		playing = true;
		playStart = getTimer();
	
		if (!isNaN(cursX)) {
			px = parseFloat(cursX);
		} else {
			px = targClip._xmouse;
		}
		if (!isNaN(cursY)) {
			py = parseFloat(cursY);
		} else {
			py = targClip._ymouse;
		}
		
		demoCursor._x = cursorX = targClip._x + px - this._x;
		demoCursor._y = cursorY = targClip._y + py - this._y;
	
		demoCursor.activateCursor(true);
		demoCursor.showCursor(true);
	
		playID = setInterval(this, "playingMonitor", 50);
	}
	
	// Last event has been executed, so dissolve the mouse pointer
	function stopPlay (hideCur) {
		clearInterval(playID);
		playing = false;
		demoCursor.activateCursor(false);
		demoCursor.showCursor(hideCur == true);
	}
	
	/**
	* Computes and returns value for sinusoidal interpolation between 1D points b and c.
	* t gives current time, from 0 to end time d.
	* Written by Robert Penner, www.robertpenner.com
	*/

	private	function easeInOutSine (t, b, c, d) {
		return c/2 * (1 - Math.cos(t/d * Math.PI)) + b;
	}

}