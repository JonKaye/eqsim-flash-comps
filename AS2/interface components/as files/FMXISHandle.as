import mx.fmxis.FMXISJoystick;

[InspectableList("evtJChg", "evtJStart", "evtJReleased", "initX", "initY", "baseID", "stickID", "hsID", "forceInt", "maxVal", "showHand", "listener", "axisLock")]

class mx.fmxis.FMXISHandle extends FMXISJoystick {
	
	var className:String = "FMXISHandle";
	static var symbolOwner:Object = FMXISHandle;
	static var symbolName:String = "FMXISHandle";


	[Inspectable(name="Force values to integer", type=Boolean, defaultValue=true)]
	public var forceInt:Boolean;

	private var _kSticky:Number = 1;
	public var _pulseFreq:Number = -1;
	public var _pulseID:Number;
	
	/**
	Maximum value for the vector coordinates when the joystick is at full extension.  The
	joystick center is always 0 (for both x and y coordinates), and this property sets
	the maximum value for the coordinate.  The maximum is used to set positive and negative
	extent, so joystick range will be (-maxVal,-maxVal) to (maxVal, maxVal).
	
	@property maxVal
	*/
	[Inspectable(name="Max value", type=Number, defaultValue=100)]
	public function set maxVal (v) {
		_maxVal = v;
		resetCenter();
	}
	public function get maxVal () {
		return _maxVal;
	}
	private var _maxVal:Number;
	
	/**
	Boolean property indicating whether or not to display the hand cursor when the cursor is
	over the hit area of this component.
	@property showHand
	*/
	[Inspectable(name="Show Hand Cursor", type=Boolean, defaultValue=true)]
	public function set showHand (f) {
		useHandCursor = f;
		_showHand = f;
	}
	public function get showHand () {
		return(_showHand);
	}
	private var _showHand:Boolean;
	
	[Inspectable(name="Lock to axis", type=List, enumeration="x,y,none", defaultValue="none")]
	public var axisLock:String;

	[Inspectable(name="Init X Position", type=Number, defaultValue=0)]	
	public var initX:Number;
	
	[Inspectable(name="Init Y Position", type=Number, defaultValue=0)]	
	public var initY:Number;

	
	// event dispatch stuff
	private var dispatchEvent:Function;

	var allowEvents:Boolean;
		
	// clipParameters - for backward compatibility with Flash 6 player
	var clipParameters:Object = { evtJChg:"onJChg", evtJStart:"onJStart", evtJReleased:"onJReleased",
								  baseID:null, stickID:null, hsID:null,
				 				  forceInt:false, maxVal:100, showHand:true, listener:null, axisLock:null };
	private static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(FMXISHandle.prototype.clipParameters, 
                               UIObject.prototype.clipParameters);
	
	static var jstickEvents:Array = new Array("onJChg", "onJPulse", "onJReturned", "onJStart", "evtJReleased", "disabled");
	
	// by default, use the event names as given by jstickEvents.  We made it a static
	// variable for space efficiency.
	private var myEvents:Array = jstickEvents;
	
	function FMXISHandle () {
		setXY(initX, initY);
	}
	
	private function setXY (x, y) {
		if (axisLock == "x") {
			y = 0;
		} else if (axisLock == "y") {
			x = 0;
		}
		super.setXY(x, y);
	}
}
	