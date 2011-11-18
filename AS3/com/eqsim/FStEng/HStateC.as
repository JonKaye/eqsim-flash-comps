/*
	************************************************
	
	EXAMPLE: Hierarchical State Machine Engine
	AUTHOR: Jonathan Kaye
	RELEASE: 	August, 2009
	Implementation originally conceived and developed DECEMBER 2001
		
	FILE: HStateC.as (hierarchical state class w/concurrency)
	
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
	
	/**
	  * A hierarchical state with concurrency.
	  * <p>A hierarchical state with concurrency is a state that has multiple sub-networks of states, each operating in parallel.
	  * Each sub-network has a State Manager to keep track of the current and last states for that sub-network.  Most of the time,
	  * engines will use HState's, which are hierarchical states with a single sub-network of states.  From an implementation point
	  * of view, however, HState's are specializations of HStateC's, namely a hierarchical state with concurrency but only a single
	  * sub-network (so no real concurrency, then).</p>
	  * @class HStateC
	  * @author  Jonathan Kaye (FlashSim.com)
	  * @see StateEngine StateEngine definition examples.
	*/
	
	public class HStateC extends State {
		
		/**
		 * Number of state managers (i.e., sub-networks) within this state.
		 */
		public var numStMgrs:uint;
		/**
		 * An object that holds a hash table (indexed by State Manager id's) to the State Managers for this state.
		 */
		public var stMgrs:Object;
		/**
		 * Collection of children states.
		 * An object that holds a hash table (indexed by state id's) to the children of this state.  Grandchildren (if there are
		 * any) are stored in the children's states, not here.
		 */
		public var substates:Object;
		
		/**
		 * Create a new hierarchical state with more than one sub-network.
		 * <p>The State Manager distinguishes states it controls via unique state identifiers (for that network). The identifer
		 * must be unique among all states in the State Engine.</p>
		 * <p>When you create an HStateC or an HState, you must also create state managers (StateManager).  When you create a StateManager, you
		 * specify the hierarchical state which it manages.  Therefore, for HStateC's, you will create several StateManager's and hook them up
		 * to the same (container) state.  For HState's, you will only need to create one (1) StateManager.</p>
		 * 
		 * @param identifier 	State identifier (id).  Must be unique among all states in the state engine.
		 * @param	msm			Pointer to the StateManager in the network that this HStateC belongs.  Pass in the parent
		 * state, not the StateManager that will control this state's sub-network.
		 * @param nm 			Display name of the State.  If null (not supplied), routines use the id for the display name.
		 */
		public function HStateC (identifier:*, msm:StateManager = null, nm:String = null) {
			super(identifier, msm, nm);
			
			stMgrs 		= { };
			numStMgrs 	= 0;
			substates 	= { };
		}
		
		/**
		 * Adds a sub-state to this state.  This is not for developers.  Developers add
		 * state managers (addStMgr) and then connect sub-states using those managers.
		 * 
		 * @method addAsSubState
		 * @param st
		 * @private
		 */
		internal function addAsSubState(st:State) : void {
			var id:String = st.id;
			
			// check for duplicate ID
			if (substates[id] != undefined) {
				if (this is HState) {
					throw new Error("Trying to add a sub-state of '" + this.name + "' with the same id (" + id + ").");
				} else {
					throw new Error("Trying to add a sub-state of '" + this.name + "' with the same id (" + id + ").  Remember that all siblings in HStateC (from any manager) must have a unique id.");
				}
			}
			
			// Check that we have the state's state manager within this state
			if (stMgrs[st.myStMgr.id] != st.myStMgr) {
				throw new Error("State " + st.name + "'s StateManager not found in container state " + name + "'s State Manager list.");
			}
			
			substates[id] = st;
		}
		
		/**
		 * Deletes memory associated with this state.
		 * @method removeState
		 */
		public override function removeState () : void {
			super.removeState();
			for each (var s:State in substates) {
				s.removeState();
			}
			substates = null;
		}
		
		/**
		 * isSubstate allows the caller to ask if a state is a substate of the state being called. It returns true if it
		 * is a substate, false if it is not.
		 * @method isSubstate
		 * @param	st
		 */
		public override function isSubstate (st:State) : Boolean {
			return (substates[st.id] != undefined);
		}
		
		/**
		 * Allows the developer to specify the default start state for a given sub-network.
		 * <p>The default start state is specified in the State Manager.  This routine lets the developer
		 * specify the start state for this manager.  The same can be done in the StateManager constructor,
		 * but this may be a more convenient way to do it.</p>
		 * <p>Ordinarily, we could retrieve the manager from the state id alone, but the developer may not have created the state yet.</p>
		 * @method setDefaultStartState
		 * @param id	String identifier for the state
		 * @param mgr	Parameter specifying the manager of the sub-state.  It is declared as optional so that HState (a child class) does not have to require the manager.  For HStateC's, you need to specify which manager is managing the state to make default start.
		 */
		public function setDefaultStartState(id:String, mgr:StateManager = null) : void {
			var i:String;
			
			if (mgr == null) {
				throw new Error("For " + name + " (an HStateC), you must supply the manager of state " + id + "."); 
			} else if (stMgrs[mgr.id] != mgr) {
				throw new Error("The manager you supplied, " + mgr + ", is not a manager of state " + name);
			}
			
			mgr.defSt = id;
		}
		
		/**
		 * Adds the specified state manager (StateManager) to this state.
		 * <p>The State Manager keeps track of the active state within a sub-network.  Once you have created a new instance of
		 * a StateManager, you pass that instance pointer into this routine.
		 * State manager id's must be unique among sibling managers.  By convention, state manager id's are alphabetic, though
		 * in this implementation, we make identifiers as Strings.</p>
		 * @method addStateManager
		 * @paramsm	State manager pointer that will control this HStateC's network of states.
		 */
		public function addStateManager (sm:StateManager) : void {
			var id:String = sm.id;
			
			if (stMgrs[id] == undefined) {
				stMgrs[id] = sm;
			} else {
				// defined already -- issue warning
				throw new Error("Add State Manager Error: duplicate ID ("+id+") for state '"+name+"'");
			}
			
			this.numStMgrs++;
		}
		
		/**
		 * Goes through substates to register them with the state engine.
		 * @method registerSubStates
		 * @private
		 */
		override internal function registerSubStates (stateEng:StateEngine) : void {
			super.registerSubStates(stateEng);
			
			// Go through all the substatates and register them.  We don't care which sub-network they belong to,
			// as the purpose is just to get a state engine pointer and a unique state id off each state.
			for each (var ss:State in substates) {
				ss.registerSubStates(stateEng);
				
			}
		}
		
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
		@private
		*/
		override internal function enter(hist:Boolean = false, specIDs:Array = null):void {
			var curMgrID:String, jsm:StateManager, sm:StateManager;
			
			// Fire off entry actions and Start any state activities
			super.enter();
			
			// If this is a special jump, record which state manager not to activate with default start state
			if (specIDs != null) {
				jsm = (this.substates[specIDs[0]]).myStMgr;
			}
			
			// Activate all the state managers, except for the special one dictated by the jump (if specIDs is non-null).
			// Arbitrarily, we activate all the state managers
			// (and consequently their lower level states) before we activate the state manager
			// along the branch that contains the special ids (state path).
			for (curMgrID in stMgrs) {
				sm = stMgrs[curMgrID];
				if (sm == null) {
					throw new Error("ERROR: State Manager id = " + curMgrID + " of state " + name + " is null.  Did you delete the manager somewhere?");
				}
				
				if (specIDs == null) {
					sm.activate(hist, null);
					
				} else if (jsm != sm) {
					// history only applies to the last state on the path we're taking on specIDs, so
					// if we're activating a state manager not on this path, don't pass along the history flag.
					// We don't pass along specIDs because this manager does not manage that state (that state is managed by the manager in jsm).
					sm.activate(false, null);
				}
			}
			
			// If there are any other managers, and the caller has given a specific list of states to activate (contravening the default start usage),
			// now we activate that network with the state on the head of the list
			if (specIDs != null) {
				jsm.activate(hist, specIDs);
			}
		}
		
		/**
		 * @private
		 */
		override internal function leave():void {
			for each (var mgr:StateManager in stMgrs) {
				mgr.deactivate();
			}
			super.leave();
		}
		
		/**
		 * @private
		 */
		override internal function resetHistory () : void {
			// tell managers to reset history
			for each (var mgr:StateManager in stMgrs) {
				mgr.resetHistory();
			}
		}
		
		/**
		 * Given an identifier, create a new sub-state that is a simple state (State).
		 * <p>If a manager has already been declared, use it.  Otherwise, create a new manager.  If we create a new manager,
		 * the developer must use <code>setDefaultStartState</code> to initialize the default start state.</p>
		 * @param sid	state identifier for the sub-state
		 * @param mgr	Manager for the sub-state's network.  We set it as optional so HState users don't need to provide it, but for sub-networks of HStateC's, it is required.
		 * @param name	Optional display name for the state.  If not provided, we use the state id.
		 */
		public function addSubState(sid:String, mgr:StateManager = null, name:String = null) : State {
			return new State(sid, verifyManagerForStateCreation(sid, mgr), name);
		}
		
		/**
		 * Given an identifier, create a new sub-state that is a hierarchical state (HState).
		 * <p>If a manager has already been declared, use it.  Otherwise, create a new manager.  If we create a new manager,
		 * the developer must use <code>setDefaultStartState</code> to initialize the default start state.</p>
		 * @param sid	state identifier for the sub-state
		 * @param mgr	Manager for the sub-state's network.  We set it as optional so HState users don't need to provide it, but for sub-networks of HStateC's, it is required.
		 * @param name	Optional display name for the state.  If not provided, we use the state id.
		 */
		public function addSubHState(sid:String, mgr:StateManager = null, name:String = null) : HState {
			return new HState(sid, verifyManagerForStateCreation(sid, mgr), name);
		}
		
		/**
		 * Given an identifier, create a new sub-state that is a concurrent, hierarchical state (HStateC).
		 * <p>If a manager has already been declared, use it.  Otherwise, create a new manager.  If we create a new manager,
		 * the developer must use <code>setDefaultStartState</code> to initialize the default start state.</p>
		 * @param sid	state identifier for the sub-state
		 * @param mgr	Manager for the sub-state's network.  We set it as optional so HState users don't need to provide it, but for sub-networks of HStateC's, it is required.
		 * @param name	Optional display name for the state.  If not provided, we use the state id.
		 * 
		 */
		public function addSubHStateC(sid:String, mgr:StateManager = null, name:String = null) : HStateC {
			return new HStateC(sid, verifyManagerForStateCreation(sid, mgr), name);
			
		}
		
		/**
		 * Routine checks to see if the proper manager is supplied.  If not, and the state is an HState, we create
		 * the manager.  Otherwise we go through checks to ensure caller is using the correct manager.
		 * @private
		 */
		private function verifyManagerForStateCreation (sid:String, mgr:StateManager) : StateManager {
			var i:String, sm:StateManager = null;
			
			// 'mgr' is required for HStateC's
			if (mgr == null) {
				if (!(this is HState)) {
					throw new Error("You must supply a manager to add state " + sid + " as a sub-state of state " + name + ".");
				} else {
					// This is an HState, so retrieve the state manager.
					for (i in stMgrs) {
						sm = stMgrs[i];
					}
					// if no manager has been created yet, sm == null
					if (sm == null) {
						// automatically create a manager for an HState sub-state
						sm = new StateManager("<" + id + " MANAGER>", this);
					}
				}
			} else {
				if (stMgrs[mgr.id] != mgr) {
					throw new Error("You are trying to add a sub-state to a manager " + mgr.name + " that is not a manager of this state " + name);
				} else {
					sm = mgr;
				}
			}
			
			return sm;
		}
	}
}