/*
	************************************************
	
	FILE: AlphaNumDigits.as
	
	Copyright (c) 2004-2012, Jonathan Kaye, All rights reserved.

	Redistribution and use in source and binary forms, with or without modification, are permitted
	provided that the following conditions are met:

	- Redistributions of source code must retain the above copyright notice, this list of conditions
	and the following disclaimer.
	- Redistributions in binary form must reproduce the above copyright notice, this list of conditions
	and the following disclaimer in the documentation and/or other materials provided with the distribution.
	- Neither the name of the Equipment Simulations LLC nor the names of its contributors may be used to endorse or
	promote products derived from this software without specific prior written permission. 
	
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
	INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
	SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
	WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
	USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

	[Read more about this license at http://www.opensource.org/licenses/bsd-license.php]
	
	************************************************
*/

package com.eqsim.components { 
	
	import fl.core.UIComponent;
	import fl.core.InvalidationType;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	import com.eqsim.events.EventWithData;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	
	 /**
	Event generated when numeric value is larger (whole numbers) than what can fit in the display to
	the left of the decimal point. Negative numbers consume one digit to represent the negative sign.
	@event onOverflow
	*/
	[Event("onOverflow")]

	[IconFile("digits.png")]
	
	/** ************************************************
	<p>This class subsumes the behavior of NumDigits to allow alphanumeric characters.  In its "auto" mode, it has two possible behaviors: first, if the
	value is numeric (positive or negative floating-point number), it does the same as <code>NumDigits</code>.  Second, if the value
	is a string, it outputs it using alphanumeric characters.
	As opposed to "auto" mode, the <code>mode</code> property can also be set
	to <code>text</code> or <code>number</code> to force the component to that type.</p>
	
	<p>This components adds the option to
	left justify the alphanumeric string (this only works in text mode, or in auto mode when the value is not a number).
	Padding the left of a number with zeroes only works when the value is a number.</p>

	<p>All English letters are represented, but a few non-alphanumeric characters (punctuation) are provided.  To extend
	this component with other character sets, or with characters not provided, open and modify the <code>defDigXGfx</code>
	MovieClip, and see the explanation for the <code>extendedCharactersFunction</code> property (which can only be set programmatically).</p>
	 
	<p>Users can change the appearance by creating a MovieClip that has a background, decimal point, and digits graphics, exactly
	like defDigXPlusBkgnd.  Set the property <code>digSkinClassName</code> to the class name.</p>
	 
	<p>The class has one event -- "onOverflow", indicating value has overflowed
	the display.  This occurs on positive and negative values that do not
	fit in the display window, as well as strings that don't fit.
	The value is returned in the event's value.  If overflow occurs, the display is set to a line of 8s.</p> 
	 * ************************************************* */

	public class AlphaNumDigits extends UIComponent {

		/* ***************************************************
		 * Exposed Properties
		 * *************************************************** */
		 
		/**
		Event name for event generated if the value of the display exceeds the
		number of positions.  Negative numbers consume one
		digit to represent the negative sign.  If the number exceeds the space, the component
		puts 8888s in the display.
		@property evtOverflow
		*/
		[Inspectable(name="onOverflow method name", type=String, defaultValue="onOverflow")]
		public var evtOverflow:String = "onOverflow";

		/**
		 * The digSkinClassName lets you change the appearance of the alphanumeric display by using your own
		 * class based on MovieClip, with a structure paralleling the default class, defDigXPlusBkgnd.  Specifically,
		 * that class is composed of a MovieClip instance for digits named <code>dig</code> and a background graphic (MovieClip)
		 * named <code>bkgnd</code>.  Inside the <code>dig</code> MovieClip, there is are frames
		 * representing each graphical character, and a MovieClip in there named <code>dpt</code>. 
		 * <p>By default, the class name is <code>defDigXPlusBkgnd</code>.</p>
		 */
		[Inspectable(name="Alphanumeric skin class name", type=String, defaultValue="defDigXSkinClass")]
		public function set digSkinClassName (s:String) : void {
			changeSkin(_digSkinXClassName = s);
		}
		public function get digSkinClassName () : String {
			return _digSkinXClassName;
		}
		protected var _digSkinXClassName:String = "defDigXSkinClass";
		
		/**
		 * The default character set does not implement the full set of possible characters -- just alphanumeric.  If the
		 * developer wants to extend the set with more symbols or special characters, he can add them to the end of the
		 * skin class, and then use this function to determine which keyframe to jump to for that character.
		 *
		 * @property extendedCharactersFunction
		 * @example
		 * Suppose you want to extend the character set of this component.  First duplicate or edit the skin class defDigXGfx, and add
		 * your characters at the end of the movie clip in their own keyframes.  Then provide a function to <code>extendedCharactersFunction</code>
		 * that accepts a character code (integer, result of <code>getCharCode()</code>) and the digit movie clip.  Your function may look like this:
		 *
		 * function extendCharacters(c, mc) {
				switch (c) { case 62: mc.gotoAndStop(11); ...
				
			or something like that.  Make sure to assign your function to the <code>extendedCharactersFunction</code> property:
			
			inst.extendedCharactersFunction = extendCharacters;
		 */
		public var extendedCharactersFunction:Function;

		/**
		Number of characters.  This can be set only in the component property panel.
		@property numDigs
		*/
		[Inspectable(name="Number of digits", type=Number, defaultValue=1)]
		public function set numDigs (v:int) : void {
			_digs2Del = _numDigs;
			_numDigs = v;
			invalidate();
		}
		public function get numDigs () : int {
			return _numDigs;
		}
		protected var _numDigs:int = 1;
		private var _digs2Del:int = -1;

		/**
		Whether or not to display the background graphic.
		@property showBkgnd
		*/
		[Inspectable(name="Show background", type=Boolean, defaultValue=true)]
		public function set showBkgnd (v:Boolean) : void {
			dispBkgnd(_showBkgnd = v);
			invalidate();
		}
		
		public function get showBkgnd () : Boolean {
			return _showBkgnd;
		}
		protected var _showBkgnd:Boolean = true;
		
		/**
		Whether or not to display the digit value.  This is used to simulate the
		display on (true) or off (false).
		@property display
		*/
		[Inspectable(name="Display on", type=Boolean, defaultValue=true)]
		public function set display (v:Boolean) : void {
			displayDigs(_digsOn = v);
			invalidate();
		}
		public function get display () : Boolean {
			return _digsOn;
		}
		protected var _digsOn:Boolean = true;
		

		/**
		Number of decimal places to the right of the decimal point.
		
		@property decimalPlaces
		*/
		[Inspectable(name="Number of decimal places", type=Number, defaultValue=0)]
		public function set decimalPlaces (v:int) : void {
			_decPl = v;
			invalidate();
		}
		public function get decimalPlaces () : int {
			return _decPl;
		}
		protected var _decPl:Number = 0;
		
		/**
		Boolean property true or false, whether or not to pad left of decimal point with zeroes.
		This can be set only in the component parameter panel.
		@property leadZero
		*/
		[Inspectable(name="Pad with leading 0's", type=Boolean, defaultValue=false)]
		public function set leadZero (v:Boolean) : void {
			chgLeadZero(_leadZero = v);
			invalidate();
		}
		public function get leadZero () : Boolean {
			return _leadZero;
		}
		protected var _leadZero:Boolean = false;
		
		/**
		Color (int) of each digit, for example, 0xFF0000 is pure red.
		@property digTint
		*/
		[Inspectable(name="Digit color", type=Color, defaultValue="#00FF00")]
		public function set digTint (v:int) : void {
			setDigColor(_digTint = v);
			invalidate();
		}
		public function get digTint () : int {
			return _digTint;
		}
		protected var _digTint:int;

		/**
		Set and retrieve the display's value.
		@property val
		*/
		[Inspectable(name="Starting value", type=String, defaultValue="0")]
		public function set val (v:*) : void {
			setVal(pval = v);
			invalidate();
		}
		public function get val () : * {
			return pval;
		}
		/**
		A private value used to hold the digital display's value.
		@property pval
		@access private
		*/
		protected var pval:* = "0";
		
		
		/**
		If true, the alphanumeric string is left justified, otherwise (default) it is right justified. Note:
		this only affects strings, not numbers.
		
		@property leftJust
		*/
		[Inspectable(name="Left justify", type=Boolean, defaultValue=true)]
		public function set leftJust (v:Boolean) : void {
			_leftJust = v;
			invalidate();
		}
		
		public function get leftJust () : Boolean  {
			return _leftJust;
		}
		protected var _leftJust:Boolean = true;
		
		/**
		The 'mode' property can tell the component to render the value in a specific way: auto, number, or text.
		
		<li>auto - if the value can be parsed as a number, make it a number, otherwise treat it as a text string</li>
		<li>number - treat the value only as a number.  The component will use parseFloat() to render it as a number</li>
		<li>text - treat the value as a text string, regardless of whether it could be recognized as a number. Note: there is
		no built-in character for a period or decimal point when the value is treated as a string.</li>
		
		@property mode
		*/
		[Inspectable(name="Character mode", type=List, enumeration="auto,text,number", defaultValue="auto")]
		public function set mode (s:String) : void {
			_mode = s;
			invalidate();
		}
		
		public function get mode () : String {
			return _mode;
		}
		protected var _mode:String = "auto";
		
		// Used to prevent wasted updated before configUI has been invoked
		private var firstUpdateDone:Boolean = false;
		
		
		/* ***************************************************
		 * Protected/Private Properties
		 * *************************************************** */
		 
		/**
		 * An instance of the digit skin we use to get its height and width, for overall scaling.
		 */
		protected var digClip:MovieClip;
		/** 
		 * Sprite containing all the digits, makes it easier for overall scaling.
		 */
		protected var digitsContainer:Sprite;
		/**
		 * Class object for the digit skin.
		 */
		protected var digSkinClass:Class;
		
		/**
		An array of defDigPlusBkgnd clips, for digits 1 - (numDigs-1).
		@property digs
		@access private
		*/
		protected var digs:Array; // list of digit movie clips
		
		/**
		An array of Colors to modify the digit graphics (tint).
		@property digCol
		@access private
		*/
		protected var digCols:Array; // array of colors for each digit
		
		/* ***************************************************
		 * Constants
		 * *************************************************** */
		 
		/**
		 *
		 */
		

		/* ***************************************************
		 * Constructor and Required Methods (UIComponent)
		 * *************************************************** */ 

		/**
		 *
		 */
		public function AlphaNumDigits() {
			super();
			
			updateDisplay();
		}
		
		/**
		 * configUI
		 * Get the display objects created in preparation of launch.  Note that we get called before
		 * our constructor, and before we are notified that we are on the stage!
		 */
		override protected function configUI():void {
			super.configUI();
			
			digitsContainer = new Sprite();
			addChild(digitsContainer);
			
			changeSkin(_digSkinXClassName);
		
			digs = [];
		}
		
		
		/**
		 * 
		 */
		override protected function draw():void {
		
			arrangeDigits(_numDigs);
			setVal(pval);
			chgDecPlaces(_decPl);
			chgLeadZero(_leadZero);
			setDigColor(_digTint);
			dispBkgnd(_showBkgnd);
			displayDigs(_digsOn);
			updateDisplay();
		
			// Last line must call superclass method
			super.draw();
		}
		
		
		/* ***************************************************
		 * Exposed Methods
		 * *************************************************** */
		 
		 
		 
		/* ***************************************************
		 * Private/Protected Methods
		 * *************************************************** */
		/**
		 * Looks at the number of digits needed (and what is there already), then creates
		 * the digits and places them in the data structures for rendering.
		 * @access private
		 */
		protected function arrangeDigits (numOfDigits:int) : void {
			var i:int, d2d:int = _digs2Del;
			
			if (d2d == _numDigs && width == digitsContainer.width &&
				height == digitsContainer.height) {
				return;
			}
			
			for (i=0; i<digs.length; i++) {
				digitsContainer.removeChild(digs[i]);
			}
			_digs2Del = _numDigs;
			
			digitsContainer.scaleX = width / (_numDigs * digClip.width);
			digitsContainer.scaleY = height / digClip.height;
			
			_numDigs = numOfDigits;
			
			digCols = new Array(_numDigs);
			digs = new Array(_numDigs);

			for (i=0; i<_numDigs; i++) {
				digs[i] = new digSkinClass() as MovieClip;
				// place next digit directly to right of last digit
				digs[i].x = i * digClip.width;
				digs[i].y = digClip.height;
	
				digCols[i] = digs[i].dig.transform.colorTransform;
				digCols[i].color = _digTint;
				digs[i].dig.transform.colorTransform = digCols[i];
				digitsContainer.addChild(digs[i]);
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
		protected function setVal (v:*) : void {
			pval = v;
		}

												
		/**
		Sets the tint color of the digits (RGB value).
		
		@method setColor
		@param c RGB value of tint color.
		@example
		myDigs.setColor(0xFF0000);  // sets the digits to pure red
		@access private
		*/
		protected function setDigColor (c:Number) : void {
			
			// We're getting called before digits configured, so don't do anything if called in that situation
			if (digCols == null) {
				return;
			}
			for (var i:int=0; i<_numDigs; i++) {
				digCols[i].color = c;
				digs[i].dig.transform.colorTransform = digCols[i];
			}
			_digTint = c;
		}
		
		/**
		Changes the number of decimal places displayed.
		
		@method decimalPlaces
		@param dp Number of decimal places (0 for none).
		@example
		myDigs.decimalPlaces(2);  // sets the display to two decimal places
		@access private
		*/
		protected function chgDecPlaces (dp:int) : void {
			this._decPl = dp;
		}
		
		/**
		Sets whether or not to pad the left of decimal point with zeroes (default is false).
		
		@method chgLeadZero
		@param f Pass in <code>true</code> to pad the display, <code>false</code> not to pad it.
		@example
		myDigs.chgLeadZero(true);
		@access private
		*/ 
		protected function chgLeadZero (f:Boolean) : void {
			this._leadZero = f;
		}
		
		/**
		Turn on (true) or off (false) the digital display.  Note: this does not turn then background off.
		
		@method display
		@param f Pass in <code>true</code> to show the digits, <code>false</code> to hide them (_visible == false).
		@example
		myDigs.display(false);  // turn off the digits
		@access private
		*/
		protected function displayDigs (f:Boolean) : void {
			_digsOn = f;
		}

		/**
		Update, the main routine.  This takes the internal value, pval, and
		translates it into the digital display.
		@method update
		@access private
		*/
		protected function updateDigitDisplay () : void {
			var i:int, nd:int = _numDigs, negnum:Boolean = false,
				runval:Number, curpow:Number, dpow:Number, isodig:Number, dpt:Number, pn:Boolean, highdig:Boolean;
				
			if (!firstUpdateDone) {
				firstUpdateDone = true;
				return;
			}
		
			if (_digsOn) {
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
				if (Math.floor(runval/dpow) >= 10) {
					dispatchEvent(new EventWithData(evtOverflow, false, false, pval));
					fillWith8s();
					return;
				}
				
				pn = !negnum;  // have we placed negative yet?
				dpt = nd - _decPl - 1;  // pos decimal pt should appear
				
				// For each digit place, see how many units of dpow there are
				// in the current value.  If it's zero, and we're on the left of
				// the decimal point and we're not supposed to pad, then ignore.
				// Otherwise, put in the appropriate digit.
				for (i=0; i<nd; i++) {
					isodig = Math.floor(runval / dpow);
		
					if (isodig != 0 || i >= dpt) {
						highdig = true;
						if (!pn) {
							if (i == 0) {
								// Run out of space!  Signal overflow.
								dispatchEvent(new EventWithData(evtOverflow, false, false, pval));
								fillWith8s();
								return;
							}
							pn = true;
							if (_leadZero) {
								digs[0].dig.gotoAndStop(11);
								digs[0].dig.visible = true;
							} else {
								digs[i-1].dig.gotoAndStop(11);
								digs[i-1].dig.visible = true;
							}
						}
					}
					
					digs[i].dig.visible = (isodig != 0 || highdig);
					digs[i].dig.gotoAndStop(isodig + 1);
		
					runval -= (isodig * dpow);
					digs[i].dig.dpt.visible = (_decPl != 0 && i == dpt);
					if (digs[i].dig.dpt.visible && !digs[i].dig.visible)
						digs[i].dig.visible = true;
					dpow /= 10;
				}
			} else if (!isNaN(_numDigs)) {
				// digits are off, so make blank
				for (i=0; i<_numDigs; i++) {
					digs[i].dig.visible = false;
				}
			}
		}
		
		/**
		 * In the case of an overflow value, set the display to all 8s.
		 * @private
		 */
		protected function fillWith8s () : void {
			var i:int;
			
			for (i=0; i<_numDigs; i++) {
				digs[i].dig.gotoAndStop(9);
				digs[i].dig.dpt.visible = false;
			}
		}
		
		/**
		Update, the main routine.  This takes the internal value, pval, and
		translates it into the digital display.
		@method update
		*/
		protected function updateDisplay () : void {
			
			if (!firstUpdateDone) {
				firstUpdateDone = true;
				return;
			}
		
			if (mode != "text" && isFinite(parseFloat(pval))) {
				pval = parseFloat(pval);
				updateDigitDisplay();
				return;
			} 
		
			var i:int, sv:int, cc:int, cp:int, len:int = Math.min(numDigs, pval.length);
		
			if (_digsOn) {
				sv = (leftJust ? 0 : (numDigs - len));
			
				if (pval.length > numDigs) {
					dispatchEvent(new EventWithData(evtOverflow, false, false, pval));
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
					} else if (extendedCharactersFunction != null) {
						extendedCharactersFunction(cc, digs[i].dig);
					}
					
					digs[i].dig.visible = true;
					if (digs[i].dig.dpt != null) {
						digs[i].dig.dpt.visible = false;
					}
				}
				if (leftJust) {
					while (i < numDigs) {
						digs[i].dig.visible = false;
						i++;
					}
				} else {
					for (i=0; i<sv; i++) {
						digs[i].dig.visible = false;
					}
				}
			} else {
				for (i=0; i<numDigs; i++)
					digs[i].dig.visible = false;
			}
		}
		 
		/**
		 * Changes the skin of the digit.
		 * @private
		 */
		protected function changeSkin (s:String) : void {
			digSkinClass = getDefinitionByName(s) as Class;
			
			digClip = new digSkinClass() as MovieClip;
			_digSkinXClassName = s;
			
			invalidate();
		}
		
		/**
		 * Turns on or off the background in the digital display.
		 * @private
		 */
		protected function dispBkgnd (f:Boolean) : void {
			// We're getting called before digits configured, so don't do anything if called in that situation
			if (digs.length < _numDigs) {
				return;
			}
			for (var i:int=0; i<_numDigs; i++) {
				digs[i].bkgnd.visible = (f == true);
			}
		}
	}
}