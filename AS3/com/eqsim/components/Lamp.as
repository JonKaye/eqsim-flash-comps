/*
	************************************************
	
	FILE: Lamp.as
	
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
	import fl.core.InvalidationType;
	import flash.display.MovieClip;
	import flash.utils.getDefinitionByName;
	import com.eqsim.events.EventWithData;
	import flash.display.Sprite;

	[IconFile("lampAttach.png")]
	
	/**
	 <p>This class implements a multi-state lamp (indicator) with attached graphics.</p>
	 <p>There is a default background supplied, but you can remove it by changing the background class name (<code>bkgndClassName</code>) to null ("").
	 You create the various state graphics by supplying <code>classNames</code> with the class names of the various states, then set <code>displayLamp</code>
	 to the index of the state graphic you want to display (0 for the first).</p>
	  
	<p>The class generates no events.</p>
	 */
	public class Lamp extends UIComponent {

		/* ***************************************************
		 * Exposed Properties
		 * *************************************************** */
		 
		/**
		 * Array of strings representing the class names of the lamp movie clips.
		 * @property
		 */
		[Inspectable(name="Lamp state skin class names", type=Array)]
		public function set classNames (a:Array) : void {
			changeSkins(a);
			_classNames = a;
			invalidate();
		}
		public function get classNames () : Array {
			return _classNames;
		}
		
		protected var _classNames:Array;

		/**
		 * Class name of the background movie clip.  If you do not want a background clip, make this field empty.
		 * @property
		 */
		[Inspectable(name="Class name of background clip", type=String, defaultValue="defLampAttachBkgnd")]
		public function set bkgndClassName (a:String) : void {
			changeBkgndSkin(a);
			_bkgndClassName = a;
			invalidate();
		}
		public function get bkgndClassName () : String {
			return _bkgndClassName;
		}
		protected var _bkgndClassName:String = "defLampAttachBkgnd";

		
		/**
		 * Numeric index of the lamp graphic to display currently (starting at 0).
		 * @property
		 */
		[Inspectable(name="Index of lamp graphic to display", type=Number, defaultValue="0")]
		public function set displayLamp (v:int) : void {
			_prevLampState = _lampState;
			_lampState 	   = v;
			invalidate();
		}
		public function get displayLamp () : int {
			return _lampState;
		}
		protected var _lampState:int;
		
		
		
		/* ***************************************************
		 * Protected/Private Properties
		 * *************************************************** */
		protected var lampClips:Array;
		protected var lampBkgnd:MovieClip;
		protected var lampContainer:Sprite;
		protected var _prevLampState:int;
		
		
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
		public function Lamp() {
			super();
		}
		 
		/**
		 * configUI
		 * Get the display objects created in preparation of launch.  Note that we get called before
		 * our constructor, and before we are notified that we are on the stage!
		 */
		override protected function configUI():void {
			
			super.configUI();
			
			lampClips = [];
			lampContainer = new Sprite();
			addChild(lampContainer);
			changeBkgndSkin(_bkgndClassName);
		}
		
		
		/**
		 * 
		 */
		protected override function draw():void {
			
			if (isInvalid(InvalidationType.SIZE)) {
				lampContainer.scaleX = width / lampBkgnd.width;
				lampContainer.scaleY = height / lampBkgnd.height;
			}
			
			if (lampClips.length > 0) {
				if (lampClips[_prevLampState].stage != null) {
					lampContainer.removeChild(lampClips[_prevLampState]);
				}
			
				lampContainer.addChild(lampClips[_lampState]);
			}

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
		 *
		 */
		protected function changeSkins (a:Array) : void {
			var gfxSkinClass:Class;
			var lampInst:MovieClip;
			var i:int;

			if (_classNames == null || a[0] != _classNames[0]) {
				if (lampClips.length > 0 && lampClips[0].stage != null) {
					for (i=0; i<lampClips.length; i++) {
						removeChild(lampClips[i]);
					}
				}
				
				lampClips = [];
				
				for (i=0; i<a.length; i++) {
					gfxSkinClass = getDefinitionByName(a[i]) as Class;
					lampInst = new gfxSkinClass() as MovieClip;
					lampClips.push(lampInst);
				}
			}
		}
		
		/**
		 *
		 */
		protected function changeBkgndSkin (s:String) : void {
			// If the lamp background has been placed on the stage already, remove it
			if (lampBkgnd != null && lampBkgnd.stage != null) {
				lampContainer.removeChild(lampBkgnd);
			}
			
			if (s != "") {
				var classConstruct:Class = getDefinitionByName(s) as Class;
				lampBkgnd = new classConstruct() as MovieClip;
				lampContainer.addChild(lampBkgnd);
			}
		}
	}
}