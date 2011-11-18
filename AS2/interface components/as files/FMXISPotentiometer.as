/**
<p>This class implements a simple potentiometer, which is virtually identical in functionality to
the jog knob we implemented (FMXISJog).  Developers can set the increment, number of values
in one cycle, integer vs. discrete, minimum and maximum values, and whether the jog is adjusted by clicking and dragging,
or merely moving in a circular motion (<code>dragOrOver</code>).</p>

Developers can change the appearance by modifying:
<li><code>defPotBkgnd</code> - background</li>
<li><code>defPotIndicator</code> - indicator clip</li>
<li><code>defPotIncr</code> - Increment button (increments by 1 unit)</li>
<li><code>defPotDecr</code> - Decrement button (decrements by 1 unit)</li>

<p>The class also has one property that developers can set in the component property panel,
<code>indLinkID</code>, that replaces the default indicator graphic with a movie clip from
the Library specified by the linkage ID supplied.  The movie clip must have its center at
the center of rotation, so if the developer simply wants to change the indicator (notch), then the
indicator should be placed in the topmost (pointing up) position at the edge of the background.  When
a linkage ID is given, the component scales the background graphic to the maximum dimension of the indicator
movie clip, so the hit area (determined by the background) is correct.  Usually, the developer will
want to turn off the background graphic (using the property in the component property panel).</p>
<p>The class has one event, by default called "onValChg" (but this can
be changed in the property inspector, or by changing the <code>vChg</code> property), and
the value is the new value of the potentiometer.  If the user does not change values, this component
still reports the current knob position.  The <code>drawTicks</code> property, if true, tells the component
to draw <code>numTicks</code> ticks.</p>

<p>The potentiometer value can be set using the <code>val</code> property or through the <code>setVal()</code> method.</p>
 
<p>This class inherits from <code>FMXISJog</code> to get most of its functionality.</p>

@class FMXISPotentiometer
@codehint _pot
@author Jonathan Kaye (FlashSim.com)
@tooltip Potentiometer knob
*/

/*
This code was developed by Jonathan Kaye and Amethyst Interactive LLC,
Copyright 2002-2004, all rights reserved.
v2.0, February, 2004
*/
import mx.core.UIObject;
import mx.fmxis.FMXISJog;

[IconFile("potentiometer.png")]

class mx.fmxis.FMXISPotentiometer extends FMXISJog {
		
	var className:String = "FMXISPotentiometer";
	static var symbolOwner:Object = FMXISPotentiometer;
	static var symbolName:String = "FMXISPotentiometer";

	// Inspectable properties.
	
	[Inspectable(name="Minimum knob value", type=Number, defaultValue=0)]
	public function set minVal (v) {
		_minVal = v;
		setVal(_val, true);
	}
	public function get minVal () {
		return _minVal;
	}
	private var _minVal:Number;
	
	[Inspectable(name="Maximum knob value", type=Number, defaultValue=100)]
	public function set maxVal (v) {
		_maxVal = v;
		setVal(_val, true);
	}
	public function get maxVal () {
		return _maxVal;
	}
	private var _maxVal:Number;

	
	// clipParameters - for backward compatibility with Flash 6 player
	var clipParameters:Object = { listener:1, vChg:1, showBkgnd:1, showHand:1,
								  showButs:1, clickSnd:1, units:1, numTicks:1, showTicks:1,
								  dragOrOver:1, minVal:1, maxVal:1, snap2Int:1,
								  discreteSteps:1, val:1, bkgndLinkID:1, indLinkID:1 };
	private static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(FMXISPotentiometer.prototype.clipParameters, 
                               UIObject.prototype.clipParameters);

	// constructor
	function FMXISPotentiometer () {
	}
	
	// initialize the events for the jog, the jog element clips, and the default values
	private function init (evts): Void {
	
		// if the user has changed any event names, make sure named listeners are handled
		if (myEvents[0] != vChg  ||
		    evts != null) {
			this.myEvents = [ vChg ];
		}
		if (evts != null) {
			if (!(evts instanceof Array)) {
				evts = [ evts ];
			}
			
			super.init(myEvents = myEvents.concat(evts));
			
		} else {
			super.init(myEvents);
		}
		
		_val = Math.min(Math.max(_val, minVal), maxVal);

		// initialize potentiometer at starting position
		setVal(_val, true);
	}
	
	// Attach the potentiometer elements and position them appropriately
	private function attachChildren () {
		var bg = "defPotBkgnd";
		
		if (bkgndLinkID != undefined && bkgndLinkID != "") {
			bg = bkgndLinkID;
		}
		attachMovie(bg, "bkgnd", 1);
		attachMovie("defPotIncr", "rotIncr", 2);
		attachMovie("defPotDecr", "rotDecr", 3);
		rotIncr._x = 30; rotIncr._y = 90;
		rotDecr._x = -30; rotDecr._y = 90;
		
		if (indLinkID != "") {
			attachMovie(indLinkID, "ind", 4);

		} else {
			attachMovie("defPotIndicator", "ind", 4);
		}
	}
	
	
/**
Sets the potentiometer value.

@method setVal
@param v Numeric value (between 0 and <code>units</code>)
@param q (optional) Boolean flag indicating whether to set the value quietly (no event notification) or with notification (default).  You can also use the <code>val</code> property to set the value, but it does not generate an event.
@example
myPot.setVal(5); // sets the knob to 5
*/
	public function setVal (v, q) {
		// clamp desired value to min and max
		v = Math.min(Math.max(v, minVal), maxVal);
		super.setVal(v, q);
	}
	
	// We override the jog's method so we send the value property, not the incremental difference
	private function genEvent(v) {
		eventObj.type = vChg;
		if (snap2Int)
			eventObj.val = Math.round(_val);
		else
			eventObj.val = _val;
		dispatchEvent(eventObj);
	}
	
/**
Given an event string and value that matches what this component would generate, perform the action.
For the potentiometer component, the event is onValChg and the value is the new value.

@method execEvent
@param evName Event name (string) must match the event this component generates
@param evVal (optional) value accompanying the event (if the event has an accompanying value)
@param quiet (optional) set this to true if component should perform the action but not generate an event (this should be false or undefined, unless you know what you are doing)
@example
myPot.execEvent("onValChg", 1); // set the potentiometer to 1
*/
	public function execEvent (evName, evVal, q) {
		if (evName == myEvents[0]) {
			setVal(evVal, q);
		}
		
	}
}

/**
Event generated when jog knob value has changed.
@event onValChg
*/

/**
A Boolean property indicating whether (true) or not (false) to use the hand cursor when the mouse is over the potentiometer's hit area.
@property showHand
*/

/**
A Boolean property indicating whether (true) or not (false) to force the steps to integers.
@property discreteSteps
*/

/**
Number of divisions to draw ticks.
@property numTicks
*/

/**
Number of units in one revolution.
@property units
*/

/**
A String saying whether one clicks-and-drags to turn knob ("drag"), or just by rolling the mouse over ("rollover").
@property dragOrOver
*/

/**
Show the adjuster buttons (true) or not (false).
@property showButs
*/

/**
Potentiometer value (0-units).  This can be used to change the position of the potentiometer immediately, but
it does not generate a value change event.

@property val
*/

/**
Property holding the name of the event generated by this component, by default "onValChg".  This can be
changed in the component property panel or programmatically.

@property vChg
*/



/**
Increments the potentiometer by incr units (positive or negative).  This can be used to simulate turning the potentiometer.

@method incrVal
@param incr Numeric increment to change the potentiometer
@param quietly (optional) Set this to true to make the change without generating an event
@example
myPot.incrVal(2.5);
*/ 


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