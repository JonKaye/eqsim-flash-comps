/**
   This class is used to hold a listener instance when
   the component FMXISBase needs to evaluate the listener
   at event notification time, rather than at compile-time.
   
   @class  FMXISProxyListener
   @package mx.fmxis
   @author Jonathan Kaye (FlashSim.com)
*/
/*
This code was developed by Jonathan Kaye and Amethyst Interactive LLC,
Copyright 2002-2004, all rights reserved.
v2.0, February, 2004
*/

class mx.fmxis.FMXISProxyListener {
	/**
	Holds the string name of the listener.
	@property
	*/
	public var lstner:String;
	/**
	Holds the MovieClip instance of the timeline on which the listener is supposed to reside.
	@property
	*/
	public var tline:MovieClip;
	
	// constructor
	function FMXISProxyListener (tl, l) {
		tline = tl;
		lstner = l;
	}
	
	// Receives all events for this component and passes them to the listener on record.
	function handleEvent (ev) {
		var l;
		l = tline[lstner];
		
		if (l.handleEvent != undefined) {
			l.handleEvent(ev);
		} else {
			l[ev.type](ev);
		}
	}
}