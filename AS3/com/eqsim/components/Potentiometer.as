/*
	************************************************
	
	FILE: Potentiometer.as
	
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
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	import flash.geom.Point;
	import flash.media.Sound;
	import com.eqsim.events.EventWithData;
	import com.eqsim.components.Jog;

[IconFile("potentiometer.png")]

/**
Event generated when jog knob value has changed.
@event onValChg
*/
[Event("onValChg")]
[Event("onDisabled")]

	/** ************************************************
	<p>This class implements a simple potentiometer, which is virtually identical in functionality to
	the jog knob (Jog).  Developers can set the increment, number of values
	in one cycle, integer vs. discrete, minimum and maximum values, and whether the jog is adjusted by clicking and dragging,
	or merely moving in a circular motion (<code>dragOrOver</code>).</p>

	<p>Developers can change the appearance by modifying:</p>
	<li><code>defPotBkgnd</code> - background</li>
	<li><code>defPotIndicator</code> - indicator clip</li>

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

	<p>The potentiometer value can be set using the <code>val</code> property or through the <code>setVal()</code> method.</p>

	<p>If the <code>enabled</code> property is set to <code>false</code>, the component will generate an <code>onDisabled</code> event with no data.</p>
 * ************************************************* */
	public class Potentiometer extends Jog {

		/* ***************************************************
		 * Exposed Properties
		 * *************************************************** */
		 
		/**
		 * Set the minimum value for this knob.
		 * @property
		 */
		[Inspectable(name="Minimum knob value", type=Number, defaultValue=0)]
		public function set minVal (v:Number) : void {
			_minVal = v;
			setVal(_val, true);
		}
		public function get minVal () : Number {
			return _minVal;
		}
		private var _minVal:Number = 0;
		
		/**
		 * Set the maximum value for this knob.
		 * @property
		 */
		[Inspectable(name="Maximum knob value", type=Number, defaultValue=100)]
		public function set maxVal (v:Number) : void {
			_maxVal = v;
			setVal(_val, true);
		}
		public function get maxVal () : Number {
			return _maxVal;
		}
		private var _maxVal:Number = 100;
		
		
		/* ***************************************************
		 * Protected/Private Properties
		 * *************************************************** */
		
		
		
		/* ***************************************************
		 * Constants
		 * *************************************************** */
		 /**
		  * @private
		  */
		 private static const CONST_180_OVER_PI:Number = (180/Math.PI);
		 /**
		  * @private
		  */
		 private static const DEGREE_PER_RADIAN:Number = 0.0174532925199433;
		

		/* ***************************************************
		 * Constructor and Required Methods (UIComponent)
		 * *************************************************** */ 

		/**
		 *
		 */
		public function Potentiometer() {
			super();
		}
		 
		/**
		 * configUI
		 * Get the display objects created in preparation of launch.  Note that we get called before
		 * our constructor, and before we are notified that we are on the stage!
		 */
		override protected function configUI():void {
			super.configUI();
		
			changeBackground(_backgroundClassName);
			changeIndicator(_indicatorClassName);
			setClickSound(_clickSoundClass);
			
			// Reset private values used in angle computations
			oldAng = baseAng = 0;
			
			setupMouseEvents();

			// hold onto current integer value, in case we are supposed to snap to integer
			// and we need to know if we've reached an integer yet
			lastIntVal = int(_val);
			
			_val = Math.min(Math.max(_val, minVal), maxVal);

			// initialize potentiometer at starting position
			setVal(_val, true);
		
			// Draw the tick marks, if directed to
			if (_showTicks)
				drawTicks();
		}
		
		
		/* ***************************************************
		 * Exposed Methods
		 * *************************************************** */
		 
		 
		 
		/* ***************************************************
		 * Private/Protected Methods
		 * *************************************************** */
		 
		/**
		Sets the position of the potentiometer.

		@method setVal
		@param v Numeric value (between <code>minVal</code> and <code>maxVal</code>)
		@param quiet Boolean flag indicating whether to set the value quietly (no event notification) or with notification (false [default]).
		@example
		myPotentiometer.setVal(5); // sets the jog knob to the certain position
		@access private
		*/

		override protected function setVal (v:Number, q:Boolean = false) : void {
			// clamp desired value to min and max
			v = Math.min(Math.max(v, minVal), maxVal);
			super.setVal(v, q);
		}
	
		/**
		 * We override the potentiometer's method for genEvent so we send the value property, not the incremental difference.
		 * @method genEvent
		 * @param v value of the knob
		 */
		override protected function genEvent(v:Number) : void {
			var val:Number;
			
			if (snap2Int)
				val = Math.round(_val);
			else
				val = _val;
			dispatchEvent(new EventWithData(evtChg, false, false, val));
		}
	}
}