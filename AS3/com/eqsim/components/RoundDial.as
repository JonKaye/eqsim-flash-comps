/*
	************************************************
	
	FILE: RoundDial.as
	
	Copyright (c) 2004-2011, Jonathan Kaye, All rights reserved.

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
	
	[IconFile("icons/rdial.png")]
	
	import fl.core.UIComponent;
	import com.eqsim.events.EventWithData;
	import flash.utils.getDefinitionByName;
	import flash.display.Sprite;

	
	/** ************************************************
	<p>This class implements a simple round dial gauge.  Developers can set its
	value by setting the <code>val</code> property to have the
	dial jump immediately to that value.  If you want to have the needle transition smoothly,
	use the sub-class <code>RoundDialSmooth</code> in which you can set the needle rate.</p>

	<p>Users can change the appearance (skin) of the
	hand by modifying: <code>centerDotClassName</code>, 
	center of the dial by modifying: <code>needleClassName</code>,
	the background graphic by modifying: <code>backgroundClassName</code>.</p>

	<p>The component also provides properties to bring in attached graphics based
	on movie clip linkage ID's.  This allows the developer to have multiple instances
	on the Stage with different looks.</p>

	<p>Showing the dial center and background skins are optional.</p>
	 * ************************************************* */

	public class RoundDial extends UIComponent {

		/* ***************************************************
		 * Exposed Properties
		 * *************************************************** */
		 
		/**
		This property gives the class name of the background to use.
		@property backgroundClassName
		*/
		[Inspectable(name="Background skin class name", type=String, defaultValue="defRoundDialBkgnd")]
		public function set backgroundClassName (v:String) : void {
			changeBackground(v);
		}
		public function get backgroundClassName () : String {
			return _backgroundClassName;
		}
		protected var _backgroundClassName:String = "defRoundDialBkgnd";
			
		/**
		This property gives the class name of the center dot (overlay) to use.
		@property centerDotClassName
		*/
		[Inspectable(name="Center overlay skin class name", type=String, defaultValue="defRoundDialCenter")]
		public function set centerDotClassName (v:String) : void {
			changeCenterOverlay(v);
		}
		public function get centerDotClassName () : String {
			return _centerDotClassName;
		}
		protected var _centerDotClassName:String = "defRoundDialCenter";
			
		/**
		This property gives the class name of the needle to use.  The Sprite should be centered at the point you want it to rotate.

		@property needleClassName
		*/
		[Inspectable(name="Needle skin class name", type=String, defaultValue="defRoundDialNeedle")]
		public function set needleClassName (v:String) : void {
			changeNeedle(v);
		}
		public function get needleClassName () : String {
			return _needleClassName;
		}
		protected var _needleClassName:String = "defRoundDialNeedle";

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
		public function RoundDial() {
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
			bkgndClip.y = bkgndClip.height / 2;
			bkgndClip.visible = _showBack;
			
			dCenterClip.x = bkgndClip.width / 2;
			dCenterClip.y = bkgndClip.height / 2;
			dCenterClip.visible = _centerVis;
			
			needleClip.x = bkgndClip.width / 2;
			needleClip.y = bkgndClip.height / 2;
			
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

			if (enabled) {
				// Don't let value exceed our range!
				v %= units;

				// if value passed in is less than 0, calc its approp positive value
				if (v < 0) {	
					v = units + v;
				}
				needleClip.rotation = 360 * v/units;
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
			var oldOverlay:Sprite = dCenterClip;
		
			dCenterClip = new overlaySkinClass() as Sprite;
	
			dialContainer.addChildAt(dCenterClip, 2);
			if (oldOverlay != null) {
				dialContainer.removeChild(oldOverlay);
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