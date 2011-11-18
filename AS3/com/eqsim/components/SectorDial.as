/*
	************************************************
	
	FILE: SectorDial.as
	
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
	
	[IconFile("icons/sdial.png")]
	
	import fl.core.UIComponent;
	import com.eqsim.events.EventWithData;
	import flash.utils.getDefinitionByName;
	import flash.display.Sprite;

	
	/** ************************************************
	<p>This class implements a simple sector dial. Developers can set its
	value by setting the <code>val</code> property to have the
	dial jump immediately to that value.</p>

	<p>Users can change the appearance (skin) of the
	hand by modifying: <code>centerDotClassName</code>, 
	center of the dial by modifying: <code>needleClassName</code>,
	the background graphic by modifying: <code>backgroundClassName</code>.</p>

	<p>The component also provides properties to bring in attached graphics based
	on movie clip class names.  This allows the developer to have multiple instances
	on the Stage with different looks.</p>

	<p>Showing the dial center and background skins are optional.</p>
	 * ************************************************* */
	public class SectorDial extends UIComponent {

		/* ***************************************************
		 * Exposed Properties
		 * *************************************************** */
		 
		/**
		This property gives the class name of the background to use.
		@property backgroundClassName
		*/
		[Inspectable(name="Background skin class name", type=String, defaultValue="defSectDialBkgnd")]
		public function set backgroundClassName (v:String) : void {
			changeBackground(v);
		}
		public function get backgroundClassName () : String {
			return _backgroundClassName;
		}
		protected var _backgroundClassName:String = "defSectDialBkgnd";
			
		/**
		This property gives the class name of the center dot (overlay) to use.
		@property centerDotClassName
		*/
		[Inspectable(name="Center overlay skin class name", type=String, defaultValue="defSectDialCenter")]
		public function set centerDotClassName (v:String) : void {
			changeCenterOverlay(v);
		}
		public function get centerDotClassName () : String {
			return _centerDotClassName;
		}
		protected var _centerDotClassName:String = "defSectDialCenter";
			
		/**
		This property gives the class name of the needle to use.  The Sprite should be centered at the point you want it to rotate.

		@property needleClassName
		*/
		[Inspectable(name="Needle skin class name", type=String, defaultValue="defSectDialNeedle")]
		public function set needleClassName (v:String) : void {
			changeNeedle(v);
		}
		public function get needleClassName () : String {
			return _needleClassName;
		}
		protected var _needleClassName:String = "defSectDialNeedle";

		/**
		Current value of the dial (where needle is set).  Set this property to change the displayed
		value immediately.
		@property val
		*/
		[Inspectable(name="Starting value", type=Number, defaultValue=0)]
		public function set val (v:Number) : void {
			if (enabled) {
				setNeedle(v);
				_val = v;
			}
		}
		public function get val ():Number {
			return _val;
		}
		protected var _val:Number = 0;
		
		/**
		Minimum value of the gauge.  Set this property to change the minimum at any time.
		@property minVal
		*/
			[Inspectable(name="Minimum dial value", type=Number, defaultValue=0)]
			public function set minVal (v:Number) : void {
				_minVal = v;
				setNeedle(_val);
			}
			public function get minVal () : Number {
				return _minVal;
			}
			private var _minVal:Number = 0;

		/**
		Maximum value of the gauge.  Set this property to change the maximum at any time.
		@property maxVal
		*/
			[Inspectable(name="Maximum dial value", type=Number, defaultValue=100)]
			public function set maxVal (v:Number) : void {
				_maxVal = v;
				setNeedle(_val);
			}
			public function get maxVal () : Number {
				return _maxVal;
			}
			private var _maxVal:Number = 100;

		/**
		Angle of needle when reaches minimum value.  Set this property to change the minimum at any time.
		@property minAngle
		*/
			[Inspectable(name="Needle angle at minimum", type=Number, defaultValue="-45")]
			public function set minAngle (v:Number) : void {
				_minAngle = v;
				setNeedle(_val);
			}
			public function get minAngle () : Number {
				return _minAngle;
			}
			private var _minAngle:Number = -45;

		/**
		Angle of needle when reaches maximum value.  Set this property to change the maximum at any time.
		@property maxAngle
		*/
			[Inspectable(name="Needle angle at maximum", type=Number, defaultValue=45)]
			public function set maxAngle (v:Number) : void {
				_maxAngle = v;
				setNeedle(_val);
			}
			public function get maxAngle () : Number {
				return _maxAngle;
			}
			private var _maxAngle:Number = 45;
			
		/**
		Determines whether minimum is on the left (left2right == true) or on the right (left2right == false).

		@property left2right
		*/
			[Inspectable(name="Increase values left to right", type=Boolean, defaultValue=true)]
			public function set left2right (f:Boolean) : void {
				_left2right = f;
				setNeedle(_val);
			}
			public function get left2right () : Boolean {
				return _left2right;
			}
			private var _left2right:Boolean = true;
		
		
		/**
		Scaling factor along the x axis (width) for the needle.

		@property nXScale
		*/
		/**
		Scaling factor along the y axis (height) for the needle.

		@property nYScale
		*/
		[Inspectable(name="Needle horizontal scaling %", type=Number, defaultValue=1)]
		public function set nXScale (v:Number) : void {
			needleClip.scaleX = v;
			_nXScale = v;
		}
		public function get nXScale () : Number {
			return _nXScale;
		}
		protected var _nXScale:Number = 1;

		[Inspectable(name="Needle vertical scaling %", type=Number, defaultValue=1)]
		public function set nYScale (v:Number) : void {
			needleClip.scaleY = v;
			_nYScale = v;
		}
		public function get nYScale () : Number {
			return _nYScale;
		}
		protected var _nYScale:Number = 1;


		/**
		Boolean property indicating whether the center graphic is visible (true) or not (false).

		@property centerVis
		*/
		[Inspectable(name="Display center graphic", type=Boolean, defaultValue=true)]
		public function set centerVis (f:Boolean) : void {
			dCenterClip.visible = _centerVis = f;
		}
		public function get centerVis () : Boolean {
			return _centerVis;
		}
		protected var _centerVis:Boolean = true;

			
		/**
		Boolean property indicating whether the background graphic is visible (true) or not (false).

		@property showBack
		*/
		[Inspectable(name="Display background graphic", type=Boolean, defaultValue=true)]
		public function set showBack (f:Boolean) : void {
			bkgndClip.visible = _showBack = f;
		}
		public function get showBack () : Boolean {
				return _showBack;
		}
		protected var _showBack:Boolean = true;

		/**
		Number of units in a full cycle for the dial.
		@property units
		*/
		[Inspectable(name="Units in one revolution", type=Number, defaultValue=50)]
		public function set units (n:int) : void {
			_units = n;
			setNeedle(_val);
		}
		public function get units () : int {
				return _units;
		}
		protected var _units:Number = 50;
		
		
		
		/* ***************************************************
		 * Protected/Private Properties
		 * *************************************************** */
		protected var dCenterClip:Sprite;
		protected var bkgndClip:Sprite;
		protected var needleClip:Sprite;
		protected var dialContainer:Sprite;
		
		
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
		public function SectorDial() {
			super();
		}
		 
		/**
		 * configUI
		 * Get the display objects created in preparation of launch.  Note that we get called before
		 * our constructor, and before we are notified that we are on the stage!
		 */
		override protected function configUI():void {
			super.configUI();
			
			dialContainer = new Sprite();
			changeBackground(_backgroundClassName);
			changeNeedle(_needleClassName);
			changeCenterOverlay(_centerDotClassName);
			
			addChild(dialContainer);
		}
		
		
		/**
		 * 
		 */
		protected override function draw():void {
			
			
			
			bkgndClip.x = bkgndClip.width / 2;
			bkgndClip.y = bkgndClip.height;
			bkgndClip.visible = _showBack;
			
			dCenterClip.x = bkgndClip.width / 2;
			dCenterClip.y = bkgndClip.height;
			dCenterClip.visible = _centerVis;
			
			needleClip.x = bkgndClip.width / 2;
			needleClip.y = bkgndClip.height;
			
			dialContainer.scaleX = width / bkgndClip.width;
			dialContainer.scaleY = height / bkgndClip.height;
			
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
		Sets the needle to the passed in value v.  Change to the new value is immediate.  This routine does not change the needle value -- use <code>val</code> to do that.
		@method setNeedle
		@param v New value to display for needle.
		*/
		protected function setNeedle (v:Number) : void {
			var arange:Number = _maxAngle - _minAngle;
	   		var vrange:Number = _maxVal - _minVal;
			
			if (enabled) {
				// Don't let value exceed our range!
				if (v < _minVal) {
					 v = _minVal;
				} else if (v > _maxVal) {
					v = _maxVal;
				}
				// l2r == true if min is on left and max is on right, otherwise opposite
				if (_left2right) {
					needleClip.rotation = _minAngle + arange * ((v - _minVal) / vrange);
				} else {
					needleClip.rotation = _maxAngle - arange * ((v - _minVal) / vrange);
				}
			}
			
		}
		
		protected function changeBackground (n:String) : void {
			var bkgndSkinClass:Class = getDefinitionByName(n) as Class;
			var oldBkgnd:Sprite = bkgndClip;
			
			bkgndClip = new bkgndSkinClass() as Sprite;

			dialContainer.addChildAt(bkgndClip, 0);
			if (oldBkgnd != null) {
				dialContainer.removeChild(oldBkgnd);
			}
			_backgroundClassName = n;
			
			invalidate();
		}
		
		protected function changeCenterOverlay (n:String) : void {
			var overlaySkinClass:Class = getDefinitionByName(n) as Class;
			var oldCenter:Sprite = dCenterClip;
			
			dCenterClip = new overlaySkinClass() as Sprite;
	
			dialContainer.addChildAt(dCenterClip, 2);
			
			if (oldCenter != null) {
				dialContainer.removeChild(oldCenter);
			}
			
			_centerDotClassName = n;
			
			invalidate();
		}
		
		protected function changeNeedle (n:String) : void {
			var needleSkinClass:Class = getDefinitionByName(n) as Class;
			var oldNeedle:Sprite = needleClip;
			
			needleClip = new needleSkinClass() as Sprite;
			
			needleClip.scaleX = _nXScale;
			needleClip.scaleY = _nYScale;
			
			dialContainer.addChildAt(needleClip, 1);
			if (oldNeedle != null) {
				dialContainer.removeChild(oldNeedle);
			}
			_needleClassName = n;
			
			setNeedle(_val);
			
			invalidate();
		}
		
	}
}