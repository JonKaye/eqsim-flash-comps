/**
<p>This class implements a simple jog.  Developers can set the increment, number of positions
in one cycle, integer vs. discrete, and whether the jog is adjusted by clicking and dragging,
or merely moving in a circular motion (<code>dragOrOver</code>).</p>

Developers can change the appearance by modifying:
<li><code>defJogBkgnd</code> - background</li>
<li><code>defJogIndicator</code> - indicator clip</li>
<li><code>defJogIncr</code> - Increment button (increments by 1 unit)</li>
<li><code>defJogDecr</code> - Decrement button (decrements by 1 unit)</li>

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
the value is the increment that
the jog was moved.  The <code>drawTicks</code> property, if true, tells the component
to draw <code>numTicks</code> ticks.</p>

<p>The position of the jog indicator can be set using the <code>val</code> property.</p>
 
<p>This class inherits from <code>FMXISBase</code> to get listener capabilities.</p>

@class FMXISJog
@codehint _jog
@author Jonathan Kaye (FlashSim.com)
@tooltip Jog knob
*/
/*
This code was developed by Jonathan Kaye and Amethyst Interactive LLC,
Copyright 2002-2004, all rights reserved.
v2.0, February, 2004
*/
/*
Programmer's Note:
From a programming view, this component is a great example of an issue in
Flash regarding scoping.  We use the background graphic as the clip receiving the mouse
events, yet we define the methods at the level of the component (one higher than the
background, since the background is attached).  Therefore, in several methods, even
though they are defined at the level of the component, we know that "this"
will come in scoped to the background graphic, so to access the component properties,
we have to use this._parent.  We think this is a nice example of Flash's dynamic scoping
causing problems, as Flash does not preserve the scope (context) when methods
are assigned to variables.
*/


import mx.core.UIObject;
import mx.fmxis.FMXISBase;

[IconFile("jog.png")]

/**
Event generated when jog knob value has changed.
@event onValChg
*/
[Event("onValChg")]
[Event("disabled")]

class mx.fmxis.FMXISJog extends FMXISBase {

	// bounding box for this button component
	private var boundingBoxClip:MovieClip;
	private var tickClip:MovieClip;
	private var bkgnd:MovieClip;
	private var ind:MovieClip;
	private var rotIncr:MovieClip;
	private var rotDecr:MovieClip;
		
	var className:String = "FMXISJog";
	static var symbolOwner:Object = FMXISJog;
	static var symbolName:String = "FMXISJog";

	// Inspectable properties.
	
	// Let user change the event names, if desired.
	// The event name has to be set at the time the component is instantiated (either
	// at run-time, or programmatically at the attachMovie/createClassObject time).
	[Inspectable(name="onValChg method name", type=String, defaultValue="onValChg")]
	public var vChg:String;
	
	// Whether interaction is by click-and-drag (true) or roll-over (false)
	[Inspectable(name="Turn by drag or rollover", type=String, defaultValue="drag", enumeration="drag,rollover")]
	private var dragOrOver:Boolean;
		
	// Whether jog moves in discrete steps or continuous
	[Inspectable(name="Discrete steps", type=Boolean, defaultValue=false)]
	public function set discreteSteps(f) {
		_discreteSteps = f;
		setVal(_val, true);
	}
	public function get discreteSteps () {
		return _discreteSteps;
	}
	private var _discreteSteps:Boolean;
			
	// Whether or not to show the tick marks
	[Inspectable(name="Show tick marks", type=Boolean, defaultValue=false)]
	public function set showTicks (f) {
		_showTicks = f;
		if (f) {
			drawTicks();
		}
		tickClip._visible = f;
	}
	public function get showTicks () {
		return _showTicks;
	}
	private var _showTicks:Boolean;
	
	// Whether or not to show the tick marks
	[Inspectable(name="Num of tick marks", type=Number, defaultValue=12)]
	public function set numTicks (n) {
		_numTicks = n;
		if (_showTicks) {
			drawTicks();
		}
	}
	public function get numTicks () {
		return _numTicks;
	}
	private var _numTicks:Number;
	
	// Units in one revolution
	[Inspectable(name="Num of units in 1 revolution", type=Number, defaultValue=12)]
	public function set units (v:Number) {
		_units = v;
		setVal(_val, true);
	}
	public function get units () {
		return (_units);
	}
	private var _units:Number;
	
	// Starting value
	[Inspectable(name="Starting position", type=Number, defaultValue=0)]
	public function set val (v:Number) {
		setVal(v, true);
	}
	public function get val () {
		return (_val);
	}
	private var _val:Number;

	[Inspectable(name="Snap to integer?", type=Boolean, defaultValue=false)]
	public var snap2Int:Boolean;
	
	[Inspectable(name="Indicator Linkage ID", type=String)]
	private var indLinkID:String;
	
	[Inspectable(name="Background Linkage ID", type=String)]
	private var bkgndLinkID:String;

	
	// Audio click on change
	[Inspectable(name="Linkage ID of audio click", type=String, defaultValue="")]
	public function set clickSnd (s) {
		setClickSound(s);
		_clickSnd = s;
	}
	public function get clickSnd () {
		return _clickSnd;
	}
	private var _clickSnd:String;
	private var sndObj:Sound;
	
	// Show or hide the increase and decrease buttons
	[Inspectable(name="Show incr/decr buttons", type=Boolean, defaultValue=false)]
	public function set showButs (f) {
		rotIncr._visible = rotDecr._visible = _showButs = f;
	}
	public function get showButs () {
		return (_showButs);
	}
	private var _showButs:Boolean;
	
	// Show or hide the hand cursor
	[Inspectable(name="Use hand cursor", type=Boolean, defaultValue=true)]
	private var showHand:Boolean;
	
	// Show or hide the background
	[Inspectable(name="Show background", type=Boolean, defaultValue=true)]
	private var showBkgnd:Boolean;
	
	var allowEvents:Boolean;
	
	static var JogEvent = new Array("onValChg", "disabled");
	
	// by default, use the event names as given by JogEvent.  We made it a static
	// variable for space efficiency.
	private var myEvents = JogEvent;
	
	// Values used internally to manipulate jog
	private var holdAng:Number;
	private var baseAng:Number;
	private var oldAng:Number;
	private var valPriv:Number;
	private var lastIntVal:Number;
	private var _beginVal:Number;
	
	// clipParameters - for backward compatibility with Flash 6 player
	var clipParameters:Object = { listener:1, vChg:1, showBkgnd:1, showHand:1,
								  showButs:1, clickSnd:1, units:1, numTicks:1, showTicks:1,
								  dragOrOver:1, snap2Int:1, discreteSteps:1, val:1, bkgndLinkID:1, indLinkID:1 };
	private static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(FMXISJog.prototype.clipParameters, 
                               UIObject.prototype.clipParameters);

	// constructor
	function FMXISJog () {
	}
	
	// initialize the events for the jog, the jog element clips, and the default values
	private function init (evts): Void {
	
		// if the user has changed any event names, make sure named listeners are handled
		if (myEvents[0] != vChg  ||
		    evts != null) {
			this.myEvents = [ vChg, "disabled" ];
		}
		if (evts != null) {
			if (!(evts instanceof Array)) {
				evts = [ evts ];
			}
			
			super.init(myEvents = myEvents.concat(evts));
			
		} else {
			super.init(myEvents);
		}
		
		attachChildren();
		
		// Reset private values used in angle computations
		oldAng = baseAng = 0;
		
		// Set up the mouse event handlers depending on whether we're supposed
		// to respond to click-and-drag, or rollOver/rollOut
		if (dragOrOver == "drag") {
			bkgnd.onPress = jogEngage;
			bkgnd.onRelease = jogRelease;
			bkgnd.onReleaseOutside = jogRelease;
		} else {
			bkgnd.onRollOver = jogEngage;
			bkgnd.onRollOut = jogRelease;
		}

		// hold onto current integer value, in case we are supposed to snap to integer
		// and we need to know if we've reached an integer yet
		lastIntVal = int(_val);

		// initialize jog at starting position
		setVal(_val, true);
	
		// Setup the incr/decr buttons
		rotIncr.onPress = incrJog;
		rotDecr.onPress = decrJog;
		rotIncr._visible = rotDecr._visible = _showButs;
	
		if (clickSnd != "") {
			setClickSound(clickSnd);
		}
	
		// Draw the tick marks, if directed to
		if (_showTicks)
			drawTicks();

		bkgnd.useHandCursor = showHand;
		allowEvents = true;
		bkgnd._alpha = (showBkgnd ? 100 : 0);
	}
	
	// Attach the jog elements and position them appropriately
	private function attachChildren():Void {
		var bg = "defJogBkgnd";
		
		if (bkgndLinkID != undefined && bkgndLinkID != "") {
			bg = bkgndLinkID;
		}		
		attachMovie(bg, "bkgnd", 1);
		attachMovie("defJogIncr", "rotIncr", 2);
		attachMovie("defJogDecr", "rotDecr", 3);
		rotIncr._x = 30; rotIncr._y = 90;
		rotDecr._x = -30; rotDecr._y = 90;
		
		if (indLinkID != undefined && indLinkID != "") {
			attachMovie(indLinkID, "ind", 4);
		} else {
			attachMovie("defJogIndicator", "ind", 4);
		}
	}
	
	
/**
A Boolean property indicating whether (true) or not (false) to use the hand cursor when the mouse is over the jog's hit area.
@property showHand
*/

/**
A Boolean property indicating whether (true) or not (false) to force the steps to integers.  If you
change this during program execution, set a new value (<code>val</code>) to have the change take effect.
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
Position of the indicator (0-units).  This can be used to change the position of the jog immediately, but
it does not generate a value change event.

@property val
*/

/**
Name of the event generated by this component, by default "onValChg". This can be
changed in the component property panel or programmatically.

@property vChg
*/


/**
Called when the operator is about to move the jog.  It may seem weird that we are using _parent in
this method, but the reason is that 'this' is set to the background graphic, which is one level
below the component.  This occurs because we have assigned jogEngage (and jogRelease) to the background
graphic onPress and onRelease.


@method jogEngage
@access private
*/ 
	private function jogEngage ():Void {
		if (!_parent.allowEvents) {
			_parent.eventObj.type = "disabled";
			_parent.dispatchEvent(_parent.eventObj);
			return;
		}
		_parent.holdAng = undefined;
		_parent._beginVal = _parent._val;
		onMouseMove = _parent.trackMouse;
	}

/**
Called when the operator releases the jog from turning.

@method jogRelease
@access private
*/
	private function jogRelease ():Void {
		if (!_parent.allowEvents) {
			return;
		}
		if (_parent.snap2Int) {
			// On release, set knob at closest integer
			_parent.setVal(Math.round(_parent._val));
			// If the current value is the same as the value we started movement at, then setVal() would
			// not make an audio click.  Therefore, make a click in this situation only.
			if (_parent._val == _parent._beginVal) {
				if (_parent.sndObj != undefined) {
					_parent.sndObj.start();
				}
				_parent.genEvent(0);
			}
		}
		
		delete onMouseMove;
	}

/**
<p>The routine that tracks mouse movements and converts them to jog movements.
We look at the current mouse position (the center of dial is (0, 0)) as
a vector, and find out the angle between this vector and the angle recorded
when the jog was last manipulated (holdAng).  We then rotate the jog by
the difference of the angles, then reset holdAng.</p>

<p>We have to invert the y axis values because in
screen coords, y values increase going down, and decrease going up.</p>

<p>Developers shouldn't really use this method unless you know what you want to do with it.</p>
@method trackMouse
@access private
*/
	private function trackMouse () {
		var ax, ay, neg, sum, vdot, angle;

		// Compute the dot product, which will give us the rotation angle based
		// on the current mouse position
		ax = this._xmouse;
		ay = this._ymouse;
		neg = ax < 0;

		// normalize the vector
		sum = Math.sqrt(ax*ax + ay*ay);
		// check to see if zero-length vector, which means passing through center
		if (sum == 0)
			return;
		// ax /= sum;  ax gets ignored after this point, so don't bother computing
		ay /= sum;
		// dot product gives us the angle between vectors (original and now new position)
		// vdot = ax*nx + ay*ny; but we can simplify because nx = 0 and ny = -1.
		vdot = -ay;
		// convert from radians to degrees
		angle = 57.2957795130823 * Math.acos(vdot);

		if (neg)
			angle *= -1;
		
		// If holdAng is undefined, it means this is the first time through
		// for the current interaction, so we have to record the initial angle
		// so we can update the rotation based on changes to the initial angle
		if (this._parent.holdAng == undefined)
			this._parent.holdAng = angle;

		// set the current angle to be the angular difference plus current pos
		this._parent.baseAng += angle - this._parent.holdAng;
		
		// given the cumulative (baseAng) and angle of current mouse pos, set
		// the jog into position and update
		this._parent.setAVal(this._parent.baseAng, angle);

		updateAfterEvent();
	}


/**
Translate the current angle into an increment from the last knob position,
then notify listeners with the new value.

@method setAVal
@param ang
@param realAng
@access private
*/
	private function setAVal (ang, realAng) {
		var rv = ang - this.oldAng, incr, ov = this._val;
	
		if (ang > this.oldAng) {
			if (rv > 180)
				rv -= 360;
		} else {
			if (rv < -180)
				rv += 360;
		}
	
		this.oldAng = ang;
		incr = (_units * rv) / 360;
		this.valPriv += incr;
	
		this.setVal(this.valPriv);
		this.holdAng = realAng;
	}


/**
Increase the jog by 1 unit.
@method incrJog
*/
	public function incrJog():Void {
		this._parent.incrVal(1);
	}

/**
Decrease the jog by 1 unit.
@method decrJog
*/
	public function decrJog():Void {
		this._parent.incrVal(-1);
	}


/**
Increments the jog by incr units (positive or negative).  This can be used to simulate turning the jog.

@method incrVal
@param incr Numeric increment to change the jog.
@param quietly (optional) Set this to true to make the change without generating an event.
@example
myJog.incrVal(2.5);
*/ 
	public function incrVal(incr, q) {
		this.setVal(this._val + incr, q);
	}
	
/**
Sets the position of the jog knob.

@method setVal
@param val Numeric value (between 0 and <code>units</code>)
@param quiet Boolean flag indicating whether to set the value quietly (no event notification) or with notification (false [default]).
@example
myJog.setVal(5); // sets the jog knob to the certain position
@access private
*/
	private function setVal (v, q) {
		var v4ang = v % _units, ang, ov = this._val;
		
		this.valPriv = v;
		ang = (360 / _units) * v4ang;
	
		if (_discreteSteps) {
			this._val = Math.round(this.valPriv);
			this.ind._rotation = (360 / _units)  * (this._val % _units);
		} else {
			this._val = this.valPriv;
			this.ind._rotation = ang;
		}
	
		if (this._val != ov && q != true) {
			if (!snap2Int && !_discreteSteps) {
				genEvent(_val - ov);
				this.sndObj.start();
				
			} else if (_discreteSteps && Math.abs(_val - ov) >=1) {
				genEvent(_val - ov);
				this.sndObj.start();
	
			} else if (snap2Int && Math.abs(valPriv - lastIntVal) >= 1) {
				if (lastIntVal != _val) {
					genEvent(Math.round(valPriv - lastIntVal));
					this.sndObj.start();
				}
				lastIntVal = Math.round(valPriv);
			}
		}
	}
	
	
	// Generate this component's event with the given value.  This is broken out as
	// as a separate method so that it can be overriden in subclasses, if necessary.
	private function genEvent(v) {
		eventObj.type = vChg;
		eventObj.val = v;
		dispatchEvent(eventObj);
	}

/**
Routine draws the tick marks, when developer requests them drawn.

@method drawTicks
@access private
*/
	private function drawTicks():Void {
		var len = 5+ this.bkgnd._width / 2, ang = 360 / _numTicks, ptObj;
	
		if (tickClip != undefined)
			tickClip.removeMovieClip();
	
		createEmptyMovieClip("tickClip", -100);
		tickClip.clear();

		tickClip.lineStyle(0x000000);
		ptObj = new Object();
		ptObj.x = 0;
		ptObj.y = -len;

		for (var i = 0; i < 360; i += ang) {
			rotZ(ptObj, i);
			tickClip.moveTo(0, 0);
			tickClip.lineTo(ptObj.xp, ptObj.yp);
		}
		delete ptObj;
		
	}

/**
Rotates a given point <code>(vObj.xp, vObj.yp)</code> around the Z-axis by <code>ang</code> degrees.

@method rotZ
@param vObj A vertex object (with properties <code>xp</code> and <code>yp</code>)
@param ang Angle to rotate point on Z-axis (0 degrees points north, positive is clockwise)
@access private
*/

	private function rotZ (vObj, ang) {
		ang = 0.0174532925199433 * ang;  // convert degrees to radians
		vObj.xp = Math.cos(ang) * vObj.x - Math.sin(ang) * vObj.y;
		vObj.yp = Math.sin(ang) * vObj.x + Math.cos(ang) * vObj.y;
	}
	
	// Change the sound associated with each knob movement
	private function setClickSound (s) {
		if (sndObj == undefined) {
			sndObj = new Sound(this);
		}
		sndObj.attachSound(s);
	}
	
/**
Given an event string and value that matches what this component would generate, perform the action.
For the jog component, the event is onValChg and the value is the increment.

@method execEvent
@param evName Event name (string) must match the event this component generates
@param evVal (optional) value accompanying the event (if the event has an accompanying value)
@param quiet (optional) set this to true if component should perform the action but not generate an event (this should be false or undefined, unless you know what you are doing)
@example
myJog.execEvent("onValChg", 1); // increments jog by 1 unit
*/
	public function execEvent (evName:String, evVal, q:Boolean):Void {
		if (evName == myEvents[0]) {
			incrVal(evVal, q);
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