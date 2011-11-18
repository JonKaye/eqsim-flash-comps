/**
<p>This class extends the digital display (<code>FMXISDigs</code>) to allow display of
alphanumeric characters as well.  It functions in two modes: first, if the
value is numeric, it does the same as <code>FMXISDigs</code>.  Second, if the value
is a string, it outputs it using alphanumeric characters.  It also adds the option to
left justify the alphanumeric string.</p>

<p>All English letters are represented, but few non-alphanumeric characters are given.  To extend
this component with other character sets, or with characters not provided, open and modify the <code>defDigXGfx</code>
movie clip.</p>
 
<p>Users can change the appearance by modifying:</p>
<li><code>defDigXBkgnd</code> - background</li>
<li><code>defDigXGfx</code> - clip with alphanumeric characters used</li>
<li><code>defDigPlusBkgnd</code> - movie clip that contains chars, background, and decimal point</li>
 
<p>The class has one event -- "onOverflow", indicating value has overflowed
the display.  This occurs on positive and negative values that do not
fit in the display window, as well as strings that don't fit.
The value is returned in the event's value.</p>
 
<p>This class inherits from FMXISDigs.</p>

@class FMXISAlphaNum
@codehint _alphaNum
@author Jonathan Kaye (FlashSim.com)
@tooltip Simple alphanumeric digital display
*/ 
/*
This code was developed by Jonathan Kaye and Amethyst Interactive LLC,
Copyright 2002-2004, all rights reserved.
v2.0, February, 2004
*/

import mx.core.UIObject;
import mx.fmxis.FMXISDigits;

[IconFile("alphanum.png")]

/**
Event generated when numeric value or alphanumeric string is larger than what can fit in the display
(for numbers, to
the left of the decimal point). For numbers, negative numbers consume one digit to represent the negative sign.
@event onOverflow
*/

class mx.fmxis.FMXISAlphaNum extends FMXISDigits {

	// bounding box for this button component
	private var boundingBoxClip:MovieClip;
	private var digEx:MovieClip;
	
	var className:String = "FMXISAlphaNum";
	static var symbolOwner:Object = FMXISAlphaNum;
	static var symbolName:String = "FMXISAlphaNum";

	/**
	Number of characters.  This can be set only in the component property panel.
	@property numDigs
	*/
	[Inspectable(name="Number of characters", type=Number, defaultValue=1)]
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
	A getter/setter property used to set and retrieve the display's value.
	@property val
	*/
	[Inspectable(name="Starting value", type=String, defaultValue="0")]
	public function set val (v) {
		setVal(v);
	}
	public function get val () {
		return pval;
	}

	/**
	If true, the alphanumeric string is left justified, otherwise (default) it is right justified. Note:
	this only affects strings, not numbers.
	
	@property leftJust
	*/
	[Inspectable(name="Left justify", type=Boolean, defaultValue=true)]
	public function set leftJust (v) {
		_leftJust = v;
		update();
		
	}
	public function get leftJust () {
		return _leftJust;
	}
	private var _leftJust:Boolean;
	
	
	// clipParameters - for backward compatibility with Flash 6 player
	var clipParameters:Object = { listener:1, evtOverflow:1, numDigs:1, val:1, digPBkgnd:1,
								  leadZero:1, decPl:1, digTint:1, showBkgnd:1, display:1, leftJust:1 };
	private static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(FMXISAlphaNum.prototype.clipParameters, 
                               UIObject.prototype.clipParameters);
								  

	private function FMXISAlphaNum () {	
	}
	
	private function init (evts): Void {
	
		// if the user has changed any event names, make sure named listeners are handled
		if (myEvents[0] != evtOverflow  ||
		    evts != null) {
			this.myEvents = [ evtOverflow ];
		}
		if (evts != null) {
			if (!(evts instanceof Array)) {
				evts = [ evts ];
			}
			
			super.init(myEvents = myEvents.concat(evts));
			
		} else {
			super.init(myEvents);
		}
		
		var v = parseFloat(pval);
		if (isFinite(v))
			pval = v;
					
		setVal(pval);
	}
	
	private function attachChildren () {
		var dpb = "defDigXPlusBkgnd";
		
		if (digPBkgndID != "" && digPBkgndID != undefined) {
			dpb = digPBkgndID;
		}
		
		attachMovie(dpb, "digEx", 0);
	}

	/**
	Update, the main routine.  This takes the internal value, pval, and
	translates it into the digital display.
	@method update
	@access private
	*/
	private function update () {
		if (typeof(pval) == "number") {
			super.update();
			return;
		} 
	
		var i, sv, cc, cp, len = Math.min(numDigs, pval.length);
	
		if (digsOn) {
			sv = (leftJust ? 0 : (numDigs - len));
		
			if (pval.length > numDigs) {
				eventObj.type = evtOverflow;
				eventObj.val = pval;
				dispatchEvent(eventObj);
			}
			for (i=sv; i<(sv+len); i++) {
				cp = i - sv;  // char pos
				cc = pval.charCodeAt(cp);
	
				if (cc >= 95)
					cc -= 32;
				if (cc >= 65 && cc <= 90) {
					digs[i].dig.gotoAndStop(12 + (cc - 65));
				} else if (cc >= 48 && cc <= 57) {
					digs[i].dig.gotoAndStop(1 + (cc - 48));
				} else if (cc == 32) {  // space
					digs[i].dig.gotoAndStop(38);
				} else if (cc == 45) { // hyphen
					digs[i].dig.gotoAndStop(11);
				}
				digs[i].dig._visible = true;
				digs[i].dig.dpt._visible = false;
			}
			if (leftJust) {
				while (i < numDigs) {
					digs[i].dig._visible = false;
					i++;
				}
			} else {
				for (i=0; i<sv; i++) {
					digs[i].dig._visible = false;
				}
			}
		} else {
			for (i=0; i<numDigs; i++)
				digs[i].dig._visible = false;
		}
	}
}


/**
Event name for event generated if the value of the display (whole number) exceeds the
number of positions to the left of the decimal point.  Negative numbers consume one
digit to represent the negative sign.
@property evtOverflow
*/

/**
Whether or not to display the background graphic.  This can be set only in
the component property panel.
@property showBkgnd
*/

/**
Whether or not to display the digit value.  This is used to simulate the
display on (true) or off (false).
@property display
*/

/**
A getter/setter property used to set and retrieve the number of decimal places
(to the right of the decimal point).

@property decPl
*/

/**
Boolean property true or false, whether or not to pad left of decimal point with 0's.
This can be set only in the component parameter panel.  Use <code>chgLeadZero()</code> to set
it programmatically.
@property leadZero
*/

/**
Color of each digit.
@property digTint
*/

/**
A getter/setter property used to set and retrieve the digital display's value.
@property val
*/

/* FROM FMXISBASE */

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
