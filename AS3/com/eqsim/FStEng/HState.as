/*
	************************************************
	
	EXAMPLE: Hierarchical State Machine Engine
	AUTHOR: Jonathan Kaye
	RELEASE: 	August, 2009
	Implementation originally conceived and developed DECEMBER 2001
	
	FILE: HState.as (hierarchical state class)
	
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
	   A hierarchical state with a single sub-network.
	   Hierarchical states can either have a single sub-network (collection of sub-states)--HState, or multiple networks of sub-states (HStateC).
	   The HState is really a specialization of an HStateC that only has one sub-network.  Therefore, all the real code is going on in
	   HStateC.
	   
	   @class   HState
	   @author  Jonathan Kaye (FlashSim.com)
	*/
	
	public class HState extends HStateC {
		
		// 
		private var defaultStateMgr:StateManager;
		
		/**
		 * Create a new hierarchical state with a single sub-network.
		 * <p>You must assign the HState a unique identifier with respect to its sibling states, i.e., the states in the same network as this HState.
		 * Identifiers for states are, by convention, numeric, though the implementation uses Strings for identifiers (since numeric comparison is
		 * never required).</p>
		 * <p>When you create an HState, you must also create a state manager (StateManager).  When you create a StateManager, you
		 * specify the hierarchical state which it manages.</p>
		 * 
		 * @param identifier 	State identifier (id).  Must be unique among all states in the state engine.
		 * @param msm			Pointer to the StateManager in the network that this HStateC belongs.  Pass in the parent
		 * state, not the StateManager that will control this state's sub-network.
		 * @param nm 			Display name of the State.  If null (not supplied), routines use the id for the display name.
		 */
		public function HState (identifier:*, msm:StateManager = null, nm:String = null) {
			super(identifier, msm, nm);
		}
		
		/**
		 * @private
		 */
		override public function addStateManager (sm:StateManager) : void {
			if (numStMgrs == 1) {
				throw new Error("Trying to add more than one StateManager to HState " + name + " (by definition, HState's only can have one)");
			}
			super.addStateManager(sm);
		}
		
		/**
		 * Allows the developer to specify the default start state.
		 * <p>The default start state is specified in the State Manager, but for HState's, there is
		 * only one manager, so we can go ahead (if the manager is set) to adjust the default start
		 * state.</p>
		 * @method setDefaultStartState
		 * @param id	String identifier for the state
		 * @param mgr	Optional parameter specifying the manager for the HState's sub-network (who is the manager for the state you're making default start).  This is declared for consistency with HStateC, though it always will be null for HState's (since we can determine it automatically)
		 */
		override public function setDefaultStartState(sid:String, mgr:StateManager = null) : void {
			var i:String, myMgr:StateManager = null;
			
			if (numStMgrs == 0) {
				if (mgr == null) {
					myMgr = new StateManager("<" + id + " MANAGER>", this);
 
				} else if (stMgrs[mgr.id] != mgr) {
					throw new Error("You supplied the wrong manager to manage <state " + name + ">.  That state's manager is " + myMgr.name);
				}
			} else {
				// We need to retrieve the State Manager for this HState.  Since HState's only have
				// 1 state manager (but HStateC's, our parent class, have multiple), we loop through
				// our list of managers to retrieve the manager instance.
				for (i in stMgrs) {
					myMgr = stMgrs[i];
				}
			}
			
			// We go ahead and set the default start state without checking to see if the state belongs to this manager,
			// since it is possible the developer has not yet created that state.  If, in the end there is no state, it
			// will be caught at run-time when the manager tries to activate it.
			myMgr.defSt = sid;
		}
	}
}