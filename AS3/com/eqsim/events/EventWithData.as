/*
	************************************************
	
	FILE: EventWithData.as (event with a data field)
	
	Copyright (c) 2011, Jonathan Kaye, All rights reserved.

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
	
	************************************************
*/
	
package com.eqsim.events {
	
	import flash.events.*;
	
	/**
	 * Class that derives from Event but allows one to hang values off a <code>data</code> property. 
	 */
	public class EventWithData extends Event {
		
		/**
		 * @default an empty Object.
		 */
		public var data:Object;
		
		/**
		 * Creates an instance of an Event with a data property.
		 * <p>If you pass in an Object to the constructor for the data parameter, the event gets initialized with that Object.  Otherwise,
		 * it gets set to null.</p>
		 * @param	type
		 * @param	bubbles
		 * @param	cancelable
		 * @param	dataInit Optional.  If you do not include this, the constructor adds a new, blank Object automatically.  If you pass in a value for this,
		 * the constructor uses that Object.
		 */
		public function EventWithData (type:String, bubbles:Boolean = false, cancelable:Boolean = false, dataInit:Object = null) {
			super(type, false, false);
			this.data = dataInit;
		}
	
		/**
		 * 
		 * @private
		 */
		public override function clone():Event {
			return new EventWithData(type, bubbles, cancelable, data);
		}
		
		/**
		 * 
		 * @private
		 */
		public override function toString():String {
			return formatToString("DataEvent", "type", "bubbles", "cancelable", "eventPhase", "dataInit");
		}
		
	}
}