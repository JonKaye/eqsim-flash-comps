/**
	***********************************************
	
	EXAMPLE: Hierarchical State Machine Engine
	AUTHOR: Jonathan Kaye
	RELEASE: 	August, 2009
	Implementation originally conceived and developed DECEMBER 2001		
		
	FILE: com.flashsim.FStEng.Three.StateEngine.as
	
	This is the main code for the Flash State Engine, created
	by Jonathan Kaye to accompany the book, "Flash for Interactive Simulation"
	(October, 2002), by Jonathan Kaye and David Castillo
	(Delmar Thomson Learning).
	
	Special thanks to Zjnue Brzavi for helping to tighten up the code.
	
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
	*********************************************** ***
	*/
	
package com.eqsim.FStEng {
	
	import flash.display.Sprite;
	import flash.events.*;
	import flash.utils.Timer;
	import flash.utils.Dictionary;
	import com.eqsim.events.EventWithData;
	
	/**
	 * The StateEngine is the main data structure for the hierarchical state machine.
	 * <p>The StateEngine encapsulates the functionality for a state machine (hierarchical or finite states).
	 * Once you create an instance of a StateEngine, you then instantiate the state network as a series of
	 * State's (simple states), HState's (hierarchical states), and HStateC's (Hierarchical, concurrent states).</p>
	 * <p>To keep track of the current state(s), a data structure called a <code>StateManager</code> is used.  A State Manager
	 * keeps track of which state(s) in a network is/are current.  Trying to avoid confusion, the API hides this as
	 * much as possible by automatically creating State Managers when the developer uses State's and HState's, for example, via <code>stateInstance.addSubState()</code> and
	 * <code>stateInstance.addSubHState()</code>.  However, since
	 * a State Manager is required to manage each sub-network, if the developer creates an HStateC, he must manually create
	 * State Manager's to organize the HStateC's sub-networks.</p>
	 * <p>To activate the state network, use <code>active = true;</code>, or <code>activate()</code>.  To send events
	 * into the StateEngine, use <code>PostEvent()</code>.  Events can optionally be postponed by passing in a delay value, but there
	 * currently is no mechanism to defer events (as in UML 2.0).  Events are processed in a FIFO, priority-based queue (default priority is 1000:
	 * lower number means higher priority).  The engine guarantees
	 * that the network runs-to-completion before processing the next event in the queue.</p>
	 * <p>If you only want a finite state machine, you can create a top state as a hierarchical
	 * state (HState) and then just add simple states (State) to the network.</p>
	 * 
	 * 
	 * @class  StateEngine
	 * @author Jonathan Kaye
	 * ***********************************************************************************/
	public class StateEngine extends EventDispatcher {
		
		/**
		 * Event sent when the state engine gets activated.
		 * @eventType ACTIVATE
		 */
		public static const ACTIVATE:String 		= "ACTIVATE";
		
		/**
		 * Event sent when the state engine gets deactivated.
		 * @eventType DEACTIVATE
		 */
		public static const DEACTIVATE:String 		= "DEACTIVATE";
		
		/**
		 * Event sent when no state has handled an injected event.
		 * <p>If an event is posted but no state has an event handler to handle it.  To help the handler recognize which event went
		 * unhandled, the StateEngine has an <code>event</code> property that hangs off of the EventWithData's data object.  For example,
		 * <code>myEventWithDataPtr.data.event</code> gives the Event object that went unhandled.  The default handler can examine
		 * that event and decide what the default behavior needs to be.</p>
		 * @eventType UNHANDLED_EVENT
		 */
		public static const UNHANDLED_EVENT:String	= "UNHANDLED";
		
		/**
		 * User-defined (String) name of the state engine.
		 * @default "State Engine"
		 */
		public var name:String;							// state engine name
		
		/**
		 * A Dictionary (flash.utils.Dictionary) of the currently active states.
		 * <p>The State objects are keys, with values being <code>true</code></p>.
		 */
		public var activeStates:Dictionary;
		
		/**
		 * Count used to know when to pass events up to concurrent (hier) states.  When we pass an event
		 * to an HStateC, we have to wait until all the sub-networks have had a chance to handle the event
		 * before we give the opportunity to the ancestors.
		 * @private
		 */
		internal var _concEvCt:Dictionary;
		
		/**
		 * An instance of a Sprite to use for frame-based pulse activities.
		 * You can make pulse activities (PulseActivity) trigger based on an approximate time value (using Flash's
		 * Timer class), or based on number of frames.  We create a Sprite during initialization in case the
		 * user wants to have frame-based timings (for which we need to listen for an ENTER_FRAME event).
		 * @private
		 */
		internal var spriteForFramePulse:Sprite;
	
		/**
		 * Hash table of ids (keys) to their state.  All state ID's must be unique.
		 * @private
		 */
		internal var statesByID:Object;
		
		private var stNet:HStateC;						// topmost state in this engine's state network
		private var handlingEvent:Boolean;				// true while an event is being processed, false otherwise
		private var eventsWaiting:Array;				// Array of events waiting to be handled (new for version 3)
		
		private var unhandledEvent:EventWithData;	// event object passed when there were no handlers for an event
		
		private var eventTimerDelay:Timer;
		
		private var topLevelStateNetworkMgr:StateManager;	// state network's top manager
		
		private var networkPrepared:Boolean;			// true when network has already had state engine pointers set in states, and transitions resolved.
		
		/**
		 * Flag indicating if state engine is active.
		 * <p>Setting this flag to true will activate the engine.  Setting it to false will deactive the engine.  Retrieving
		 * the value will tell you if the state engine is active or not</p>
		 * @default false
		 */
		public function set active (f:Boolean) : void {
			if (f) {
				if (!_active) {
					activate();
				}
			} else {
				if (active) {
					deactivate();
				}
			}
		}
		
		/**
		 * @private
		 */
		public function get active () : Boolean {
			return _active;
		}
		/**
		 * Actual flag saying if engine active or not.
		 * @private
		 */
		private var _active:Boolean;
		
		/**
		 * Creates a new instance of a state engine data structure.
		 * <p>This is the constructor.  Make sure to hold onto the pointer to this somewhere safe (i.e., away from
		 * the possibility that it will be garbage-collected).  For example, you typically will set the return value
		 * to a property of an class instance in your application.  If you do not hold onto this, Flash may mark
		 * the instance for garbage collection and your network could start acting strange.</p>
		 * 
		 * @method new StateEngine
		 * @param n 			Optional name (String) for the state engine.  Default is "State Engine".
		 * @param stateNetwork 	Optional top state (HState, HStateC, or State [under rare circumstances]) of the network.
		 * 						A top state is mandatory, but supplying it in the constructor is optional.  If you don't
		 * 						supply it here, you must use <code>setStateNetwork()</code> and pass in the top state.
		 * @example <listing>  // this includes top state in instantiation<br>
		 * se = new StateEngine("engine1", new HState("TOP CONTAINER STATE", 0));</listing>
		 * @example <listing>// this assumes top state pointer will be supplied via setStateNetwork()<br>
		 * se	= new StateEngine("engine1");</listing>
		*/
		public function StateEngine(n:String = "State Engine", stateNetwork:HStateC = null) {
			name 				= n;
			stNet				= null;
			_active 			= false;
			eventsWaiting 		= [];
			handlingEvent		= false;
			unhandledEvent		= new EventWithData(StateEngine.UNHANDLED_EVENT);
			
			activeStates 		= new Dictionary(true);
			spriteForFramePulse = new Sprite();
			
			networkPrepared 	= false;
			
			statesByID			= new Object();
			
			eventTimerDelay = new Timer(0);		// used by default for delaying event handling
			eventTimerDelay.addEventListener(TimerEvent.TIMER_COMPLETE, timeDelayElapsed, false, 0, true);
			
			// Create the first state manager, by default.  This is done as a convenience.
			if (stateNetwork != null) {
				setStateNetwork(stateNetwork);
				topLevelStateNetworkMgr = new StateManager("top level State Network Manager", null, stateNetwork.id);
				stateNetwork.myStMgr 	= topLevelStateNetworkMgr;
			}
		}
		
		/**
		* Attaches the state network (referred to by topmost state) to this state engine.
		* You can use this method as an alternative to supplying the top state's pointer in the StateEngine constructor.
		* @method setStateNetwork
		* @param sn 	Pointer to topmost state (virtually always HState or HStateC, if you need it to be State, cast your State into an HStateC) for the state network.
		* @param suppressReassign Optional parameter that locks out possibility to change the top state, once it has been assigned. If an
		* attempt is made to change the name, the routine throws an Error.
		* @example <listing>myTopStatePtr = new HState("State Network", 0);<br>se.setStateNetwork(myTopStatePtr);</listing>
		*/
		public function setStateNetwork (sn:HStateC, suppressReassign:Boolean = false) : void {
			if (topLevelStateNetworkMgr == null) {
				stNet = sn;
				topLevelStateNetworkMgr = sn.myStMgr;
			} else if (suppressReassign != true) {
				throw new Error("ERROR: Trying to set " + sn.name + " as top state of state engine, but " + stNet.name + " has been set already.");
			}
		}
		
		/**
		* Topmost state in the state network.
		* Set and retrieve the topmost state (HState, HStateC) in the state network.  The top state can be a State, but that would
		* be a pretty boring state machine.  If you want the top state to be a State, you can cast your State into an HStateC and pass
		* it in, since HStateC is a sub-state of State.
		* 
		* You can set this parameter as an alternative to supplying the top state's pointer in the StateEngine constructor.
		* @default null
		*/
		public function set topState (s:HStateC) : void {
			stNet = s;
		}
		/**
		 * 
		 * @private
		 */
		public function get topState () : HStateC {
			return stNet;
		}
		
		/**
		* Removes memory associated with the state engine passed in.
		* @method removeStateEngine
		*/
		public function removeStateEngine () : void {
			stNet.removeState();
			
			eventTimerDelay = null;
		}
		
		/**
		Activates the state engine.
		<p>Typically you will use the <code>active</code> property to activate <code>active = true;</code> your state engine.  However,
		you can use this method all the same.  When an engine is activated, it combs through the state network and
		clears all the history markers by default.  If you don't want this to happen, you cannot use <code>active</code>, you
		must use this routine and set the 'resetHistory' parameter to <code>false</code>.</p>
		@method activate
		@param resetHistory (optional) Set this to 'false' if you do not want to reset the history mechanism throughout the system.  Default is true.
		*/
		public function activate(resetHistory:Boolean = true) : void {
			var i:int, j:int;
			
			// Clear all history variables to restart anew
			if (resetHistory) {
				stNet.resetHistory();
			}
			
			if (!networkPrepared) {
				prepareNetwork();
			}
			
			_active = true;
			
			if (this.hasEventListener(StateEngine.ACTIVATE)) {
				dispatchEvent(new EventWithData(StateEngine.ACTIVATE));
			}
			
			// Setup the outermost manager to active.
			stNet.myStMgr.cs 	 = stNet.id;
			stNet.myStMgr.active = true;
			
			// Enter the state network.
			stNet.enter();
		}
		
		/**
		 * Initializes the states and transitions before the engine activates the first time.
		 * <p>The State Engine must do two things before activating:</p><ol>
		 * <li>Place a state engine pointer in each state (since State's are not related to the State Engine, but States need access)</li>
		 * <li>Pre-compute the paths of transitions, to make their execution as efficient as possible.</li>
		 * </ol>
		 * <p>This routine accomplishes both tasks.  If the developer wants to avoid the time it takes to perform these
		 * when the engine activates the first time, he should call this routine.  Once complete, the developer would activate the engine.
		 * If the developer does not call this routine, the engine activation will call it automatically.</p>
		 * @method prepareNetwork.
		 */
		public function prepareNetwork () : void {
			// Go through all the substates to set their state engine ptr to us, and add their states to the master table
			setSubState2SE(stNet);
			computeTransitionPaths();
			networkPrepared = true;
		}
	
		/**
		Set the _se property of all states to the controlling state engine.  This is necessary because state engine
		keeps track of the active states.
		
		@method setSubState2SE
		@param	stPtr 	State being currently registered.
		@private
		*/
		internal function setSubState2SE (stPtr:State) : void {
		
			// If this step has been done already, skip it!
			if (stPtr._se != null) {
				return;
			} else {
				stPtr.registerSubStates(this);
			}
		}
		
		/**
		 * When developers specify transitions, the engine does not compute the path to the transition. The engine
		 * knows that when it gets activated, all the states should be present.  Therefore, at that time, it can
		 * compute and store the path from the source to the target.  This means that there is a brief delay when
		 * the engine is activated -- to run through and resolve all transitions.  If a developer wants to speed things
		 * up, he can call this routine before activation, thereby removing the need to compute the paths at activation.
		 * @method computeTransitionPaths
		 */
		private function computeTransitionPaths () : void {
			var sp:State, ta:Array, tpi:int;
			
			// Go through all the states, looking for transitions.  When we find them, compute the transition paths.
			for (var s:String in statesByID) {
				sp = statesByID[s];
				if (sp.transitions != null) {
					for (var tid:String in sp.transitions) {
						ta = sp.transitions[tid];
						for (tpi = 0; tpi < ta.length; tpi++) {
							Transition(ta[tpi]).determineTransition();
						}
					}
				}
			}
		}
	
		/**
		Deactivate the state engine.
		<p>Typically you will use the <code>active</code> property to deactivate <code>active = false;</code> your state engine.</p>
		@method deactivate
		@access public
		*/
		public function deactivate () : void {
			stNet.leave();
			
			// Setup the outermost manager to deactive.
			stNet.myStMgr.cs 	 = null;
			stNet.myStMgr.active = false;
			
			// Clear the event timer, if active
			eventTimerDelay.stop();
			
			// 
			if (this.hasEventListener(StateEngine.DEACTIVATE)) {
				dispatchEvent(new EventWithData(StateEngine.DEACTIVATE));
			}
			_active = false;
		}
		
		/**
		 * Main routine for injecting an event into the state network.
		 * <p>The state engine sits in the current state(s) and basically waits until some event comes in.  This method
		 * is how you inject an event into the network.  When you pass in an event, this routine sends the event to
		 * the active state(s) in the network.  If that/those state(s) don't handle it, the event bubbles up to the
		 * parent to take a shot at handling the event, and so on, up to the topmost state. If no state handles the event,
		 * the state engine generates a special event, <code>StateEngine.UNHANDLED_EVENT</code>, which you can subscribe to.  In
		 * that way, the caller can tell if any state handled the event or not.</p>
		 * <p>Events are Priority FIFO-queued.  The engine guarantees run-to-completion by verifying no event is currently being handled
		 * when the engine injects the event.  If a new event comes in while one is already being handled, the event gets queued.</p>
		 * <p>Callers may indicate to postpone an event for a set amount of time (in milliseconds).  This might be useful, for example, if you need to space
		 * out the time a bit due to Flash needing a moment to get to the next frame.</p>
		 * <p>Events can be assigned priorities, so that higher-priority (lower number) events can jump in line in front of lower-priority
		 * events.  However, because run-to-completion must be observed, there is no way to interrupt an event being handled currently
		 * even with a higher-priority event.</p>
		@method postEvent
		@param ev Event object (pointer)
		@param timeDelay Amount of time (in milliseconds) to wait after finishing handling the prior event, and when this event gets processed.  Default value is 0 (immediately).
		@param pty Integer indicating the priority of the event.  By default, all events are given a priority of 1000.
		@acccess public
		*/
		public function postEvent (ev:Event, timeDelay:Number = 0, pty:int = 1000) : void {
			var i:int = 0;
			var newEvent:Object = { event: ev, priority: pty, delay: timeDelay };
			
			// Add new event in order of its priority.
			for (i = 0; i < eventsWaiting.length; i++) {
				if (eventsWaiting[i].priority > pty) {
					eventsWaiting.splice(i, 0, newEvent);
					trace(">>>>>>>>>>>>>>>>>>>>>> FOUND CUTTER");
					break;
				}
			}
			if (i == eventsWaiting.length) {
				eventsWaiting.push(newEvent);
			}
			
			if (!handlingEvent) {
				handlingEvent = true;
				processEvents();
			}
		}
		
		/**
		This is the main event handler for the state engine.  It used to be called "ieh".
		In version 1 of FStEng, developers were supposed to override this method with their
		own event handler that found the active state(s) and executed actions, transitions, and
		activities.  In version 1.5, however, the event handling was modified to alleviate
		this meticulous burden from the developer, at the expense of some small time expense.
		In version 1.5, the default ieh() method sends the event to the active
		state(s) onEvent method.  The state, by default, runs through its transition
		and internal action triggers.  If any are true, then it fires those actions.  See the
		description of onEvent in the state documentation.
		The developer does not override the ieh() method, unless the developer
		needs to optimize the event handling at a global level.
		
		@method processEvent
		@private
		*/
		private function processEvents () : void {
			
			while (eventsWaiting.length > 0) {
				if (eventsWaiting[0].delay != 0) {
					// if this event should be fired after some delay, setup the timer to come back to processEvents.
					eventTimerDelay.delay 		= eventsWaiting[0].delay;
					eventTimerDelay.repeatCount = 1;
					
					// when the timer returns to this routine, the delay will be zero and the event will be fired.
					eventsWaiting[0].delay = 0;
					// start the delay
					eventTimerDelay.start();
					break;
					
				} else {
					// Handle the first event from the queue
					var ev:Event 			= eventsWaiting[0].event;
					var astates:Dictionary	= new Dictionary(true);
					var handled:Boolean 	= false;
				
					for (var sp:* in this.activeStates) {
						astates[sp] = activeStates[sp];
					}
					eventsWaiting.splice(0, 1);
					
					// clear our storage space for knowing when to pass up events to concurrent states
					_concEvCt = new Dictionary();
				
					// dispatch the event to the current active state(s).  We copy the activeStates before
					// dispatching the event because it is possible that during processing, a transition
					// is triggered and the real activeStates gets updated, then we would send the same event
					// erroneously to the new active state.
					for (var activeSt:* in astates) {
						handled = State(activeSt).onEvent(ev, false) || handled;
					}
					
					if (!handled) {
						// Pass along the unhandled event in the event property of data
						unhandledEvent.data.event = ev;
						dispatchEvent(unhandledEvent);
					}
					
					_concEvCt = null;
				}
			}
			
			// Clearing the handlingEvent flag, so future event postings invoke processEvent.  We clear the
			// flag here rather than in postEvent because an event could have been postponed and when the handling resumes, we get called.
			if (eventsWaiting.length == 0) {
				handlingEvent = false;
			}
		}
		
		/**
		 * Called when the event delay timer has elapsed, telling us it is time to resume event processing.
		 * @method timeDelayElapsed
		 * @private
		 */
		private function timeDelayElapsed (ev:Event) : void {
			processEvents();
		}
	}
}
	