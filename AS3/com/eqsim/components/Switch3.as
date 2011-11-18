/*
	************************************************
	
	FILE: Switch3.as
	
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
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.utils.getDefinitionByName;
	import flash.events.MouseEvent;

	[IconFile("icons/switch.png")]

	/**
	Event generated when switch put in the up position.
	@event onUp
	*/
	[Event("onUp")]
	/**
	Event generated when switch put in the middle position.
	@event onMiddle
	*/
	[Event("onMiddle")]
	/**
	Event generated when switch put in the down position.
	@event onDown
	*/
	[Event("onDown")]
	/**
	Event generated when component is inactive (enabled == false) and any other event (onUp, onDown, etc.) would have been invoked.
	Event value <code>data</code> gives the string of which event would have been triggered.
	@event onDisabled
	*/
	[Event("onDisabled")]


	/** ************************************************
	 <p>This class implements a simple three position switch.</p>
	 <p>The switch generates four events: <code>onUp</code>, <code>onDown</code>, <code>onMiddle</code>, and <code>onDisabled</code>.</p>
	<p>The switch has the option of auto-center, meaning it can be made to revert to the middle position after the mouse is
	let go while the switch is in the up or down position.  The switch graphics are all contained in a MovieClip which
	 you can change by setting the <code>defaultSwitchClass</code> property.  Look in that property to see more details about what that MovieClip must contain.</p>
	 * ************************************************* */
	public class Switch3 extends UIComponent {

		/* ***************************************************
		 * Exposed Properties
		 * *************************************************** */
		 
		/**
		Event name for when button is put in the up  position.
		
		@property evtUp
		*/
		[Inspectable(name="onUp Event Name", type=String, defaultValue="onUp")]
		public var evtUp:String = "onUp";

		/**
		Event name for when button is put in the middle position.
		
		@property evtMiddle
		*/
		[Inspectable(name="onMiddle Event Name", type=String, defaultValue="onMiddle")]
		public var evtMiddle:String = "onMiddle";
		
		/**
		Event name for when button is put in the down position.
		
		@property evtDown
		*/
		[Inspectable(name="onDown Event Name", type=String, defaultValue="onDown")]
		public var evtDown:String = "onDown";
		
		/**
		Boolean property indicating whether or not to display the hand cursor when the cursor is over this component.
		@property showHand
		*/
		[Inspectable(name="Show Hand Cursor", type=Boolean, defaultValue=true)]
		public function set showHand (f:Boolean) : void {
			useHandCursor = f;
			if (switchSkin != null) {
				switchSkin.buttonMode = f;
			}
			_showHand = f;
		}
		public function get showHand () : Boolean {
			return(_showHand);
		}
		protected var _showHand:Boolean = true;
		
		/**
		Event name of disabled event (when button clicked but button has enabled == false). The event names
		should really only be set at the time the component	is instantiated (either at run-time,
		or programmatically).  However, you can change it at any time programmatically and the component
		will use that event name.

		@property onDisabled
		*/
		[Inspectable(name="disabled event name", type=String, defaultValue="onDisabled")]
		public var evtDisabled:String = "onDisabled";
		
		/**
		 * Boolean value indicating whether or not to return to center after mouse click up or down.  If <code>true</code>, then there is
		 * no clickable middle position for the switch -- simply releasing the mouse when the switch is in the up or down position
		 * will have the switch return to the middle.  A value of <code>false</code> will make a clickable middle position.
		 * @property autoCenter
		 */
		[Inspectable(name="Auto-center?", type=Boolean, defaultValue=false)]
		public function set autoCenter (f:Boolean) : void {
			_autoCenter = f;
			setupSwitchHandlers();
		}
		
		public function get autoCenter () : Boolean {
			return _autoCenter;
		}
		protected var _autoCenter:Boolean = false;
		
		
		/**
		Which position the switch is in -- "up", "middle", or "down".
		
		@property position
		*/
		[Inspectable(name="Switch position", type=List, enumeration="up,middle,down", defaultValue="middle")]
		public function set position (f:String) : void {
			_position = f;
			setSwitchPosition(f);
		}
		
		public function get position () : String {
			return _position;
		}
		protected var _position:String = "middle";
		
		
		/**
		 * Property for changing the graphics (skin) of the switch.
		 * <p>The graphic (MovieClip) must have the following items defined within it:</p>
		 * <li>hUp, hMid, and hDown: instance names for movie clips used as the hot spots on the switch</li>
		 * <li>swUp, swMid, swDown: instance names for movie clips used for the switch graphic in the specific position</li>
		 *
		 * @property defaultSwitchClass
		 */
		[Inspectable(name="switch skin", type=String, defaultValue="switch3DefaultSkin")]
		public function set defaultSwitchClass (n:String) : void {
			changeSkin(n); 
		}
		public function get defaultSwitchClass () : String {
			return(_defaultSwitchClass);
		}
		protected var _defaultSwitchClass:String = "switch3DefaultSkin";
		
		
		/* ***************************************************
		 * Protected/Private Properties
		 * *************************************************** */
		/** 
		 * The MovieClip with the switch skin.
		 */
		protected var switchSkin:MovieClip;
		/**
		 * Overall Sprite container to ease scaling.
		 */
		protected var buttonContainer:Sprite;
		
		/**
		 * Used to avoid generating position change event in the case that initial parameters are different from default
		 */
		private var constructorHasRun:Boolean = false;
		
		
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
		public function Switch3() {
			super();
			
			constructorHasRun = true;
		}
		 
		/**
		 * configUI
		 * Get the display objects created in preparation of launch.  Note that we get called before
		 * our constructor, and before we are notified that we are on the stage!
		 */
		override protected function configUI():void {
			super.configUI();
		
			var switchSkinClass:Class = getDefinitionByName(_defaultSwitchClass) as Class;
			buttonContainer = new Sprite();
			switchSkin = new switchSkinClass() as MovieClip;
			switchSkin.buttonMode = _showHand;
			
			setupSwitchHandlers();
			
			buttonContainer.addChild(switchSkin);
			addChild(buttonContainer);
		}
		
		
		/**
		 * 
		 */
		protected override function draw():void {
			switch (_position) {
				case "up":
					switchSkin.swUp.visible = true;
					switchSkin.swMid.visible = 
					switchSkin.swDown.visible = false;
					break;
					
				case "down":
					switchSkin.swDown.visible = true;
					switchSkin.swMid.visible = 
					switchSkin.swUp.visible = false;
					break;
					
				case "middle":
					switchSkin.swMid.visible = true;
					switchSkin.swDown.visible = 
					switchSkin.swUp.visible = false;
					break;
			}
			
			buttonContainer.scaleX = width / switchSkin.width;
			buttonContainer.scaleY = height / switchSkin.height;
			
			// Last line must call superclass method
			super.draw();
		}
		
		
		/* ***************************************************
		 * Exposed Methods
		 * *************************************************** */
		 
		 /**
		  * Set the switch to the "up", "middle", or "down" position programmatically.  If enabled == false, the position does not
		  * change but the event that would have been triggered is sent as the data object of the onDisabled event.
		  *
		  * @param pos Can be "up", "middle", or "down" (case-sensitive)
		  * @param q If true, don't generate the corresponding event on position change.  If false (default), generate the event.
		  */
		 public function setSwitchPosition(pos:String, q:Boolean = false) : void {
			if (enabled) {
				_position = pos;
			}
		
			if (constructorHasRun) {
				switch (pos) {
					case "up":
						generateEvent(evtUp, q);
						break;
					case "middle":
						generateEvent(evtMiddle, q);
						break;
					case "down":
						generateEvent(evtDown, q);
						break;
				}
			}
		
			invalidate();
		}
		
		/**
		This method is used to programmatically invoke an action of the component based on
		the event passed in.  When a user invokes an action, like presses the up direction on the switch, the switch
		generates an onUp event.  This method does the opposite -- given an onUp event, this
		the method visually moves the switch to the up position.  This is typically used to simulate the user invoking the action.
		
		@method execEvent
		@param evtName Event name (string) must match the event this component generates
		@param evtVal Event value (only applicable if the event is onDisabled, in which case this value is evtUp, evtMiddle, or evtDown)
		@param quietly Boolean true to invoke action without generating the event, false or not given at all to allow event to be generated (default == false)
		*/
		public function execEvent (evtName:String, evtVal:* = null, q:Boolean = false) : void {
	
			switch (evtName) {
				case evtUp:
					setSwitchPosition("up", q);
					break;
					
				case evtMiddle:
					setSwitchPosition("middle", q);
					break;
					
				case evtDown:
					setSwitchPosition("down", q);
					break;
					
				case evtDisabled:
					var origEnabled:Boolean = enabled;
					enabled = false;
					switch (evtVal) {
						case evtUp:
							setSwitchPosition( "up", q);
							break;
						case evtDown:
							setSwitchPosition( "down", q);
							break;
						case evtMiddle:
							setSwitchPosition( "middle", q);
							break;
					}
					enabled = origEnabled;
					break;
			}
		}
		
		 /**
		  *
		  */
		 public function destroy () : void {
			removeListeners();
		 }
		 
		/* ***************************************************
		 * Private/Protected Methods
		 * *************************************************** */
		
		/**
		 * Change the switch skin to the given class name.
		 * @ param n class name.
		 */
		protected function changeSkin (n:String) : void {
			_defaultSwitchClass = n;
			buttonContainer.removeChild(switchSkin);
			removeListeners();
			
			var switchSkinClass:Class = getDefinitionByName(_defaultSwitchClass) as Class;
			switchSkin = new switchSkinClass() as MovieClip;
			switchSkin.buttonMode = _showHand;
			
			setupSwitchHandlers();
			
			buttonContainer.addChild(switchSkin);
			
			invalidate();
		}
		
		/**
		 * Creates the listeners for the up, middle, and down positions.
		 */
		protected function setupSwitchHandlers () : void {
			switchSkin.hUp.addEventListener(MouseEvent.MOUSE_DOWN, flipToUp);
			switchSkin.hDown.addEventListener(MouseEvent.MOUSE_DOWN, flipToDown);
			
			if (_autoCenter) {
				switchSkin.hUp.addEventListener(MouseEvent.MOUSE_UP, flipToMiddle);
				switchSkin.hDown.addEventListener(MouseEvent.MOUSE_UP, flipToMiddle);
				
				if (switchSkin.hMid.hasEventListener(MouseEvent.MOUSE_DOWN)) {
					switchSkin.hMid.removeEventListener(MouseEvent.MOUSE_DOWN, flipToMiddle);
				}
			} else {
				switchSkin.hMid.addEventListener(MouseEvent.MOUSE_DOWN, flipToMiddle);
			}
		}
		
		
		/**
		 * Removes listeners.
		 */
		protected function removeListeners () : void {
			switchSkin.hUp.removeEventListener(MouseEvent.MOUSE_DOWN, flipToUp);
			switchSkin.hDown.removeEventListener(MouseEvent.MOUSE_DOWN, flipToDown);
			
			if (switchSkin.hMid.hasEventListener(MouseEvent.MOUSE_DOWN)) {
				switchSkin.hMid.removeEventListener(MouseEvent.MOUSE_DOWN, flipToMiddle);
			}
			if (switchSkin.hUp.hasEventListener(MouseEvent.MOUSE_UP)) {
				switchSkin.hUp.removeEventListener(MouseEvent.MOUSE_UP, flipToMiddle);
			}
			if (switchSkin.hDown.hasEventListener(MouseEvent.MOUSE_UP)) {
				switchSkin.hDown.removeEventListener(MouseEvent.MOUSE_UP, flipToMiddle);
			}
		}
		
		
		/**
		 * Moves switch to up position.  If autoCenter is true, setup mechanism to return switch to center when mouse is released.
		 */
		protected function flipToUp (me:MouseEvent, q:Boolean = false) : void {
			setSwitchPosition("up", q);
			
			// To capture the user's release outside (and inside) the switch hit area, we add a listener to the stage
			if (_autoCenter && me.type == MouseEvent.MOUSE_DOWN) {
				if (stage != null) {
					stage.addEventListener( MouseEvent.MOUSE_UP, flipToMiddle );
				}
			}
		}
		
		/**
		 * Moves switch to middle position.
		 */
		protected function flipToMiddle (me:MouseEvent, q:Boolean = false) : void {
			setSwitchPosition("middle", q);
			if (_autoCenter && me.type == MouseEvent.MOUSE_UP) {
				if (stage != null) {
					stage.removeEventListener( MouseEvent.MOUSE_UP, flipToMiddle );
				}
			} 
		}
		
		
		/**
		 * Moves switch to down position.  If autoCenter is true, setup mechanism to return switch to center when mouse is released.
		 */
		protected function flipToDown (me:MouseEvent, q:Boolean = false) : void {
			setSwitchPosition("down", q);
			
			// To capture the user's release outside (and inside) the switch hit area, we add a listener to the stage
			if (_autoCenter && me.type == MouseEvent.MOUSE_DOWN) {
				if (stage != null) {
					stage.addEventListener( MouseEvent.MOUSE_UP, flipToMiddle );
				}
			}
		}
		
		/** 
		 * generates the switch events.
		 */
		protected function generateEvent (type:String,  q:Boolean) : void {
			if (enabled) {
				if (!q) { dispatchEvent(new EventWithData(type, false, false, null)); }
			} else {
				if (!q) { dispatchEvent(new EventWithData(evtDisabled, false, false, type )); }
			}
		}
		
	}
}