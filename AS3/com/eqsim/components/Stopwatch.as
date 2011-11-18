/*
	************************************************
	
	FILE: Stopwatch.as
	
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
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.display.MovieClip;

	[IconFile("icons/timer.png")]

	/**
	Event generated at a user-controllable interval while the stopwatch is running.
	@event onPulse
	*/
	[Event("onPulse")]
	
	
	/** ************************************************
	<p>This class implements a stopwatch that can be started, paused, and reset.
	It does not subclass timer, it just uses a timer object.  The <code>resolution</code> property
	is the resolution of the stopwatch (minimum value for checking if time has elapsed).  When you
	need to optimize precision, you should adjust <code>resolution</code> to a resolution that is at most half of
	the shortest interval you need to measure.</p>
	 
	<p>The class has one event, by default called "onPulse" (but this can
	be changed in the component parameter panel, or programmatically by setting <code>evtPulse</code>).</p>

	 * ************************************************* */
	public class Stopwatch extends UIComponent {

		/* ***************************************************
		 * Exposed Properties
		 * *************************************************** */
		 
		/**
		This property holds the string name of the event.
		@property evtPulse
		*/
		[Inspectable(name="onPulse event name", type=String, defaultValue="onPulse")]
		public var evtPulse:String = "onPulse";

		/**
		This property holds the resolution of the timer.  This must be set to the pulse interval
		at the maximum.  It determines how often we check to see that the stopwatch has advanced.
		@property resolution
		*/
		[Inspectable(name="Timing resolution (msec)", type=Number, defaultValue=100)]
		public function set resolution (v:int) : void {
			_resolution = v;
			resetStopwatchParameters();
			
			if (isLivePreview && previewBox != null) {
				invalidate();
			}
		}
		
		public function get resolution () : int {
			return _resolution;
		}
		
		public var _resolution:int = 100;

		
		/**
		This property indicates the interval at which to generate pulse events when the stopwatch is active.
		Use 0 to mean don't generate pulses at all.
		@property pulseInterval
		*/
		[Inspectable(name="Pulse interval msec (0 for none)", type=Number, defaultValue=0)]
		public function set pulseInterval (v:int) : void {
		
			goQuietly = (v == 0);
			
			_pulseInterval = v;
			resetStopwatchParameters();
			
			if (isLivePreview && previewBox != null) {
				invalidate();
			}
		}
		
		public function get pulseInterval () : int {
			return _pulseInterval;
		}
		
		private var _pulseInterval:int = 0;
		
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
			return st.active;
		}
		
		protected var _val:int;
		protected var _oldVal:int;
		protected var _lastTime:int;
		protected var goQuietly:Boolean;
		
		// For Live Preview rendering
		protected var previewBox:MovieClip;
		protected var origWidth:Number;
		protected var origHeight:Number;
		
		
		/* ***************************************************
		 * Protected/Private Properties
		 * *************************************************** */
		protected var st:SimpleTimer;
		protected var StopwatchPreviewClip:Class;
		
		
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
		public function Stopwatch() {
			super();
			
			_val = 0;
			
			st = new SimpleTimer();
			st.interval = _resolution;
			st.numIterations = 0;
			goQuietly = false;
			st.addEventListener("onElapsed", timerElapsed);
		}
		 
		/**
		 * configUI
		 * Get the display objects created in preparation of launch.  Note that we get called before
		 * our constructor, and before we are notified that we are on the stage!
		 */
		override protected function configUI():void {
			super.configUI();
			
			if (isLivePreview) {
				previewBox = new StopwatchPreviewClip();
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
				previewBox.pulseBox.text = (_pulseInterval == 0 ? "<none>" : String(_pulseInterval));
				previewBox.resBox.text = _resolution;
			}
			// Last line must call superclass method
			super.draw();
		}
		
		
		/* ***************************************************
		 * Exposed Methods
		 * *************************************************** */
		 
		/**
		Activate the stopwatch.
		@method start
		*/
		public function start () : void {
			if (st.active) {
				_oldVal = _val;
				_lastTime = getTimer();
			}
			
			st.interval = resolution;
			
			st.active = true;
		}
		
		/**
		Reset the stopwatch.
		@method reset
		*/
		public function reset () : void {
			if (st.active) {
				st.reset();
			}
			
			_val = _oldVal = 0;
		}
		
		/**
		Pause the stopwatch.
		@method pause
		*/
		public function pause () : void {
			if (st.active) {
				st.reset();
			}
		}
		
		/**
		Retrieve the current time of the stopwatch.
		@method getTime
		*/	
		public function getTime():Number {
			if (st.active) {
				_val = getTimer() - _lastTime + _oldVal;
			}
			
			return _val;
		}
		
		/**
		 * Remove this component's associated listeners and memory.
		 */
		public function destroy () : void {
			st.removeEventListener("onElapsed", timerElapsed);
			st.destroy();
		}
		 
		 
		/* ***************************************************
		 * Private/Protected Methods
		 * *************************************************** */
		
		/**
		 * Called when someone has changed a stopwatch parameter. If the stopwatch is running, we pause it, reset the values, then restart.  If
		 * the stopwatch is not active, we don't need to do anything (parameters are set outside us).
		 */
		protected function resetStopwatchParameters () : void {
			if (st.active) {
				st.interval = _resolution;
				st.start();					// We know if the timer is running and it gets a 'start' call, it will reset with new parameters.
			}
		}
		
		/**
		This is called on timer interrupts.  Decide if we should issue a pulse.
		*/
		protected function timerElapsed (te:EventWithData):void {
			var ct:int = getTimer();
	
			_val += ct - _lastTime;
			_lastTime = ct;
			if (_val - _oldVal >= _pulseInterval) {
				if (!goQuietly) {
					dispatchEvent(new EventWithData(evtPulse, false, false, _val));
				}
				_oldVal = _val;
			}
		}
	}
}