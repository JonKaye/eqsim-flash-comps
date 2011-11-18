    /**
<p>This class implements a simple sector dial. Developers can set its
value by setting the <code>val</code> property to have the
dial jump immediately to that value.</p>

<p>Users can change the appearance of the
hand by modifying: <code>defSectDialHand</code>, 
center of the dial by modifying: <code>defSectDialCenter</code>,
the background graphic by modifying: <code>defSectDialBkgnd</code>.</p>

<p>The component also provides properties to bring in attached graphics based
on movie clip linkage ID's.  This allows the developer to have multiple instances
on the Stage with different looks.</p>

<p>Showing the dial center and background are optional.</p>
 
<p>This class inherits from <code>FMXISBase</code> for consistency with other
components, but it doesn't need listener capabilities (its subclass,
FISSectorDialSmooth does, however)</p>

@class FISSectDial
@codehint _sdial
@author Jonathan Kaye (FlashSim.com)
@tooltip Simple sector dial (gauge)
*/
/*
This code was developed by Jonathan Kaye and Amethyst Interactive LLC,
Copyright 2002-2004, all rights reserved.
v2.0, February, 2004
*/
import mx.fmxis.FMXISBase;
import mx.core.UIObject;

// Use InspectableList to block out listener, since this component doesn't have any events
[InspectableList("units", "showBack", "centerVis", "nXScale", "nYScale", "val", "bkgndLinkID", "centerLinkID", "needleLinkID", "minAngle", "maxAngle", "minVal", "maxVal", "left2right")]

[IconFile("sdial.png")]


class mx.fmxis.FMXISSectorDial extends FMXISBase {

	// bounding box for this component
	private var boundingBoxClip:MovieClip;
	private var h:MovieClip;
	private var dCenter:MovieClip;
	private var bkgnd:MovieClip;
	
	var className:String = "FMXISSectorDial";
	static var symbolOwner:Object = FMXISSectorDial;
	static var symbolName:String = "FMXISSectorDial";
	
/**
This property gives the linkage ID of the background to use instead of the default graphic
in the Library. This must
be set through the component property panel or programmatically
through the initObject parameter of attachMovie/createClassObject.
@property bkgndLinkID
*/
	[Inspectable(name="Background graphic linkage ID", type=String, defaultValue="")]
	private var bkgndLinkID:String;
	
/**
This property gives the linkage ID of the center overlay graphic to use instead of the default graphic
in the Library. This must
be set through the component property panel or programmatically
through the initObject parameter of attachMovie/createClassObject.
@property centerLinkID
*/
	[Inspectable(name="Center overlay graphic linkage ID", type=String, defaultValue="")]
	private var centerLinkID:String;
	
/**
This property gives the linkage ID of the graphic to use instead of the default needle graphic
in the Library.  This must
be set through the component property panel or programmatically
through the initObject parameter of attachMovie/createClassObject.

@property needleLinkID
*/
	[Inspectable(name="Needle graphic linkage ID", type=String, defaultValue="")]
	private var needleLinkID:String;

/**
Current value of the dial (where needle is set).  Set this property to change the displayed
value immediately.
@property val
*/
	[Inspectable(name="Starting value", type=Number, defaultValue=0)]
	public function set val (v:Number) {
		setNeedle(v);
		_val = v;
	}
	public function get val () {
		return _val;
	}
	private var _val:Number;

/**
Minimum value of the gauge.  Set this property to change the minimum at any time.
@property minVal
*/
	[Inspectable(name="Minimum dial value", type=Number, defaultValue=0)]
	public function set minVal (v:Number) {
		_minVal = v;
		setNeedle(_val);
	}
	public function get minVal () {
		return _minVal;
	}
	private var _minVal:Number;

/**
Maximum value of the gauge.  Set this property to change the maximum at any time.
@property maxVal
*/
	[Inspectable(name="Maximum dial value", type=Number, defaultValue=100)]
	public function set maxVal (v:Number) {
		_maxVal = v;
		setNeedle(_val);
	}
	public function get maxVal () {
		return _maxVal;
	}
	private var _maxVal:Number;

/**
Angle of needle when reaches minimum value.  Set this property to change the minimum at any time.
@property minAngle
*/
	[Inspectable(name="Needle angle at minimum", type=Number, defaultValue="-45")]
	public function set minAngle (v:Number) {
		_minAngle = v;
		setNeedle(_val);
	}
	public function get minAngle () {
		return _minAngle;
	}
	private var _minAngle:Number;

/**
Angle of needle when reaches maximum value.  Set this property to change the maximum at any time.
@property maxAngle
*/
	[Inspectable(name="Needle angle at maximum", type=Number, defaultValue=45)]
	public function set maxAngle (v:Number) {
		_maxAngle = v;
		setNeedle(_val);
	}
	public function get maxAngle () {
		return _maxAngle;
	}
	private var _maxAngle:Number;
	
/**
Determines whether minimum is on the left (left2right == true) or on the right (left2right == false).

@property left2right
*/
	[Inspectable(name="Increase values left to right", type=Boolean, defaultValue=true)]
	public function set left2right (f) {
		_left2right = f;
		setNeedle(_val);
	}
	public function get left2right () {
		return _left2right;
	}
	private var _left2right:Boolean;

	
/**
Scaling factor along the x axis (width) for the needle.

@property nXScale
*/
/**
Scaling factor along the y axis (height) for the needle.

@property nYScale
*/
	[Inspectable(name="Needle horizontal scaling %", type=Number, defaultValue=100)]
	public function set nXScale (v) {
		h._xscale = v;
		_nXScale = v;
	}
	public function get nXScale () {
		return _nXScale;
	}
	private var _nXScale:Number;

	[Inspectable(name="Needle vertical scaling %", type=Number, defaultValue=100)]
	public function set nYScale (v) {
		h._yscale = v;
		_nYScale = v;
	}
	public function get nYScale () {
		return _nYScale;
	}
	private var _nYScale:Number;

/**
Boolean property indicating whether the center graphic is visible (true) or not (false).

@property centerVis
*/
	[Inspectable(name="Display center graphic", type=Boolean, defaultValue=true)]
	public function set centerVis (f) {
		dCenter._visible = _centerVis = f;
	}
	public function get centerVis () {
		return _centerVis;
	}
	private var _centerVis:Boolean;
	
/**
Boolean property indicating whether the background graphic is visible (true) or not (false).

@property showBack
*/
	[Inspectable(name="Display background graphic", type=Boolean, defaultValue=true)]
	public function set showBack (f) {
		bkgnd._visible = _showBack = f;
	}
	public function get showBack () {
		return _showBack;
	}
	private var _showBack:Boolean;
	
	// clipParameters - for backward compatibility with Flash 6 player
	var clipParameters:Object = {listener:1, showBack:1, centerVis:1, nXScale:1,
								nYScale:1, val:1, bkgndLinkID:1, centerLinkID:1, needleLinkID:1, minAngle:1,
								maxAngle:1, minVal:1, maxVal:1, left2right:1 };
	private static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(FMXISSectorDial.prototype.clipParameters, 
                               UIObject.prototype.clipParameters);
	
	
	// constructor
	function FMXISSectorDial () {
	}
		
	private function init (evts): Void {
		super.init(evts);
		attachChildren();
		
		bkgnd._visible = _showBack;
		dCenter._visible = _centerVis;
		h._xscale = _nXScale;
		h._yscale = _nYScale;
	
		setNeedle(_val);
	}
	
	
	function attachChildren () {
		var ng = (needleLinkID == "" ? "defSectDialHand" : needleLinkID),
		    bg = (bkgndLinkID == "" ? "defSectDialBkgnd" : bkgndLinkID),
		    cg = (centerLinkID == "" ? "defSectDialCenter" : centerLinkID);

		attachMovie(bg, "bkgnd", 1);
		attachMovie(ng, "h", 2);
		attachMovie(cg, "dCenter", 3);
	}	

	private function setNeedle(v) {
		var arange = _maxAngle - _minAngle,
	   		vrange = _maxVal - _minVal;

		//Don't let value exceed our range!
		if (v < _minVal)
			 v = _minVal;
		else if (v > _maxVal)
			v = _maxVal;
		// l2r == true if min is on left and max is on right, otherwise opposite
		if (_left2right) {
			h._rotation = _minAngle + arange * ((v - _minVal) / vrange);
		} else {
			h._rotation = _maxAngle - arange * ((v - _minVal) / vrange);
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