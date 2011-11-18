/*
	************************************************
	
	FILE: SimpleTimer.as
	
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
	import com.eqsim.events.EventWithData;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.display.MovieClip;

	[IconFile("icons/timer.png")]
	
	/**
	Event generated when interval elapses.  Value supplied with the event (<code>data</code>) is the number of
	remaining iterations until shutdown (0 means loop infinitely).
	@event onElapsed
	*/
	[Event("onElapsed")]
	
	
	/** ************************************************
	<p>This class implements a countdown timer.</p>
	 
	<p>The class has one event, by default called "onElapsed" (but this can
	be changed in the property inspector, or programmatically via <code>evtElapsed</code>).  The value is the number of
	remaining iterations until shut down (-1 is infinite).</p>
	 * 
	 * ************************************************* */
	public class SimpleTimer extends UIComponent {

		/* ***************************************************
		 * Exposed Properties
		 * *************************************************** */
		 
		/**
		Set this value to change the number of times the timer repeats the interval. If changed
		while the timer is active, the timer resets and starts again.  If the value is 0, the timer repeats
		the interval indefinitely.
		@property numIterations
		*/
		[Inspectable(name="iterations (0 == infinite)", type=Number, defaultValue=0)]
		public function set numIterations (v:int) : void {
			_numIterations = v;
			if (active) {
				reset();
				start();
			}
			
			if (isLivePreview && previewBox != null) {
				invalidate();
			}
		}
		public function get numIterations () : int {
			return _numIterations;
		}
		protected var _numIterations:int = 0;
		
		/**
		This property holds the string name of the event.
		@property evtElapsed
		*/
		[Inspectable(name="onElapsed event name", type=String, defaultValue="onElapsed")]
		public var evtElapsed:String = "onElapsed";
		
		/**
		Set this value to change the timing interval. If changed while the timer is active,
		the timer resets and starts again.
		@property interval
		*/
		[Inspectable(name="Timing interval (milliseconds)", type=Number, defaultValue=1000)]
		public function set interval (v:int) : void {
			_interval = v;
			
			reset();
			if (active) {
				start();
			}
			
			if (isLivePreview && previewBox != null) {
				invalidate();
			}
		}
		public function get interval () : int {
			return _interval;
		}
		protected var _interval:int = 1000;
		
		
		/**
		Set this value to start or stop the timing interval. If changed while the timer is active,
		the timer resets and starts again.
		@property active
		*/
		[Inspectable(name="Timer active", type=Boolean, defaultValue=false)]
		public function set active (v:Boolean) : void {
			if (v) {
				start();
			} else {
				pause();
			}
		}
		public function get active () : Boolean {
			return intTimer.running;
		}
		
		
		/* ***************************************************
		 * Protected/Private Properties
		 * *************************************************** */
		protected var _loopCt:Number;
		protected var intTimer:Timer;
		protected var SimpleTimerPreviewClip:Class;
		
		// For Live Preview rendering
		protected var previewBox:MovieClip;
		protected var origWidth:Number;
		protected var origHeight:Number;
		
		
		/* ***************************************************
		 * Constants
		 * *************************************************** */
		

		/* ***************************************************
		 * Constructor and Required Methods (UIComponent)
		 * *************************************************** */ 

		/**
		 *
		 */
		public function SimpleTimer() {
			super();
			
			intTimer = new Timer(_interval);
			intTimer.addEventListener(TimerEvent.TIMER, elapsed);
		}
		 
		/**
		 * configUI
		 * Get the display objects created in preparation of launch.  Note that we get called before
		 * our constructor, and before we are notified that we are on the stage!
		 */
		override protected function configUI():void {
			super.configUI();
			
			if (isLivePreview) {
				previewBox = new SimpleTimerPreviewClip();
				addChild(previewBox);
				origWidth = previewBox.width;
				origHeight = previewBox.height;
			}
		}
		
		
		/**
		 * 
		 */
		protected override function draw():void {
			if (isLivePreview && previewBox != null) {
				previewBox.scaleX = width / origWidth;
				previewBox.scaleY = height / origHeight;
				previewBox.iterBox.text = (_numIterations == 0 ? "infinite" : _numIterations);
				previewBox.intvlBox.text = _interval;
			}
			
			// Last line must call superclass method
			super.draw();
		}
		
		
		/* ***************************************************
		 * Exposed Methods
		 * *************************************************** */
		public function start () : void {
			if (intTimer.running) {
				intTimer.reset();
			}
			
			_loopCt = 0;
			
			intTimer.start();
		}
		
		public function reset () : void {
		
			intTimer.delay = _interval;
			intTimer.repeatCount = (_numIterations < 1 ? 0 : _numIterations);
			_loopCt = 0;
			
			if (intTimer.running) {
				intTimer.stop();
			}
		}
		
		public function pause () : void {
			intTimer.stop();
		}
		
		/**
		 * Remove this component's associated listeners and memory.
		 */
		public function destroy () : void {
			intTimer.removeEventListener(TimerEvent.TIMER, elapsed);
		}
		 
		 
		/* ***************************************************
		 * Private/Protected Methods
		 * *************************************************** */
		
		protected function elapsed (te:TimerEvent) : void {
			dispatchEvent(new EventWithData(evtElapsed, false, false, _loopCt++));
			if (_numIterations > 0 && _loopCt == _numIterations) {
				reset();
			}
		}
		
	}
}