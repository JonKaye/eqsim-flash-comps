/*
	************************************************
	
	EXAMPLE: Hierarchical State Machine Engine
	AUTHOR: Jonathan Kaye
	RELEASE: 	August, 2009
	Implementation originally conceived and developed DECEMBER 2001
		
	FILE: Transition.as (generic transition class)
	
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
	 * Creates transitions from source to self, target states, and to history pseudo-states.
	 * <p>This class is used to create transitions.
	 * In previous versions of the state engine, we required the developer to specify the relation of the source and target (siblings, ancestors, etc.), but we have removed
	 * that restriction in version 3.  The processing is hidden from the developer so that making
	 * and using transitions is as easy as possible.</p><p>Essentially, when one creates a Transition, one only has to supply
	 * the target state ID, and the code figures out the path required to accomplish the transition.</p>
	 * <p>The code figures out the path from the source to the target, by default, at the moment before the state engine
	 * is activated.  This operation, therefore, can delay the activation of the engine proportional to the number and complexity
	 * of the state transitions.  To eliminate this delay, the developer can invoke <code>myStateEnginePtr.prepareNetwork()</code> at
	 * any time that all the states and transitions have been defined.  Then, when <code>myStateEnginePtr.active = true</code> is invoked,
	 * the engine checks to see if the network has been prepared, and, if so, does not have to compute the transition paths again.</p>
	 * <p>Transitions can point to themselves -- we call these "transitions to self."  This class permits developers to specify how many
	 * levels to exit before returning to the same state (see the final argument of the constructor), for transitions to self.</p>
	 * @author Jonathan Kaye
	 */
	public class Transition {
		
		/**
		 * Pointer to the source State (HState or HStateC).
		 */
		public var 		source:State;
		
		/**
		 * ID of the target state.
		 * Identifier must be unique across all states in the state engine.
		 */
		public var 		targetID:String;
		
		/**
		 * Pointer to the target State (HState or HStateC).
		 * Important: this value is computed just before the stage engine is activated, or when the developer calls <code>myStateEnginePtr.prepareNetwork()</code>.
		 * Therefore, the value may be <code>null</code> if you try to access it before that condition has occurred.
		 * @private
		 */
		internal var 	target:State;
		
		/**
		 * @private
		 */
		internal var	xFn:Function;
		
		/**
		 * @private
		 */
		internal var	hist:Boolean;
		
		/**
		 * The number of levels in the state network to go up (towards the root) if this an external transition.
		 * @private
		 */
		internal var	upLevelsForExtTrans:uint;
		
		/**
		 * The number of levels in the state network to go up to reach the Least Common Ancestor.
		 */
		internal var	upLvls:int;
		
		/**
		 * An array consisting of state identifiers from the LCA to the target state.
		 */
		internal var 	stPath:Array;
	
		
		/**
		 * Creates a Transition instance.
		 * <p>Transition instances are used to connect states.  Transitions are triggered by events, but that information is stored in the
		 * State to which the Transition is attached.  The transition permits one to invoke a function when the transition is triggered.</p>
		 * <p>If <code>upLevelsForExternalTransition</code> is supplied, the developer must ensure that the either the source or the target
		 * is the ancestor of the other.  We cannot verify this at the moment this method is called because the target state may not
		 * exist yet (it may only be referred to as its id).</p>
		 * @param	src Source state pointer.
		 * @param	tid Target state identifier.
		 * @param	tfn Transition function -- invoked if the Transition is fired.
		 * @param	doHistory Boolean value indicating whether or not to go to the History pseudo-state of the target state.
		 * @param	upLevelsForExternalTransition This is only for external transitions: it lets one control how many parent states upward the engine exits before returning to enter the state again.
		 */
		function Transition (src:State, tid:String, tfn:Function = null, doHistory:Boolean = false, upLevelsForExternalTransition:uint = 0 ) {
			source					= src;
			targetID 				= tid;
			upLevelsForExtTrans 	= upLevelsForExternalTransition;
			hist					= doHistory;
			xFn						= tfn;
			upLvls					= 0;		// this will get supplied when we determine the path of the transition (determineTransition())
		}
		
		/**
		 * Determines the transition path from the source to the target, once we know all states have been instantiated.
		 * This routine determines if the transition is simple (among siblings), or a crossbound one (requiring jumping outside
		 * current sibling network).  It then sets the type of transition inside this Transition, which the State Manager will
		 * use in making the transition.
		 * @determineTransition
		 * @private
		 */
		internal function determineTransition () : void {
			var stPathArray:Array, sp:State, lca_src:Array, lca_targ:Array, smp:StateManager, ai:int, aj:int, found:Boolean;
			var sid:String;
			
			var statesByID:Object = source._se.statesByID;
			
			target = statesByID[targetID];
			
			// make sure not sending to history of simple state
			if (!(target is HStateC) && hist == true) {
				throw new Error("History pseudo-states are only in in hierarchical states. Cannot transition from " + source.id + " to history of State " + targetID);
			}
			
			// Check the type of transition to see if it is a sibling transition or cross-boundary transition
			if (source == target) {
				// (a) This is a transition to self
				stPathArray = new Array(source.id);
				sp = source;
				for (var i:uint = upLevelsForExtTrans; i > 0; i--) {
					sp = sp.myStMgr.contSt;
					if (sp == null) {
						throw new Error("Hit the top of the state network during transition-to-self path determination for state " + source.name + " -- up levels must be reduced");
					}
					stPathArray.unshift(sp.id);
				}
				upLvls = upLevelsForExtTrans;
				stPath = stPathArray;
				// trace("TRANS TO SELF " + source.id + "->" + target.id + ", HIST = " + hist);
			
			} else if (source.myStMgr == target.myStMgr) {
					// (b) Transition to sibling
					upLvls = 0;
					stPath = [target.id];
					// trace("TRANS TO SIBLING " + source.id + "->" + target.id + ", HIST = " + hist);
			
			} else if ( hist && source.myStMgr.contSt == target ) {
				// (c) Transition to history within same network
				upLvls = 0;
				stPath = [];
				
				// trace("TRANS TO HIST WITHIN SAME NETWORK " + source.id + "->" + target.id + ", HIST = " + hist);
			
			} else {
				// compute ancestor states of source
				lca_src = [];
				smp 	= source.myStMgr;
				while (smp.contSt != null) {
					lca_src.push(smp.contSt.id);
					smp = smp.contSt.myStMgr;
				}
				found = false;
				// Is target an ancestor of source?
				// Case (a) is a special case of this in which the source and target are the same.  Since we've
				// reached here, we know source is not the same as target so we can start our search for target
				// one level above the source state (that's why we didn't put the source state into lca_src[]).
				for (ai = 0; ai < lca_src.length; ai++) {
					if (lca_src[ai] == targetID) {
						// We know we have to go up 'ai' levels to get to the target.  We add in upLevelsForExtTrans
						// to allow the external transition to exit the state as high as desired, then re-enter
						upLvls = ai + upLevelsForExtTrans;
						stPath = [];
						if (upLevelsForExtTrans > 0) {
							// We have to construct the path back to the level of the state appropriate for
							// the external transition's descent
							var ancestorState:State = source.myStMgr.contSt;
							var statesUpCt:uint 	= upLevelsForExtTrans;
							while (statesUpCt > 0) {
								stPath.push(ancestorState.id);
								ancestorState = ancestorState.myStMgr.contSt;
								statesUpCt--;
							}
							stPath.reverse();
						}
							
						// (d) target is an ancestor of source
						found = true;
						break;
					}
				}
				
				if (found == false) {
					// compute ancestors of target
					lca_targ = [targetID];
					smp = target.myStMgr;
					while (smp.contSt != null) {
						lca_targ.push(smp.contSt.id);
						smp = smp.contSt.myStMgr;
					}
					// Is source an ancestor of target? 
					for (ai = 0; ai < lca_targ.length; ai++) {
						if (lca_targ[ai] == source.id) {
							// (e) source is an ancestor of target
							lca_targ.splice(ai + upLevelsForExtTrans, lca_targ.length - ai - upLevelsForExtTrans);
							upLvls = -1 + upLevelsForExtTrans;
							stPath = lca_targ.reverse();
							found = true;
							break;
						}
					}
					
					if (found == false) {
						for (ai = 0; ai < lca_src.length && !found; ai++) {
							for (aj = 1; aj < lca_targ.length; aj++) {
								if (lca_src[ai] == lca_targ[aj]) {
									// (f) SOURCE AND TARGET IN DIFFERENT PATHS
									lca_targ.splice(aj, 1);
									upLvls = ai;
									stPath = lca_targ.reverse();
									found = true;
									break;
								}
							}
						}
						
						if (found == false) {
							throw new Error("State Engine logic for transition computation is faulty.  Cannot find transition from " + source.name + " -> " + target.name );
						}
					}
				}
			}
		}

	}
}