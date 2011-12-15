/*
	************************************************
	
	FILE: Jog.as
	
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
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	import flash.geom.Point;
	import flash.media.Sound;
	import com.eqsim.events.EventWithData;

[IconFile("jog.png")]

/**
Event generated when jog knob value has changed.  You can change the name of the event in the <code>evtChg</code> property.
@event onValChg
*/
[Event("onValChg")]
/**
Event generated when jog knob is set as <code>enabled == false</code>.  You can change the name of the event in the <code>evtDisabled</code> property.
@event onDisabled
*/
[Event("onDisabled")]

	/** ************************************************
	<p>This class implements a simple jog.  Developers can set the increment, number of positions
	in one cycle, integer vs. discrete, and whether the jog is adjusted by clicking and dragging,
	or merely moving in a circular motion.</p>

	<p>Developers can change the appearance by modifying:</p>
	<li><code>defJogBkgnd</code> - background</li>
	<li><code>defJogIndicator</code> - indicator clip</li>

	<p>You can change the indicator (the part of the jog that rotates) by changing the
	<code>indicatorClassName</code> parameter, to replace the default indicator graphic with a MovieClip/Sprite from
	the Library specified by class name.  The movie clip must have its center at
	the center of rotation, so if the developer simply wants to change the indicator (notch), then the
	indicator should be placed in the topmost (pointing up) position at the edge of the background.  Even if you turn off the background graphic, that clip
	is used to determine the hit area of the knob, as well as the indicator graphic itself.</p>
	<p>The class has one event, by default called "onValChg" (but this can
	be changed in the property inspector, or by changing the <code>evtChg</code> property), and
	the value is the increment that
	the jog was moved.  The <code>drawTicks</code> property, if true, tells the component
	to draw <code>numTicks</code> ticks.</p>

	<p>The position of the jog indicator can be set using the <code>val</code> property (from 0 to <code>units</code> [number of units in one revolution]).</p>

	<p>If the <code>enabled</code> property is set to <code>false</code>, the component will generate an <code>onDisabled</code> event with no data.  That event
	name can also be changed using the <code>evtDisabled</code> property.</p>
	 * ************************************************* */
	public class Jog extends UIComponent {

		/* ***************************************************
		 * Exposed Properties
		 * *************************************************** */
		 
		/**
		 * Let user change the event names, if desired.
		 * The event name has to be set at the time the component is instantiated (either
		 * at run-time, or programmatically).
		 * @property
		 */
		[Inspectable(name="onValChg method name", type=String, defaultValue="onValChg")]
		public var evtChg:String = "onValChg";
		
		/**
		 * Let user change the event names, if desired.
		 * The event name has to be set at the time the component is instantiated (either
		 * at run-time, or programmatically).
		 * @property
		 */
		[Inspectable(name="onDisabled method name", type=String, defaultValue="onDisabled")]
		public var evtDisabled:String = "onDisabled";
		
		/**
		 * Whether interaction is by click-and-drag (true) or roll-over (false).
		 * @property
		 */
		[Inspectable(name="Turn by dragging", type=Boolean, defaultValue="true")]
		public function set turnByDragging (f:Boolean) : void {
			_turnByDragging = f;
			setupMouseEvents();
		}
		public function get turnByDragging () : Boolean {
			return _turnByDragging;
		}
		public var _turnByDragging:Boolean = true;
			
		/**
		 * Whether jog moves in discrete steps (integers) or continuous.
		 * @property
		 */
		[Inspectable(name="Discrete steps", type=Boolean, defaultValue=false)]
		public function set discreteSteps(f:Boolean) : void {
			_discreteSteps = f;
			setVal(_val, true);
		}
		public function get discreteSteps () : Boolean {
			return _discreteSteps;
		}
		protected var _discreteSteps:Boolean = false;
				
		/**
		 * Whether or not to show the tick marks.
		 * @property
		 */
		[Inspectable(name="Show tick marks", type=Boolean, defaultValue=false)]
		public function set showTicks (f:Boolean) : void {
			_showTicks = f;
			if (f) {
				drawTicks();
			} else if (tickSprite != null) {
				tickSprite.graphics.clear();
			}
		}
		public function get showTicks () : Boolean {
			return _showTicks;
		}
		protected var _showTicks:Boolean = false;
		
		/**
		 * Tick line color (if showTicks is true).
		 * @property
		 */
		[Inspectable(name="Tick line color", type=Color, defaultValue="0")]
		public function set tickLineColor (c:int) : void {
			_tickLineColor = c;
			if (_showTicks) {
				drawTicks();
			}
		}
		public function get tickLineColor () : int {
			return _tickLineColor;
		}
		protected var _tickLineColor:int = 0;
		
		/**
		 * Tick line thickness (if showTicks is true).
		 * @property
		 */
		[Inspectable(name="Tick line thickness", type=Number, defaultValue="1")]
		public function set tickLineThickness (c:int) : void {
			_tickLineThickness = c;
			if (_showTicks) {
				drawTicks();
			}
		}
		public function get tickLineThickness () : int {
			return _tickLineThickness;
		}
		protected var _tickLineThickness:Number = 1;
		
		/**
		 * Number of tick marks to distribute around knob.
		 * @property
		 */
		[Inspectable(name="Num of tick marks", type=Number, defaultValue=12)]
		public function set numTicks (n:int) : void {
			_numTicks = n;
			if (_showTicks) {
				drawTicks();
			}
		}
		public function get numTicks () : int {
			return _numTicks;
		}
		protected var _numTicks:int = 12;
		
		/**
		 * Units in one revolution.
		 * @property
		 */
		[Inspectable(name="Num of units in 1 revolution", type=Number, defaultValue=12)]
		public function set units (v:int) : void {
			_units = v;
			setVal(_val, true);
		}
		public function get units () : int {
			return (_units);
		}
		protected var _units:int = 12;
		
		/**
		 * Starting value (from 0 to <code>units</code> (number of units in 1 revolution).
		 * @property
		 */
		[Inspectable(name="Starting value", type=Number, defaultValue=0)]
		public function set val (v:Number) : void {
			setVal(v, true);
		}
		public function get val () : Number {
			return (_val);
		}
		protected var _val:Number = 0;

		/**
		 * Snap the indicator to the closest integer position when user released mouse
		 * @property
		 */
		[Inspectable(name="Snap to integer?", type=Boolean, defaultValue=false)]
		public var snap2Int:Boolean = false;
		
		/**
		 * Class name of the indicator Sprite
		 * @property
		 */
		[Inspectable(name="Indicator Class Name", type=String, defaultValue="defJogIndicator")]
		public function set indicatorClassName (v:String) : void {
			changeIndicator(v);
		}
		public function get indicatorClassName () : String {
			return (_indicatorClassName);
		}
		protected var _indicatorClassName:String = "defJogIndicator";
		
		/**
		 * Class name of the background Sprite
		 * @property
		 */
		[Inspectable(name="Background skin Class", type=String, defaultValue="defJogBackground")]
		public function set backgroundClassName (v:String) : void {
			changeBackground(v);
		}
		public function get backgroundClassName () : String {
			return (_backgroundClassName);
		}
		protected var _backgroundClassName:String = "defJogBackground";

		/**
		Whether or not to play the sound on a value change (default is false, do not play sound).
		@property useSound
		*/
		[Inspectable(name="Use sound on change", type=Boolean, defaultValue="false")]
		public function set useSound (f:Boolean) : void {
			_useSound = f;
		}
		public function get useSound () : Boolean {
			return useSound;
		}
		protected var _useSound:Boolean = false;
		
		/**
		 * Class name of the audio click.  If you do not want a click, clear this field, or set useSound to false.  The click
		 * is really only for when discreteSteps or snap-to-integer are in place -- otherwise the click sounds get garbled since a click sound
		 * is generated each value change (which may be quite small).
		 * @property
		 */
		[Inspectable(name="Audio click class name", type=String, defaultValue="aClickSound")]
		public function set clickSoundClass (s:String) : void {
			setClickSound(s);
		}
		public function get clickSoundClass () : String {
			return _clickSoundClass;
		}
		protected var _clickSoundClass:String = "aClickSound";
		protected var sndObj:Sound;
		
		/**
		 * Show or hide the hand cursor
		 * @property
		 */
		[Inspectable(name="Use hand cursor", type=Boolean, defaultValue=true)]
		public function set showHand (f:Boolean) : void {
			backgroundClip.useHandCursor = indicatorClip.useHandCursor = _showHand = f;
		}
		public function get showHand () : Boolean {
			return _showHand;
		}
		protected var _showHand:Boolean = true;
		
		/**
		 * Show or hide the background.  Even if the background is hidden (alpha == 0, not visible == false), it is still used as
		 * a hit area for the knob.  Therefore, if you want to set the hit area for the knob, you
		 * need to size the background appropriately, even if you set it to be hidden.
		 * @property
		 */
		[Inspectable(name="Show background", type=Boolean, defaultValue=true)]
		public function set showBkgnd (f:Boolean) : void {
			backgroundClip.alpha = (f ? 100 : 0);
			_showBkgnd = f;
		}
		public function get showBkgnd () : Boolean {
			return _showBkgnd;
		}
		protected var _showBkgnd:Boolean = true;
		
		
		/* ***************************************************
		 * Protected/protected Properties
		 * *************************************************** */
		
		protected var indicatorClip:Sprite;
		protected var backgroundClip:Sprite;
		protected var tickSprite:Sprite;
		protected var knobContainer:Sprite;
		
		// Properties used internally to manipulate Jog
		protected var holdAng:Number;
		protected var holdAngSet:Boolean;
		protected var baseAng:Number;
		protected var oldAng:Number;
		protected var valPriv:Number;
		protected var lastIntVal:Number;
		protected var _beginVal:Number;
		
		
		
		/* ***************************************************
		 * Constants
		 * *************************************************** */
		 protected static const CONST_180_OVER_PI:Number = (180/Math.PI);
		 protected static const DEGREE_PER_RADIAN:Number = 0.0174532925199433;
		

		/* ***************************************************
		 * Constructor and Required Methods (UIComponent)
		 * *************************************************** */ 

		/**
		 *
		 */
		public function Jog() {
			super();
		}
		 
		/**
		 * configUI
		 * Get the display objects created in preparation of launch.  Note that we get called before
		 * our constructor, and before we are notified that we are on the stage!
		 */
		override protected function configUI():void {
			super.configUI();
		
			knobContainer = new Sprite();
			changeBackground(_backgroundClassName);
			changeIndicator(_indicatorClassName);
			setClickSound(_clickSoundClass);
			
			// Reset protected values used in angle computations
			oldAng = baseAng = 0;
			
			setupMouseEvents();

			// hold onto current integer value, in case we are supposed to snap to integer
			// and we need to know if we've reached an integer yet
			lastIntVal = int(_val);

			// initialize jog at starting position
			setVal(_val, true);
		
			// Draw the tick marks, if directed to
			if (_showTicks)
				drawTicks();
				
			addChild(knobContainer);
			
			addEventListener(Event.REMOVED_FROM_STAGE, catchNoStagePtr);
		}
		
		protected function setupMouseEvents () : void {
			// Set up the mouse event handlers depending on whether we're supposed
			// to respond to click-and-drag, or rollOver/rollOut
			if (_turnByDragging) {
				if (!hasEventListener(MouseEvent.MOUSE_DOWN)) {
					backgroundClip.addEventListener(MouseEvent.MOUSE_DOWN, jogEngage);
					backgroundClip.addEventListener(MouseEvent.MOUSE_UP, jogRelease);
					indicatorClip.addEventListener(MouseEvent.MOUSE_DOWN, jogEngage);
					indicatorClip.addEventListener(MouseEvent.MOUSE_UP, jogRelease);
				}
				
				if (hasEventListener(MouseEvent.ROLL_OVER)) {
					backgroundClip.removeEventListener(MouseEvent.ROLL_OVER, jogEngage);
					backgroundClip.removeEventListener(MouseEvent.ROLL_OUT, jogRelease);
					indicatorClip.removeEventListener(MouseEvent.ROLL_OVER, jogEngage);
					indicatorClip.removeEventListener(MouseEvent.ROLL_OUT, jogRelease);
				}
				
			} else if (!hasEventListener(MouseEvent.ROLL_OVER)) {
				backgroundClip.addEventListener(MouseEvent.ROLL_OVER, jogEngage);
				backgroundClip.addEventListener(MouseEvent.ROLL_OUT, jogRelease);
				indicatorClip.addEventListener(MouseEvent.ROLL_OVER, jogEngage);
				indicatorClip.addEventListener(MouseEvent.ROLL_OUT, jogRelease);
				
				if (hasEventListener(MouseEvent.MOUSE_DOWN)) {
					backgroundClip.removeEventListener(MouseEvent.MOUSE_DOWN, jogEngage);
					backgroundClip.removeEventListener(MouseEvent.MOUSE_UP, jogRelease);
					indicatorClip.removeEventListener(MouseEvent.MOUSE_DOWN, jogEngage);
					indicatorClip.removeEventListener(MouseEvent.MOUSE_UP, jogRelease);
				}
					
			}
			
		}
		
		/**
		 * 
		 */
		protected override function draw():void {
			
			knobContainer.scaleX = width / backgroundClip.width;
			knobContainer.scaleY = height / backgroundClip.height;
			
			// Last line must call superclass method
			super.draw();
		}
		
		
		/* ***************************************************
		 * Exposed Methods
		 * *************************************************** */
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
		public function execEvent (evName:String, evVal:Number, q:Boolean):void {
			if (evName == evtChg) {
				incrVal(evVal, q);
			}
		}
		
		/**
		Increments the jog by incr units (positive or negative).  This can be used to simulate turning the jog.

		@method incrVal
		@param incr Numeric increment to change the jog.
		@param quietly (optional) Set this to true to make the change without generating an event.
		@example
		myJog.incrVal(2.5);
		*/ 
		public function incrVal(incr:Number, q:Boolean) : void {
			setVal(this._val + incr, q);
		}
		
		/**
		 * Removes internal listeners and memory associated with the component.
		 */
		public function destroy () : void {
			backgroundClip.removeEventListener(MouseEvent.MOUSE_DOWN, jogEngage);
			backgroundClip.removeEventListener(MouseEvent.MOUSE_UP, jogRelease);
			backgroundClip.removeEventListener(MouseEvent.ROLL_OVER, jogEngage);
			backgroundClip.removeEventListener(MouseEvent.ROLL_OUT, jogRelease);
			indicatorClip.removeEventListener(MouseEvent.MOUSE_DOWN, jogEngage);
			indicatorClip.removeEventListener(MouseEvent.MOUSE_UP, jogRelease);
			indicatorClip.removeEventListener(MouseEvent.ROLL_OVER, jogEngage);
			indicatorClip.removeEventListener(MouseEvent.ROLL_OUT, jogRelease);
			removeEventListener(Event.REMOVED_FROM_STAGE, catchNoStagePtr);
		}
		 
		 
		/* ***************************************************
		 * protected/Protected Methods
		 * *************************************************** */
		 
		/**
		Sets the position of the jog knob.

		@method setVal
		@param v Numeric value (between 0 and <code>units</code>)
		@param quiet Boolean flag indicating whether to set the value quietly (no event notification) or with notification (false [default]).
		@example
		myJog.setVal(5); // sets the jog knob to the certain position
		@access protected
		*/
		protected function setVal (v:Number, q:Boolean = false) : void {
			var v4ang:Number = v % _units, ang:Number, ov:Number = _val;
			
			valPriv = v;
			ang = (360 / _units) * v4ang;
			
			if (_discreteSteps) {
				_val = Math.round(valPriv);
				indicatorClip.rotation = (360 / _units)  * (_val % _units);
			} else {
				_val = valPriv;
				indicatorClip.rotation = ang;
			}
		
			if (_val != ov && q != true) {
				if (!snap2Int && !_discreteSteps) {
					genEvent(_val - ov);
					playClick();
					
					
				} else if (_discreteSteps && Math.abs(_val - ov) >=1) {
					genEvent(_val - ov);
					playClick();
		
				} else if (snap2Int && Math.abs(valPriv - lastIntVal) >= 1) {
					if (lastIntVal != _val) {
						genEvent(Math.round(valPriv - lastIntVal));
						playClick();
					}
					lastIntVal = Math.round(valPriv);
				}
			}
		}
		
		protected function playClick() : void {
			if (_useSound && sndObj != null) {
				sndObj.play();
			}
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
		@access protected
		*/
		protected function trackMouse (me:MouseEvent) : void {
			var ax:Number, ay:Number, neg:Boolean, sum:Number, vdot:Number, angle:Number;
			
			// Compute the dot product, which will give us the rotation angle based
			// on the current mouse position
			ax = backgroundClip.mouseX;
			ay = backgroundClip.mouseY;
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
			// convert from radians to degrees.  We could precompute 180/PI but the cost is minimal vs. code clarity.
			angle = Jog.CONST_180_OVER_PI * Math.acos(vdot);
			
			if (neg)
				angle *= -1;
			
			// If holdAng is undefined, it means this is the first time through
			// for the current interaction, so we have to record the initial angle
			// so we can update the rotation based on changes to the initial angle
			if (holdAngSet == false) {
				holdAng = angle;
				holdAngSet = true;
			}

			// set the current angle to be the angular difference plus current pos
			baseAng += angle - holdAng;
			
			// given the cumulative (baseAng) and angle of current mouse pos, set
			// the jog into position and update
			setAVal(baseAng, angle);
		}
		
		
		/**
		Called when the operator releases the jog from turning.

		@method jogRelease
		@access protected
		*/
		protected function jogRelease (me:MouseEvent) : void {
		
			if (me.currentTarget == stage) {
				stage.removeEventListener(MouseEvent.MOUSE_UP, jogRelease);
			}
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, trackMouse);
			
			if (!enabled) {
				return;
			}
			
			if (snap2Int) {
				// On release, set knob at closest integer
				setVal(Math.round(_val));
				// If the current value is the same as the value we started movement at, then setVal() would
				// not make an audio click.  Therefore, make a click in this situation only.
				if (_val == _beginVal) {
					if (sndObj != null) {
						playClick();
					}
					genEvent(0);
				}
			}
		}
		
		/**
		Called when the operator is about to move the jog.


		@method jogEngage
		@access protected
		*/ 
		protected function jogEngage (me:MouseEvent):void {
			if (!enabled) {
				dispatchEvent(new EventWithData(evtDisabled, false, false, null));
				return;
			}
			
			holdAngSet = false;
			_beginVal = _val;
			
			if (stage != null) {
				stage.addEventListener(MouseEvent.MOUSE_MOVE, trackMouse);
				if (_turnByDragging) {
					stage.addEventListener(MouseEvent.MOUSE_UP, jogRelease);
				}
			}
		}
		
		/**
		 * If we're removed from the stage after a press event but before getting a release event, make sure we remove the stage listener.
		 */
		protected function catchNoStagePtr (e:Event) {
			if (stage != null && stage.hasEventListener( MouseEvent.MOUSE_UP ) ) {
				stage.removeEventListener(MouseEvent.MOUSE_UP, jogRelease);
			}
			if (stage != null && stage.hasEventListener ( MouseEvent.MOUSE_MOVE ) ) {
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, trackMouse);
			}
		}
		
		/**
		Translate the current angle into an increment from the last knob position,
		then notify listeners with the new value.

		@method setAVal
		@param ang
		@param realAng
		@access protected
		*/
		protected function setAVal (ang:Number, realAng:Number) : void {
			var rv:Number = ang - oldAng, incr:Number, ov:Number = _val;
		
			if (ang > oldAng) {
				if (rv > 180)
					rv -= 360;
			} else {
				if (rv < -180)
					rv += 360;
			}
		
			oldAng = ang;
			incr = (_units * rv) / 360;
			valPriv += incr;
		
			setVal(valPriv);
			holdAng = realAng;
		}
	
		
		protected function changeBackground (n:String) : void {
			var bkgndSkinClass:Class = getDefinitionByName(n) as Class;
			var oldBkgnd:Sprite = backgroundClip;
			
			backgroundClip = new bkgndSkinClass() as Sprite;
			
			backgroundClip.x = backgroundClip.width / 2;
			backgroundClip.y = backgroundClip.height / 2;

			knobContainer.addChildAt(backgroundClip, 0);
			
			if (oldBkgnd != null) {
				knobContainer.removeChild(oldBkgnd);
			}
	
			backgroundClip.buttonMode = backgroundClip.useHandCursor = showHand;
			backgroundClip.alpha = (showBkgnd ? 100 : 0);
			
			_backgroundClassName = n;
			
			invalidate();
		}
		
		protected function changeIndicator (n:String) : void {
			var indicatorSkinClass:Class = getDefinitionByName(n) as Class;
			var oldIndicator:Sprite = indicatorClip;
			
			indicatorClip = new indicatorSkinClass() as Sprite;
			
			indicatorClip.x = backgroundClip.width / 2;
			indicatorClip.y = backgroundClip.height / 2;

			knobContainer.addChildAt(indicatorClip, 1);
			if (oldIndicator != null) {
				knobContainer.removeChild(oldIndicator);
			}
			
			indicatorClip.buttonMode = indicatorClip.useHandCursor = showHand;
			
			_indicatorClassName = n;
			
			invalidate();
		}
		
		// Change the sound associated with each knob movement
		protected function setClickSound (s:String) : void {
			if (s != "") {
				var clickSound:Class = getDefinitionByName(s) as Class;
				sndObj = new clickSound() as Sound;
				
			} else if (sndObj != null) {
				sndObj = null;
			}
			
			_clickSoundClass = s;
		}
		
		
		/**
		Routine draws the tick marks, when developer requests them drawn.

		@method drawTicks
		@access protected
		*/
		protected function drawTicks() : void {
			var len:Number = 5 + backgroundClip.width / 2;
			var ang:Number = 360 / _numTicks;
			var ptObj:Point;
		
			if (tickSprite != null)
				tickSprite.graphics.clear();
		
			tickSprite = new Sprite();
			
			knobContainer.addChildAt(tickSprite, 0);
			tickSprite.graphics.clear();

			tickSprite.graphics.lineStyle(_tickLineThickness, _tickLineColor);

			ptObj = new Point(0, -len);

			for (var i:int = 0; i < 360; i += ang) {
				ptObj.x = 0;
				ptObj.y = -len;
				rotZ(ptObj, i);
				tickSprite.graphics.moveTo(0, 0);
				tickSprite.graphics.lineTo(ptObj.x, ptObj.y);
			}
			
			tickSprite.x = backgroundClip.width / 2;
			tickSprite.y = backgroundClip.height / 2;
			
			invalidate();
		}
		
		/**
		Rotates a given Point <code>(vObj.x, vObj.y)</code> around the Z-axis by <code>ang</code> degrees and puts the new point back in the <code>x</code> and <code>y</code> properties.

		@method rotZ
		@param vObj A Point (with properties <code>x</code> and <code>y</code>)
		@param ang Angle to rotate point on Z-axis (0 degrees points north, positive is clockwise)
		@access protected
		*/
		protected function rotZ (vObj:Point, ang:Number) : void {
			var xVal:Number = vObj.x, yVal:Number = vObj.y;
			ang = Jog.DEGREE_PER_RADIAN * ang;  // convert degrees to radians
			vObj.x = Math.cos(ang) * xVal - Math.sin(ang) * yVal;
			vObj.y = Math.sin(ang) * xVal + Math.cos(ang) * yVal;
		}
	
		/**
		 * Generate this component's event with the given value.  This is broken out as
		 * as a separate method so that it can be overriden in subclasses, if necessary.
		 * @method genEvent
		 * @param v current knob value
		 */
		protected function genEvent(v:Number) : void {
			dispatchEvent(new EventWithData(evtChg, false, false, v));
		}
	}
}