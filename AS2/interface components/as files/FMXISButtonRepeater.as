/**
<p>This class implements a simple momentary push button that is capable of
generating repeated, button down events (onPress) given a waiting period and frequency.
Users can change the
appearance by changing the <i>defaultButUp</i> and <i>defaultButDn</i> movie clips
in the Library.</p>
  
<p>The class has six events, by default called:</p>
<li><code>onPress</code> - Generated when button first pressed, and repeated at specified frequency</li>
<li><code>onRelease</code> - Generated when button released</li>
<li><code>onReleaseOutside</code> - Generated when button released outside confines of the hit area</li>
<li><code>onRollOver</code> - Generated when cursor rolls over button hit area</li>
<li><code>onRollOut</code> - Generated when cursor rolls out of button hit area</li>
<li><code>onDragOut</code> - Generated when cursor rolls out of button hit area while left mouse button down</li>

<p>The event names can be changed (if desired) in the component property inspector or on initialization through
the <code>initObject</code> of <code>attachMovie()</code>.</p>

<p>This class inherits from FMXISButton to get basic button capabilities.</p>

@class FMXISButton
@codehint _bRep
@author Jonathan Kaye (FlashSim.com)
@tooltip Simple momentary button with repeat-on-down event
*/
/*
This code was developed by Jonathan Kaye and Amethyst Interactive LLC,
Copyright 2002-2004, all rights reserved.
v2.0, February, 2004
*/
import mx.core.UIObject;
import mx.fmxis.FMXISBase;
import mx.fmxis.FMXISButton;

class mx.fmxis.FMXISButtonRepeater extends FMXISButton {

	var className:String = "FMXISButtonRepeater";
	static var symbolOwner:Object = FMXISButtonRepeater;
	static var symbolName:String = "FMXISButtonRepeater";
	
	/**
	Sets the interval (in milliseconds) between repeated onPress when the button is pressed.  The
	first interval begins after the waiting period (<code>wait4Start</code>).
	@property pulseFreq
	*/
	[Inspectable(name="Pulse Frequency (millisec)", type=Number, defaultValue=100)]
	private var pulseFreq:Number;
	
	/**
	Sets the duration (in milliseconds) to wait after the user has pressed the left mouse button
	and before the button begins to repeat the onPress event.  Note that one onPress event is
	generated immediately when the user first presses the button.  If this value is -1, then
	the button does not repeat onPress events.
	@property wait4Start
	*/
	[Inspectable(name="Wait until Repeat (millisec)", type=Number, defaultValue=250)]
	private var wait4Start:Number;
	
	private var intID:Number; // interval ID for repeating functionality
		
	var clipParameters:Object = { listener:1, evtPress:1, evtRelease:1, evtReleaseOutside:1,
								  evtRollOver:1, evtRollOut:1, evtDragOut:1, pulseFreq:1, wait4Start:1,
								  showHand:1 };
	private static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(FMXISButtonRepeater.prototype.clipParameters, 
                               UIObject.prototype.clipParameters);


	// constructor
	function FMXISButtonRepeater () {
	}
	
	// This method gets called by the UIComponent default.  We just do what our
	// parent does, and set our own values.  We set our values here rather than
	// in the constructor because this method gets called before the constructor!  Weird.
	// If we needed to add events to our parent class, we'd write "super.init([evt1, ...])
	// in which evt1 is the name of the event (string).
	private function init (evts): Void {
		super.init(evts);
		pulseFreq = Math.max(pulseFreq, 10);
	}
	
	// Override FMXISButton's setDown routine to add repeater functionality
	private function setDown (state:Boolean) {
		mcButDown._visible = state;
		mcButUp._visible = !state;
		
		if (state) {
			if (wait4Start != -1) {
				if (intID != undefined) {
					clearInterval(intID);
				}
				intID = setInterval(this, "waitElapse", wait4Start);
			}
		} else	{
			clearInterval(intID);
			intID = undefined;
		}
		
	}

	// Generate a key-down event.  We need this method so we can pass something
	// to setInterval while the button is pressed.
	private function genDownEvent () {
		genEvent(evtPress, true);
	}
	
	// This method is called after the waiting period before repeat has elapsed.
	// If the user releases the button before time's up, then the setInterval
	// is cancelled in setDown(false).
	private function waitElapse () {
		if (intID != null) {
			clearInterval(intID);
		}
	
		intID = setInterval(this, "genDownEvent", pulseFreq);
	}
}

/**
Event generated when user presses the button.
@event onPress
*/

/**
Event generated when user releases the button and the cursor is within the button's hit area.
@event onRelease
*/

/**
Event generated when user releases the button and the cursor is outside the button's hit area.
@event onReleaseOutside
*/

/**
Event generated when user moves the cursor over the button's hit area.
@event onRollOver
*/

/**
Event generated when user moves the cursor from the button's hit area to away from the hit area.
@event onRollOut
*/

/**
Event generated when user moves the cursor from the button's hit area to away from the hit area while holding the left mouse button down.
@event onDragOut
*/

/**
Event name of onPress event. The event names should really only be set at the time the component is instantiated (either
at run-time, or programmatically at the attachMovie/createClassObject time).  However, you can
change it at any time programmatically and the component will use that event name.
@property evtPress
*/
	/**
Event name of onRelease event. The event names should really only be set at the time the component is instantiated (either
at run-time, or programmatically at the attachMovie/createClassObject time).  However, you can
change it at any time programmatically and the component will use that event name.

@property evtRelease
*/

/**
Event name of onReleaseOutside event. The event names should really only be set at the time the component is instantiated (either
at run-time, or programmatically at the attachMovie/createClassObject time).  However, you can
change it at any time programmatically and the component will use that event name.

@property evtReleaseOutside
*/

/**
Event name of onRollOver event. The event names should really only be set at the time the component is instantiated (either
at run-time, or programmatically at the attachMovie/createClassObject time).  However, you can
change it at any time programmatically and the component will use that event name.

@property evtRollOver
*/

/**
Event name of onRollOut event. The event names should really only be set at the time the component is instantiated (either
at run-time, or programmatically at the attachMovie/createClassObject time).  However, you can
change it at any time programmatically and the component will use that event name.

@property evtRollOut
*/

/**
Event name of onDragOut event. The event names should really only be set at the time the component is instantiated (either
at run-time, or programmatically at the attachMovie/createClassObject time).  However, you can
change it at any time programmatically and the component will use that event name.

@property evtDragOut
*/

/**
Boolean property indicating whether or not to display the hand cursor when the cursor is
over the hit area of this component.
@property showHand
*/
	
/**
This method is used to programmatically invoke an action of the component based on
the event passed in.  When a user invokes an action, like presses a button, the button
generates an onPress event.  This method does the opposite -- given an onPress event, this
the method visually depresses the button.  This is typically used to simulate the user invoking the action.

@method execEvent
@param evtName Event name (string) must match the event this component generates
@param evtVal Event value (for button, this value is ignored)
@param quietly Boolean true to invoke action without generating the event, false or not given at all to allow event to be generated
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

/**
Called to invoke action of pressing the button.
@method onPress
@param quietly Boolean property indicating whether or not to suppress the event generation as a
result of the action.  Defaults to false (don't suppress event).
*/

/**
Called to invoke action of releasing the button when the cursor is over the hit area.
@method onRelease
@param quietly Boolean property indicating whether or not to suppress the event generation as a
result of the action.  Defaults to false (don't suppress event).
*/	

/**
Called to invoke action of releasing the button when the cursor has moved outside the hit area.
@method onReleaseOutside
@param quietly Boolean property indicating whether or not to suppress the event generation as a
result of the action.  Defaults to false (don't suppress event).
*/

/**
Called to invoke action of passing the cursor over the button's hit area.
@method onRollOver
@param quietly Boolean property indicating whether or not to suppress the event generation as a
result of the action.  Defaults to false (don't suppress event).
*/

/**
Called to invoke action of passing the cursor away from the button's hit area.
@method onRollOut
@param quietly Boolean property indicating whether or not to suppress the event generation as a
result of the action.  Defaults to false (don't suppress event).
*/

/**
Called to invoke action of passing passing the cursor outside the hit area while the left mouse button is down.
@method onRollOver
@param quietly Boolean property indicating whether or not to suppress the event generation as a
result of the action.  Defaults to false (don't suppress event).
*/