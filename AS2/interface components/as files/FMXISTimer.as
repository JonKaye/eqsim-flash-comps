/**
<p>This class implements a countdown timer.</p>
 
<p>The class has one event, by default called "onElapsed" (but this can
be changed in the property inspector).  The value is the number of
remaining iterations until shut down (-1 is infinite).</p>
 
<p>This class inherits from FMXISBase to get listener capabilities.</p>

@class FMXISTimer
@codehint _timer
@author Jonathan Kaye (FlashSim.com)
@tooltip Countdown timer
*/
/*
This code was developed by Jonathan Kaye and Amethyst Interactive LLC,
Copyright 2002-2004, all rights reserved.
v2.0, February, 2004
*/
import mx.core.UIObject;
import mx.fmxis.FMXISBase;

[IconFile("timer.png")]

[Event("onElapsed")]
/**
Event generated when interval elapses.  Value supplied with the event is the number of
remaining iterations until shutdown (-1 is infinite).
@event onElapsed
*/

class mx.fmxis.FMXISTimer extends FMXISBase {

	// bounding box for this button component
	private var boundingBoxClip:MovieClip;
	
	private var _intvl:Number;
	private var active:Boolean;
	private var _nIters:Number;
	private var _loopCt:Number;
	private var _tID:Number;
	
	var className:String = "FMXISTimer";
	static var symbolOwner:Object = FMXISTimer;
	static var symbolName:String = "FMXISTimer";
	
	// Inspectable properties.  Let user change the event names, if desired.
	// The event names have to be set at the time the component is instantiated (either
	// at run-time, or programmatically at the attachMovie/createClassObject time).
	
	/**
	Set this value to change the number of times the timer repeats the interval. If changed
	while the timer is active, the timer resets and starts again.
	@property nIters
	*/
	[Inspectable(name="iterations (-1 infinite)", type=Number, defaultValue=-1)]
	public function set nIters (v) {
		setIterations(v);
	}
	public function get nIters () {
		return _nIters;
	}
	
	/**
	This property holds the string name of the event.
	@property evtElapsed
	*/
	[Inspectable(name="onElapsed event name", type=String, defaultValue="onElapsed")]
	private var evtElapsed:String;
	
	/**
	Set this value to change the timing interval. If changed while the timer is active,
	the timer resets and starts again.
	@property intvl
	*/
	[Inspectable(name="Timing interval (milliseconds)", type=Number, defaultValue=1000)]
	public function set intvl (v) {
		setTimingInterval(v);
	}
	public function get intvl () {
		return _intvl;
	}
			
	// event dispatch stuff
	private var dispatchEvent:Function;
	
	// clipParameters - for backward compatibility with Flash 6 player
	var clipParameters:Object = { listener:1, evtElapsed:1, intvl:1, nIters:1 };
	private static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(FMXISTimer.prototype.clipParameters, 
                               UIObject.prototype.clipParameters);

	
	static var buttonEvents:Array = new Array("onElapsed");
	
	// by default, use the event names as given by buttonEvents.  We made it a static
	// variable for space efficiency.
	private var myEvents:Array = buttonEvents;
	
	// constructor
	function FMXISTimer () {
	}
	
	private function init (evts): Void {
		// if the user has changed any event names, make sure named listeners are handled
		if (myEvents[0] != evtElapsed  ||
		    evts != null) {
			this.myEvents = new Array(evtElapsed );
		}
		if (evts != null) {
			if (!(evts instanceof Array)) {
				evts = [ evts ];
			}
			
			super.init(myEvents = myEvents.concat(evts));
			
		} else {
			super.init(myEvents);
		}
		
		boundingBoxClip._visible = false;
	}
	
/**
Activate the timer.  If the timer is currently active, it is reset and then started again.
@method start
*/
	public function start () {
		if (active) {
			reset();
		}
		
		if (_nIters != 0) {
			_loopCt = _nIters;
			_tID = setInterval(this, "TimerCbk", _intvl);
			active = true;
		}
	}
	/**
Called when the timer elapses.  Determine whether or not more intervals remain.
@method TimerCbk
@access private
*/
	private function TimerCbk () {
		eventObj.type = evtElapsed;
		_loopCt -= 1;
		eventObj.val = (_nIters == -1 ? -1 : _loopCt);
	
		if (_loopCt == 0) {
			reset();
		}
		dispatchEvent(eventObj);
	}

	
	/**
	Called to reset (and halt, if active) the timer.
	@method reset
	*/
	function reset () {
		if (active) {
			clearInterval(_tID);
			_tID = undefined;
			active = false;
		}
	}
	
	/**
	This method is used to tell if the timer is currently active.
	@method isActive
	@return True if timer is currently active, false otherwise
	*/
	function isActive () {
		return active;
	}
	
	private function setTimingInterval (v) {
		if (active) {
			reset();
			start();
		}
		_intvl = v;
	}
	
	private function setIterations (v) {
		if (active) {
			_loopCt = v;
		}
		_nIters = v;
	}
	
}
/**
This method allows the developer to register a listener object to receive event notification
for the specific event, given by name.  This method is provided by mx.events.EventDispatcher.

@method addEventListener
@param eventName String name of the event to listen for
@param inst Listener instance
*/

/**
This method removes the listener specified from those notified when the specified event is generated.
This method is provided by mx.events.EventDispatcher.

@method removeEventListener
@param eventName String name of the event to listen for
@param inst Listener instance
*/

/**
<p>The listener property is designed for convenience at component instantiation time.  It is
the string name of a listener to register on this component.  Developers can certainly register
listeners programmatically through <code>addListener()</code> or <code>addEventListener()</code>,
but this property makes it convenient to add the first listener -- in many cases, there is only one.</p>

<p>FMXISBase simply takes this property at initialization time and calls <code>addProxyListener()</code>.
Therefore, developers can also prefix the name by a relative (e.g., _parent) or absolute (e.g., _root,
_level, or _global) path.</p>
	
@property listener
*/

/**
Register the listener programmatically to receive <b>all</b> events for this component.
We can accept the listener if it is an instance name (use addEventListener directly)
or the string name of the listener (then we add a proxy listener).
	
@method addListener
@param lstner The listener's instance or string name (with or without relative or absolute path)
*/
	
/**
Remove the listener from this component's event notification list.  Inside, we see if the listener specified
is an instance or a string, then call the appropriate removal routine to clean up.
@method removeListener
@param lstnr
*/

/**
This adds a listener instance name (string) to the list of listeners.  The name
may carry a relative or absolute path (_parent, _level, _global, etc.). If evts
is undefined, use the existing list of events for this component (from myEvents,
which subclasses that have events must override).  If evts is not undefined, then
it is an array containing elements that are event names (strings) for each event
that the listener wants to hear.

@method addProxyListener
@param listenerName String name of the listener instance
@param evts Array of events to register listener for, leave undefined for all component events
*/

/**
Removes the given listener (listenerName, a) from our records, and event notification.  If
the listener was added with a relative or absolute path, then it must be removed with a path
that gets to the correct timeline as well, even if that prefix is different from when the listener
was added (for example, if the handler removing the listener is on a different timeline than the
one that added the listener).

@method removeProxyListener
@param listenerName Listener instance name (string)
*/