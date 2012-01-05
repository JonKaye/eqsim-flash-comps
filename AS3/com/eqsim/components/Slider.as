/*
	************************************************
	
	FILE: Slider.as
	
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
	import flash.utils.getDefinitionByName;
	import flash.media.Sound;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.eqsim.events.EventWithData;

	[IconFile("slider.png")]

	/**
	Event generated when the indicator reaches a new value.  The value passed in the event is the new value.  You can change the name of the event in the <code>evtChange</code> property.
	of the slider.
	@event onChange
	*/
	[Event("onChange")]
	
	/**
Event generated when slider is set as <code>enabled == false</code>.  You can change the name of the event in the <code>evtDisabled</code> property.
@event onDisabled
*/
	[Event("onDisabled")]

	
	
	/**
	<p>This class implements a simple horizontal slider.  Users can change the appearance by modifying:</p>
	<li><code>defSliderBkgnd</code> - gutter along which slider slides</li>
	<li><code>defSliderSide</code> - left and right sides of the slider</li>
	<li><code>defSliderThumb</code> - the indicator (button)</li>

	<p>The class has two events (<code>onChange</code> and <code>onDisabled</code>), but can be changed in the component property panel or programmatically via the 
	evtChange or evtDisabled properties.  The value of the onChange event (in <code>data</code>) is the new value.</p>
	 */
	public class Slider extends UIComponent {

		/* ***************************************************
		 * Exposed Properties
		 * *************************************************** */
		 
		/**
		The name of the event.  Change this programmatically to change the event name.
		@property evtChange
		*/
		[Inspectable(name="onChange method name", type=String, defaultValue="onChange")]
		public var evtChange:String = "onChange";
		
		/**
		 * Let user change the event name, if desired.
		 * @property
		 */
		[Inspectable(name="onDisabled method name", type=String, defaultValue="onDisabled")]
		public var evtDisabled:String = "onDisabled";
		
		/**
		The class name of an audio clip to play on value change (if useSound == true).
		@property clickSoundClass
		*/
		[Inspectable(name="Sound clip class name", type=String, defaultValue="aSliderClickSound")]
		public function set clickSoundClass (s:String) : void {
			setClickSound(s);
		}
		public function get clickSoundClass () : String {
			return _clickSoundClass;
		}
		protected var _clickSoundClass:String = "aSliderClickSound";
		protected var sndObj:Sound;
		
		
		/**
		Whether or not to play the sound on a value change (default is false, do not play sound).
		@property clickSoundClass
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
		The class name of the 'gutter' (the thing on which the thumb slides) Sprite.
		@property gutterClassName
		*/
		[Inspectable(name="gutter class name", type=String, defaultValue="defSliderBkgnd")]
		public function set gutterClassName (v:String) : void {
			changeGutter(v, sideClassName);
		}
		public function get gutterClassName () : String {
			return (_gutterClassName);
		}
		protected var _gutterClassName:String = "defSliderBkgnd";

		/**
		The class name of the side of the gutter.  This class is used directly on the right of the gutter, and inverted for the left side.
		@property sideClassName
		*/
		[Inspectable(name="gutter side class name", type=String, defaultValue="defSliderSide")]
		public function set sideClassName (v:String) : void {
			changeGutter(_gutterClassName, v);
		}
		public function get sideClassName () : String {
			return (_sideClassName);
		}
		public var _sideClassName:String = "defSliderSide";

		/**
		The linkage ID of the thumb (indicator).
		@property thumbClassName
		*/
		[Inspectable(name="thumb class name", type=String, defaultValue="defSliderThumb")]
		public function set thumbClassName (v:String) : void {
			changeThumb(v);
		}
		public function get thumbClassName () : String {
			return (_thumbClassName);
		}
		protected var _thumbClassName:String = "defSliderThumb";

			
		/**
		Boolean property indicating whether or not to display the hand cursor when the cursor is
		over the hit area of this component.
		@property showHand
		*/
		[Inspectable(name="Show Hand Cursor", type=Boolean, defaultValue=true)]
		public function set showHand (f:Boolean) : void {
			gutterClip.useHandCursor = thumbClip.useHandCursor = _showHand = f;
		}
		public function get showHand () : Boolean {
			return(_showHand);
		}
		protected var _showHand:Boolean = true;
		
		/**
		Minimum value for the slider.  Use <code>setMinMax()</code> to change the value.
		@property minVal
		*/
		[Inspectable(name="minimum value", type=Number, defaultValue=0)]
		public function set minVal (f : Number) : void {
			_minVal = f;
			resetBounds();
		}
		public function get minVal () : Number {
			return(_minVal);
		}
		private var _minVal:Number = 0;
		
		/**
		Maximum value for the slider.  Use <code>setMinMax()</code> to change the value.
		@property maxVal
		*/
		[Inspectable(name="maximum value", type=Number, defaultValue=100)]
		public function set maxVal (f : Number) : void {
			_maxVal = f;
			resetBounds();
		}
		public function get maxVal () : Number {
			return(_maxVal);
		}
		private var _maxVal:Number = 100;
		
		/**
		Boolean property saying whether steps or discrete or continuous.  If true, discrete steps
		are based on <code>numDivs</code>.  If false, slider is continuous.
		@property discreteStep
		*/
		[Inspectable(name="Discrete steps", type=Boolean, defaultValue=false)]
		public var discreteStep:Boolean = false;
		
		/**
		Boolean property saying whether to allow value change if the user clicks on a place in the gutter.
		@property gutClicks
		*/
		[Inspectable(name="Allow gutter clicks", type=Boolean, defaultValue=true)]
		public function set gutClicks (f:Boolean) : void {
			_gutClicks = f;

			setGutterClicking();

		}
		public function get gutClicks () : Boolean {
			return(_gutClicks);
		}
		private var _gutClicks:Boolean = true;
		
		/*
		 * Tick line color (if showTicks is true)
		 * @property
		 */
		[Inspectable(name="Tick line color", type=Color, defaultValue="0")]
		public function set tickLineColor (c:int) : void {
			_tickLineColor = c;
			drawTicks();
		}
		public function get tickLineColor () : int {
			return _tickLineColor;
		}
		protected var _tickLineColor:int = 0;
		
		/*
		 * Tick line thickness (if showTicks is true)
		 * @property
		 */
		[Inspectable(name="Tick line thickness", type=Number, defaultValue="2")]
		public function set tickLineThickness (c:int) : void {
			_tickLineThickness = c;
			drawTicks();
		}
		public function get tickLineThickness () : int {
			return _tickLineThickness;
		}
		protected var _tickLineThickness:Number = 2;
		
		/*
		 * Tick line length.  If positive, ticks drawn beneath the gutter.  If negative, gives the length above the gutter.  The length
		 * is measured from the vertical center of the gutter, up or down.
		 * @property
		 */
		[Inspectable(name="Tick line length", type=Number, defaultValue="10")]
		public function set tickLineLength (c:int) : void {
			_tickLineLength = c;
			drawTicks();
		}
		public function get tickLineLength () : int {
			return _tickLineLength;
		}
		protected var _tickLineLength:Number = 10;
		
		
		/**
		Number of divisions, for discrete slider (and tick marks).
		@property numDivs
		*/
		[Inspectable(name="Number of tick intervals", type=Number, defaultValue=10)]
		public function set numDivs (f:int) : void {
			_numDivs = f;
			drawTicks();
		}
		public function get numDivs () : int {
			return(_numDivs);
		}
		private var _numDivs:int = 10;

		
		/**
		Current slider value.  Set this property to move the indicator programmatically, or use
		it to retrieve the current indicator position.
		@property val
		*/
		[Inspectable(name="indicator position", type=Number, defaultValue=50)]
		public function set val (f:Number) : void {
			_val = f;
			invalidate();
		}
		public function get val () : Number {
			return(_val);
		}

		private var _val:Number = 50;
		  
		/**
		Boolean property indicating whether or not to show tick marks.  Tick marks are really only
		for placement, as you really should hand-design slider backgrounds for best effect.
		@property showTicks
		*/
		[Inspectable(name="Show tick marks", type=Boolean, defaultValue=false)]
		public function set showTicks (f:Boolean) : void {
			_showTicks = f;
			drawTicks();
		}
		public function get showTicks () : Boolean {
			return(_showTicks);
		}
		private var _showTicks:Boolean = false;
		
		
		
		/* ***************************************************
		 * Protected/Private Properties
		 * *************************************************** */
		protected var rightSideClip:Sprite;
		protected var leftSideClip:Sprite;
		protected var gutterClip:Sprite; 
		protected var thumbClip:Sprite;
		protected var tickClip:Sprite;
		protected var sliderContainer:Sprite;
	
		protected var indOffset:Number;
		protected var _valRange:Number;
		protected var leftPos:Number;
		protected var rightPos:Number;
		
		
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
		public function Slider () {
			super();
		}
		 
		/**
		 * configUI
		 * Get the display objects created in preparation of launch.  Note that we get called before
		 * our constructor, and before we are notified that we are on the stage!
		 */
		override protected function configUI():void {
			super.configUI();
			
			sliderContainer = new Sprite();
			
			tickClip = new Sprite();
			sliderContainer.addChildAt(tickClip, 0);
			
			changeGutter(_gutterClassName, _sideClassName);
			changeThumb(_thumbClassName);
			setClickSound(_clickSoundClass);
			
			resetBounds();
			addChild(sliderContainer);
			
			addEventListener(Event.REMOVED_FROM_STAGE, catchNoStagePtr);
		}
		
		
		/* ***************************************************
		 * Exposed Methods
		 * *************************************************** */
		
		
		/**
		 * 
		 */
		protected override function draw():void {
			setVal(_val, true);
			
			sliderContainer.scaleX = width / (gutterClip.width + leftSideClip.width * 2);
			sliderContainer.scaleY = height / gutterClip.height;
			
			// Last line must call superclass method
			super.draw();
		}
		
		/**
		 *
		 */
		public function destroy () : void {
			
			thumbClip.removeEventListener(MouseEvent.MOUSE_DOWN, thumbEngage);
			
			if (gutterClip.hasEventListener(MouseEvent.CLICK)) {
				gutterClip.removeEventListener(MouseEvent.CLICK, gutterClick);
			}
			
			removeEventListener(Event.REMOVED_FROM_STAGE, catchNoStagePtr);
		}
		 
		 
		/* ***************************************************
		 * Private/Protected Methods
		 * *************************************************** */
		
		/**
		 * If we're removed from the stage after a press event but before getting a release event, make sure we remove the stage listener.
		 */
		protected function catchNoStagePtr (e:Event) {
			if (stage != null && stage.hasEventListener( MouseEvent.MOUSE_UP ) ) {
				stage.removeEventListener(MouseEvent.MOUSE_UP, thumbRelease);
			}
			if (stage != null && stage.hasEventListener ( MouseEvent.MOUSE_MOVE ) ) {
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, thumbMove);
			}
		}
		
		/**
		Called to set the position of the indicator, and notify listeners.
		@method setVal
		@param v New slider value
		@param quiet Boolean property, true if not to notify listeners, false to notify (default)
		@access private
		*/
		private function setVal (v:Number, quiet:Boolean = false) : void {
			var ov:Number = _val;
		
			if (v < _minVal)
				v = _minVal;
			else if (v > _maxVal)
				v = _maxVal;
				
			if (discreteStep) {
				var divSize:Number = (_maxVal - _minVal) / _numDivs;
				v = _minVal + divSize * Math.round((v - _minVal) / divSize);
			}

			thumbClip.x = leftPos + (rightPos - leftPos) * (v - _minVal)/_valRange;
			_val = v;
			if (v != ov) {
				if (quiet != true) {
					dispatchEvent(new EventWithData(evtChange, false, false, v));
					playClick();
				}
			}
		}
		
		/**
		Internal routine that draws the new slider based on the min and max values.
		@method resetBounds
		@access private
		*/
		private function resetBounds () : void {
			leftPos = gutterClip.x - (gutterClip.width/2 - thumbClip.width/2);
			rightPos = gutterClip.x + (gutterClip.width/2 - thumbClip.width/2);
			_valRange = _maxVal - _minVal;
		}
		
		protected function drawTicks () : void {
			
			if (_showTicks) {
				tickClip.graphics.clear();
			
				var dist:Number = (rightPos - leftPos) / _numDivs;
					
				tickClip.graphics.lineStyle(_tickLineThickness, _tickLineColor);
				for (var i:int=0; i<=_numDivs; i++) {
					tickClip.graphics.moveTo(i*dist + leftPos, gutterClip.y);
					tickClip.graphics.lineTo(i*dist + leftPos, gutterClip.y - _tickLineLength);
				}
			} else {
				tickClip.graphics.clear();
			}
			
			tickClip.visible = _showTicks;
		}
		
		protected function thumbEngage (me: MouseEvent) : void {
			stage.addEventListener(MouseEvent.MOUSE_MOVE, thumbMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, thumbRelease);
			indOffset = thumbClip.x - sliderContainer.mouseX;
		}
		
		protected function thumbRelease (me: MouseEvent) : void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, thumbRelease);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, thumbMove);
		}
		
		protected function thumbMove(me: MouseEvent): void {
			sliderClickHandle(sliderContainer.mouseX + indOffset);
		}
	
		protected function gutterClick (me: MouseEvent) : void {
			if (enabled) {
				sliderClickHandle(sliderContainer.mouseX);
			} else {
				dispatchEvent(new EventWithData(evtChange, false, false, evtDisabled));
			}
		}
		
		/**
		this method takes a position in gutter coordinates
		and moves the indicator there.  It is used during gutter clicking
		and indicator dragging.
		@method sliderClickHandle
		@param m numeric desired slider (x) coordinate, not value
		@access private
		*/
		private function sliderClickHandle (m:Number) : void {
			var click:Number, sRange:Number;
				
			click = m - leftPos;
			sRange = rightPos - leftPos;
			if (click < 0) {
				click = 0;
			} else if (click > sRange) {
				click = sRange;
			}
			setVal(_minVal + _valRange * (click/sRange));
		}
		
		protected function changeGutter (gut:String, side:String) : void {
			var gutterSkinClass:Class = getDefinitionByName(gut) as Class;
			var sideSkinClass:Class = getDefinitionByName(side) as Class;
			
			// If told to change gutter to what is there already, we don't have to do anything
			if (gutterClip != null && gut == _gutterClassName && side == _sideClassName) {
				return;
			}
			
			if (gutterClip != null) {
				sliderContainer.removeChild(gutterClip);
			}
			if (rightSideClip != null) {
				sliderContainer.removeChild(rightSideClip);
			}
			if (leftSideClip != null) {
				sliderContainer.removeChild(leftSideClip);
			}
			
			gutterClip = new gutterSkinClass() as Sprite;
			rightSideClip = new sideSkinClass() as Sprite;
			leftSideClip = new sideSkinClass() as Sprite;
			
			gutterClip.x = leftSideClip.width + gutterClip.width/2 - 2.5;
			gutterClip.y = gutterClip.height / 2;
			
			rightSideClip.x = leftSideClip.width + gutterClip.width + rightSideClip.width/2 - 5;
			rightSideClip.y = rightSideClip.height / 2;
			leftSideClip.x  = leftSideClip.width/2;
			leftSideClip.rotation = 180;
			leftSideClip.y = leftSideClip.height / 2;

			sliderContainer.addChildAt(rightSideClip, 1);
			sliderContainer.addChildAt(leftSideClip, 2);
			sliderContainer.addChildAt(gutterClip, 3);
	
			gutterClip.buttonMode = gutterClip.useHandCursor = _showHand;
			
			_gutterClassName = gut;
			_sideClassName  = side;
			
			setGutterClicking();
			
			invalidate();
		}
		
		protected function changeThumb (n:String) : void {
			var indicatorSkinClass:Class = getDefinitionByName(n) as Class;
			
			if (thumbClip != null) {
				sliderContainer.removeChild(thumbClip);
			}
			thumbClip = new indicatorSkinClass() as Sprite;
			
			thumbClip.x = gutterClip.width / 2;
			thumbClip.y = gutterClip.height / 2;

			sliderContainer.addChildAt(thumbClip, 4);
	
			thumbClip.buttonMode = thumbClip.useHandCursor = showHand;
			
			thumbClip.addEventListener(MouseEvent.MOUSE_DOWN, thumbEngage);
			
			_thumbClassName = n;
			
			invalidate();
		}
		
		protected function setGutterClicking () : void {
			if (_gutClicks) {
				if (!gutterClip.hasEventListener(MouseEvent.CLICK)) {
					gutterClip.addEventListener(MouseEvent.CLICK, gutterClick);
				}
			} else if (gutterClip.hasEventListener(MouseEvent.CLICK)) {
				gutterClip.removeEventListener(MouseEvent.CLICK, gutterClick);
			}
			gutterClip.useHandCursor = _showHand && (gutterClip.buttonMode = (_gutClicks == true));
		}
		
		// Change the sound associated with each discrete thumb movement
		protected function setClickSound (s:String) : void {
			if (s != "") {
				var clickSound:Class = getDefinitionByName(s) as Class;
				sndObj = new clickSound() as Sound;
				
			} else if (sndObj != null) {
				sndObj = null;
			}
			
			_clickSoundClass = s;
		}
		
		protected function playClick() : void {
			if (sndObj != null && _useSound) {
				sndObj.play();
			}
		}
	}
}