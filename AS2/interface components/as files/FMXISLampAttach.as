/**
<p>This class implements a multi-state lamp (indicator) with attached graphics.  Users can change the
appearance by changing the <i>defLampXGraphic</i> and <i>defLampXBkgnd</i> movie clips
in the Library, or the linkage ID's of each state.</p>
  
<p>The class generates no events, but it inherits from FMXISBase for consistency with the component
library.</p>

@class FMXISLampAttach
@codehint _lampAttach
@author Jonathan Kaye (FlashSim.com)
@tooltip Multi-state lamp
*/ 
/*
This code was developed by Jonathan Kaye and Amethyst Interactive LLC,
Copyright 2002-2004, all rights reserved.
v2.0, February, 2004
*/
import mx.core.UIObject;
import mx.fmxis.FMXISBase;

[IconFile("lampAttach.png")]

[InspectableList("lampBackID", "linkageIDs", "displayLamp")]

class mx.fmxis.FMXISLampAttach extends FMXISBase {

	// bounding box for this button component
	private var boundingBoxClip:MovieClip;
	private var lampClips:Array;
	private var lampBkgnd:MovieClip;
	private var lampState:Number;
		
	var className:String = "FMXISLampAttach";
	static var symbolOwner:Object = FMXISLampAttach;
	static var symbolName:String = "FMXISLampAttach";
	
	// Inspectable properties.  Let user change the event names, if desired.
	// The event names have to be set at the time the component is instantiated (either
	// at run-time, or programmatically at the attachMovie/createClassObject time).

	[Inspectable(name="Lamp states Linkage IDs", type=Array)]
	public var linkageIDs:Array;

	[Inspectable(name="Linkage ID of background", type=String, defaultValue="")]
	public var lampBackID:String;
	
	[Inspectable(name="Index of linkage ID to display", type=Number, defaultValue="0")]
	public function set displayLamp (v:Number) {
		invalidate();
		lampState = v;
	}
	public function get displayLamp () {
		return lampState;
	}
	
		
	// clipParameters - for backward compatibility with Flash 6 player
	var clipParameters:Object = { lampBackID:1, linkageIDs:1, displayLamp:1 };
	private static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(FMXISLampAttach.prototype.clipParameters, 
                               UIObject.prototype.clipParameters);

	
	// constructor
	function FMXISLamp () {
	}
	
	private function init (evts): Void {
		super.init();
		attachChildren();
	}
	
	private function attachChildren () {
		var bk = "defLampAttachBkgnd", mcp;
		
		if (lampBackID != "" && lampBackID != undefined) {
			bk = lampBackID;
		}
		attachMovie(bk, "lampBkgnd", 1);
		
		if (linkageIDs.length > 0) {
			lampClips = new Array();
			for (var i=0; i<linkageIDs.length; i++) {
				if (linkageIDs[i] == "") {
					// show background only
					mcp = null;
				} else {
					mcp = attachMovie(linkageIDs[i], "lampClip"+i, i+2);
				}
				
				lampClips.push(mcp);
			}
		}
	}
	
	private function draw () {
		setLampState(lampState);
	}
	
	private function setLampState (v) {
		for (var i=0; i<lampClips.length; i++) {
			if (i != v) {
				lampClips[i]._visible = false;
			} else {
				lampClips[i]._visible = true;
			}
		}				
	}
	
}