 /**
This class implements a simple barrel dial that displays
positive integer values.  The values can increase by rolling the display
upwards or downwards (depending on parameter set in the component parameter panel).

<p>The class has one event, "onOverflow", indicating the current value has exceeded
the maximum value of the display.  The value is passed as the value of the event.</p>

<p>Users can change the appearance by modifying:</p>

<li><code>defBDialBkgnd</code> - background for digit</li>
<li><code>defBDialDigGfx</code> - clip with digits used</li>
<li><code>defBDialDigPlusBkgnd</code> - movie clip that contains two digits
(one in regular space for digit, one above) &amp; background</li>

<p>This class inherits from FMXISBase to get listener capabilities.</p>

@class FMXISBarrelDial
@codehint _bDial
@author Jonathan Kaye (FlashSim.com)
@tooltip Simple roll-up or roll-down barrel down
*/
/*
This code was developed by Jonathan Kaye and Amethyst Interactive LLC,
Copyright 2002-2004, all rights reserved.
v2.0, February, 2004
*/
import mx.core.UIObject;
import mx.fmxis.FMXISBase;

/**
This component generates an event named "onOverflow" (can be changed programmatically or through the
component parameter panel) when the barrel dial exceeds its maximum value.  Note: underflow
(i.e., a value below 0) is not caught in this implementation.

@event onOverflow
*/
[Event("onOverflow")]

class mx.fmxis.FMXISBarrelDial extends FMXISBase {

	// bounding box for this button component
	private var boundingBoxClip:MovieClip;
	private var digEx:MovieClip;
	
	var className:String = "FMXISBarrelDial";
	static var symbolOwner:Object = FMXISBarrelDial;
	static var symbolName:String = "FMXISBarrelDial";
	
	// Inspectable properties.  Let user change the event names, if desired.
	// The event names have to be set at the time the component is instantiated (either
	// at run-time, or programmatically at the attachMovie/createClassObject time).
	/**
	Event name for event generated if the value of the display (whole number) exceeds the
	number of positions.  Unlike the digital display, the barrel
	dial does not handle negative numbers. 
	@property evtOverflow
	*/
	[Inspectable(name="onOverflow method name", type=String, defaultValue="onOverflow")]
	public var evtOverflow:String;

	/**
	The linkage ID of a movie clip containing the digits and the background.
	@property digPBkgndID
	*/
	[Inspectable(name="digit plus bkgnd linkage ID", type=String)]
	private var digPBkgndID:String;


	/**
	Number of digits.  This can be set only in the component property panel.
	@property numDigs
	*/
	[Inspectable(name="Number of digits", type=Number, defaultValue=1)]
	public function set numDigs (v) {
		_digs2Del = _numDigs;
		_numDigs = v;
		invalidate();
	}
	public function get numDigs () {
		return _numDigs;
	}
	private var _numDigs:Number;
	private var _digs2Del:Number;
	
	/**
	Whether or not to display the background graphic.
	@property showBkgnd
	*/
	[Inspectable(name="Show background", type=Boolean, defaultValue=true)]
	public function set showBkgnd (v) {
		displayBkgnd(v);
	}
	public function get showBkgnd () {
		return _showBkgnd;
	}
	private var _showBkgnd:Boolean;
	
	/**
	Whether the dial increases by rolling up (true) or down (false).
	@property rollUp
	*/
	[Inspectable(name="Increase by rolling up", type=Boolean, defaultValue=true)]
	public function set rollUp (v) {
		_rollUp = v;
		setVal(pval);
	}
	public function get rollUp () {
		return _rollUp;
	}
	private var _rollUp:Boolean;
	
	/**
	Whether or not to display the digit value.  This is used to simulate the
	display on (true) or off (false).
	@property display
	*/
	[Inspectable(name="Display on", type=Boolean, defaultValue=true)]
	public function set display (v) {
		displayDigs(v);
	}
	public function get display () {
		return digsOn;
	}
	private var digsOn:Boolean;
	
	
	/**
	Color of each digit.
	@property digTint
	*/
	[Inspectable(name="Digit color", type=Color, defaultValue="#000000")]
	public function set digTint (v) {
		setDigColor(v);
	}
	public function get digTint () {
		return _digTint;
	}
	private var _digTint:Color;


	/**
	A getter/setter property used to set or retrieve the value of the dial.
	@property val
	@example
	// set the barrel display to 3-2, in which rightmost digit (2) is half way between 2 and 3.
	myBDial.val = 32.5;
	*/
	[Inspectable(name="Starting value", type=Number, defaultValue=0)]
	public function set val (v) {
		setVal(v);
	}
	public function get val () {
		return pval;
	}
		
	/**
	An private value used to hold the digital display's value.
	@property pval
	@access private
	*/
	private var pval;
	
	/**
	An array of defDigPlusBkgnd clips, for digits 1 - (_numDigs-1).
	@property digs
	@access private
	*/
	private var digs:Array; // list of digit movie clips
	
	/**
	An array of Colors to modify the digit graphics (tint).
	@property digCol
	@access private
	*/
	private var digCols:Array; // array of colors for each digit
	private var digColsOth:Array; // second digit per position (on top or bottom) color
	private var digsVal:Array; // value of digit in each position
	
	private var oneCharWidth:Number;
	private var oneCharHeight:Number;
	
	private var curWidth:Number;
	private var curHeight:Number;
	
	// event dispatch stuff
	private var dispatchEvent:Function;
	
	// clipParameters - for backward compatibility with Flash 6 player
	var clipParameters:Object = { listener:1, evtOverflow:1, numDigs:1, val:1,
								  digTint:1, display:1, showBkgnd:1, rollUp:1, digPBkgndID:1 };
	private static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(FMXISBarrelDial.prototype.clipParameters, 
                               UIObject.prototype.clipParameters);

	
	static var dialEvents:Array = new Array("onOverflow");
	
	// by default, use the event names as given by digEvents.  We made it a static
	// variable for space efficiency.
	private var myEvents:Array = dialEvents;
	
	function FMXISBarrelDial () {
		// update();
	}
	
	private function displayBkgnd (f) {
		// set the digit background to visible or not visible
		for (var i=0; i<_numDigs; i++) {
			digs[i].bkgnd._visible = f;
		}
		_showBkgnd = f;
	}
	
	
	/**
	Initialization of component.  Create the digits that are
	necessary by copying from first (digEx).  Also initialize arrays that
	hold digits and colors.
	@method init
	@access private
	*/
	private function init (evts): Void {
		var origW = _width, origH = _height;
		
		// if the user has changed any event names, make sure named listeners are handled
		if (myEvents[0] != evtOverflow  ||
		    evts != null) {
			this.myEvents = new Array(evtOverflow);
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
		_xscale = _yscale = 100;
		oneCharWidth = _width;
		oneCharHeight = _height;
		
		// size to available space
		arrangeDigits(_numDigs);
		setSize(origW, origH);
		update();
	}
	
	
	private function attachChildren () {
		var dpb = "defBDialDigPlusBkgnd";
		
		if (digPBkgndID != "" && digPBkgndID != undefined) {
			dpb = digPBkgndID;
		}
		attachMovie(dpb, "digEx", 0);
	}
	
	private function draw () {
		arrangeDigits(_numDigs);
		setVal(pval); // restore value
		setDigColor(_digTint);
		setSize(curWidth, curHeight);
		displayBkgnd(_showBkgnd);
		displayDigs(digsOn);
	}
	
	private function arrangeDigits(nNum) {
		var i, nm, d2d = _digs2Del;
		
		if (d2d == undefined) {
			d2d = _numDigs;
		}
		if (nNum != d2d) {
			for (i=1; i<d2d; i++) {
				digs[i].removeMovieClip();
				delete digCols[i];
				delete digColsOth[i];

			}
			delete digCols;
			delete digColsOth;
			delete digs;
		}
		
		_numDigs = nNum;
		
		digCols = new Array(_numDigs);
		digColsOth = new Array(_numDigs);
		digs = new Array(_numDigs);
		digs[0] = digEx;
		digsVal = new Array(_numDigs + 1);
		
		for (i=0; i<_numDigs; i++) {
			
			if (i == 0) {
				digs[0]._x = digs[0]._y = 0;
			} else {
				nm = "d" + i;
				digs[i] = digEx.duplicateMovieClip(nm, i);
				// place next digit directly to right of last digit
				digs[i]._x = digs[i-1]._x + digs[0]._width - 1;
				digs[i]._y = 0;
			}
			
			digCols[i] = new Color(digs[i].dig);
			digCols[i].setRGB(Number(_digTint));
			digColsOth[i] = new Color(digs[i].odig);
			digColsOth[i].setRGB(Number(_digTint));
		}
		
		displayBkgnd(_showBkgnd);
	}
	
	/**
	Internal routine to change the display value.  Note that the internal
	value may have greater precision than the display since the display
	is limited to the # of decimal places set.
	
	@method setVal
	@param v New value
	@access private
	*/
	function setVal (v) {
		pval = v;
		update();
	}

											
	/**
	Sets the tint color of the digits (RGB value).
	
	@method setColor
	@param c RGB value of tint color.
	@example
	myDigs.setColor(0xFF0000);  // sets the digits to pure red
	@access private
	*/
	private function setDigColor (c) {
		for (var i=0; i<_numDigs; i++) {
			digCols[i].setRGB(c);
		}
		_digTint = c;
	}
	
		
	/**
	Display (true) or do not display (false) the dial.
	@method displayDigs
	@param flag true or false, indicating whether display should be on or off, respectively.
	@example
	myBDial.display(false);  // turns dial off
	@access private
	*/
	private function displayDigs (f) {
		digsOn = f;
		update();
		for (var i=0; i<_numDigs; i++) {
			digs[i].dig._visible = digs[i].odig._visible = f;
		}
	}
	
	private function setSize (nW, nH) {
		var i, digXScale, digYScale;
		
		if (oneCharWidth == undefined)
			return;
			
		_xscale = _yscale = 100;
		digXScale = 100 * nW / oneCharWidth / _numDigs;
		digYScale = 200 * nH / oneCharHeight;
		
		for (i=0; i<_numDigs; i++) {
			digs[i]._xscale = digXScale;
			digs[i]._yscale = digYScale;
			if (i != 0) {
				digs[i]._x = digs[i-1]._x + digs[0]._width - 1;
				digs[i]._y = 0;
			}
		}
		
		curWidth = nW;
		curHeight = nH;
	}

	/**
	Sets the tint color of the digits to the given color.
	@method setColor
	@param RGBColor RGB value (typically hexadecimal values for Red, Green, and Blue)
	@example
	myBDial.setColor(0xFF0000); // sets digits to pure red
	*/
	function setColor (c) {
	
		for (var i=0; i<this._numDigs; i++) {
			this.digCols[i].setRGB(c);
			this.digColsOth[i].setRGB(c);
		}
		this.digTint = c;
	}

	/**
	Update, the main routine.  This takes the internal value, pval, and
	translates it into the barrel dial display.
	@method update
	@access private
	*/
	private function update () {
		
		var i, nd = _numDigs, runval, curpow, dpow, rmndr, isodig, chgNext,
			halfHeight = digEx.bkgnd._height / 2;
		
		if (_numDigs == undefined)
			return;
			
		if (digsOn) {
			// The idea is to take the available space in the display, use
			// that to determine how many digits will fit (dpow), then go
			// through the current value isolating the digits and placing
			// them in the display.
			dpow = Math.pow(10, _numDigs - 1);
			// runval holds the value remaining so we can isolate digits
			runval = pval;
			
			// Check for overflow
			if (Int(runval/dpow) >= 10) {
				eventObj.type = evtOverflow;
				eventObj.val = pval;
				dispatchEvent(eventObj);
				runval %= Math.pow(10, _numDigs);
			}
			
			// Compute the digits for each place
			for (i=0; i<nd; i++) {
				digsVal[i] = isodig = Int(runval / dpow);			
				runval -= (isodig * dpow);
				dpow /= 10;
			}
			// Set the remainder
			rmndr = runval/dpow/10;
				
			if (_rollUp) {
				// increase by rolling upwards
				// set the digits, from last to first
				chgNext = true;  // whether or not to rotate this digit.  Once false, never
								 // gets set back to true.
				for (i=nd-1; i>=0; i--) {
					digs[i].dig.gotoAndStop(digsVal[i] + 1);
					if (chgNext) {
						// Adjust the current digit to reflect intermediate value based
						// on remainder
						digs[i].odig.gotoAndStop(1 + (digsVal[i] + 1) % 10);
						digs[i].odig._y = digEx.bkgnd._height + 
							(digs[i].dig._y = -rmndr * digEx.bkgnd._height - halfHeight);
						chgNext = (digsVal[i] == 9);
					} else {
						digs[i].dig._y = -halfHeight;
						digs[i].odig._y = halfHeight;					}
				}
			} else {
				// increase by rolling downward
				chgNext = true;	 // whether or not to rotate this digit.  Once false, never
								 // gets set back to true.
				for (i=nd-1; i>=0; i--) {
					digs[i].dig.gotoAndStop(digsVal[i] + 1);
					if (chgNext) {
						digs[i].odig.gotoAndStop(1 + (digsVal[i] + 1) % 10);
						digs[i].odig._y = -digEx.bkgnd._height +
								(digs[i].dig._y = rmndr * digEx.bkgnd._height - halfHeight);
						chgNext = (digsVal[i] == 9);

					} else {
						digs[i].dig._y = -halfHeight;
						digs[i].odig._y = halfHeight;
					}
				}
			}
		} else {
			// digits are off, so make blank
			for (i=0; i<=_numDigs; i++) {
				digs[i].dig._visible = false;
			}
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