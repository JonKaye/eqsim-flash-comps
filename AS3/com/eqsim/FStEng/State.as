/*
	************************************************
	
	EXAMPLE: Hierarchical State Machine Engine
	AUTHOR: Jonathan Kaye
		
	FILE: State.as (simple state class)
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
	
	import flash.events.*;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.display.MovieClip;
	import com.eqsim.events.EventWithData;
	
	/**
	   A finite state, or a simple, non-hierarchical state.
	   <p>State's are atomic, unlike HState's or HStateC's.  HStateC is a subclass of State, and HState is a subclass of HStateC.
	   In technical terms, one could think about states by the number of state managers each has -- the State has none, an HState has
	   one, and an HStateC has more than one.  Therefore, while it would be possible to collapse the definition of state to a single
	   class, we define three separate classes because we feel it is easier to explain the theory of hierarchical states if there are three
	   state concepts, even if technically they all could be implemented in a single class.</p>
	   
	   @class  State
	   @author Jonathan Kaye (FlashSim.com)
	*/
	
	public class State extends EventDispatcher {
		
		/**
		 * Event generated on entry to a state.
		 * <p>Listeners will be notified when the state becomes active (is entered).</p>
		 * @eventType ENTRY
		 */
		public static const ENTRY:String = "ENTRY";
		/**
		 * Event generated when the state is no longer active.
		 * <p>Listeners will be notified when the state is no longer an active state.</p>
		 * @eventType LEAVE
		 */
		public static const LEAVE:String = "LEAVE";
		
		/**
		 * String identifier for the state.  Must be unique in the entire state network.
		 */
		public var id:String;
		
		/**
		 * An optional name for the State to give to the State Manager, used for display purposes only. If no
		 * name is set, we use id by default.
		 */
		public var name:String;
		
		/**
		 * An Object, keyed by target state id, that contains all the transitions for this State.
		 * <p>The value of transitions is itself an array of transitions, because it's possible to have multiple transitions
		 * with the same target state (though they must have different event types).</p>
		 */
		public var 		transitions:Object;
		
		/**
		 * An array containing the pulse activities (<code>PulseActivity</code>) for this state.
		 */
		public var 		pulseActivities:Array;
		
		/**
		 * Pointer to the State Engine instance.  This is set at the time the engine is first activate, or, if the
		 * developer does not want to delay at that point, the developer can call <code>prepareNetwork()</code> once.
		 */
		internal var 	_se:StateEngine;
		
		/**
		 * Pointer to this State's State Manager instance.
		 */
		internal var 	myStMgr:StateManager;			// I had these as 'protected', but Flex kept complaining when used in HStateC
		
		private var		transitionEvents:Object;	// List of Events that trigger transition for this state
		
		/**
		 * Boolean flag used to determine if the State has handled the current event.  It is reset to <code>false</code> when the State
		 * has a chance to handle a given event.  Developers will rarely (if ever) use this.
		 */
		internal var	handledEvYet:Boolean;
		
		private  var	entryEvent:EventWithData;		// We keep the same event objects for leave and entry to try to conserve memory.  We can't
		private  var	leaveEvent:EventWithData;			// use the same event object for both because 'type' is read-only.
		
		
		
		/**
		The constructor for the state class.  Pass in a name, an ID (typically numeric),
		and a pointer to the state network manager.  If this state is the topmost in the
		whole network, the manager is <code>null</code>.
		@method new State
		@param identifier 	State identifier (id).  Must be unique among all states in the state engine.
		@param msm 			Pointer to a state manager, or null if this state is topmost
		@param nm 			Display name of the State.  If null (not supplied), routines use the id for the display name.
		*/
		
		public function State (identifier:String, msm:StateManager = null, nm:String = null) {
			id = identifier;
			if (nm == null) {
				name = id;
			} else {
				name = nm;
			}
			myStMgr = msm;
			
			if (msm != null && msm.contSt is HStateC) {
				msm.contSt.addAsSubState(this);
			}
			
			transitions = pulseActivities = null;
			
			entryEvent = new EventWithData(State.ENTRY, false, false, { stateName: "", stateID : "0" } );
			leaveEvent = new EventWithData(State.LEAVE, false, false, { stateName: "", stateID : "0" } );
			
			transitionEvents = new Object();
		}
		
		
		/**
		 * Deletes memory associated with this state.
		 * @method removeState
		 */
		public function removeState () : void {

			if (transitions != null) {
				for (var targetID:String in transitions) {
					delete transitions[targetID];
				}
				transitions = null;
			}
		
			if (pulseActivities != null) {
				for (var i:uint = 0; i < pulseActivities.length; i++) {
					removePulseActivity(pulseActivities[i]);
					delete pulseActivities[i];
				}
				pulseActivities = null;
			}
			
			entryEvent = null;
			leaveEvent = null;
			
			if (transitionEvents != null) {
				for (var evtType:String in transitionEvents) {
					delete transitionEvents[evtType];
				}
				transitionEvents = null;
			}
		}
		
		/**
		Called when the state is entered.  This is a private routine and should not be
		overriden by developers.
		@method enter
		@access private
		*/
		/**
		Called when a state is entered.  This routine is for internal use, not for developers
		to override for executing actions on entry.  'hist' is true to use state history, false to use
		default start state.
		When we're told to jump into a specific sub-state, we don't want to allow the default start state or
		the history to get invoked.  'specIDs' tells us which sub-state, if not == null, we're jumping into.
		Therefore, for the state manager of that sub-state, we call activate() with this special 
		sub-state id.
		@method enter
		@param hist
		@param specIDs
		@access private
		*/
		internal function enter(hist:Boolean = false, specIDs:Array = null):void {

			// only put leaf states (State, not HStateC nor HState) into the master list of active states
			if (!(this is HStateC)) {
				_se.activeStates[this] = true;
			}
			if (this.hasEventListener(State.ENTRY)) {
				entryEvent.data.stateName 	= name;
				entryEvent.data.stateID 	= id;
				dispatchEvent(entryEvent);
			}
			startStateActivities();
		}
		
		/**
		This event is generated upon entering a specified state if the developer has registered
		a state on-entry notice using <code>addEventListener()</code>.
		@event State.ENTRY
		*/
		
		/**
		This event is generated upon leaving a specified state if the developer has registered
		a state on-leave notice using <code>addEventListener()</code>.
		@event State.LEAVE
		*/
		
		/**
		Start any pulse state activities for this state.
		@method startStateActivities
		@access private
		*/
		private function startStateActivities () : void {
			// Start any pulse activities for this state
			if (pulseActivities != null) {
				for (var i:int = 0; i < pulseActivities.length; i++) {
					pulseActivities[i].start();
				}
			}
		}
		
		/**
		Called when the state is exited (deactivated).  This is a private routine and should not be
		overriden by developers.
		@method leave
		@access private
		*/
		internal function leave () : void {
			
			delete _se.activeStates[this];
			
			stopStateActivities();
			
			if (hasEventListener(State.LEAVE)) {
				leaveEvent.data.stateName 	= name;
				leaveEvent.data.stateID 	= id;
				dispatchEvent(leaveEvent);
			}
		}
		
		/**
		Stops any pulse state activities for this state.
		@method stopStateActivities
		@access private
		*/
		private function stopStateActivities () : void {
			// turn off mode pulse activities
			if (pulseActivities != null) {
				for (var i:int = 0; i < pulseActivities.length; i++) {
					pulseActivities[i].stop();
				}
			}
		}
		
		/**
		<p>Change state using transition trans, with an optional value for the
		transition function as a second argument.</p>
		<p>The typical way to invoke transitions is by defining an event trigger for the transition,
		then posting that event into the state engine. However, if you want to manage your state network
		more manually, you might want a mechanism for invoking a transition directly.
		</p>
		<p>For example, if a caller wants to change the current state,
		state 2 (stored in an example variable, <code>state2</code>), using transition <code>trans1</code>, the caller would write:</p>
		<code>state2.chgSt(trans1);</code>
		<p>The transition <code>trans1</code> is a Transition the caller created with <code>state2.addTransition...</code> method.</p>
		<p>If you do not want to make separate variables for each transition, you can use the
		<code>transitions</code> property of a State to retrieve transitions based on their target state ID. So the call
		above could have been: <code>state2.chgSt(state2.transitions["trans target id"][0])</code> (where the
		trans_target_id is the transition's target state ID). The reason for the [0] is that there may be more
		than one transition going to the same target state, but in this case, we assume there is only one.
		<p>The second argument, val, is an optional value to send in to the transition function.</p>
		@method chgSt
		@param trans
		@param val
		*/
		public function chgSt(trans:Transition, val:* = null) : void {
			if (trans.source.id != myStMgr.cs) {
				throw new Error("Called to change state from " + trans.source.id + " but it is not active in this network currently.");
			} else {
				this.myStMgr.chgSt(trans, val);
			}
		}
		
		/**
		convenience function.  Returns true if this state is currently active,
		false if not.
		@method isActive
		@return True if the state is active, false if not.
		*/
		public function isActive() : Boolean {
			return (this.myStMgr.cs == this.id);
		}
		
		/**
		 * Add a transition from this State to a target state other than history.
		 * <p>Use this method to define a transition from one State to another.  If the target state is the same as the source, this method
		 * exits the source and re-enters it.  If the developer wants to exit parent states, use <code>addTransitionToSelf</code> which allows
		 * the developer to specify exactly how many levels to exit and re-enter.</p>
		 * <p>To transition to the history pseudo-state, use <code>addTransitionToHistory</code>.</p>
		 * <p>If the developer wants
		 * to manually code the event handler, then the developer uses <code>chgSt()</code> to fire
		 * this transition when it is triggered (just remember to hold onto the transition instance, which is the return value of this method).</p>
		 * <p>By default, when the developer creates a transition with this method, the actual determination of transition path (through which nodes,
		 * up/down how many levels, etc.) is postponed until the first activation of the State Engine.  This avoids the problem of defining a transition
		 * to a state that does not exist yet, for example, when two states have reciprocal transitions.  However, if the developer has activated the
		 * state engine already, or called the state engine's <code>prepareNetwork()</code>, he can add a transition and have its path resolved
		 * immediately by first calling <code>transPtr = addTransition()</code>, then, calling <code>transPtr.determineTransition()</code>.</p>
		 * 
		 * @method addTransitionToTarget
		 * @param tEvtName 			Name of the event that triggers the transition (if null, then transition must be manually triggered with [State].chgSt())
		 * @param targetStateID 	id of the target state
		 * @param transFn 			An optional function to execute when the transition is fired
		*/
		public function addTransitionToTarget (tEvtName:String, targetStateID:String, transFn:Function = null) : Transition {
			if (id == targetStateID) {
				return addTransitionToSelf(tEvtName, transFn, 0);
			} else {
				return addTransitionInstance(targetStateID, tEvtName, transFn, false);
			}
		}
		
		/**
		 * Add a transition from this State to itself, specifying parents to exit and re-enter.
		 * <p>Use this method to transition out of the current state, up any number of parent state levels, then re-enter the state.</p>
		 * <p>If the developer wants
		 * to manually code the event handler, then the developer uses <code>chgSt()</code> to fire
		 * this transition when it is triggered (just remember to hold onto the transition instance, which is the return value of this method).</p>
		 * <p>By default, when the developer creates a transition with this method, the actual determination of transition path (through which nodes,
		 * up/down how many levels, etc.) is postponed until the first activation of the State Engine.  This avoids the problem of defining a transition
		 * to a state that does not exist yet, for example, when two states have reciprocal transitions.  However, if the developer has activated the
		 * state engine already, or called the state engine's <code>prepareNetwork()</code>, he can add a transition and have its path resolved
		 * immediately by first calling <code>transPtr = addTransition()</code>, then, calling <code>transPtr.determineTransition()</code>.</p>
		 * 
		 * @method addTransitionToSelf
		 * @param tEvtName 			Name of the event that triggers the transition (if null, then transition must be manually triggered with [State].chgSt())
		 * @param transFn 			An optional function to execute when the transition is fired
		 * @param ulfst				(abbrev. "up levels for self transition") For a transition to self, this value says how many levels to go up before coming back down.  The developer uses this to determine how many states to exit and re-enter.
		*/
		public function addTransitionToSelf (tEvtName:String, transFn:Function = null, ulfst:int = 0) : Transition {
			return addTransitionInstance(id, tEvtName, transFn, false, ulfst);
		}
		
		/**
		 * Add an 'external' transition, i.e., from this State to a target state.
		 * <p>Use this method to transition out of the current state, up any number of parent state levels, then re-enter the path down towards the current state.  The
		 * difference between this method and <code>addTransitionToTarget()</code> is that the latter does not give the developer the ability to leave parent states of
		 * the target and return to the target, but this method does.  This method would be used in the following situation.  The source is a descendent of the target
		 * state.  The source wants to transition to the target state, leave the parent of the target state, and then re-enter the parent of the target state and finally
		 * go to the target state.  This would be accomplished by giving a final parameter value of 1 (up 1 level above the target).  If ulfxt == 0, this method is
		 * equivalent to <code>addTransitionToTarget()</code>.</p>
		 * <p>If the developer wants
		 * to manually code the event handler, then the developer uses <code>chgSt()</code> to fire
		 * this transition when it is triggered (just remember to hold onto the transition instance, which is the return value of this method).</p>
		 * <p>By default, when the developer creates a transition with this method, the actual determination of transition path (through which nodes,
		 * up/down how many levels, etc.) is postponed until the first activation of the State Engine.  This avoids the problem of defining a transition
		 * to a state that does not exist yet, for example, when two states have reciprocal transitions.  However, if the developer has activated the
		 * state engine already, or called the state engine's <code>prepareNetwork()</code>, he can add a transition and have its path resolved
		 * immediately by first calling <code>transPtr = addTransition()</code>, then, calling <code>transPtr.determineTransition()</code>.</p>
		 * 
		 * @method addTransitionExternal
		 * @param tEvtName 			Name of the event that triggers the transition (if null, then transition must be manually triggered with [State].chgSt())
		 * @param targetStateID 	id of the target state
		 * @param transFn 			An optional function to execute when the transition is fired
		 * @param ulfxt				(abbrev. "up levels for external transition") For an external transition, this value says how many levels to go up before re-entering that topmost state.  The developer uses this to determine how many states to exit and re-enter.
		*/
		public function addTransitionExternal (tEvtName:String, targetStateID:String, transFn:Function = null, ulfxt:uint = 1) : Transition {
			return addTransitionInstance(targetStateID, tEvtName, transFn, false, ulfxt);
		}
		
		/**
		 * Add a transition from the current state to the history pseudo-state of a state.
		 * <p>The history pseudo-state is an automatic element part of an HState or HStateC.  Conceptually, a transition to history makes the
		 * current state the last state visited in that state network.  Therefore, you specify the target state that <i>contains</i> the history
		 * state.  For example, if you have three states in the same network, A, B, and C, and A is current but C was the last state visited,
		 * you could add a transition from A -> history, and when that was triggered, the state engine would leave A and enter C.</p>
		 * <p>If the developer wants
		 * to manually code the event handler, then the developer uses <code>chgSt()</code> to fire
		 * this transition when it is triggered (just remember to hold onto the transition instance, which is the return value of this method).</p>
		 * <p>By default, when the developer creates a transition with this method, the actual determination of transition path (through which nodes,
		 * up/down how many levels, etc.) is postponed until the first activation of the State Engine.  This avoids the problem of defining a transition
		 * to a state that does not exist yet, for example, when two states have reciprocal transitions.  However, if the developer has activated the
		 * state engine already, or called the state engine's <code>prepareNetwork()</code>, he can add a transition and have its path resolved
		 * immediately by first calling <code>transPtr = addTransition()</code>, then, calling <code>transPtr.determineTransition()</code>.</p>
		 * 
		 * @method addTransitionToHistory
		 * @param tEvtName 			Name of the event that triggers the transition (if null, then transition must be manually triggered with [State].chgSt())
		 * @param targetStateID 	id of the target state
		 * @param transFn 			An optional function to execute when the transition is fired
		 */
		public function addTransitionToHistory (tEvtName:String, targetStateID:String, transFn:Function = null) : Transition {
			return addTransitionInstance(targetStateID, tEvtName, transFn, true);
		}
		
		/**
		 * Internal routine that captures transition.
		 * We added convenience methods so it makes it easier for developers to specify the transition type, rather than filling in optional parameters.
		 * 
		 * having to fill in optional parameters.
		 * @param	targetStateID	id of the target state
		 * @param	tEvtName		Name of the event that triggers the transition (if null, then transition must be manually triggered with [State].chgSt())
		 * @param	transFn			An optional function to execute when the transition is fired
		 * @param	doHistory		Whether or not to go to the history state
		 * @param	ulfst			For external transitions, how many states to go up and then re-enter downward
		 * @return
		 */
		private function addTransitionInstance(targetStateID:String, tEvtName:String = null, transFn:Function = null, doHistory:Boolean = false, ulfst:uint = 0) : Transition {
			var trans:Transition, i:int;
			
			if (this.transitions == null) {
				this.transitions = new Object();
			}
			
			if (tEvtName != null) {
				if (tEvtName == State.ENTRY || tEvtName == State.LEAVE) {
					throw new Error("You cannot register a transition to a StateEvent " + tEvtName);
				} else if (hasEventListener(tEvtName)) {
					throw new Error("Trying to add a transition triggered by an event (" + tEvtName + ") that is already registered to an internal action.");
				}
			}
			
			trans = new Transition(this, targetStateID, transFn, doHistory, ulfst);
			if (transitions[targetStateID] == null) {
				transitions[targetStateID] = new Array(trans);
			} else {
				for (i = 0; i < transitions[targetStateID].length; i++) {
					if (Transition(transitions[targetStateID][i]).targetID == targetStateID && transitionEvents[tEvtName] != null) {
						// duplicate transition
						throw new Error("Duplicate transition on same event name (" + tEvtName + ") from " + name + " to " + targetStateID);
					}
				}
				transitions[targetStateID].push(trans);
			}
			
			transitionEvents[tEvtName]  = trans;
			
			return trans;
		}

		
		/**
		 * Remove the given transition from this State.
		 * <p>Unhook the given transition from the source state.</p>
		 * @method removeTransition
		 * @param trans	Transition instance to remove from source state.
		 */
		public function removeTransition(trans:Transition) : void {
			var ti:int, tei:int, foundTrans:Boolean=false, foundEvent:Boolean=false;
			
			for (ti = 0; ti < transitions[trans.targetID].length; ti++) {
				if (Transition(transitions[trans.targetID][ti]) == trans) {
					transitions[trans.targetID].splice(ti, 1);
					for (var tn:String in transitionEvents) {
						if (Transition(transitionEvents[tn]) == trans) {
							delete transitionEvents[tn];
							foundEvent = true;
							break;
						}
					}
					// shouldn't we also check
					foundTrans = true;
					break;
				}
			}
			
			if (!foundTrans) {
				throw new Error("Trying to remove a transition (from " + trans.source.name + " to " + trans.targetID + " that was not found on " + name + ")");
			}
			if (!foundEvent) {
				throw new Error("Engine logic error in transition -- did not find transition in transitionEvents (from " + trans.source.name + " to " + trans.targetID + " on " + name + ")");
			}
		}
			
		
		
		/**
		Use this method to add an activity to the state that fires at a specified interval.  You
		can specify a function or method to call. Note: if you need to refer to the timeline
		from within a function, use the last example to call your function.
		
		@method addPulseActivity
		@param intvl Interval, in milliseconds, between calls
		@param fnOrMet Function or method to invoke
		@example
		// For a function: myFunc
		myState.addPulseActivity(0, 500, myFunc);
		// For a method: myObj.myMethod
		myState.addPulseActivity(0, 500, myObj.myMethod); 
	
		*/
		public function addPulseActivity (intvl:uint, cb:Function, fb:Boolean = false) : PulseActivity {
			var pa:PulseActivity;
			
			if (pulseActivities == null) {
				pulseActivities = new Array();
			}
			
			// Check to see we're not adding a duplicate activity (same callback)
			for (var i:uint = 0; i < pulseActivities.length; i++) {
				if (pulseActivities[i].handler == cb) {
					throw new Error("Pulse Activity with that callback already exists for this state <" + name + ">");
				}
			}
			
			pa = new PulseActivity(intvl, this, cb, fb);
			pulseActivities.push(pa);
			pa.addEventListener(PulseActivity.TICK, cb, false, 0, true);
			
			return pa;
		}
	
		
		/**
		Removes the specified pulse activity from the state.
		@method removePulseActivity
		@param id ID of the activity
		*/
		public function removePulseActivity (pa:PulseActivity) : void {
			var found:Boolean = false;
			
			if (pulseActivities == null) {
				throw new Error("No pulse activity on " + name + " with given Function.");
			}
			for (var i:int = 0; i < pulseActivities.length; i++) {
				if (pulseActivities[i] == pa) {
					pulseActivities[i].prepareToRemove();
					pulseActivities.splice(i, 1);
					found = true;
					break;
				}
			}
			
			if (!found) {
				throw new Error("The given pulse activity was not found on state " + name);
			}
		}
	
		
		/**
		<p>This is a new feature of FStEng v1.5, which provides an easy way to direct and process
		events.  Rather than having the developer provide an <code>ieh()</code> method, which
		determines the current state and which transitions or actions should be triggered, the
		new mechanism automatically routes the event to the most specific (deepest in network) active state's
		<code>onEvent</code> handler.  The handler, by default, looks through the triggers of
		the transitions and internal actions on the state.  If a trigger is true, it then fires
		the transition or action.  The default routine passes the event to the state's parent
		to check its transitions and actions as well.  If a transition gets fired, then parent
		states do not evaluate their transitions, but still evaluate their internal action
		triggers.</p>
		<p>This extra processing can add time because all triggers are checked in the chain of
		active states, regardless of their chance of success.  The beauty of this system is that
		if a state wants to optimize event handling for itself
		and its sub-networks, it merely needs to override <code>onEvent</code> and follow the
		rules about passing up the event once finished.  If you really need to optimize the
		event handling, you can still override <code>ieh()</code> and bypass this feature
		completely, and do it as described in our book.</p>
		@event onEvent
		*/
		public function onEvent(ev:Event, handledYet:Boolean) : Boolean {
			var contaningState:HStateC, tt:Transition, tei:int;
			
			// trace("onEvent(" + ev.type + ") for " + this.name + " (handledYet: " + handledYet + ") from " + (ev.target is State ? "state <" + State(ev.target).name + ">" : ev.target));
			
			// Check internal actions
			// See if there are any listeners to handle this event
			if (hasEventListener(ev.type)) {
				dispatchEvent(ev);
				handledYet = true;
			}
			
			// Check transitions
			if (!handledYet) {
				// figure out of there's a transition to trigger
				if (transitionEvents[ev.type] != null) {
					tt = transitionEvents[ev.type];		// value is the transition
					
					// v1.5
					// Take transition, if supposed to handle it.  This mechanism makes highest
					// (outermost) transition take precedence over sub-state transitions.  It also
					// makes sure that all internal actions are executed in higher-level states
					// before possibly leaving the state.
					if (ev is EventWithData) {
						this.chgSt(tt, EventWithData(ev).data);
					} else {
						this.chgSt(tt, null);
					}
					
					// indicate that transition was handled here
					handledYet = true;
					
				} else {
					// For HStateC's, we only want to pass the event up once all the sub-networks
					// have had a chance to handle the event.  Therefore, we keep track of how many
					// sub-networks have handled the event so far (using the _concEvCt object in the state engine)
					// which has a count of those sub-networks that has handled event to this point.
					// When that count reaches the # of state managers, we know it's the last one
					// and so we pass it up.
					//
					// Logically, since HState's are HStateC's, we don't need the if..else statement (the code would work
					// without the conditional, just using the code in the else block),
					// but if we are dealing with an HState, we can save a tiny bit of space and time by
					// not setting _concEvCt unnecessarily (since there is only one state manager for an HState).
					contaningState = myStMgr.contSt;
					
					if (contaningState is HState) {
						handledYet = contaningState.onEvent(ev, false);
						
					} else if (contaningState is HStateC) {
						if (this._se._concEvCt[contaningState] == undefined) {
							this._se._concEvCt[contaningState] = 1;
							contaningState.handledEvYet = handledYet;
						} else {
							this._se._concEvCt[contaningState]++;
						}
						contaningState.handledEvYet = contaningState.handledEvYet || handledYet;
						
						if (this._se._concEvCt[contaningState] == HStateC(contaningState).numStMgrs) {
							handledYet = contaningState.onEvent(ev, contaningState.handledEvYet);
						}
					}
				}
			}
			
			return handledYet;
		}
		
		
		internal function resetHistory () : void {
			// History is stored in the manager, and a simple state does not have an internal manager, so we do nothing.
		}
		
		/**
		Goes through substates to register them with the state engine.
		@method registerSubStates
		@access private
		*/
		internal function registerSubStates (stateEng:StateEngine) : void {
			_se = stateEng;
			
			if (stateEng.statesByID[id] != undefined) {
				throw new Error("State ID's must be unique.  State " + State(stateEng.statesByID[id]).name + " and " + name + " cannot share id = " + id);
			} else {
				stateEng.statesByID[id] = this;
			}
		}
		
		/**
		 * isSubstate allows the caller to ask if a state is a substate of the state being called. It returns true if it
		 * is a substate, false if it is not.  For simple states, it always returns false since there are no substates.
		 * @method isSubstate
		 * @param	st
		 */
		public function isSubstate (st:State) : Boolean {
			return false;
		}
	}
}