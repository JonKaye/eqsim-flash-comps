/*
	************************************************
	
	FILE: NumDigits.as
	
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
	
	/** ************************************************
	<p>This class implements a simple digital display (positive and negative numbers, as integers or floating point).</p>

	Users can change the appearance by modifying:
	<li><code>defDigBkgnd</code> - background</li>
	<li><code>defDigGfx</code> - clip with digits used</li>
	<li><code>defDigDecPt</code> - decimal point graphic</li>
	<li><code>defDigPlusBkgnd</code> - movie clip that contains digits, background, and decimal point</li>
	 
	<p>The class has one event -- "DigOverflow", indicating value cannot be represented in the specified
	number of digits.  This occurs on positive and negative values that do not
	fit in the display window (negative numbers require one more digit for the minus sign).
	The value is passed to the handler as the event value.</p> 
	 * ************************************************* */

	 /**
	Event generated when numeric value is larger (whole numbers) than what can fit in the display to
	the left of the decimal point. Negative numbers consume one digit to represent the negative sign.
	@event onOverflow
	*/
	[Event("onOverflow")]

	[IconFile("digits.png")]

	public class NumDigits extends UIComponent {

		/* ***************************************************
		 * Exposed Properties
		 * *************************************************** */
		 
		/**
		Event name for event generated if the value of the display (whole number) exceeds the
		number of positions to the left of the decimal point.  Negative numbers consume one
		digit to represent the negative sign.  If the number exceeds the space, the component
		puts all 8s in the display.
		@property evtOverflow
		*/
		[Inspectable(name="onOverflow method name", type=String, defaultValue="onOverflow")]
		public var evtOverflow:String = "onOverflow";

		[Inspectable(name="Digit skin class name", type=String, defaultValue="defDigSkinClass")]
		public function set digSkinClassName (s:String) : void {
			changeSkin(_digSkinClassName = s);
			invalidate();
		}
		public function get digSkinClassName () : String {
			return _digSkinClassName;
		}
		protected var _digSkinClassName:String = "defDigSkinClass";

		/**
		Number of digits.
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
		protected var _numDigs:Number = 1;
		private var _digs2Del:Number;		// used to hold number of digits previous to numDigs change.

		/**
		Whether or not to display the background graphic.
		@property showBkgnd
		*/
		[Inspectable(name="Show background", type=Boolean, defaultValue=true)]
		public function set showBkgnd (v:Boolean) : void {
			if (v != _showBkgnd) {
				dispBkgnd(_showBkgnd = v);
				invalidate();
			}
		}
		
		public function get showBkgnd () : Boolean {
			return _showBkgnd;
		}
		protected var _showBkgnd:Boolean = true;
		
		/**
		Whether or not to display the set value.  This is used to simulate the
		display on (true) or off (false).
		@property display
		*/
		[Inspectable(name="Display on", type=Boolean, defaultValue=true)]
		public function set display (v:Boolean) : void {
			if (_digsOn != v) {
				displayDigs(_digsOn = v);
				invalidate();
			}
		}
		public function get display () : Boolean {
			return _digsOn;
		}
		protected var _digsOn:Boolean = true;
		

		/**
		Number of decimal places (to the right of the decimal point).
		
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
		@property leadZero
		*/
		[Inspectable(name="Pad with leading 0's", type=Boolean, defaultValue=false)]
		public function set leadZero (v:Boolean) : void {
			if (_leadZero != v) {
				chgLeadZero(_leadZero = v);
				invalidate();
			}
		}
		public function get leadZero () : Boolean {
			return _leadZero;
		}
		protected var _leadZero:Boolean = false;
		
		/**
		Color of each digit (integer RGB, for example 0xFF0000 for Pure Red).
		@property digTint
		*/
		[Inspectable(name="Digit color", type=Color, defaultValue="#00FF00")]
		public function set digTint (v:int) : void {
			if (_digTint != v) {
				setDigColor(_digTint = v);
				invalidate();
			}
		}
		public function get digTint () : int {
			return _digTint;
		}
		protected var _digTint:int;

		/**
		Get or set the digital display's value.
		@property val
		*/
		[Inspectable(name="Starting value", type=Number, defaultValue=0)]
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
		protected var pval:* = 0;
	
		
		
		/* ***************************************************
		 * Protected/Private Properties
		 * *************************************************** */
		 
		/**
		 * MovieClip holding the digit graphics
		 */
		protected var digClip:MovieClip;
		/**
		 * Sprite container for the digital display (to make scaling easier).
		 */
		protected var digitsContainer:Sprite;
		
		/**
		 * The class for the digit skin.
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
		
		/**
		 * Used to prevent wasted updated before configUI has been invoked
		 */
		private var firstUpdateDone:Boolean = false;
		
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
		public function NumDigits() {
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
			
			changeSkin(_digSkinClassName);
		
			digs = [];
		}
		
		
		/**
		 * 
		 */
		protected override function draw():void {
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
			
			_digs2Del = _numDigs;
			for (i=0; i<digs.length; i++) {
				digitsContainer.removeChild(digs[i]);
			}
			
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
			if ( digCols == null || (_numDigs > 0 && digCols[0].color == c) ) {
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
		*/
		protected function updateDisplay () : void {
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
		 * Changes the skin of the digit.
		 * @private
		 */
		protected function changeSkin (s:String) : void {
			digSkinClass = getDefinitionByName(s) as Class;
			
			digClip = new digSkinClass() as MovieClip;
			_digSkinClassName = s;
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