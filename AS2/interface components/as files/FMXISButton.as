/**
<p>This class implements a simple momentary push button.  Users can change the
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
<p>This class inherits from FMXISBase to get listener capabilities.</p>

@class FMXISButton
@codehint _button
@author Jonathan Kaye (FlashSim.com)
@tooltip Simple momentary button
*/ 
/*
This code was developed by Jonathan Kaye and Amethyst Interactive LLC,
Copyright 2002-2004, all rights reserved.
v2.0, February, 2004
*/
import mx.core.UIObject;
import mx.fmxis.FMXISBase;


[Event("onPress")]
[Event("onRelease")]
[Event("onReleaseOutside")]
[Event("onRollOver")]
[Event("onRollOut")]
[Event("onDragOut")]
[Event("disabled")]

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


class mx.fmxis.FMXISButton extends FMXISBase {

	// bounding box for this button component
	private var boundingBoxClip:MovieClip;
	private var mcButDown:MovieClip;
	private var mcButUp:MovieClip;
	
	var className:String = "FMXISButton";
	static var symbolOwner:Object = FMXISButton;
	static var symbolName:String = "FMXISButton";
	
	// Inspectable properties.  Let user change the event names, if desired.
	// The event names should really only be set at the time the component is instantiated (either
	// at run-time, or programmatically at the attachMovie/createClassObject time).
	/**
	Event name of onPress event. The event names should really only be set at the time the component is instantiated (either
	at run-time, or programmatically at the attachMovie/createClassObject time).  However, you can
	change it at any time programmatically and the component will use that event name.
	@property evtPress
	*/
	[Inspectable(name="onPress method name", type=String, defaultValue="onPress")]
	public var evtPress:String;
	/**
	Event name of onRelease event. The event names should really only be set at the time the component is instantiated (either
	at run-time, or programmatically at the attachMovie/createClassObject time).  However, you can
	change it at any time programmatically and the component will use that event name.

	@property evtRelease
	*/
	[Inspectable(name="onRelease method name", type=String, defaultValue="onRelease")]
	public var evtRelease:String;
	/**
	Event name of onReleaseOutside event. The event names should really only be set at the time the component is instantiated (either
	at run-time, or programmatically at the attachMovie/createClassObject time).  However, you can
	change it at any time programmatically and the component will use that event name.

	@property evtReleaseOutside
	*/
	[Inspectable(name="onReleaseOutside method name", type=String, defaultValue="onReleaseOutside")]
	public var evtReleaseOutside:String;
	/**
	Event name of onRollOver event. The event names should really only be set at the time the component is instantiated (either
	at run-time, or programmatically at the attachMovie/createClassObject time).  However, you can
	change it at any time programmatically and the component will use that event name.

	@property evtRollOver
	*/
	[Inspectable(name="onRollOver method name", type=String, defaultValue="onRollOver")]
	public var evtRollOver:String;
	/**
	Event name of onRollOut event. The event names should really only be set at the time the component is instantiated (either
	at run-time, or programmatically at the attachMovie/createClassObject time).  However, you can
	change it at any time programmatically and the component will use that event name.

	@property evtRollOut
	*/
	[Inspectable(name="onRollOut method name", type=String, defaultValue="onRollOut")]
	public var evtRollOut:String;
	/**
	Event name of onDragOut event. The event names should really only be set at the time the component is instantiated (either
	at run-time, or programmatically at the attachMovie/createClassObject time).  However, you can
	change it at any time programmatically and the component will use that event name.

	@property evtDragOut
	*/
	[Inspectable(name="onDragOut method name", type=String, defaultValue="onDragOut")]
	public var evtDragOut:String;
	
	
	/**
	Boolean property indicating whether or not to display the hand cursor when the cursor is
	over the hit area of this component.
	@property showHand
	*/
	[Inspectable(name="Show Hand Cursor", type=Boolean, defaultValue=true)]
	public function set showHand (f) {
		this.useHandCursor = f;
		_showHand = f;
	}
	public function get showHand () {
		return(_showHand);
	}
	private var _showHand:Boolean;
	
	public var allowEvents:Boolean;
			
	// event dispatch stuff
	private var dispatchEvent:Function;
	
	// clipParameters - for backward compatibility with Flash 6 player
	var clipParameters:Object = { listener:1, evtPress:1, evtRelease:1, evtReleaseOutside:1,
								  evtRollOver:1, evtRollOut:1, evtDragOut:1, showHand:1 };
	private static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(FMXISButton.prototype.clipParameters, 
                               UIObject.prototype.clipParameters);

	
	static var buttonEvents:Array = new Array("onPress", "onRelease", "onReleaseOutside",
											  "onRollOver", "onRollOut", "onDragOut", "disabled");
	
	// by default, use the event names as given by buttonEvents.  We made it a static
	// variable for space efficiency.
	private var myEvents:Array = buttonEvents;
	
	// constructor
	function FMXISButton () {
		setDown(false);
	}
	
	private function init (evts): Void {
		// if the user has changed any event names, make sure named listeners are handled
		if (myEvents[0] != evtPress  ||
			myEvents[1] != evtRelease ||
			myEvents[2] != evtReleaseOutside ||
		    myEvents[3] != evtRollOver ||
		    myEvents[4] != evtRollOut ||
		    myEvents[5] != evtDragOut ||
		    evts != null) {
			this.myEvents = new Array(evtPress, evtRelease, evtReleaseOutside, evtRollOver, evtRollOut, evtDragOut, "disabled" );
		}
		if (evts != null) {
			if (!(evts instanceof Array)) {
				evts = [ evts ];
			}
			
			super.init(myEvents = myEvents.concat(evts));
			
		} else {
			super.init(myEvents);
		}
		
		this.useHandCursor = _showHand;
		allowEvents = true;
		
		attachChildren();
	}
	
	private function attachChildren (up, down) {
		if (down != false)
			attachMovie("defaultButDn", "mcButDown", 2);
		if (up != false)
			attachMovie("defaultButUp", "mcButUp", 1);
	}
	
	/**
	Called to invoke action of pressing the button.
	@method onPress
	@param quietly Boolean property indicating whether or not to suppress the event generation as a
	result of the action.  Defaults to false (don't suppress event).
	*/
	function onPress (q:Boolean) {
		if (!allowEvents) {
			eventObj.type = "disabled";
			eventObj.val = evtPress;
			dispatchEvent(eventObj);
			return;
		}
		setDown(true);
		if (!q) {
			genEvent(evtPress, true);
		}
	}
	
	/**
	Called to invoke action of releasing the button when the cursor is over the hit area.
	@method onRelease
	@param quietly Boolean property indicating whether or not to suppress the event generation as a
	result of the action.  Defaults to false (don't suppress event).
	*/	
	function onRelease (q) {
		if (!allowEvents) {
			eventObj.type = "disabled";
			eventObj.val = evtRelease;
			dispatchEvent(eventObj);
			return;
		}
		setDown(false);
		if (!q) {
			genEvent(evtRelease, false);
		}
	}
	
	/**
	Called to invoke action of releasing the button when the cursor has moved outside the hit area.
	@method onReleaseOutside
	@param quietly Boolean property indicating whether or not to suppress the event generation as a
	result of the action.  Defaults to false (don't suppress event).
	*/
	function onReleaseOutside (q) {
		if (!allowEvents) {
			eventObj.type = "disabled";
			eventObj.val = evtReleaseOutside;
			dispatchEvent(eventObj);
			return;
		}
		setDown(false);
		if (!q) {
			genEvent(evtReleaseOutside, false);
		}
	}
	
	/**
	Called to invoke action of passing the cursor over the button's hit area.
	@method onRollOver
	@param quietly Boolean property indicating whether or not to suppress the event generation as a
	result of the action.  Defaults to false (don't suppress event).
	*/
	function onRollOver (q) {
		if (!allowEvents) {
			eventObj.type = "disabled";
			eventObj.val = evtRollOver;
			dispatchEvent(eventObj);
			return;
		}
		if (!q) {
			genEvent(evtRollOver, false);
		}
	}
	
	/**
	Called to invoke action of passing the cursor away from the button's hit area.
	@method onRollOut
	@param quietly Boolean property indicating whether or not to suppress the event generation as a
	result of the action.  Defaults to false (don't suppress event).
	*/
	function onRollOut (q) {
		if (!allowEvents) {
			eventObj.type = "disabled";
			eventObj.val = evtRollOut;
			dispatchEvent(eventObj);
			return;
		}
		if (!q) {
			genEvent(evtRollOut, false);
		}
	}
	
	/**
	Called to invoke action of passing passing the cursor outside the hit area while the left mouse button is down.
	@method onRollOver
	@param quietly Boolean property indicating whether or not to suppress the event generation as a
	result of the action.  Defaults to false (don't suppress event).
	*/
	function onDragOut (q) {
		if (!allowEvents) {
			return;
		}
		if (!q) {
			genEvent(evtDragOut, false);
		}
	}
	
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
	function execEvent (evtName, evtVal, q) {
		switch (evtName) {
			case myEvents[0]:
				onPress(q);
				break;
				
			case myEvents[1]:
				onRelease(q);
				break;
			
			case myEvents[2]:
				onReleaseOutside(q);
				break;
				
			case myEvents[3]:
				onRollOver(q);
				break;

			case myEvents[4]:
				onRollOut(q);
				break;
			
			case myEvents[5]:
				onDragOut(q);
				break;
		}
	}

	// Sets the graphics to the appropriate visual state, up or down
	private function setDown (state:Boolean) {
		mcButDown._visible = state;
		mcButUp._visible = !state;
	}
	
	// broadcasts the given event
	private function genEvent (msg:String, upState:Boolean) {
		eventObj.type = msg;
		eventObj.down = upState;
		dispatchEvent(eventObj);
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