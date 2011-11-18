  /**
<p>This class implements a stopwatch that can be started, paused, and reset.
It does not subclass timer, it just uses a timer object.  The <code>res</code> property
is the resolution of the stopwatch (minimum value for checking if time has elapsed).  When you
need to optimize performance, you should adjust <code>res</code> to a resolution that is about half of
the shortest interval you need to measure.</p>
 
<p>The class has one event, by default called "SWPulse" (but this can
be changed in the component parameter panel, or programmatically with <code>setSWMsg()</code>).</p>
 
<p>This class inherits from FISBase to get listener capabilities.</p>

@class FISStopwatch
@codehint _stopwatch
@author Jonathan Kaye
@tooltip Stopwatch
*/
/*
This code was developed by Jonathan Kaye and Amethyst Interactive LLC,
Copyright 2002-2004, all rights reserved.
v2.0, February, 2004
*/
import mx.core.UIObject;
import mx.fmxis.FMXISBase;

[IconFile("stopwatch.png")]

[Event("onPulse")]
/**
Event generated at a user-controllable interval while the stopwatch is running.
@event onPulse
*/

class mx.fmxis.FMXISStopwatch extends FMXISBase {

	// bounding box for this button component
	private var boundingBoxClip:MovieClip;
	private var st:mx.fmxis.FMXISTimer;
		
	var className:String = "FMXISStopwatch";
	static var symbolOwner:Object = FMXISStopwatch;
	static var symbolName:String = "FMXISStopwatch";
	
	/**
	This property holds the string name of the event.
	@property evtPulse
	*/
	[Inspectable(name="onPulse event name", type=String, defaultValue="onPulse")]
	private var evtPulse:String;

	/**
	This property holds the resolution of the timer.  This must be set to the pulse interval
	at the maximum.  It determines how often we check to see that the stopwatch has advanced.
	@property res
	*/
	[Inspectable(name="Timing resolution", type=Number, defaultValue=50)]
	private var res:Number;

	
	/**
	This property indicates the interval at which to generate pulse events when the stopwatch is active.
	Use -1 to mean don't generate pulses at all.
	@property pulseInt
	*/
	[Inspectable(name="Pulse interval (-1 for none)", type=Number, defaultValue="-1")]
	public function set pulseInt (v) {
		if (_active) {
			if (v == -1) {
				st.reset();
			} else if (_pulseInt == -1) {
				_lastTime = getTimer();
				st.start();
			}
		}
		
		_pulseInt = v;
	}
	
	public function get pulseInt () {
		return _pulseInt;
	}
	
	private var _pulseInt:Number;
	
	private var _val:Number;
	private var _oldVal:Number;
	private var _lastTime:Number;
	private var _active:Boolean;
	
	// event dispatch stuff
	private var dispatchEvent:Function;
	
	// clipParameters - for backward compatibility with Flash 6 player
	var clipParameters:Object = { listener:1, evtPulse:1, pulseInt:1, res:1 };
	private static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(FMXISStopwatch.prototype.clipParameters, 
                               UIObject.prototype.clipParameters);
	
	static var swEvents:Array = new Array("onElapsed");
	
	// by default, use the event names as given by swEvents.  We made it a static
	// variable for space efficiency.
	private var myEvents:Array = swEvents;
	
	function FMXISStopwatch () {
		_val = 0;
	}
	
	private function init (evts): Void {
		// if the user has changed any event names, make sure named listeners are handled
		if (myEvents[0] != evtPulse  ||
		    evts != null) {
			this.myEvents = new Array(evtPulse );
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
		
		this.createClassObject(mx.fmxis.FMXISTimer, "st", 1, {evtElapsed:"onPulse", intvl: res, nIters: -1});
		st.addEventListener("onPulse", this);
		
		reset();
	}
	
	/**
	This is called on timer interrupts.  Decide if we should issue a pulse.
	@method internalEH
	@access private
	*/
	public function onPulse () {
		var ct = getTimer();
	
		_val += ct - _lastTime;
		_lastTime = ct;
		if (_val - _oldVal >= _pulseInt) {
			eventObj.type = evtPulse;
			eventObj.val = _val;
			dispatchEvent(eventObj);
			_oldVal = _val;
		}
	}

	/**
	Retrieve the current time of the stopwatch.
	@method getTime
	*/	
	public function getTime():Number {
		if (_active) {
			_val = getTimer() - _lastTime + _oldVal;
		}
		
		return _val;
	}
	
	/**
	Activate the stopwatch.
	@method start
	*/
	public function start () {
		if (!_active) {
			_oldVal = _val;
			_lastTime = getTimer();
			if (_pulseInt != -1) {
				st.start();
			}
						
			_active = true;
		}
	}
	
	/**
	Reset the stopwatch.
	@method reset
	*/
	public function reset () {
		if (_active) {
			st.reset();
		}
		
		_val = _oldVal = 0;
		
		_active = false;
	
	}
	
	/**
	Pause the stopwatch.
	@method pause
	*/
	public function pause () {
		if (_active) {
			st.reset();
			_active = false;
		}
	}
	
	
	/**
	Use this method to determine if the stopwatch is currently running (returns true) or stopped (false).
	@method isActive
	@return true or false, depending on whether the stopwatch is running or not (respectively).
	*/
	public function isActive () {
		return _active;
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