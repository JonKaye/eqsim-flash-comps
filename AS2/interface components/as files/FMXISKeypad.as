/**
<p>This class implements a keyboard arranged in a grid.  Users can change the
appearance of buttons by changing the following graphics:</p>
<li><code>defKeypadKey</code> - graphic for keys in up and down positions</li>
<li><code>defKeypadCharsUp</code> - ggraphic overlay for keys in up position</li>
<li><code>defKeypadCharsDown</code> - ggraphic overlay for keys in down position</li>
 
<p>The class has the following events:</p>
<li><code>onKeyUp</code> Key pressed.  Value is object with properties <code>num</code> (index) and <code>char</code> (string character)</li>
<li><code>onKeyDown</code> Key released.  Value is same as onKeyUp</li>

<p>Key-down (<code>onKeyDown</code>, unless changed by the developer)
repeats at <code>repFreq</code> frequency when a key is held down longer than <code>holdDur</code> milliseconds.
Unlike a physical
keyboard, it also allows
you to show an offset of the overlay clips (the key labels) instead of all at once.  This
can be used to simulate a series of keys whose labels change.</p>

<p>If you have set a non-zero offset, then the number returned in the event still corresponds to
the row and column position (0 is first), but the component returns the character from
the character array respecting the offset.</p>
 
<p>This class inherits from FMXISBase to get listener capabilities.</p>
 
@class FMXISKeypad
@codehint _kpad
@author Jonathan Kaye (FlashSim.com)
@tooltip Simple keypad with repeater keys
*/
/*
This code was developed by Jonathan Kaye and Amethyst Interactive LLC,
Copyright 2002-2004, all rights reserved.
v2.0, February, 2004
*/
import mx.core.UIObject;
import mx.fmxis.FMXISBase;

[IconFile("keypad.png")]

/**
Event generated when user releases a key.
Value is object with properties <code>num</code> (index) and <code>char</code> (string character).  The
index corresponds to the row and column position (row major order) of the key on the screen.
If you have set a non-zero offset, then the number returned in the event still corresponds to
the row and column position (0 is first), but the component returns the character from
the character array respecting the offset.

@event onKeyUp
*/

/**
<p>Event generated when user presses a key, and repeatedly if the key is held down for longer
than <code>holdDur</code> milliseconds (repeated at <code>repFreq</code> millisecond frequency).</p>
<p>The event value is an object with properties <code>num</code> (index) and <code>char</code> (string character).  The
index corresponds to the row and column position (row major order) of the key on the screen.
If you have set a non-zero offset, then the number returned in the event still corresponds to
the row and column position (0 is first), but the component returns the character from
the character array respecting the offset.</p>

@event onKeyDown
*/

[Event("onKeyUp")]
[Event("onKeyDown")]
[Event("disabled")]

class mx.fmxis.FMXISKeypad extends FMXISBase {

	// bounding box for this button component
	private var boundingBoxClip:MovieClip;
	private var k0:MovieClip;
	
	var className:String = "FMXISKeypad";
	static var symbolOwner:Object = FMXISKeypad;
	static var symbolName:String = "FMXISKeypad";
	
	// Inspectable properties.  Let user change the event names, if desired.
	// The event names have to be set at the time the component is instantiated (either
	// at run-time, or programmatically at the attachMovie/createClassObject time).
	/**
	Name of the on-key-up event sent to listeners when a key is released.
	@property evtKeyUp
	*/
	[Inspectable(name="onKeyUp method name", type=String, defaultValue="onKeyUp")]
	public var evtKeyUp:String;
	/**
	Name of the on-key-down event sent to listeners when a key is pressed and when it is repeated.
	@property evtKeyDown
	*/
	[Inspectable(name="onKeyDown method name", type=String, defaultValue="onKeyDown")]
	public var evtKeyDown:String;
	
	[Inspectable(name="Momentary or toggle action", type=List, enumeration="momentary,toggle" defaultValue="momentary")]
	private var actionType:String;
	
	[Inspectable(name="Multi-selection (toggle only)", type=Boolean, defaultValue=false)]
	private var multiSelect:String;
	
	/**
	# of milliseconds after which we repeat key down events.  If this value is set to -1,
	then the component does not repeat key down events.
	@property holdDur
	*/
	[Inspectable(name="Pause before repeat", type=Number, defaultValue=250)]
	public var holdDur:Number;
	
	/**
	# of millisconds to repeat onKeyDown's, after key has been down <code>holdDur</code>
	(so long as <code>holdDur</code> is not -1).
	@property repFreq
	*/
	[Inspectable(name="Repetition frequency", type=Number, defaultValue=100)]
	public var repFreq:Number;
	
	/**
	Which index should be first displayed in series stored in Up and Down Chars
	movie clips
	@property keyOffset
	*/
	[Inspectable(name="Initial label offset", type=Number, defaultValue=0)]
	public function set keyOffset (v) {
		_keyOffset = v;
		invalidate();
	}
	public function get keyOffset () {
		return _keyOffset;
	}
	private var _keyOffset:Number;

	
	/**
	Boolean property indicating whether or not to display the hand cursor when the cursor is
	over the hit area of a key.
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
	
	// Object we use to pass events.  We reuse the same object for space efficiency concerns.
	private var keyReturnVal:Object = new Object();
	
	/**
	Number of rows of keys.  Use <code>setGrid()</code> to change the # of rows at runtime.
	@property _rows
	*/
	[Inspectable(name="Number of rows", type=Number, defaultValue=4)]
	public var _rows:Number;
	
	/**
	Number of columns of keys. Use <code>setGrid()</code> to change the # of rows at runtime.

	@property _cols
	*/
	[Inspectable(name="Number of columns", type=Number, defaultValue=3)]
	public var _cols:Number;

	
	/**
	Array of characters to add for keys, if pressed.
	@property chars
	*/
	[Inspectable(name="Characters", type=Array, defaultValue="0,1,2,3,4,5,6,7,8,9,10,11,12")]
	private var chars:Array;
	
	[Inspectable(name="Keypad key linkage ID", type=String, defaultValue="")]
	private var kpadKeyID:String;
	
	/**
	array of integers saying which keys should NOT be shown.
	@property noKeys
	*/
	[Inspectable(name="Index of no keys", type=Array, defaultValue="")]
	private var noKeys:Array;
	
	[Inspectable(name="Key spacing in X dimension", type=Number, defaultValue=0)]
	public function set xSpacing(v) {
		_xSpacing = v;
		invalidate();
	}
	public function get xSpacing() {
		return _xSpacing;
	}
	private var _xSpacing:Number;
	
	[Inspectable(name="Key spacing in Y dimension", type=Number, defaultValue=0)]
	public function set ySpacing(v) {
		_ySpacing = v;
		invalidate();
	}
	public function get ySpacing() {
		return _ySpacing;
	}
	private var _ySpacing:Number;

	
	// Used internally for timing of key down repetitions
	private var holdID:Number;
	private var repID:Number;
	
	private var kpadWidth:Number;
	private var kpadHeight:Number;
	
	public var allowEvents:Boolean;
			
	// event dispatch stuff
	private var dispatchEvent:Function;
	
	// clipParameters - for backward compatibility with Flash 6 player
	var clipParameters:Object = { listener:1, evtKeyUp:1, evtKeyDown:1, keyOffset:1,
								  actionType:1, multiSelect:1,
								  xSpacing:1, ySpacing:1,
								  holdDur:1, repFreq:1, showHand:1, kpadKeyID:1 };
	private static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(FMXISKeypad.prototype.clipParameters, 
                               UIObject.prototype.clipParameters);

	
	static var keyEvents:Array = new Array("onKeyUp", "onKeyDown", "disabled");
	
	// by default, use the event names as given by keyEvents.  We made it a static
	// variable for space efficiency.
	private var myEvents:Array = keyEvents;
	
	private var suppressEvents:Boolean; // used during execEvent if caller does not want to generate events
	
	// constructor
	function FMXISKeypad () {
	}
	
	private function init (evts): Void {
		// if the user has changed any event names, make sure named listeners are handled
		if (myEvents[0] != evtKeyUp  ||
			myEvents[1] != evtKeyDown ||
		    evts != null) {
			this.myEvents = new Array(evtKeyUp, evtKeyDown, "disabled");
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
		
		kpadWidth = _width;
		kpadHeight = _height;
		
		setupKeys(_rows, _cols);
	}
	
	// Resets all keys to their up state (not pressed)
	public function resetKeysToUp (q) {
		var nKeys = _rows * _cols, k;
		for (var i=0; i<nKeys; i++) {
			k = this["k" + i];
			if (k.upState == false) {
				releaseKey(i, q);
			}
		}
	}
	
	// We don't do setupKeys here because rows and cols can only be changed
	// through setGrid().
	private function draw () {
		setKeyOffset(_keyOffset);
	}
	
	private function setupKeys (newRows, newCols) {
		var i, j, ri, k, nk;

		if (newRows != _rows || newCols != _cols) {
			// We have to reset the grid, so delete the existing keys
			for (i=0, ri=0; i<_rows; i++) {
				for (j=0; j<_cols; j++, ri++) {
					if (ri != 0) {
						this["k" + ri].removeMovieClip();
					}
				}
			}
		}
		
		for (ri=0, i=0; i<newRows; i++) {
			for (j=0; j<newCols; j++, ri++) {
				if (ri != 0) {
					k = k0.duplicateMovieClip("k" + ri, ri);
				} else {
					k = k0;
				}
				k.txt._visible = true;
				k.dntxt._visible = false;
				k.onPress = keyPressHandle;
				k.onRelease = k.onReleaseOutside = keyReleaseHandle;
				k.useHandCursor = showHand;
				k._visible = true;
				k.upState = true;
				// We'll set the key's position in setSize()
			}
		}
		
		_rows = newRows;
		_cols = newCols;
		
		// remove keys that shouldn't be visible
		nk = new Array();
		
		for (i=0; i<noKeys.length; i++)
			nk.push(parseInt(noKeys[i]));
		
		this.chgNoKeys(nk);
		// added for key text offset.  This shows the text for keys starting at the
		// offset specified
		this.setKeyOffset(_keyOffset);
		
		// size to available space
		setSize(kpadWidth, kpadHeight);
	}
	
	/**
	This method is for resetting the grid at runtime to a new grid configuration.
	@method setGrid
	@param rows Number of rows
	@param cols Number of columns
	@param chars (optional) New character set array
	@param noKeys (optional) Array of key indexes where keys should not appear (row major).  If you pass this in but don't want to change <code>chars</code>, pass <code>undefined</code> for chars.
	@example
	myKeypad.setGrid(3, 2); // reset to 3x2 grid
	myKeypad.setGrid(2, 2, undefined, [2, 3]); // reset to 2x2 grid with keys 3 and 4 missing
	*/
	public function setGrid (r, c, chars, nk) {
		if (chars != undefined) {
			chgChars(chars);
		}
		if (nk != undefined) {
			chgNoKeys(nk);
		}
			
		setupKeys (r, c);
	}
	
	private function attachChildren () {
		var kpk = "defKeypadKey";
		
		if (kpadKeyID != "" && kpadKeyID != undefined) {
			kpk = kpadKeyID;
		}
		
		attachMovie(kpk, "k0", 0);
	} 
 
	private function generateKeyDown () {
		if (!suppressEvents) {
			eventObj.type = evtKeyDown;
			eventObj.val = keyReturnVal;
			dispatchEvent(eventObj);
		}
	}
	
	private function wait4Hold () {
		clearInterval(holdID);
		holdID = undefined;
		repID = setInterval(this, "generateKeyDown", repFreq);
	}
	
	/**
	Simulate the pressing of key <code>knum</code>.
	@method pressKey
	@param knum Index of key to press
	@example
	myKeypad.pressKey(2); // simulate pressing the third key (row major) in the keypad
	*/
	
	function pressKey (knum, q) {
		var k = this["k" + knum];
		
		if (actionType == "toggle") {
			if (!k.upState) {
				releaseKey(knum, q);
				return;
			}
			if (!multiSelect) {
				resetKeysToUp(q);
			}
		}

		k.gotoAndStop(2);
		k.upState = false;
		k.txt._visible = false;
		k.dntxt._visible = true;
		keyReturnVal.num = knum;
		keyReturnVal.char = chars[knum + _keyOffset];
		
		suppressEvents = (q == true);
		if (holdDur != -1 && actionType == "momentary") {
			holdID = setInterval(this, "wait4Hold", holdDur);
		}
		generateKeyDown();
	}
	
	/**
	Given an event string and value that matches what this component would generate, perform the action.
	For the keypad component, the events are onKeyDown and onKeyUp, and the value is an object
	with a num (index) position and character.
	
	@method execEvent
	@param evName Event name (string) must match the event this component generates
	@param evVal (optional) value accompanying the event (if the event has an accompanying value)
	@param quiet (optional) set this to true if component should perform the action but not generate an event (this should be false or undefined, unless you know what you are doing)
	@example
	myKeypad.execEvent("onKeyDown", {num:0} ); // presses the top left key
	*/
	public function execEvent (evName:String, evVal, q:Boolean):Void {
		if (evName == myEvents[0]) {
			releaseKey(evVal.num, q);
		} else if (evName == myEvents[1]) {
			pressKey(evVal.num, q);
		}
	}

	
	/**
	Simulate the releasing of key <code>knum</code>.
	@method releaseKey
	@param knum Index of key to release
	@param quiet (optional) set this to true if component should perform the action but not generate an event (this should be false or undefined, unless you know what you are doing)
	@example
	myKeypad.releaseKey(2); // simulate releasing the third key (row major) in the keypad
	*/
	function releaseKey (knum, q) {
		if (holdID != undefined) {
			clearInterval(holdID);
			holdID = undefined;
		}
		if (repID != undefined) {
			clearInterval(repID);
			repID = undefined;
		}
		
		var k = this["k" + knum];
		k.gotoAndStop(1);
		k.txt._visible = true;
		k.dntxt._visible = false;
		keyReturnVal.num = knum;
		keyReturnVal.char = chars[knum + _keyOffset];
		k.upState = true;
		
		if (q != true) {
			eventObj.type = evtKeyUp;
			eventObj.val = keyReturnVal;
			dispatchEvent(eventObj);
		}
	}
	
	private function keyPressHandle () {
		// Note: we have to use this._parent because 'this' refers to
		// the individual key clip, not the component (scoping bug due to MM, I think)
		if (!_parent.allowEvents) {
			_parent.eventObj.type = "disabled";
			_parent.dispatchEvent(_parent.eventObj);
			return;
		}
		this._parent.pressKey(parseInt((this._name).substr(1)));
	}
	private function keyReleaseHandle () {
		if (!_parent.allowEvents) {
			return;
		}
		if (this._parent.actionType == "momentary") {
			this._parent.releaseKey(parseInt((this._name).substr(1)));
		}
	}
	
	/**
	Replace the character map with the given array of characters indexed from 0 to
	row X column.
	
	@method chgChars
	@param ch Array of characters to use as the character map (indexed by key index)
	*/
	private function chgChars (ch) {
		chars = ch;
	}
	
	/**
	Set the base index for the characters and keys to be displayed.  This allows the developer
	to change the characters to a different set (for example, lowercase and uppercase) on the fly.
	
	@method setKeyOffset
	@param offset
	*/
	private function setKeyOffset (offset) {
		for (var i=0; i<_rows * _cols; i++) {
			with (this["k" + i]) {
				txt.gotoAndStop(1 + i + offset);
				dntxt.gotoAndStop(1 + i + offset);
			}
		}
		_keyOffset = offset;
	}
	
	/**
	Given an array of key indices <code>nk</code>, turn the key's off that are in the array, and
	on that are not in the array.
	@method chgNoKeys
	@param nk Array of key indexes
	@access private
	*/
	private function chgNoKeys (nk) {
		var i, k, keyAr = new Array(this.chars.length);
		
		for (i=0; i<this.chars.length; i++) {
			keyAr[i] = i;
		}
		for (i=0; i<nk.length; i++) {
			keyAr[nk[i]] = -1;
		}
		for (i=0; i<this.chars.length; i++) {
			k = this["k" + i];
			k._visible = (keyAr[i] == i);
		}
		
		delete keyAr;
		noKeys = nk;
	}
	
	
	private function setSize (nW, nH) {
		var i, j, ri, digXScale, digYScale, k;
				
		k0._xscale = k0._yscale = 100;
		
		digXScale = 100 * (nW - xSpacing*(_cols-1)) / kpadWidth / _cols;
		digYScale = 100 * (nH - ySpacing*(_rows-1)) / kpadHeight / _rows;

		for (i=0, ri=0; i<_rows; i++) {
			for (j=0; j<_cols; j++, ri++) {
				k = this["k" + ri];
				k._xscale = digXScale;
				k._yscale = digYScale;
				if (ri == 0) {
					k._x = k0._width / 2;
					k._y = k0._height / 2;
				} else {
					k._x = k0._width / 2 + j*k._width + j*xSpacing/4;
					k._y = k0._height / 2 + i*k._height + i*ySpacing/4;
				}
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