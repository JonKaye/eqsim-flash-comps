/**
<p>This class implements a simple toggle button.  Users can change the
appearance by changing the <i>defaultButTogUp</i> and <i>defaultButTogDn</i> movie clips
in the Library.</p>
  
<p>The class has two events, by default called:</p>
<li><code>onSet</code> - Generated when button goes from up to down position</li>
<li><code>onUnset</code> - Generated when button goes from down to up position</li>

<p>The event names can be changed (if desired) in the component property inspector or on initialization through
the <code>initObject</code> of <code>attachMovie()</code>.</p>

<p>This class inherits from FMXISBase to get listener capabilities.</p>

@class FMXISButtonToggle
@codehint _butTog
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

[IconFile("buttonToggle.png")]
/**
Event generated when button goes from the up to down position.
@event onSet
*/

/**
Event generated when button goes from the down to up position.
@event onUnset
*/

[Event("onSet")]
[Event("onUnset")]
[Event("disabled")]

class mx.fmxis.FMXISButtonToggle extends FMXISBase {

	// bounding box for this button component
	private var boundingBoxClip:MovieClip;
	private var mcButDown:MovieClip;
	private var mcButUp:MovieClip;
	
	var className:String = "FMXISButtonToggle";
	static var symbolOwner:Object = FMXISButtonToggle;
	static var symbolName:String = "FMXISButtonToggle";

	// Inspectable properties.  Let user change the event names, if desired.
	// The event names have to be set at the time the component is instantiated (either
	// at run-time, or programmatically at the attachMovie/createClassObject time).
	
	/**
	Event name for when button is put in the set (down) position.  Change this value
	at any time.
	@property evtSet
	*/
	[Inspectable(name="onSet method name", type=String, defaultValue="onSet")]
	public var evtSet:String;
	/**
	Event name for when button is put in the unset (up) position.  Change this value
	at any time.
	@property evtUnset
	*/	[Inspectable(name="onUnset method name", type=String, defaultValue="onUnset")]
	public var evtUnset:String;
	
	/**
	Whether or not to display the hand cursor when the mouse is over the hit area.
	Defaults to true (must be set in the component property panel).
	@property showHand
	*/
	[Inspectable(name="Show Hand Cursor", type=Boolean, defaultValue=true)]
	private var showHand:Boolean;
	
	/**
	Linkage ID of the button in the set (down) position.  Must be set in the component
	property panel only.
	@property butSetID
	*/
	[Inspectable(name="Button set graphic ID", type=String, defaultValue="")]
	private var butSetID:String;

	/**
	Linkage ID of the button in the unset (up) position.  Must be set in the component
	property panel only.
	@property butUnsetID
	*/
	[Inspectable(name="Button unset graphic ID", type=String, defaultValue="")]
	private var butUnsetID:String;
		
	private var _isUpNow;
	
	/**
	Whether the button is in the up (unset) position -- true -- on first viewing, or
	in the down (set) position -- false.
	@property butIsUp
	*/
	[Inspectable(name="Start in Up Position", type=Boolean, defaultValue=true)]
	public function set butIsUp (f) {
		_isUpNow = f;
		invalidate();
	}
	
	public function get butIsUp () {
		return _isUpNow;
	}
	
	var allowEvents:Boolean;
			
	// event dispatch stuff
	private var dispatchEvent:Function;
	
	// clipParameters - for backward compatibility with Flash 6 player
	var clipParameters:Object = { listener:1, evtSet:1, evtUnset:1, butIsUp:1, showHand:1 };
	private static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(FMXISButtonToggle.prototype.clipParameters, 
                               UIObject.prototype.clipParameters);

	
	static var buttonEvents:Array = new Array("onSet", "onUnset", "disabled");
	
	// by default, use the event names as given by buttonEvents.  We made it a static
	// variable for space efficiency.
	private var myEvents:Array = buttonEvents;
	
	// constructor
	function FMXISButtonToggle () {
	}
	
	private function init (evts): Void {
		// if the user has changed any event names, make sure named listeners are handled
		if (myEvents[0] != evtSet  ||
			myEvents[1] != evtUnset ||
		    evts != null) {
			this.myEvents = new Array(evtSet, evtUnset, "disabled" );
		}
		if (evts != null) {
			if (!(evts instanceof Array)) {
				evts = [ evts ];
			}
			
			super.init(myEvents = myEvents.concat(evts));
			
		} else {
			super.init(myEvents);
		}
		
		this.useHandCursor = this.showHand;
		this.allowEvents = true;
		
		attachChildren(butUnsetID, butSetID);
		
	}
	
	private function attachChildren (up, down) {
		if (up == undefined || up == "") {
			up = "defaultButTogUp";
		}
		if (down == undefined || down == "") {
			down = "defaultButTogDn";
		}
		attachMovie(down, "mcButDown", 1);
		attachMovie(up, "mcButUp", 2);
	}
	
	private function draw () {
		setDown(!_isUpNow);
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
			dispatchEvent(eventObj);
			return;
		}
		setDown(_isUpNow);
		if (!q) {
			eventObj.type = (_isUpNow ? evtUnset : evtSet);
			dispatchEvent(eventObj);
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
				setDown(false);
				onPress(q);
				break;
				
			case myEvents[1]:
				setDown(true);
				onPress(q);
				break;
		}
	}


	private function setDown (state:Boolean) {
		mcButDown._visible = state;
		mcButUp._visible = !state;
		_isUpNow = !state;
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