/**
<p>This class implements a simple horizontal slider.  Users can change the appearance by modifying:</p>
<li><code>defSliderBkgnd</code> - gutter along which slider slides</li>
<li><code>defSliderSide</code> - left and right sides of the slider</li>
<li><code>defSliderIndicator</code> - the indicator (button)</li>

<p>The class has one event, but can be changed in the component property panel or programmatically:
"onChange" on change.  Value is new value.</p>

<p>This class inherits from FMXISBase to get listener capabilities.</p>

@class FMXISSlider
@codehint _slider
@author Jonathan Kaye (FlashSim.com)
@tooltip Slider
*/
/*
This code was developed by Jonathan Kaye and Amethyst Interdisable LLC,
Copyright 2002-2004, all rights reserved.
v2.0, February, 2004
*/
import mx.core.UIObject;
import mx.fmxis.FMXISBase;

[IconFile("slider.png")]


[Event("onChange")]
[Event("disabled")]

/**
Event generated when the indicator reaches a new value.  The value passed in the event is the new value
of the slider.
@event onChange
*/


class mx.fmxis.FMXISSlider extends FMXISBase {

	// bounding box for this button component
	private var boundingBoxClip:MovieClip;
	private var rightSide:MovieClip;
	private var leftSide:MovieClip;
	private var gut:MovieClip; // gutter
	private var ind:MovieClip; // indicator
	private var tickClip:MovieClip; // draw tick marks here
	
	private var sndObj:Sound; // optional audio
	private var indOffset:Number;
	private var _valRange:Number;
	private var leftPos:Number;
	private var rightPos:Number;
	
	var className:String = "FMXISSlider";
	static var symbolOwner:Object = FMXISSlider;
	static var symbolName:String = "FMXISSlider";
	
	// Inspectable properties.  Let user change the event names, if desired.
	// The event names have to be set at the time the component is instantiated (either
	// at run-time, or programmatically at the attachMovie/createClassObject time).
	/**
	The name of the event.  Change this programmatically to change the event name.
	@property evtChange
	*/
	[Inspectable(name="onChange method name", type=String, defaultValue="onChange")]
	public var evtChange:String;
	
	/**
	The linkage ID of an audio clip to play on value change. This can only be set in the property panel.
	@property clickSnd
	*/
	[Inspectable(name="Sound clip linkage ID", type=String, defaultValue="")]
	private var clickSnd:String;

	/**
	The linkage ID of the gutter clip.
	@property bkgndID
	*/
	[Inspectable(name="gutter linkage ID", type=String, defaultValue="")]
	private var bkgndID:String;

	/**
	The linkage ID of the right side of the gutter (duplicated on left, rotated 180 degrees).
	@property sideID
	*/
	[Inspectable(name="gutter side linkage ID", type=String, defaultValue="")]
	private var sideID:String;

	/**
	The linkage ID of the thumb.
	@property thumbID
	*/
	[Inspectable(name="thumb linkage ID", type=String, defaultValue="")]
	private var thumbID:String;

		
	/**
	Boolean property indicating whether or not to display the hand cursor when the cursor is
	over the hit area of this component.
	@property showHand
	*/
	[Inspectable(name="Show Hand Cursor", type=Boolean, defaultValue=true)]
	public function set showHand (f) {
		this.ind.useHandCursor = f;
		_showHand = f;
	}
	public function get showHand () {
		return(_showHand);
	}
	private var _showHand:Boolean;
	
	/**
	Minimum value for the slider.  Use <code>setMinMax()</code> to change the value.
	@property minVal
	*/
	[Inspectable(name="minimum value", type=Number, defaultValue=0)]
	public function set minVal (f) {
		_minVal = f;
		resetBounds();
	}
	public function get minVal () {
		return(_minVal);
	}
	private var _minVal:Number;
	
	/**
	Maximum value for the slider.  Use <code>setMinMax()</code> to change the value.
	@property maxVal
	*/
	[Inspectable(name="maximum value", type=Number, defaultValue=100)]
	public function set maxVal (f) {
		_maxVal = f;
		resetBounds();
	}
	public function get maxVal () {
		return(_maxVal);
	}
	private var _maxVal:Number;
	
	/**
	Boolean property saying whether steps or discrete or continuous.  If true, discrete steps
	are based on <code>numDivs</code>.  If false, slider is continuous.
	@property discreteStep
	*/
	[Inspectable(name="Discrete steps", type=Boolean, defaultValue=true)]
	private var discreteStep:Boolean;
	
	/**
	Boolean property saying whether to allow value change on gutter clicks or not.
	@property gutClicks
	*/
	[Inspectable(name="Allow gutter clicks", type=Boolean, defaultValue=true)]
	public function set gutClicks (f) {
		gut.onPress = (f ? gutPress : undefined);
		_gutClicks = f;
	}
	public function get gutClicks () {
		return(_gutClicks);
	}
	private var _gutClicks:Number;
	
	
	/**
	Number of divisions, for discrete slider (and tick marks).
	@property numDivs
	*/
	[Inspectable(name="Number of tick intervals", type=Number, defaultValue=10)]
	public function set numDivs (f) {
		_numDivs = f;
		if (_showTicks)
			drawTicks();
		tickClip._visible = f;
	}
	public function get numDivs () {
		return(_numDivs);
	}
	private var _numDivs:Number;

	
	/**
	Current slider value.  Set this property to move the indicator programmatically, or use
	it to retrieve the current indicator position.
	@property val
	*/
	[Inspectable(name="indicator position", type=Number, defaultValue=50)]
	public function set val (f) {
		_val = f;
		invalidate();
	}
	public function get val () {
		return(_val);
	}

	private var _val:Number;
	  
	/**
	Boolean property indicating whether or not to show tick marks.  Tick marks are really only
	for placement, as you really should hand-design slider backgrounds for best effect.
	@property showTicks
	*/
	[Inspectable(name="Show tick marks", type=Boolean, defaultValue=false)]
	public function set showTicks (f) {
		_showTicks = f;
		if (_showTicks)
			drawTicks();

		tickClip._visible = f;
	}
	public function get showTicks () {
		return(_showTicks);
	}
	private var _showTicks:Boolean;
	
	public var allowEvents:Boolean;
	
	// event dispatch stuff
	private var dispatchEvent:Function;
	
	// clipParameters - for backward compatibility with Flash 6 player
	var clipParameters:Object = { listener:1, evtChange:1, clickSnd:1, showHand:1,
									minVal:1, maxVal:1, discreteSteps:1, gutClicks:1, numDivs:1,
									val:1, showTicks:1, sideID:1, bkgndID:1, thumbID:1};
	private static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(FMXISSlider.prototype.clipParameters, 
                               UIObject.prototype.clipParameters);

	
	static var sliderEvents:Array = new Array("onChange", "disabled");
	
	// by default, use the event names as given by buttonEvents.  We made it a static
	// variable for space efficiency.
	private var myEvents:Array = sliderEvents;
	
	// constructor
	function FMXISSlider () {
	}
	
	private function init (evts): Void {
		
		// if the user has changed any event names, make sure named listeners are handled
		if (myEvents[0] != evtChange  ||
		    evts != null) {
			this.myEvents = new Array(evtChange, "disabled");
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
		this.allowEvents = true;
		attachChildren();
		
		// Setup clicking on the gutter
		gut.onPress = (_gutClicks ? gutPress : undefined);
		
		gut.useHandCursor = false;
				
		ind.onPress = handleDrag;
		ind.onRelease = handleStopDrag;
		ind.onReleaseOutside = handleStopDrag;
		
		if (clickSnd != "") {
			sndObj = new Sound(this);
			sndObj.attachSound(clickSnd);
		}
		
		resetBounds();
	
		setValQuiet(_val);

		this.ind.useHandCursor = this._showHand;
	}
	

	private function attachChildren () {
		var bk = "defSliderBkgnd", ss = "defSliderSide", tid = "defSliderIndicator";
		if (bkgndID != "" && bkgndID != undefined) {
			bk = bkgndID;
		}
		if (sideID != "" && sideID != undefined) {
			ss = sideID;
		}
		if (thumbID != "" && thumbID != undefined) {
			tid = thumbID;
		}

		attachMovie(bk, "gut", 1);
		attachMovie(ss, "rightSide", 2);
		rightSide.duplicateMovieClip("leftSide", 3);
		rightSide._x = gut._width / 2;
		leftSide._x = -gut._width / 2;
		leftSide._rotation = 180;
		attachMovie(tid, "ind", 4);
	}	
	
	/**
	Routine called when user clicks in the gutter.
	@method gutPress
	@access private
	*/
	private function gutPress () {
		if (_parent.allowEvents) {
			_parent.sliderClickHandle(_parent._xmouse);
		} else {
			_parent.eventObj.type = "disabled";
			_parent.dispatchEvent(_parent.eventObj);
		}
	}
	
	/**
	Given an event string and value that matches what this component would generate, perform the action.
	For the slider component, the event is onChange and the value is the new value.
	
	@method execEvent
	@param evName Event name (string) must match the event this component generates
	@param evVal (optional) value accompanying the event (if the event has an accompanying value)
	@param quiet (optional) set this to true if component should perform the action but not generate an event (this should be false or undefined, unless you know what you are doing)
	@example
	mySlider.execEvent("onChange", 10); // sets the slider to value 10
	*/
	public function execEvent (evName:String, evVal, q:Boolean):Void {
		if (evName == myEvents[0]) {
			setVal(evVal, q);
		}
	}


	/**
	Routine called when user is first clicks on indicator to drag it.
	@method mouseDrag
	@access private
	*/
	private function mouseDrag () {
		_parent.sliderClickHandle(_parent._xmouse + indOffset);
		updateAfterEvent();
	}
	
	/**
	Routine called while user is dragging the indicator.
	@method handleDrag
	@access private
	*/
	private function handleDrag () {
		if (!_parent.allowEvents) {
			_parent.eventObj.type = "disabled";
			_parent.dispatchEvent(_parent.eventObj);
			return;
		}
			
		// factor in the difference between where mouse went down on indicator
		// and the indicator's position
		indOffset = _parent.ind._x - _parent._xmouse;
		onMouseMove = _parent.mouseDrag;
	}
	
	private function handleStopDrag () {
		onMouseMove = undefined;
	}
	
	/**
	this method takes a position in gutter coordinates
	and moves the indicator there.  It is used during gutter clicking
	and indicator dragging.
	@method sliderClickHandle
	@param m numeric desired slider (x) coordinate, not value
	@access private
	*/
	private function sliderClickHandle (m) {
		var click, sRange;
			
		click = m - leftPos;
		sRange = rightPos - leftPos;
		if (click < 0)
			click = 0;
		else if (click > sRange)
			click = sRange;
		setVal(_minVal + _valRange * (click/sRange));
	}
	
	/**
	This method is used to set the indicator value without generating an event.
	@method setValQuiet
	@param v New value
	*/
	public function setValQuiet (v) {
		setVal(v, true);
	}
	
	private function draw () {
		setVal(_val);
	}
	
	/**
	Called to set the position of the indicator, and notify listeners.
	@method setVal
	@param v New slider value
	@param quiet Boolean property, true if not to notify listeners, false to notify (default)
	@access private
	*/
	private function setVal (v, quiet) {
		var ov = _val;
	
		if (v < _minVal)
			v = _minVal;
		else if (v > _maxVal)
			v = _maxVal;
			
		if (discreteStep) {
			var divSize = (_maxVal - _minVal) / _numDivs;
			v = _minVal + divSize * Math.round((v - _minVal) / divSize);
		}

		ind._x = leftPos + (rightPos - leftPos) * (v - _minVal)/_valRange;
		_val = v;
		if (v!= ov) {
			if (quiet != true) {
				eventObj.type = evtChange;
				eventObj.val = v;
				dispatchEvent(eventObj);
			}
			sndObj.start();
		}
	}
	
	/**
	Internal routine that draws the new slider based on the min and max values.
	@method resetBounds
	@access private
	*/
	private function resetBounds () {
		leftPos = gut._x - (gut._width/2 - ind._width/2);
		rightPos = gut._x + (gut._width/2 - ind._width/2);
		_valRange = _maxVal - _minVal;
		
		if (showTicks)
			drawTicks();
		
		tickClip._visible = showTicks;
	}
	
	/**
	Called to draw tick marks for each step.
	@method drawTicks
	@access private
	*/
	private function drawTicks () {
		var dist = (rightPos - leftPos) / _numDivs,
		    th = 4 + (gut._height / 2);
		    
		if (tickClip != undefined)
			tickClip.removeMovieClip();
		createEmptyMovieClip("tickClip", -100);
		tickClip.clear();
		tickClip.lineStyle(0, 0x000000);
		for (var i=0; i<=_numDivs; i++) {
			tickClip.moveTo(i*dist + leftPos, -th);
			tickClip.lineTo(i*dist + leftPos, th);
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