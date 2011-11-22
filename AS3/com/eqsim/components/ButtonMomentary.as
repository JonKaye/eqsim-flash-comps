/*
	************************************************
	
	FILE: ButtonMomentary.as
	
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
	import com.eqsim.events.EventWithData;
	import flash.utils.getDefinitionByName;
	import flash.utils.Timer;
	import flash.events.TimerEvent;

	/**
	Default event generated when user presses the button.
	@event onPress
	*/
	[Event(name="onPress")]
	/**
	Default event name of event generated when user releases the button and the cursor is within the button's hit area.
	@event onRelease
	*/
	[Event(name="onRelease")]
	/**
	Default event name of event generated when user releases the button and the cursor is outside the button's hit area.
	@event onReleaseOutside
	*/
	[Event(name="onReleaseOutside")]
	/**
	Default event name of event generated when user moves the cursor over the button's hit area.
	@event onRollOver
	*/
	[Event(name="onRollOver")]
	/**
	Default event name of event generated when user moves the cursor from the button's hit area to away from the hit area.
	@event onRollOut
	*/
	[Event(name="onRollOut")]
	/**
	Default event name of event generated when component is inactive (<code>enabled == false</code>) and any other event (press, release, rollover, etc.) would have been invoked.
	Event value (data) tells the target which event (a string).
	@event onDisabled
	*/
	[Event(name="onDisabled")]
	
	[IconFile("icons/buttonMomentary.png")]

	/** ************************************************
	<p>This class implements a momentary push button with an optional repeater.  Developers can configure
	how much time to wait until repeating starts, and the frequency for the repeat <code>onPress</code> event generated.  Developers can change the
	appearance by changing the <code>defaultButtonUpClassName</code> and <code>defaultButtonDownClassName</code> properties to Sprite/MovieClip classes
	in the Library.</p>
	  
	<p>The class has six events, by default called:</p>
	<li><code>onPress</code> - Generated when button first pressed, and repeated at specified frequency</li>
	<li><code>onRelease</code> - Generated when button released</li>
	<li><code>onReleaseOutside</code> - Generated when button released outside confines of the hit area</li>
	<li><code>onRollOver</code> - Generated when cursor rolls over button hit area</li>
	<li><code>onRollOut</code> - Generated when cursor rolls out of button hit area</li>
	<li><code>onDisabled</code> - Generated if the user does any operation above (except ReleaseOutside) when the button is disabled (i.e., enabled == false)</li>

	<p>The events have no data associated with them, except in the case of the onDisabled event: its data is a String indicating
	the type is the event that would have been invoked, i.e., onPress, onRelease, etc.  If one registers for onDisabled, the caller will receive
	notices for all the events, since the user is subscribing to the onDisabled event.</p>

	@class ButtonMomentary
	@author Jonathan Kaye
	@tooltip momentary button 
	 * ************************************************* */
	public class ButtonMomentary extends UIComponent {

		/* ***************************************************
		 * Exposed Properties
		 * *************************************************** */
		 
		/**
		Event name of onPress event. The event names should really only be set at the time the component
		is instantiated (either at run-time, or programmatically).  However, you can change it at any time
		programmatically and the component will use that event name.
		@property evtPress
		*/
		[Inspectable(name="onPress event name", type=String, defaultValue="onPress")]
		public var evtPress:String = "onPress";
		
		/**
		Event name of onRelease event. The event names should really only be set at the time the component
		is instantiated (either at run-time, or programmatically).  However, you can change it at any time
		programmatically and the component will use that event name.

		@property evtRelease
		*/
		[Inspectable(name="onRelease event name", type=String, defaultValue="onRelease")]
		public var evtRelease:String = "onRelease";
		
		/**
		Event name of onReleaseOutside event. The event names should really only be set at the time the component
		is instantiated (either at run-time, or programmatically).  However, you can change it at any time
		programmatically and the component will use that event name.

		@property evtReleaseOutside
		*/
		[Inspectable(name="onReleaseOutside event name", type=String, defaultValue="onReleaseOutside")]
		public var evtReleaseOutside:String = "onReleaseOutside";
		
		/**
		Event name of onRollOver event. The event names should really only be set at the time the component
		is instantiated (either at run-time, or programmatically).  However, you can change it at any time
		programmatically and the component will use that event name.

		@property evtRollOver
		*/
		[Inspectable(name="onRollOver event name", type=String, defaultValue="onRollOver")]
		public var evtRollOver:String = "onRollOver";
		
		/**
		Event name of onRollOut event. The event names should really only be set at the time the component
		is instantiated (either at run-time, or programmatically).  However, you can change it at any time
		programmatically and the component will use that event name.

		@property evtRollOut
		*/
		[Inspectable(name="onRollOut event name", type=String, defaultValue="onRollOut")]
		public var evtRollOut:String = "onRollOut";
		
		/**
		Event name of disabled event (when button clicked but button has enabled == false). The event names
		should really only be set at the time the component	is instantiated (either at run-time,
		or programmatically).  However, you can change it at any time programmatically and the component
		will use that event name.

		@property disabled
		*/
		[Inspectable(name="disabled event name", type=String, defaultValue="onDisabled")]
		public var evtDisabled:String = "onDisabled";
		
		/**
		Boolean property indicating whether or not to display the hand cursor when the cursor is over this component.
		@property showHand
		*/
		[Inspectable(name="Show Hand Cursor", type=Boolean, defaultValue=true)]
		public function set showHand (f:Boolean) : void {
			useHandCursor = f;
			if (butUpSkin != null) {
				butUpSkin.buttonMode = butDownSkin.buttonMode = f;
			}
			_showHand = f;
		}
		public function get showHand () : Boolean {
			return(_showHand);
		}
		protected var _showHand:Boolean = true;
		
		/**
		 * Property for changing the graphics (skin) of the button's up (unpressed) state.  The default value is <code>ButtonMomentaryDefaultUp</code>.
		 * To change the skin, create a Sprite or MovieClip class, exporting for ActionScript, and enter the name here.
		 * @property defaultButtonUpClassName
		 */
		[Inspectable(name="button up skin class", type=String, defaultValue="ButtonMomentaryDefaultUp")]
		public function set defaultButtonUpClassName (n:String) : void {
			_defaultButtonUpClassName = n;
			changeUpSkin(); 
		}
		public function get defaultButtonUpClassName () : String {
			return(_defaultButtonUpClassName);
		}
		protected var _defaultButtonUpClassName:String = "ButtonMomentaryDefaultUp";
		
		/**
		 * Property for changing the graphics (skin) of the button's down (pressed) state. The default value is <code>ButtonMomentaryDefaultDown</code>.
		 * To change the skin, create a Sprite or MovieClip class, exporting for ActionScript, and enter the name here.
		 * @property defaultButtonDownClassName
		 */
		[Inspectable(name="button down skin class", type=String, defaultValue="ButtonMomentaryDefaultDown")]
		public function set defaultButtonDownClassName (n:String) : void {
			_defaultButtonDownClassName = n;
			changeDownSkin(); 
		}
		public function get defaultButtonDownClassName () : String {
			return(_defaultButtonDownClassName);
		}
		protected var _defaultButtonDownClassName:String = "ButtonMomentaryDefaultDown";
		
		
		/**
		Sets the interval (in milliseconds) between repeated onPress when the button is pressed.  The
		first interval begins after the waiting period (<code>wait4Start</code>).
		@property pulseFreq
		*/
		[Inspectable(name="Pulse Frequency (millisec)", type=Number, defaultValue=100)]
		public var pulseFreq:int = 100;
		
		/**
		Sets the duration (in milliseconds) to wait after the user has pressed the left mouse button
		and before the button begins to repeat the onPress event.  Note that one onPress event is
		generated immediately when the user first presses the button.  If this value is 0, then
		the button does not repeat onPress events.
		@property wait4Start
		*/
		[Inspectable(name="Wait until Repeat (millisec)", type=Number, defaultValue=250)]
		public var wait4Start:int = 250;
		
		/**
		 Timer used internally to implement repeater behavior.
		 */
		protected var repeaterInstance:Timer;
		/**
		 Timer instance for waiting while mouse is down until we start repeating.
		 */
		protected var timeUntilRepeat:Timer; 
		/**
		 If true, repeated presses are quiet (no evtPress generate), false is regular (evtPress generated)
		 */
		protected var repeatPressQuiet:Boolean;
		
		/* ***************************************************
		 * Protected/Private Properties
		 * *************************************************** */
		/**
		 Sprite containing the button down skin.
		 */
		protected var butDownSkin:Sprite;
		/**
		 Sprite containing the button up skin.
		 */
		protected var butUpSkin:Sprite;
		/**
		 Sprite container used for scaling button easily.
		 */
		protected var buttonContainer:Sprite;
		
		
		/* ***************************************************
		 * Constants
		 * *************************************************** */
		

		/* ***************************************************
		 * Constructor and Required Methods (UIComponent)
		 * *************************************************** */ 

		/**
		 *
		 */
		public function ButtonMomentary() {
			super();
			
			repeaterInstance = new Timer(pulseFreq);
			repeaterInstance.addEventListener(TimerEvent.TIMER, repeatPressHandler);
			timeUntilRepeat = new Timer( (wait4Start == -1 ? 0 : wait4Start) );
			timeUntilRepeat.addEventListener(TimerEvent.TIMER, timeToRepeatHandler);
			
		}
		 
		/**
		 * configUI
		 * Get the display objects created in preparation of launch.  Note that we get called before
		 * our constructor, before strings and before we are notified that we are on the stage!
		 */
		override protected function configUI():void {
			super.configUI();
			
			var upSkinClass:Class = getDefinitionByName(defaultButtonUpClassName) as Class;
			var downSkinClass:Class = getDefinitionByName(defaultButtonDownClassName) as Class;
			
			buttonContainer = new Sprite();
			butUpSkin = new upSkinClass() as Sprite;
			butDownSkin = new downSkinClass() as Sprite;
			
			butUpSkin.buttonMode = butDownSkin.buttonMode = _showHand;
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			this.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			this.addEventListener(MouseEvent.MOUSE_OVER, mouseRollOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, mouseRollOut);
			
			buttonContainer.addChild(butUpSkin);
			buttonContainer.addChild(butDownSkin);
			addChild(buttonContainer);
			
			setDown(false);
		}
		
		/**
		 *
		 */
		 protected function changeUpSkin () : void {
			var upSkinClass:Class = getDefinitionByName(defaultButtonUpClassName) as Class;
			
			buttonContainer.removeChild(butUpSkin);
			butUpSkin = new upSkinClass() as Sprite;
			buttonContainer.addChild(butUpSkin);
			setDown(false);
			invalidate();
		 }
		 
		 /**
		 *
		 */
		 protected function changeDownSkin () : void {
			var downSkinClass:Class = getDefinitionByName(defaultButtonDownClassName) as Class;
			
			buttonContainer.removeChild(butDownSkin);
			butDownSkin = new downSkinClass() as Sprite;
			buttonContainer.addChild(butDownSkin);
			setDown(false);
			invalidate();
		 }
		
		
		/**
		 * 
		 */
		protected override function draw():void {
			
			buttonContainer.scaleX = width/butUpSkin.width;
			buttonContainer.scaleY = height/butUpSkin.height;
			
			butDownSkin.x = butUpSkin.x = butUpSkin.width / 2;
			butDownSkin.y = butUpSkin.y = butUpSkin.height / 2;
			
			// Last line must call superclass method
			super.draw();
		}
		
		
		/* ***************************************************
		 * Exposed Methods
		 * *************************************************** */
		 
		 /**
		This method is used to programmatically invoke an action of the component based on
		the event passed in.
		
		When a user invokes an action, like presses a button, the button
		generates an onPress event.  This method does the opposite -- given an onPress event, this
		the method visually depresses the button.  This is typically used to simulate the user invoking the action (like our event recorder/playback component).
		
		@method execEvent
		@param evtName Event name (string) must match the event this component generates
		@param evtVal Event value (for momentary button, this value is ignored)
		@param quietly Boolean true to invoke action without generating the event, false or not given at all to allow event to be generated
		*/
		public function execEvent (evtName:String, evtVal:* = null, q:Boolean = false) : void {
			switch (evtName) {
				case evtPress:
					press(q);
					break;
					
				case evtRelease:
					release(q);
					break;
					
				case evtRollOver:
					rollover(q);
					break;
					
				case evtRollOut:
					rollout(q);
					break;
					
				case evtDisabled:
					disabled(evtVal, q);
					break;
					
				case evtReleaseOutside:
					releaseOutside(q);
					break;
			}
		}
		
		/**
		 * Releases the listeners and any memory associated with the component.
		 */
		public function destroy () : void {
			this.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			this.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			this.removeEventListener(MouseEvent.MOUSE_OVER, mouseRollOver);
			this.removeEventListener(MouseEvent.MOUSE_OUT, mouseRollOut);
		}
		 
		/* ***************************************************
		 * Private/Protected Methods
		 * *************************************************** */
		 
		/**
		 When mouse clicked, do the button press action.
		 */
		protected function mouseDown (me:MouseEvent) : void {
			press();
			// catch the mouse up anywhere -- so we can tes
			stage.addEventListener( MouseEvent.MOUSE_UP, mouseUpHandlerForReleaseOutside );
		}
		
		/**
		 Catches 'mouse up' when the mouse is released (inside the button or outside).
		 */
		protected function mouseUpHandlerForReleaseOutside ( me : MouseEvent ) : void {
			releaseOutside();
    		stage.removeEventListener( MouseEvent.MOUSE_UP, mouseUpHandlerForReleaseOutside );
		}
		
		/**
		 Called when button pressed, we generate the onPress event and setup mechanism to see if we should repeat.
		 */
		protected function press (q:Boolean = false) : void {
			generateEvent(evtPress, q);
			if (enabled) {
				setDown(true);
			}
			
			if (wait4Start > 0) {
				timeUntilRepeat.delay = wait4Start;
				timeUntilRepeat.repeatCount = 1;
				repeatPressQuiet = q;
				timeUntilRepeat.start();
			}
		}
		
		/**
		 Called when time elapses that we should start repeating presses.
		 */
		protected function timeToRepeatHandler (te:TimerEvent) : void {
			if (pulseFreq > 0) {
				repeaterInstance.delay = pulseFreq;
				repeaterInstance.repeatCount = 0;
				repeaterInstance.start();
			}
		}
			
		
		/**
		 Called on each repetition while repeater is active.
		 */
		protected function repeatPressHandler (te:TimerEvent) : void {
			press(repeatPressQuiet);
		}
		
		/**
		 Mouse is released; release the button and stop the repeater or any stage we're at, as well.
		 */
		protected function mouseUp (me:MouseEvent) : void {
			release();
			// don't bubble up, which would trigger the mouse up on the stage to invoke onReleaseOutside
    		me.stopImmediatePropagation( );
		}
		
		/**
		 Button is released, stop anything dependent on that and generate the onRelease event.
		 */
		protected function release (q:Boolean = false) : void {
			timeUntilRepeat.stop();
			repeaterInstance.stop();
			
			generateEvent(evtRelease, q);
			if (enabled) {
				setDown(false);
			}
		}
		
		/**
		 Button released with mouse outside the hit area of the button.  Process the release.
		 */
		protected function releaseOutside (q:Boolean = false) : void {
			timeUntilRepeat.stop();
			repeaterInstance.stop();
			
			generateEvent(evtReleaseOutside, q);
			if (enabled) {
				setDown(false);
			}
		}
		
		/**
		 Mouse rolls over button hit area.
		 */
		protected function mouseRollOver (me:MouseEvent) : void {
			rollover();
		}
		
		/**
		 Generates onRollOver event.
		 */
		protected function rollover (q:Boolean = false) : void {
			generateEvent(evtRollOver, q);
		}
		
		/**
		 Mouse leaves button hit area.
		 */
		protected function mouseRollOut (me:MouseEvent) : void {
			rollout();
		}
		
		/**
		 Generates onRollOut event.
		 */
		protected function rollout (q:Boolean = false) : void {
			generateEvent(evtRollOut, q);
		}
		
		/**
		 Generates onDisabled event.
		 */
		protected function disabled (val:String, q:Boolean = false) : void {
			var e:Boolean = enabled;
			enabled = false;
			generateEvent(val, q);
			enabled = e;
		}
		
		/**
		 Generates the given event type passed in.
		 */
		protected function generateEvent (type:String, q:Boolean) : void {
			if (enabled) {
				if (!q) { dispatchEvent(new EventWithData(type, false, false, null)); }
			} else {
				if (!q) { dispatchEvent(new EventWithData(evtDisabled, false, false, type )); }
			}
		}
		
		/**
		 * Sets the graphics to the appropriate visual state, up or down
		 */
		protected function setDown (buttonState:Boolean) : void {
			butUpSkin.visible = !buttonState;
			butDownSkin.visible = buttonState;
		}
	}
}