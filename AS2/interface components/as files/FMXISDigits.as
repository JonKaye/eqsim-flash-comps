/**
<p>This class implements a simple digital display (positive and negative
numbers, as integers or floating point).</p>

Users can change the appearance by modifying:
<li><code>defDigBkgnd</code> - background</li>
<li><code>defDigGfx</code> - clip with digits used</li>
<li><code>defDigDecPt</code> - decimal point graphic</li>
<li><code>defDigPlusBkgnd</code> - movie clip that contains digits, background, and decimal point</li>
 
<p>The class has one event -- "DigOverflow", indicating value cannot be represented in the specified
number of digits.  This occurs on positive and negative values that do not
fit in the display window (negative numbers require one more digit for the minus sign).
The value is passed to the handler as the event value.</p>

<p>This class inherits from FMXISBase to get listener capabilities.</p>

@class FMXISDigits
@codehint _digs
@author Jonathan Kaye (FlashSim.com)
@tooltip Simple digital display
*/ 
/*
This code was developed by Jonathan Kaye and Amethyst Interactive LLC,
Copyright 2002-2004, all rights reserved.
v2.0, February, 2004
*/
import mx.core.UIObject;
import mx.fmxis.FMXISBase;

[Event("onOverflow")]

[IconFile("digits.png")]

/**
Event generated when numeric value is larger (whole numbers) than what can fit in the display to
the left of the decimal point. Negative numbers consume one digit to represent the negative sign.
@event onOverflow
*/

class mx.fmxis.FMXISDigits extends FMXISBase {

	// bounding box for this button component
	private var boundingBoxClip:MovieClip;
	private var digEx:MovieClip;
	
	var className:String = "FMXISDigits";
	static var symbolOwner:Object = FMXISDigits;
	static var symbolName:String = "FMXISDigits";
	
	// Inspectable properties.  Let user change the event names, if desired.
	// The event names have to be set at the time the component is instantiated (either
	// at run-time, or programmatically at the attachMovie/createClassObject time).
	/**
	Event name for event generated if the value of the display (whole number) exceeds the
	number of positions to the left of the decimal point.  Negative numbers consume one
	digit to represent the negative sign.
	@property evtOverflow
	*/
	[Inspectable(name="onOverflow method name", type=String, defaultValue="onOverflow")]
	public var evtOverflow:String;

	[Inspectable(name="Digit plus bkgnd linkage ID", type=String, defaultValue="")]
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
	Whether or not to display the background graphic.  This can be set only in
	the component property panel.
	@property showBkgnd
	*/
	[Inspectable(name="Show background", type=Boolean, defaultValue=true)]
	public function set showBkgnd (v) {
		dispBkgnd(_showBkgnd = v);
	}
	
	public function get showBkgnd () {
		return _showBkgnd;
	}
	private var _showBkgnd:Boolean;
	
	/**
	Whether or not to display the digit value.  This is used to simulate the
	display on (true) or off (false).
	@property display
	*/
	[Inspectable(name="Display on", type=Boolean, defaultValue=true)]
	public function set display (v) {
		displayDigs(digsOn = v);
	}
	public function get display () {
		return digsOn;
	}
	private var digsOn:Boolean;
	

	/**
	A getter/setter property used to set and retrieve the number of decimal places
	(to the right of the decimal point).
	
	@property decPl
	*/
	[Inspectable(name="Number of decimal places", type=Number, defaultValue=1)]
	public function set decPl (v) {
		_decPl = v;
		invalidate();
	}
	public function get decPl () {
		return _decPl;
	}
	private var _decPl:Number;
	
	/**
	Boolean property true or false, whether or not to pad left of decimal point with 0's.
	This can be set only in the component parameter panel.  Use <code>chgLeadZero()</code> to set
	it programmatically.
	@property leadZero
	*/
	[Inspectable(name="Pad with 0's", type=Boolean, defaultValue=false)]
	public function set leadZero (v) {
		chgLeadZero(_leadZero = v);
	}
	public function get leadZero () {
		return _leadZero;
	}
	private var _leadZero:Boolean;
	
	/**
	Color of each digit.
	@property digTint
	*/
	[Inspectable(name="Digit color", type=Color, defaultValue="#00FF00")]
	public function set digTint (v) {
		setDigColor(_digTint = v);
	}
	public function get digTint () {
		return _digTint;
	}
	private var _digTint:Color;

	/**
	A getter/setter property used to set and retrieve the digital display's value.
	@property val
	*/
	[Inspectable(name="Starting value", type=Number, defaultValue=0)]
	public function set val (v) {
		setVal(pval = v);
	}
	public function get val () {
		return pval;
	}
	/**
	A private value used to hold the digital display's value.
	@property pval
	@access private
	*/
	private var pval;
	
	/**
	An array of defDigPlusBkgnd clips, for digits 1 - (numDigs-1).
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
	
	// event dispatch stuff
	private var dispatchEvent:Function;
	
	// clipParameters - for backward compatibility with Flash 6 player
	var clipParameters:Object = { listener:1, evtOverflow:1, numDigs:1, val:1, digPBkgndID:1,
								  leadZero:1, decPl:1, digTint:1, showBkgnd:1, display:1 };
	private static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(FMXISDigits.prototype.clipParameters, 
                               UIObject.prototype.clipParameters);

	
	static var digEvents:Array = new Array("onOverflow");
	
	// by default, use the event names as given by digEvents.  We made it a static
	// variable for space efficiency.
	private var myEvents:Array = digEvents;
	
	private var oneCharWidth:Number;
	private var oneCharHeight:Number;
	
	private var origW:Number;
	private var origH:Number;
	
	function FMXISDigits () {
		update();
	}
	
	private function dispBkgnd (f) {
		for (var i=0; i<_numDigs; i++) {
			digs[i].bkgnd._visible = (f == true);
		}
	}
	
	/**
	Initialization of component.  Create the digits that are
	necessary by copying from first (digEx).  Also initialize arrays that
	hold digits and colors.
	@method init
	@access private
	*/
	private function init (evts): Void {
	
		origW = _width
		origH = _height;
		
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
		
		// store original width and height of one character
		_xscale = _yscale = 100;
		oneCharWidth = _width;
		oneCharHeight = _height;
		
		arrangeDigits(_numDigs);
		setSize(origW, origH);
	}
	
	private function attachChildren () {
		var dpb = "defDigPlusBkgnd";
		
		if (digPBkgndID != "" && digPBkgndID != undefined) {
			dpb = digPBkgndID;
		}
		attachMovie(dpb, "digEx", 0);
	}
	
	private function draw () {
		arrangeDigits(_numDigs);
		setVal(pval); // restore value
		chgDecPlaces(_decPl);
		chgLeadZero(_leadZero);
		setDigColor(_digTint);
		setSize(origW, origH);
		dispBkgnd(_showBkgnd);
		displayDigs(digsOn);
	}
	
	private function arrangeDigits (nNum) {
		var i, nm, d2d = _digs2Del;
		
		if (d2d == undefined) {
			d2d = _numDigs;
		}
		
		if (nNum != d2d) {
			for (i=1; i<d2d; i++) {
				digs[i].removeMovieClip();
				delete digCols[i];
			}
			delete digCols;
			delete digs;
		}
		
		_numDigs = nNum;
		
		digCols = new Array(_numDigs);
		digs = new Array(_numDigs);
		digs[0] = digEx;
		
		for (i=0; i<_numDigs; i++) {
			if (i == 0) {
				digs[0]._x = digs[0]._y = 0;
				
			} else {
				nm = "d" + i;
				digs[i] = digEx.duplicateMovieClip(nm, i);
				// place next digit directly to right of last digit
				digs[i]._x = digs[i-1]._x + digs[0]._width;
			}
			digCols[i] = new Color(digs[i].dig);
			digCols[i].setRGB(Number(_digTint));
		}
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
		this.pval = v;
		this.update();
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
	Changes the number of decimal places displayed.
	
	@method chgDecPlaces
	@param dp Number of decimal places (0 for none).
	@example
	myDigs.chgDecPlaces(2);  // sets the display to two decimal places
	@access private
	*/
	private function chgDecPlaces (dp) {
		this._decPl = dp;
		this.update();
	}
	
	/**
	Sets whether or not to pad the left of decimal point with 0's (default is false).
	
	@method chgLeadZero
	@param f Pass in <code>true</code> to pad the display, <code>false</code> not to pad it.
	@example
	myDigs.chgLeadZero(true);
	@access private
	*/ 
	private function chgLeadZero (f) {
		this._leadZero = f;
		this.update();
	}
	
	/**
	Turn on (true) or off (false) the digital display.  Note: this does not turn then background off.
	
	@method display
	@param f Pass in <code>true</code> to show the digits, <code>false</code> to hide them (_visible == false).
	@example
	myDigs.display(false);  // turn off the digits
	@access private
	*/
	private function displayDigs (f) {
		digsOn = f;
		update();
	}

	/**
	Update, the main routine.  This takes the internal value, pval, and
	translates it into the digital display.
	@method update
	@access private
	*/
	private function update () {
		var i, ud, nd = _numDigs, negnum = false,
			runval, curpow, dpow, isodig, dpt, pn, highdig;
	
		if (digsOn) {
			// The idea is to take the available space in the display, use
			// that to determine how many digits will fit (dpow), then go
			// through the current value isolating the digits and placing
			// them in the display.
			// Along the way, if we're supposed to pad leading zeroes, do it,
			// but also make sure 0's are put to the right of the decimal
			// point whether or not padding is asked for.
			
			dpow = Math.pow(10, _numDigs - 1);
			// runval holds the value remaining so we can isolate digits
			runval = Math.round(pval * Math.pow(10, _decPl));
			if (pval < 0) {
				// If the value is negative, we'll add minus later.
				negnum = true;
				runval = -runval;
			}
			
			// highdig is used above 0 when the first non-zero digit is placed, it will tell future digits still on the left of the decimal pt that 0 is okay (such as 100).
			highdig = _leadZero;
			
			// Check for overflow
			if (Int(runval/dpow) >= 10) {
				eventObj.type = evtOverflow;
				eventObj.val = pval;
				dispatchEvent(eventObj);
				return;
			}
			
			pn = !negnum;  // have we placed negative yet?
			dpt = nd - _decPl - 1;  // pos decimal pt should appear
			
			// For each digit place, see how many units of dpow there are
			// in the current value.  If it's zero, and we're on the left of
			// the decimal point and we're not supposed to pad, then ignore.
			// Otherwise, put in the appropriate digit.
			for (i=0; i<nd; i++) {
				isodig = Int(runval / dpow);
	
				if (isodig != 0 || i >= dpt) {
					highdig = true;
					if (!pn) {
						if (i == 0) {
							// Run out of space!  Signal overflow.
							eventObj.type = evtOverflow;
							eventObj.val = pval;
							dispatchEvent(eventObj);
							return;
						}
						pn = true;
						if (_leadZero) {
							digs[0].dig.gotoAndStop(11);
							digs[0].dig._visible = true;
						} else {
							digs[i-1].dig.gotoAndStop(11);
							digs[i-1].dig._visible = true;
						}
					}
				}
				
				digs[i].dig._visible = (isodig != 0 || highdig);
				digs[i].dig.gotoAndStop(isodig + 1);
	
				runval -= (isodig * dpow);
				digs[i].dig.dpt._visible = (_decPl != 0 && i == dpt);
				if (digs[i].dig.dpt._visible && !digs[i].dig._visible)
					digs[i].dig._visible = true;
				dpow /= 10;
			}
		} else if (!isNaN(_numDigs)) {
			// digits are off, so make blank
			for (i=0; i<=_numDigs; i++) {
				digs[i].dig._visible = false;
			}
		}
	}
	
	private function setSize (nW, nH) {
		var i, digXScale, digYScale;
		
		if (oneCharWidth == undefined) {
			// called at the wrong time -- before anything set up
			return;
		}
		
		digXScale = 100 * nW / oneCharWidth / _numDigs;
		digYScale = 100 * nH / oneCharHeight;
		
		for (i=0; i<_numDigs; i++) {
			digs[i]._xscale = digXScale;
			digs[i]._yscale = digYScale;
			if (i != 0) {
				digs[i]._x = digs[i-1]._x + digs[0]._width;
			}
		}
		origW = nW;
		origH = nH;
		
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