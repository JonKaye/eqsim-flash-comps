/*
	************************************************
	
	AUTHOR: Jonathan Kaye
		
	FILE: PulseActivity.as
	RELEASE: 	August, 2009
	Implementation originally conceived and developed DECEMBER 2001
	
	Copyright (c) 2009, Jonathan Kaye, All rights reserved.

	Redistribution and use in source and binary forms, with or without modification, are permitted
	provided that the following conditions are met:

	- Redistributions of source code must retain the above copyright notice, this list of conditions
	and the following disclaimer.
	- Redistributions in binary form must reproduce the above copyright notice, this list of conditions
	and the following disclaimer in the documentation and/or other materials provided with the distribution.
	
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
	PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
	ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
	TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
	HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
	POSSIBILITY OF SUCH DAMAGE.

	[New BSD License, http://www.opensource.org/licenses/bsd-license.php]
	
	For questions or comments, please refer to http://code.google.com/p/flashsim-state-engines/.
	************************************************
	*/
	
package com.eqsim.FStEng {
	
	import flash.display.Sprite;
	import flash.events.*;
	import flash.utils.Timer;
	import flash.display.MovieClip;
	import com.eqsim.events.EventWithData;
	
	/**
	 * Time-based or frame-based state activity.
	 * <p>A pulse activity is an action that gets triggered at some time- or frame-based interval while a
	 * state is active.  Like transitions, developers use a State's <code>addPulseActivity</code> to attach
	 * a pulse activity to a given State.</p>
	 * When you create a pulse activity, you tell the constructor whether you want to invoke the action (function)
	 * at an interval of milliseconds or of number of frames elapsed.
	 * @class PulseActivity
	*/
	public class PulseActivity extends EventDispatcher  {
		
		/**
		 * Event sent on each pulse of the activity.
		 * <p>The developer tells the pulse activity how frequently to emit pulses.  When the time elapses, the engine
		 * generates a TICK event that callers can register to listen for.</p>
		 * @eventType TICK
		 */
		public static const TICK:String = "TICK";
		
		/**
		 * Interval of pulse.
		 * <p>Interval is in milliseconds if pulse activity is time-based, or is in number of frames if frame-based.</p>
		 */
		internal var intvl:uint;
		/**
		 * @private
		 */
		internal var pulseEvent:EventWithData;
		/**
		 * Frame-based or time-based.
		 * <p>Boolean value indicating true: pulse activity is frame-based, or false: pulse activity is time-based.</p>
		 * @default false
		 */
		internal var frameBased:Boolean;
		/**
		 * Handler routine for this pulse activity.
		 */
		internal var handler:Function;
		
		private var timerObj:Timer;
		private var frameSprite:Sprite;
		private var frameCount:uint;
		
		/**
		 * Boolean flag indicating if this activity is currently active (true) or not (false).
		 */
		private var active:Boolean;
		
		/**
		 * Creates an instance of a Pulse Activity.
		 * <p>Pulse Activities are time- or frame-based triggered actions that do not cause state changes (unless the
		 * developer invokes a transition during the handling of the pulse.  Developers send in the handler function to
		 * the State's pulse activity creator, <code>myStatePtr.addPulseActivity()</code>.</p>
		 * <p>When a tick is generated, the handler receives an <code>EventWithData</code> that has 1 property, <code>event.data.state</code>.
		 * This allows the handler to tell which state originated this pulse activity.</p>
		 * @param	interval	For time-based activities (the default), use milliseconds.  For frame-based activities, use number of frames.
		 * @param	origState	A pointer to the state on which the activity is defined.
		 * @param	cb			Callback function for event handler.
		 * @param	fb			Boolean value that is true for frame-based pulses, or false (default) for time-based.
		 */
		public function PulseActivity (interval:uint, origState:State, cb:Function, fb:Boolean = false) {
			intvl 		= interval;
			frameBased	= fb;
			handler		= cb;
			active		= false;
			
			if (frameBased) {
				frameSprite = new Sprite();
			} else {
				timerObj = new Timer(intvl, 0);
				timerObj.addEventListener(TimerEvent.TIMER, timerElapsed, false, 0, true);
			}
			
			pulseEvent =  new EventWithData(PulseActivity.TICK, false, false, { state : origState });
		}
		
		/**
		 * Stops the activity and unhooks the listeners.
		 * This routine is called when a pulse activity is removed.  We unhook the internal listeners so
		 * they don't get stranded from garbage collection (though we do explicitly make the listener have a weak reference).
		 * @private
		 */
		internal function prepareToRemove () : void {
			this.removeEventListener(PulseActivity.TICK, handler);
			stop();
			if (!frameBased) {
				timerObj.removeEventListener(TimerEvent.TIMER, timerElapsed);
			}
		}
		
		/**
		 * Start the pulse activity.
		 * @private
		 */
		public function start () : void {
			if (!active) {
				if (frameBased) {
					frameCount = 0;
					frameSprite.addEventListener(Event.ENTER_FRAME, frameElapsed, false, 0, true);
				} else {
					timerObj.reset();
					timerObj.start();
				}
				active = true;
			}
		}
		
		
		/**
		 * Stop the pulse activity.
		 * @private
		 */
		public function stop () : void {
			if (active) {
				if (frameBased) {
					frameSprite.removeEventListener(Event.ENTER_FRAME, frameElapsed);
				} else {
					timerObj.stop();
				}
				active = false;
			}
		}
		
		/**
		 * Used for frame-based pulse activities.  We count the frames and at the desired interval, send the pulse.
		 * @param	ev
		 * @private
		 */
		private function frameElapsed (ev:Event) : void {
			frameCount++;
			if (frameCount == intvl) {
				dispatchEvent(pulseEvent);
				frameCount = 0;
			}
		}
		
				/**
		 * Used for time-based pulse activities.  When the interval elapses, we send the pulse.
		 * @param	ev
		 * @private
		 */

		private function timerElapsed (ev:Event) : void {
			dispatchEvent(pulseEvent);
		}
	}
}