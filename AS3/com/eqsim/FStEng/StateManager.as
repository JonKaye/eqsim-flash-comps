	/*
	************************************************
	
	EXAMPLE: Hierarchical State Machine Engine
	AUTHOR: Jonathan Kaye
	RELEASE: 	August, 2009
	Implementation originally conceived and developed DECEMBER 2001
		
	FILE: StateManager.as (state network manager)
	
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
	 * Manages a network (collection) of states.   
	 * <p>The State (network) Manager class is used at run-time to manage which state(s) are active and
	   which have been visited last (the history mechanism), in each network (collection of states).  All HState's must
	   have only one State Manager, and all HStateC's must have one or more State Managers that you create.</p>
	   @class  StateManager
	*/
	public class StateManager {
		
		/**
		 * An optional name to give to the State Manager, used for display purposes only. If no
		 * name is set, we use id by default.
		 */
		public var name:String;
		
		/**
		 * <p>State Manager's identifier that must be different from other StateManager's in sibling networks.  By convention,
		 * the identifier is alphabetic.  The identifier uniqueness only really becomes important in HStateC's, since that is
		 * the only state class with sibling networks.</p>
		 */
		public var id:String;
		/**
		 * Identifier for the default start state.
		 * <p>State machine developers indicate which state should be the default start state.  By convention, state identifiers are numeric,
		 * but we have implemented them as String's to give more flexibility.</p>
		 */
		public var defSt:String;
		/**
		 * Pointer to state containing this manager.
		 * <p>Indicates which state encloses this network, in other words, which state is this manager working for.  Set to 'null' if this is manager at state engine (top) level.</p>
		 */
		public var contSt:HStateC;
		/**
		 * Identifier of the current state.
		 * <p>If this manager's network is active, this value is the current state's identifier.</p>
		 */
		public var cs:String;
		/**
		 * Identifier of the last state entered (for history mechanism)
		 * @private
		 */
		public var lastSt:String;
		/**
		 * true if state manager is active, false if not
		 * @private
		 */
		public var active:Boolean;
		
		
		/**
		Constructor for State (network) Manager.  One StateManager is required to manage the
		network of each HState, or each sub-network of an HStateC.
		@method new StateManager
		@param identifier 	String identifier (id) for the state manager.  Identifier must be unique only for sibling managers in an HStateC.
		@param containerSt 	Pointer to state containing this manager.  'null' if this is manager at state engine (top) level. 
		@param defaultSt 	Default start state (use the State's id).  It is optional here, but if not given here, the developer must specify one with <code>setDefaultState()</code>.
		@param n 			State manager name (optional).  Used for display purposes only.  If no name passed in, routines use id.
		*/
		public function StateManager (identifier:String, containerState:HStateC, defaultState:String = null, n:String = null) {
			id   	= identifier;
			if (n == null) {
				name = id;
			} else {
				name = n;
			}
			defSt 	= defaultState;
			contSt 	= HStateC(containerState);
			cs 		= undefined;
			lastSt 	= undefined;
			
			// Register this state manager with the state network
			if (containerState != null) {
				containerState.addStateManager(this);
			}
		}
		
		/**
		 * Called when the state engine activates the state network that we (this state manager)
		 * manage.  Our job is to activate the network by entering a state.  We can either
		 * <li>Enter the default start state;</li>
		 * <li>Enter the state that was current before we were last deactivated (history mechanism);</li>
		 * <li>Enter a specific state as given by specIDs.</li>
		 * 
		 * <p>If hist is true, we should enter the state most recently visited (lastSt). If false,
		 * enter the default start state (defSt). If specIDs is present (not null), we ignore
		 * the default start state, we ignore the hist flag, and specIDs is an array of state id's,
		 * with the first element being the numeric id of the state we're supposed to enter.
		 * This is to handle transitions that span state levels.</p>
		 * @method activate
		 * @param hist Whether or not to enter the state most recently visited
		 * @param specIDs If present (not null), this is an array of state ID's to enter.  This overrides the default start state for the state.
		 * @private
		 */
		internal function activate(hist:Boolean, specIDs:Array) : void {
			active = true;
			var ns:State;
			
			// determine which state to start in.  If specIDs is non-null, use it
			if (specIDs != null) {
				// Take off the first state in the state path.  This is for our level.
				cs = specIDs[0];
				specIDs.splice(0, 1);
				if (specIDs.length == 0) {
					specIDs = null;
				}
			} else {
				// Use the history mechanism if caller wants, otherwise use default start state
				if (hist && lastSt != null) {
					cs = lastSt;
				} else if (defSt == null) {
					throw new Error("Default start state not defined for state network managed by " + name);
				} else {
					cs = defSt;
				}
				// Clear the hist value because we just used it if we were supposed to
				hist = false;
			}
			// If last state visited is undefined, set it to the current state so we don't lose track of the last state visited
			if (lastSt == null) {
				lastSt = cs;
			}
			
			// Retrieve appropriate state to enter then do the deed!
			if (contSt.substates[cs] == null) {
				throw new Error("Manager " + name + " was told to start in state " + cs + " but it does not exist as a substate of " + contSt.name);
			}
			
			ns = contSt.substates[cs];
			ns.enter(hist, specIDs);
		}
		
		/**
		Called when the network this state manager manages is deactivated (because
		the state engine has left the state that contains us).
		@method deactivate
		@private
		*/
		internal function deactivate () : void {
			var sp:State;
			
			if (active && cs != null) {
				sp = this.contSt.substates[cs];
				sp.leave();
				// Record last state entered before we get deactivated
				this.lastSt = cs;
				active 		= false;
				// Reset current state
				cs = null;
			}
		}
		
		/**
		 * Walks through the states controlled by this manager and sub-managers
		 * and clears the history variable (lastSt) so that next time through this state network,
		 * the last state visited will be undefined.
		 * @method resetHistory
		 * @private
		 */
		internal function resetHistory () : void {
			var smp:StateManager, sp:State;
			
			// if history mechanism is still null, meaning no one has entered this state yet, don't waste time resetting sub-network
			if (lastSt == null) {
				return;
			}
			lastSt = null;
			
			for each (sp in contSt.substates) {
				if (sp is HStateC) {
					for each (smp in HStateC(sp).stMgrs) {
						smp.resetHistory();
					}
				}
			}
		}
		
		/**
		 * Changes the current state (managed by this manager) based on the given transition ID.
		 * <p>In most circumstances, the engine handles triggering transitions based on injected events.  In some rare situations,
		 * developers may want to trigger a transition manually.  There is a method of State called <code>chgSt()</code>, which
		 * triggers the transition specified by the given transition identifier.  Similarly, the StateManager chgSt() can be used
		 * to trigger a transition (identifier of the current state).</p>
		 * @method chgSt
		 * @param transID Transition ID to use for current state
		 * @param val an optional argument that is passed to the transition function
		 */
		public function chgSt(trans:Transition, val:*):void {
			var stp:State, cpyStPath:Array, nsm:StateManager, sm:StateManager, tmpcs:String, mgrs:Object, sid:String, curSubStateMgr:StateManager;
			var i:uint;
			var statesByID:Object = trans.source._se.statesByID;
			var hstp:HStateC;
			
			if (!active) {
				throw new Error("Trying to change states through inactive <manager " + name + ">");
			}
			
			// Steps:
			// 1. Leave current state
			// 2. Execute transition actions
			// 3. Enter new state
			// RETRIEVE TRANSITION ACTIONS
			if (trans == null) {
				throw new Error("'null' transition given to chgSt()");
				
			} else {
				if (this.contSt == null) {
					// We're at top of state engine.
					stp = trans.source._se.topState;
					
				} else {
					stp = this.contSt.substates[this.cs];
				}
					
				// If there is a path to traverse, copy the contents to a new array because we
				// will progressively delete from the array we pass as transitions occur.
				cpyStPath = new Array();
				for (i=0; i<trans.stPath.length; i++) {
					cpyStPath.push(trans.stPath[i]);
				}
				
				
				// LEAVE CURRENT STATE and any ancestors up to common parent state manager
				if (trans.upLvls > 0) {
					nsm = this.passUp(trans.upLvls, trans.hist && cpyStPath.length == 0);
					mgrs = new Object();
					mgrs[nsm.id] = nsm;
					
				} else {
					// upLvls == 0 (meaning to transition to a sibling state) or -1 (meaning to transition within this state).  We have
					// to ensure that we leave the current state ONLY if target is outside (upLvls == 0)
					nsm = this;
					
					// If upLvls == 0, we know we're transition to a sibling state if the state path (cpyStPath) is non-null.  Therefore,
					// mark the current state as the last state visited.  If the condition is not true, we are either heading to history
					// in which case we don't want to mark the current state as the last state), or we're descending into this state,
					// and so operation should not change this manager's record of last state.
					if (trans.upLvls == 0 && cpyStPath.length > 0) {
						nsm.lastSt = stp.id;
					}
					
					// upLvls == 0 means target is at same level as current state.  -1, which means target is within current state
					if (trans.upLvls == 0) {
						stp.leave();
					
						// If we should go to history, we don't want to register the current state as the last state or else
						// we would always re-enter the current state.  If we are not going to history, we record the current
						// state as the last state.
						if (trans.hist == false) {
							stp.myStMgr.lastSt = cs;
						}
						stp.myStMgr.cs = null;
						mgrs = [ nsm ];
						
					} else {
						// upLvls must be -1, which means we have to be transitioning somewhere into the current state.  This also
						// means that cpyStPath must be non-null or it is a transition to history.
						if (cpyStPath.length > 0) {
							
							// We have to see if the transition is supposed to go down a sibling sub-state rather than the current sub-state.  If
							// it goes down the current sub-state, we don't re-enter that state.  If it goes down a sibling sub-state, we have
							// to leave the current sub-state
							for (sid in HStateC(stp).substates) {
								if (HStateC(stp).substates[sid].id == cpyStPath[0]) {
									sm = HStateC(stp).substates[sid].myStMgr;
									if (sm.cs == cpyStPath[0]) {
										// The transition is going into a state which is already current.  Follow the cpyStPath down to make
										// sure we're leaving states that the transition is not going to go through.
										i = 1;
										while (i < cpyStPath.length && statesByID[cpyStPath[i]].isActive()) {
											i++;
										}
										
										// If we don't see as active all the way to the target state, then leave those states.  If
										// we get to the target state through the cpyStPath and all are active, we don't want to leave (target
										// is already current).  However, if it's a transition to history, we need to do something special --
										// we need to leave whatever the current sub-state is and go to the last state visited (history), so
										// we have to leave the current sub-state.
										if (i < cpyStPath.length) {
											curSubStateMgr = statesByID[cpyStPath[i]].myStMgr;
											statesByID[curSubStateMgr.cs].leave();
											curSubStateMgr.lastSt = curSubStateMgr.cs;
											curSubStateMgr.cs = null;
										} else if (trans.hist) {
											hstp = statesByID[cpyStPath[cpyStPath.length - 1]];
											for each (var smp:StateManager in hstp.stMgrs) {
												statesByID[smp.cs].leave();
												smp.cs = null;
											}
										}
										
									} else {
										// The transition must take us into a different sub-state from what is current, so leave the current sub-state
										statesByID[sm.cs].leave();
										sm.lastSt = cs;
										sm.cs = null;
									}
									break;
								}
							}
							
							nsm = statesByID[cpyStPath[0]].myStMgr;
							
						} else {
							// No more info on which state to go to, so pass message to all managers of substates (only legal move here is a transition to history)
							mgrs = new Object();
							if (stp is State) {
								throw new Error("Logic error in State Manager chgSt() for manager id " + id + ".  Preparing to enter a sub-state of " + stp.id + " but it is not hierarchical.");
							}
							
							if (!trans.hist) {
								throw new Error("Logic error in State Manager chgSt() for manager id " + id + ".  Transition within current state is not to history nor has a descent path.");
							}
							
							for (sid in HStateC(stp).substates) {
								if (mgrs[sid] == null) {
									mgrs[sid] = HStateC(stp).substates[sid].myStMgr;
									// Since the transitions have to be to history, we check to see if the current sub-state is the same as the last state visited, which will be entered.
									// If so, we don't leave the state since we're headed right back in.  If the last state visited is different from the current sub-state, we leave
									// the current sub-state.
									if (mgrs[sid].lastSt != mgrs[sid].cs) {
										statesByID[mgrs[sid].cs].leave();
									}
								}
							}
						}
					}
				}
					
				// EXECUTE TRANSITION ACTIONS 
				if (trans.xFn != null) {
					trans.xFn(val);
				}
			
				// now have to follow state path downward
				if (cpyStPath.length == 0) {
					for (sid in mgrs) {
						mgrs[sid].passDown(cpyStPath, trans.hist, stp._se);
						
					}
				} else {
					nsm.passDown(cpyStPath, trans.hist, stp._se);
				}
			}
		}
		
		/**
		 * Used by chgSt() to effect the transition to a state whose common
		 * ancestor/parent with the current state is above the current state manager.
		 * Called when state transition causes us to leave our level and some
		 * number of levels above us.  Go up the state network, leaving each container
		 * state, until we reach the appropriate level.  Return the state manager at this level.
		 * @method passUp
		 * @param upLvls Number of levels to ascend to reach least common ancestor
		 * @access private
		 */
		private function passUp(upLvls:uint, transToAncestorHist:Boolean):StateManager {
			var nsm:StateManager = this;
			while (upLvls > 0) {
				nsm.contSt.leave();
				upLvls--;
				// The container state's network is now in limbo as we've left the current
				// state.  We put it in limbo so that if a parent manager tries to deactivate
				// concurrent states, our network will not be re-"leave"d.
				if (upLvls == 0 && transToAncestorHist == false) {
					// If we are at the top of where we're supposed to be and we're told to go to the history
					// of the state above us, don't set the last state property since we want to use the true last state
					nsm.contSt.myStMgr.lastSt = nsm.contSt.myStMgr.cs;
				}
				nsm.contSt.myStMgr.cs = null;
				nsm = nsm.contSt.myStMgr;
				if (nsm == null) {
					throw new Error("passUp reached top of state network but was told to go higher.  This is logic error in Transition processing.");
				}
			}

			return nsm;
		}
		
		/**
		 * Used by chgSt() and passUp() to make transitions that jump to levels
		 * within a sibling state but below the current level.
		 * @method passDown
		 * @param stPath
		 * @param hist
		 * @private
		 */
		internal function passDown(stPath:Array, hist:Boolean, sep:StateEngine) : void {
			var stp:State;
		
			if (stPath == null || stPath.length == 0) {
				stPath = null;
				if (hist == false) {
					stp = contSt.substates[this.defSt];
				} else {
					stp = contSt.substates[this.lastSt];
				}
				stp.myStMgr.cs = stp.id;
				stp.enter(hist, null);
				
			} else {
				if (this.contSt == null) {
					// We're at the top of the state network, so the manager has no container state
					stp = sep.statesByID[stPath[0]];
				} else {
					stp = this.contSt.substates[stPath[0]];
				}
				
				stPath.splice(0, 1);
				if (stPath.length == 0) {
					// We've reached the right level, so if this state is not active already, enter it
					if (stp.isActive() == false) {
						stp.myStMgr.cs = stp.id;
						stp.enter(hist, null);

						
					} else if (hist) {
						// Tell stp's managers to activate
						for each (var ssm:StateManager in HStateC(stp).stMgrs) {
							if (ssm.lastSt == null) {
								ssm.cs = ssm.defSt;
								ssm.lastSt = null;
								
							} else {
								var tmpSt:String = ssm.cs;
								ssm.cs = ssm.lastSt;
								ssm.lastSt = tmpSt;
							}
							stp._se.statesByID[ssm.cs].enter(false, null);
						}
						
					}
					stPath = null;
				} else {
					// If this state is not active already, enter it
					if (stp.isActive() == false) {
						stp.myStMgr.cs = stp.id;
						stp.enter(hist, stPath);
					} else {
						// Go down to the next level and see if the first element of stPath is active, then do appropriate enter or passDown from there
						sep.statesByID[stPath[0]].myStMgr.passDown(stPath, hist, sep);
					}
				}
			}
		}
		
		/**
		 * Adds a simple state (State) to the network that this manager manages.
		 * Developers can call this routine or create a State using 'new'.
		 * @param	id	Unique identifier for this state, unique across all states.
		 * @param	nm	Optional display name for the state.  If not supplied, engine use id.
		 * @return
		 */
		public function addState (id:String, nm:String = null) : State {
			return new State(id, this, nm);
		}
		/**
		 * Adds a hierarchical state (HState) to the network that this manager manages.
		 * Developers can call this routine or create a State using 'new'.
		 * @param	id	Unique identifier for this state, unique across all states.
		 * @param	nm	Optional display name for the state.  If not supplied, engine use id.
		 * @return
		 */
		public function addHState (id:String, nm:String = null) : HState {
			return new HState(id, this, nm);
		}
		/**
		 * Adds a concurrent, hierarchical state (HStateC) to the network that this manager manages.
		 * Developers can call this routine or create a State using 'new'.
		 * @param	id	Unique identifier for this state, unique across all states.
		 * @param	nm	Optional display name for the state.  If not supplied, engine use id.
		 * @return
		 */
		public function addHStateC (id:String, nm:String = null) : HStateC {
			return new HStateC(id, this, nm);
		}
	}
}