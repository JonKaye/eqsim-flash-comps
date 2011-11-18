/**
<p>This class implements a continuous-valued joystick.  The joystick x,y values range from
<code>-maxVal</code> to <code>maxVal</code>, with 0 being the center.  The graphics should be set such that
hot spot is in the topmost position and the stick is fully extended upwards.  The
joystick uses these pixel values to compute its possible range.</p>

<p>The routines allow the user to move the hot spot and the stick is rotated to the proper
angle and scaled, from 0 (at center pos) to its fully extended position at
<code>maxVal</code> (which the user can set).  Whenever the joystick is not in the center
position, it generates an event (pulse), at a given frequency.  A property, <code>forceInt</code>, says whether
to report the value as a floating point number or rounded integer.  The default event
message is "onJChg".  When the user releases the joystick and it has returned to the center position, it generates a second
event, by default, "onJReturned" (in addition to the <code>onJChg</code> event with coordinates
[0, 0]).  Note that if the user does not release the joystick and passes over (0, 0), then the
onJChg event is generated by not onJReturned.</p>
 
<p>The joystick snaps back to the center when it released, and a coefficient says
how quickly this happens.</p>

<p>The joystick can be controlled using the mouse or programmatically.  To use the mouse,
the user drags the hotspot.  To use it programmatically, the caller invokes <code>moveHS</code>
with a single argument (non-undefined), then uses <code>setVec()</code> to set the vector, and
when done, uses <code>stopMoveHS</code> to release the joystick.</p>

<p>You can change the graphics by modifying the following clips:</p>
 
<li><code>defJStkBase</code> - background graphic for the joystick</li>
<li><code>defJStkHotSpot</code> - handle (hot spot) for the joystick</li>
<li><code>defJStkStick</code> - stick of the joystick</li>
 
This class inherits from FMXISBase to get listener capabilities.

@class FMXISJoystick
@codehint _joystick
@author Jonathan Kaye (FlashSim.com)
@tooltip Simple joystick
*/
/*
This code was developed by Jonathan Kaye and Amethyst Interactive LLC,
Copyright 2002-2004, all rights reserved.
v2.0, February, 2004
*/
import mx.fmxis.FMXISBase;
import mx.core.UIObject;

[IconFile("joystick.png")]

[Event("onJChg")]
[Event("onJPulse")]
[Event("onJReturned")]
[Event("onJStart")]
[Event("onJReleased")]
[Event("disabled")]

/**
Event generated when joystick is away from the center position, at the specified
pulse frequency.
@event onJPulse
*/

/**
Event generated when joystick changes position -- either being moved, or on its way
back to center after being released.
@event onJChg
*/

/**
Event generated when the user (or programmatic control) starts to move the joystick.
@event onJStart
*/

/**
Event generated when the user (or programmatic control) releases the joystick.
@event onJReleased
*/

/**
Event generated when the joystick has returned to the center position.
@event onJReturned
*/
 
	class mx.fmxis.FMXISJoystick extends FMXISBase {
	
	// bounding box for this joystick component
	private var boundingBoxClip:MovieClip;
	private var hs:MovieClip;
	private var stk:MovieClip;
	private var bkgnd:MovieClip;
	
	var className:String = "FMXISJoystick";
	static var symbolOwner:Object = FMXISJoystick;
	static var symbolName:String = "FMXISJoystick";
	
	// Inspectable properties.  Let user change the event names, if desired.
	// The event names have to be set at the time the component is instantiated (either
	// at run-time, or programmatically at the attachMovie/createClassObject time).
	/**
	The event name for the joystick value change event.
	@property evtJChg
	*/
	[Inspectable(name="onJChg method name", type=String, defaultValue="onJChg")]
	public var evtJChg:String;
	
	[Inspectable(name="onJPulse method name", type=String, defaultValue="onJPulse")]
	public var evtJPulse:String;
	
	/**
	The event name for the joystick "returned to center" event.  This event is
	generated when the joystick has been released by the user and it has returned to the center position (0, 0).
	@property evtJReturned
	*/
	[Inspectable(name="onJReturned method name", type=String, defaultValue="onJReturned")]
	public var evtJReturned:String;

	/**
	The event name for the joystick "begin movement".  This event is
	generated when the joystick has been engaged.
	@property evtJStart
	*/
	[Inspectable(name="onJStart method name", type=String, defaultValue="onJStart")]
	public var evtJStart:String;
	
	/**
	The event name for the event generated when the user releases the joystick.
	@property evtJReleased
	*/
	[Inspectable(name="evtJReleased method name", type=String, defaultValue="evtJReleased")]
	public var evtJReleased:String;

	
	[Inspectable(name="Base linkage ID", type=String, defaultValue="")]
	public var baseID:String;
	[Inspectable(name="Stick linkage ID", type=String, defaultValue="")]
	public var stickID:String;
	[Inspectable(name="Hot spot linkage ID", type=String, defaultValue="")]
	public var hsID:String;
	
	/**
	Any value less than this is considered zero.  This is used so the person
	doesn't have to hit 0 exactly.  Usually about 5-10% of <code>maxVal</code>.
	
	@property centerEPS
	*/
	[Inspectable(name="Center allowance", type=Number, defaultValue=2)]
	public function set centerEPS (v) {
		_centerEPS = v;
		resetCenter();
	}
	public function get centerEPS () {
		return _centerEPS;
	}
	private var _centerEPS:Number;
	
	/**
	Whether or not the vector values generated in joystick events should be rounded to integers.
	
	@property forceInt
	*/
	[Inspectable(name="Force values to integer", type=Boolean, defaultValue=true)]
	public var forceInt:Boolean;

	/**
	Coefficient (between 0 and 1, inclusive) that determines how slowly the joystick
	returns to center once released.  0 is instantaneous, 1 means the joystick remains
	in the position left when the joystick was released (ultimate stickiness!).
	
	@property kSticky
	*/
	[Inspectable(name="Stickiness (0-1)", type=Number, defaultValue=0.6)]
	public function set kSticky (v) {
		_kSticky = Math.min(1, Math.max(0, v));
	}
	public function get kSticky () {
		return _kSticky;
	}
	private var _kSticky:Number;

	/**
	Frequency of events generated when the joystick is away from center position.
	
	@property pulseFreq
	*/
	[Inspectable(name="Event pulse frequency (msec)", type=Number, defaultValue=100)]
	public function set pulseFreq (v) {
		chgPulseFreq(v);
	}
	
	public function get pulseFreq () {
		return _pulseFreq;
	}
	public var _pulseFreq:Number;
	public var _pulseID:Number;
	
	/**
	Maximum value for the vector coordinates when the joystick is at full extension.  The
	joystick center is always 0 (for both x and y coordinates), and this property sets
	the maximum value for the coordinate.  The maximum is used to set positive and negative
	extent, so joystick range will be (-maxVal,-maxVal) to (maxVal, maxVal).
	
	@property maxVal
	*/
	[Inspectable(name="Max value", type=Number, defaultValue=100)]
	public function set maxVal (v) {
		_maxVal = v;
		resetCenter();
	}
	public function get maxVal () {
		return _maxVal;
	}
	private var _maxVal:Number;
	
	/**
	Boolean property indicating whether or not to display the hand cursor when the cursor is
	over the hit area of this component.
	@property showHand
	*/
	[Inspectable(name="Show Hand Cursor", type=Boolean, defaultValue=true)]
	public function set showHand (f) {
		useHandCursor = f;
		_showHand = f;
	}
	public function get showHand () {
		return(_showHand);
	}
	private var _showHand:Boolean;
	
	
	// event dispatch stuff
	private var dispatchEvent:Function;

	var allowEvents:Boolean;
		
	// clipParameters - for backward compatibility with Flash 6 player
	var clipParameters:Object = { listener:1, evtJChg:1, evtJReturned:1, 
								  evtJReleased:1, evtJStart:1, evtJPulse:1,
								  maxVal:1, forceInt:1, baseID:1, stickID:1, hsID:1,
								  centerEPS:1, kSticky:1, pulseFreq:1, showHand:1 };
	private static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(FMXISJoystick.prototype.clipParameters, 
                               UIObject.prototype.clipParameters);
	
	static var jstickEvents:Array = new Array("onJChg", "onJPulse", "onJReturned", "onJStart", "evtJReleased", "disabled");
	
	// by default, use the event names as given by jstickEvents.  We made it a static
	// variable for space efficiency.
	private var myEvents:Array = jstickEvents;
	
	function FMXISJoystick () {
	}
	
	
	// ptObj used to return x,y value to listeners
	private var ptObj:Object = { x : 0, y : 0 };
	
	// exact position of hotspot
	private var hsExactX:Number;
	private var hsExactY:Number;
	
	private var limit:Number;
	
	private var centerPx:Number;
	private var stickLen:Number;
	
	private var zeroCall:Boolean;
	private var active:Boolean;

	
	// =============================================================
	// PUBLIC METHODS
	
	/**
	Returns the vector position of the joystick, in an object with x and y properties.  Note that
	the object is reused for subsequent calls to <code>getVec()</code>, so you should copy the
	values if you need to store them for any reason.
	@method getVec
	*/
	public function getVec () {
		ptObj.x = (hsExactX / limit) * _maxVal;
		ptObj.y = (-hsExactY / limit) * _maxVal;
		return ptObj;
	}
	
	/**
	Sets the joystick to the given vector.  Must be preceded by call to moveHS if joystick is
	being moved programmatically.
	@method setVec
	@param x x-coordinate position (<code>-maxVal</code> to <code>maxVal</code>)
	@param y y-coordinate position (<code>-maxVal</code> to <code>maxVal</code>)
	*/
	public function setVec (x, y) {
		setXY(( x / _maxVal ) * limit, ( -y / _maxVal ) * limit);
	}
	
	
	// Resets what is considered the zero (center) point
	private function resetCenter () {
		// set the center allowance in pixels (less than this amt is considered 0)
		centerPx = (_centerEPS / _maxVal) * limit;
	}

	
	/**
	Initialize moving of hot spot.  Developers use this only when moving the joystick programmatically.
	Use <code>setVec()</code> to set the position, after calling <code>moveHS()</code>, then call
	<code>stopMoveHS</code> when you are finished moving the joystick (make sure the pass the argument
	as <code>true</code>).
	@method moveHS
	@param noMouse Set this to true if you are moving the joystick programmatically.
	@param quiet Set this to true to not generate an onJStart event
	*/
	// Start tracking movement of the joystick.  The arg noMouse is a hook to allow the joystick to be
	// controlled programmatically, so the code can then call setXY and when done, call stopMoveHS
	// We need 'ref' to tell us how to refer to the joystick class, since during mouse moves
	// the 'this' refers to hs, and simulated moves 'this' refers to joystick.  This is due
	// to what I call a Flash scoping design error, but Macromedia says it is not.
	public function moveHS (noMouse, q) {
		var ref = (noMouse == undefined ? _parent : this);
		
		if (!ref.allowEvents) {
			ref.eventObj.type = "disabled";
			ref.dispatchEvent(ref.eventObj);
			return;
		}
		
		if (noMouse == undefined)
			onMouseMove = ref.trackHS;
		
		if (!q) {
			// Generate start joystick move event
			ref.eventObj.type = ref.evtJStart;
			ref.dispatchEvent(ref.eventObj);
		}
		
		delete ref.hs.onEnterFrame;
		if (ref._pulseID == undefined)
			ref._pulseID = setInterval(ref, "genPulse", ref._pulseFreq);
			
		active = true;
	}
	
	/**
	Stop tracking movement of the joystick.  The arg noMouse is a hook to allow the joystick to be
	controlled programmatically.
	@method stopMoveHS
	@param noMouse Set this to true if you are moving the joystick programmatically.
	@param quiet Set this to true to not generate an onJReleased event
	*/
	function stopMoveHS(noMouse, quiet) {
		var ref = (noMouse == undefined ? _parent : this);

		if (!ref.allowEvents) {
			return;
		}
				
		if (noMouse == undefined)
			delete ref.hs.onMouseMove;
		if (ref.kSticky < 1) {
			// Return to center unless joystick supposed to stick
			ref.hs.onEnterFrame = ref.return2Center;
			
			if (!quiet) {
				ref.computeJPosition();
				ref.eventObj.type = ref.evtJReleased;
				ref.eventObj.val = ref.ptObj;
				ref.dispatchEvent(ref.eventObj);
			}
		}
	}
	
	
	private function chgPulseFreq (pf) {
		_pulseFreq = pf;

		if (active) {
			clearInterval(_pulseID);
			if (pf != -1) {
				_pulseID = setInterval(this, "genPulse", _pulseFreq);
			}
		}
	}
	
	// =============================================================
	// INTERNAL METHODS
	
	private function attachChildren () {
		var bs = "defJStkBase", stk = "defJStkStick", htspt = "defJStkHotSpot";
		
		if (baseID != "" && baseID != undefined) {
			bs = baseID;
		}
		if (stickID != "" && stickID != undefined) {
			stk = stickID;
		}
		if (hsID != "" && hsID != undefined) {
			htspt = hsID;
		}		
		attachMovie(bs, "bkgnd", 1);
		attachMovie(stk, "stk", 2);
		attachMovie(htspt, "hs", 3);
	}
	
	// initialize the joystick graphic
	private function init(evts) {
		
		// if the user has changed any event names, make sure named listeners are handled
		if (myEvents[0] != evtJChg  ||
			myEvents[1] != evtJPulse  ||
			myEvents[2] != evtJReturned ||
			myEvents[3] != evtJStart ||
			myEvents[4] != evtJReleased ||
		    evts != null) {
			myEvents = new Array(evtJChg, evtJPulse, evtJReturned, evtJStart, evtJReleased, "disabled");
		}
		if (evts != null) {
			if (!(evts instanceof Array)) {
				evts = [ evts ];
			}
			
			super.init(myEvents = myEvents.concat(evts));
			
		} else {
			super.init(myEvents);
		}
		
		useHandCursor = _showHand;
		allowEvents = true;
		
		attachChildren();
	
		// record joystick limit based on end position of joystick stick
		hs._x = 0;
		hs._y = -stk._height;
		limit = Math.sqrt(hs._x * hs._x + hs._y * hs._y);
		stickLen = stk._height;
		
		resetCenter();  // reset what is considered center position
		active = false; // joystick starts at rest
		
		// set in center (start) position.  We use hsExactX and hsExactY because
		// hs is limited in resolution to screen position. This messes up exact
		// setting when the user sets the position programmatically.  Therefore,
		// we keep track of the exact location for the hot spot and use that in
		// calculations in place of the hs movie clip spot.
		hs._x = hs._y = hsExactX = hsExactY = 0;
		zeroCall = false;
		setStick();
		
		hs.onPress = moveHS;
		hs.onRelease = hs.onReleaseOutside = stopMoveHS;
		
		hs.useHandCursor = showHand;
	}
	
	// Using the position of the hot spot, rotate the stick and scale it based on distance
	// from center.  We compute the rotation angle using the dot product of the upright
	// vector (in screen coords, (0, -1)) and the mouse position.
	private function setStick () {
		var hsx = hs._x, hsy = hs._y, sum, angle, vdot;
			sum = Math.sqrt(hsx * hsx + hsy * hsy);
			
		if (sum != 0) {
			hsy /= sum;
			// dot product gives us the angle between vectors (upright and mouse position)
			// vdot = hsx*nx + hsy*ny; but we can simplify because nx = 0 and ny = -1.
			vdot = -hsy;
			// convert from radians to degrees
			angle = 57.2957795130823 * Math.acos(vdot);
			if (hsx < 0)
				angle *= -1;
			
			stk._rotation = angle;
		}
		stk._yscale = 100 * (sum / stickLen);
	}
	
	
	// Routine that brings the joystick back to the center (0) position
	private function return2Center() {
		var x = _parent.hs._x, y = _parent.hs._y, coeff, len;
		
		len = Math.sqrt(x*x + y*y);
		if (len < _parent.centerPx) {
			coeff = 0;
		} else {
			coeff = _parent.kSticky;
		}
	
		_parent.hs._x = _parent.hsExactX = coeff * x;
		_parent.hs._y = _parent.hsExactY = coeff * y;
		_parent.setStick();
		if (coeff == 0) {
			active = false;

			// When joystick reaches center, stop reporting values
			delete onEnterFrame;
			_parent.genPulse(true); // Generate a final pulse			
			with (_parent) {
				clearInterval(_pulseID);
				_pulseID = undefined;
				eventObj.type = evtJReturned;
				eventObj.val = undefined;
				dispatchEvent(eventObj);
			}
		} else {
			_parent.genPulse(true);
		}
	}
	
	// Called while the user is moving the hot spot.  We have to write 'this._parent'
	// all over because the method is being called with this referring to hs, which I
	// believe is a Flash scoping design error (Macromedia says it is a feature).
	private function trackHS () {
		_parent.setXY(_parent._xmouse, _parent._ymouse);
		_parent.genPulse(true);
	}
	
	
	// (internal routine)
	// Given a vector (as an XY coordinate), set the joystick along that direction.
	// The XY do not necessarily have to be within the range of the joystick -- it
	// will limit its length automatically.
	private function setXY (x, y) {
		var vLen, vX, vY, vL;

		// we compute the vector to the mouse.  We set the hotspot to the minimum of
		// that position or the joystick boundary given by distance 'limit'.
		vLen = Math.sqrt(x*x + y*y);
		// check if joystick is close enough to 0
		if (vLen < centerPx) {
			vL = vX = vY = 0;
		} else {
			vX = x / vLen;
			vY = y / vLen;
			vL = Math.min(vLen, limit);
		}

		hs._x = hsExactX = vL * vX;
		hs._y = hsExactY = vL * vY;
		
		setStick();
	}
	
	private function genPulse (chg) {
		// Tell any listeners about the change, but don't repeat once hits (0, 0)
		computeJPosition();
		
		if (zeroCall || ptObj.x != 0 || ptObj.y != 0) {
			eventObj.type = (chg ? evtJChg : evtJPulse);
			eventObj.val = ptObj;
			if (!chg) {
				var x = 5;
			}
			dispatchEvent(eventObj);
			// zeroCall says whether joystick is at 0
			zeroCall = (ptObj.x != 0 || ptObj.y != 0);
		}
	}
	
	// Compute the joystick position
	private function computeJPosition () {
		var xp = hsExactX, yp = hsExactY;
		
		ptObj.x = _maxVal * (xp / limit);
		ptObj.y = - _maxVal * (yp / limit);
	
		if (forceInt) {
			ptObj.x = Math.round(ptObj.x);
			ptObj.y = Math.round(ptObj.y);
		}
	}
	
	/**
	This method is used to programmatically invoke an action of the component based on
	the event passed in.  When a user invokes an action, like presses a button, the button
	generates an onPress event.  This method does the opposite -- given an onPress event, this
	the method visually depresses the button.  This is typically used to simulate the user invoking the action.
	
	@method execEvent
	@param evtName Event name (string) must match the event this component generates
	@param evtVal Event value (for joystick, this value is an object with an x and y property)
	@param quietly Boolean true to invoke action without generating the event, false or not given at all to allow event to be generated.  This is only respected for the onJReturned event, since onJChg is triggered at the pulse interval not as a result of setting the joystick vector
	*/
	function execEvent (evtName, evtVal, q) {
		switch (evtName) {
			case myEvents[0]:
				setVec(evtVal.x, evtVal.y);
				break;
				
			case myEvents[2]:
				setVec(0, 0);
				if (!q) {
					eventObj.type = evtJReturned;
					eventObj.val = undefined;
					dispatchEvent(eventObj);
				}
				break;
				
			case myEvents[3]:
				moveHS(true, q);
				break;
				
			case myEvents[4]:
				stopMoveHS(true, q);
				break;
		}
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