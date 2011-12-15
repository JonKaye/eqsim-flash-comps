/*
	************************************************
	
	FILE: ButtonToggle.as
	
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

	/**
	Event generated when button goes from the up (unset) to down (set) position.
	@event onSet
	*/
	[Event(name="onSet")]
	/**
	Event generated when button goes from the down (set) to up (unset) position.
	@event onUnset
	*/
	[Event(name="onUnset")]
	/**
	Event generated when component is inactive (enabled == false) and any other event (set, unset, etc.) would have been invoked.
	Event value <code>data</code> gives the string of which event would have been triggered.
	@event onDisabled
	*/
	[Event(name="onDisabled")]
	

	[IconFile("icons/buttonToggle.png")]


	/** ************************************************
	 *
	<p>This class implements a simple toggle button.  Users can change the
	appearance by setting the class names for <code>defaultButtonUpClassName</code> and <code>defaultButtonUpClassName</code> properties.</p>
	  
	<p>The class has three events, by default called:</p>
	<li><code>onSet</code> - Generated when button goes from up to down position</li>
	<li><code>onUnset</code> - Generated when button goes from down to up position</li>
	<li><code>onDisabled</code> - Generated if the user does any operation above (except ReleaseOutside) when the button is disabled (i.e., enabled == false)</li>

	<p>The events have no data associated with them, except in the case of the <code>onDisabled</code> event: its data is a String indicating
	the type is the event that would have been invoked, i.e., onPress, onRelease, etc.  If one registers for onDisabled, the caller will receive
	notices for all the events, since the user is subscribing to the onDisabled event.</p>
	<p>The event names can be changed (if desired) in the component property inspector or programmatically via <code>evtSet</code>, <code>evtUnset</code>, and <code>evtDisabled</code>.</p>

	@class ButtonToggle
	@author Jonathan Kaye
	@tooltip toggle button
	 * 
	 * ************************************************* */
	public class ButtonToggle extends UIComponent {

		/* ***************************************************
		 * Exposed Properties
		 * *************************************************** */
		 
		/**
		Event name for when button is put in the set (down) position.  Change this value
		at any time.
		@property evtSet
		*/
		[Inspectable(name="onSet method name", type=String, defaultValue="onSet")]
		public var evtSet:String = "onSet";
		
		/**
		Event name for when button is put in the unset (up) position.  Change this value
		at any time.
		@property evtUnset
		*/
		[Inspectable(name="onUnset method name", type=String, defaultValue="onUnset")]
		public var evtUnset:String = "onUnset";
		
		/**
		Event name of disabled event (when button clicked but button has enabled == false). The event names
		should really only be set at the time the component	is instantiated (either at run-time,
		or programmatically).  However, you can change it at any time programmatically and the component
		will use that event name.

		@property evtDisabled
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
		 * Property for changing the graphics (skin) of the button's up (unpressed) state.
		 * The default skin (value) for this property is <code>ButtonToggleDefaultUp</code>.  To change it, create a class
		 * and enter the name here.
		 * @property defaultButtonUpClassName
		 */
		[Inspectable(name="button up skin class", type=String, defaultValue="ButtonToggleDefaultUp")]
		public function set defaultButtonUpClassName (n:String) : void {
			_defaultButtonUpClassName = n;
			changeUpSkin(); 
		}
		public function get defaultButtonUpClassName () : String {
			return(_defaultButtonUpClassName);
		}
		protected var _defaultButtonUpClassName:String = "ButtonToggleDefaultUp";
		
		/**
		 * Property for changing the graphics (skin) of the button's down (pressed) state
		 * The default skin (value) for this property is <code>ButtonToggleDefaultDown</code>.  To change it, create a class
		 * and enter the name here.
		 * @property defaultButtonDownClassName
		 */
		[Inspectable(name="button down skin class", type=String, defaultValue="ButtonToggleDefaultDown")]
		public function set defaultButtonDownClassName (n:String) : void {
			_defaultButtonDownClassName = n;
			changeDownSkin(); 
		}
		public function get defaultButtonDownClassName () : String {
			return(_defaultButtonDownClassName);
		}
		protected var _defaultButtonDownClassName:String = "ButtonToggleDefaultDown";
		
		/**
		Whether the button is in the down (set) or up (unset) position.  Set (down) is <code>true</code>, up is <code>false</code>.
		Setting this value generates an onSet or an onUnset event.  If you do not want to generate the event, use <code>onSet(true)</code> or <code>onUnset(true)</code>.
		@property buttonSet
		*/
		[Inspectable(name="Start in Down Position", type=Boolean, defaultValue=false)]
		public function set buttonSet (f:Boolean) : void {
			if (f) {
				onSet();
			} else {
				onUnset();
			}
			invalidate();
		}
		
		public function get buttonSet () : Boolean {
			return _isDownNow;
		}
		protected var _isDownNow:Boolean = false;
		
		/* ***************************************************
		 * Protected/Private Properties
		 * *************************************************** */
		/**
		 Holds the down (set position) skin Sprite.
		 */
		protected var butDownSkin:Sprite;
		/**
		  Holds the up (unset position) skin Sprite.
		 */
		protected var butUpSkin:Sprite;
		/**
		 Container enclosing the up and down skins, for scaling purposes.
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
		public function ButtonToggle() {
			super();
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
			
			buttonContainer.addChild(butUpSkin);
			buttonContainer.addChild(butDownSkin);
			addChild(buttonContainer);
			
			setDown(_isDownNow);
		}
		
		/**
		 Replace the up (unset) skin with <code>defaultButtonUpClassName</code>.
		 */
		 protected function changeUpSkin () : void {
			var upSkinClass:Class = getDefinitionByName(defaultButtonUpClassName) as Class;
			
			buttonContainer.removeChild(butUpSkin);
			butUpSkin = new upSkinClass() as Sprite;
			buttonContainer.addChild(butUpSkin);
			setDown(_isDownNow);
			invalidate();
		 }
		 
		 /**
		 Replace the down (set) skin with <code>defaultButtonDownClassName</code>.
		 */
		 protected function changeDownSkin () : void {
			var downSkinClass:Class = getDefinitionByName(defaultButtonDownClassName) as Class;
			
			buttonContainer.removeChild(butDownSkin);
			butDownSkin = new downSkinClass() as Sprite;
			buttonContainer.addChild(butDownSkin);
			setDown(_isDownNow);
			invalidate();
		 }
		
		
		/**
		 * 
		 */
		protected override function draw():void {
			butDownSkin.visible = _isDownNow;
			butUpSkin.visible = !_isDownNow;
			
			buttonContainer.scaleX = width / butUpSkin.width;
			buttonContainer.scaleY = height / butUpSkin.height;
			
			butUpSkin.x = butUpSkin.y = 0;
			butDownSkin.x = butDownSkin.y = 0;
			
			// Last line must call superclass method
			super.draw();
		}
		
		
		/* ***************************************************
		 * Exposed Methods
		 * *************************************************** */
		 
		 /**
		This method is used to programmatically invoke an action of the component based on
		the event passed in.  When a user invokes an action, like presses a button, the button
		generates an onPress event.  This method does the opposite -- given an onPress event, this
		the method visually depresses the button.  This is typically used to simulate the user invoking the action.
		
		@method execEvent
		@param evtName Event name (string) must match the event this component generates
		@param evtVal Event value (for button, this value is ignored)
		@param quietly Boolean true to invoke action without generating the event, false or not given at all to allow event to be generated
		*/
		public function execEvent (evtName:String, evtVal:* = null, q:Boolean = false) : void {
			switch (evtName) {
				case evtSet:
					onSet(q);
					break;
					
				case evtUnset:
					onUnset(q);
					break;
					
				case evtDisabled:
					disabled(evtVal, q);
					break;
			}
		}
		
		/**
		 * Removes any listeners or memory allocated for this component.
		 * @method destroy
		 */
		public function destroy () : void {
			this.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
		}
		
		/**
		Put the button in the set (down) position and generate the onSet event (if q [quietly] is <code>false</code> [default] -- <code>true</code> suppresses event generation).
		 */
		public function onSet (q:Boolean = false) : void {
			if (enabled) {
				generateEvent(evtSet, q);
				setDown(true);
			}
		}
		
		/**
		 Put the button in the unset (up) position and generate the onUnset event (if q [quietly] is <code>false</code> [default] -- <code>true</code> suppresses event generation).
		 */
		public function onUnset (q:Boolean = false) : void {
			if (enabled) {
				generateEvent(evtUnset, q);
				setDown(false);
			}
		}
		 
		/* ***************************************************
		 * Private/Protected Methods
		 * *************************************************** */
		 
		/**
		 On a mouse click, determine whether to put the button in the up (unset) position or down (set) position.
		 */
		protected function mouseDown (me:MouseEvent) : void {
			if (_isDownNow) {
				onUnset();
			} else {
				onSet();
			}
		}
		
		/**
		 Generate the disabled event.
		 */
		protected function disabled (val:String, q:Boolean = false) : void {
			var e:Boolean = enabled;
			enabled = false;
			generateEvent(val, q);
			enabled = e;
		}
		
		/**
		 Generate the given event.
		 @param type event type
		 @param q A 'quiet' parameter.  If true, do not generate the event.  Defaults to false.
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
			_isDownNow = buttonState;
		}
	}
}