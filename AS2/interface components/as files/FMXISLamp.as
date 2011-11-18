/**
<p>This class implements a simple three state lamp (indicator).  Users can change the
appearance by changing the <i>defLampGraphic</i> and <i>defLampBkgnd</i> movie clips
in the Library.</p>
  
<p>The class generates no events, but it inherits from FMXISBase for consistency with the component
library.</p>

@class FMXISLamp
@codehint _lamp
@author Jonathan Kaye (FlashSim.com)
@tooltip Simple multi-state lamp
*/ 
/*
This code was developed by Jonathan Kaye and Amethyst Interactive LLC,
Copyright 2002-2004, all rights reserved.
v2.0, February, 2004
*/
import mx.core.UIObject;
import mx.fmxis.FMXISBase;

[InspectableList("tint1", "tint2", "displayLamp")]

[IconFile("lamp.png")]

class mx.fmxis.FMXISLamp extends FMXISBase {

	// bounding box for this button component
	private var boundingBoxClip:MovieClip;
	private var lampClip1:MovieClip;
	private var lampClip2:MovieClip;
	private var lampBkgnd:MovieClip;
	private var color1:Color;
	private var color2:Color;
	private var _lcolor:String;
		
	var className:String = "FMXISLamp";
	static var symbolOwner:Object = FMXISLamp;
	static var symbolName:String = "FMXISLamp";
	
	// Inspectable properties.  Let user change the event names, if desired.
	// The event names have to be set at the time the component is instantiated (either
	// at run-time, or programmatically at the attachMovie/createClassObject time).
	/**
	Color value (RGB) for the first color's tint.
	@property tint1
	*/
	[Inspectable(name="Tint for color 1", type=Color, defaultValue="#FF0000")]
	public function set tint1 (v) {
		_tint1 = v;
		invalidate();
	}
	public function get tint1 () {
		return _tint1;
	}
	private var _tint1:Color;
	/**
	Color value (RGB) for the second color's tint.
	@property tint2
	*/
	[Inspectable(name="Tint for color 2", type=Color, defaultValue="#00FF00")]
	public function set tint2 (v) {
		_tint2 = v;
		invalidate();
	}
	public function get tint2 () {
		return _tint2;
	}
	private var _tint2:Color;
	
	/**
	Three possible values: "off", "color1", or "color2".  This property can be set at
	any time to control which lamp color is displayed.  When the lamp is off, it only displays
	the lamp background graphic.
	@property displayLamp
	*/
	[Inspectable(name="Begin displaying which", type=List, enumeration="off,color1,color2" defaultValue="off")]
	public function set displayLamp (v:String) {
		setLampState(v);
		_lcolor = v;
	}
	public function get displayLamp () {
		return _lcolor;
	}
		
	// clipParameters - for backward compatibility with Flash 6 player
	var clipParameters:Object = { tint1:1, tint2:1, displayLamp:1 };
	private static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(FMXISLamp.prototype.clipParameters, 
                               UIObject.prototype.clipParameters);


	
	// constructor
	function FMXISLamp () {
	}
	
	private function init (evts): Void {
		super.init();
		attachChildren();
	}
	
	private function attachChildren () {
		attachMovie("defLampBkgnd", "lampBkgnd", 1);
		attachMovie("defLampGraphic", "lampClip1", 2);
		setTint1(_tint1);
		attachMovie("defLampGraphic", "lampClip2", 3);
		setTint2(_tint2);
	}
	
	private function draw () {
		if (_tint1 != color1.getRGB()) {
			setTint1(_tint1);
		}
		if (_tint2 != color2.getRGB()) {
			setTint2(_tint2);
		}
		setLampState(_lcolor);
	}
		
	private function setTint1 (c) {
		delete color1;
		color1 = new Color(lampClip1);
		color1.setRGB(Number(c));
	}
	
	private function setTint2 (c) {
		delete color2;
		color2 = new Color(lampClip2);
		color2.setRGB(Number(c));
	}
	
	private function setLampState (v) {
		switch (v) {
			case "off":
				lampClip1._visible = lampClip2._visible = false;
				break;
			
			case "color1":
				lampClip1._visible = true;
				lampClip2._visible = false;
				break;
			
			case "color2":
				lampClip1._visible = false;
				lampClip2._visible = true;
				break;
		}
				
	}
	
}