/**
<p>This class implements a simple three position switch.

<p>This class inherits from FMXISBase to get listener capabilities.</p>

@class FMXIS3Switch
@codehint _butTog
@author Jonathan Kaye (FlashSim.com)
@tooltip Simple momentary button
*/ 
/*
This code was developed by Jonathan Kaye and Amethyst Interactive LLC,
Copyright 2002-2004, all rights reserved.
v2.0, February, 2004
*/
import mx.core.UIObject;
import mx.fmxis.FMXISBase;

[IconFile("switch.png")]

[Event("onUp")]
[Event("onMiddle")]
[Event("onDown")]
[Event("disabled")]

class mx.fmxis.FMXIS3Switch extends FMXISBase {

	// bounding box for this button component
	private var boundingBoxClip:MovieClip;
	private var switchGraphics:MovieClip;
	
	var className:String = "FMXIS3Switch";
	static var symbolOwner:Object = FMXIS3Switch;
	static var symbolName:String = "FMXIS3Switch";

	// Inspectable properties.  Let user change the event names, if desired.
	// The event names have to be set at the time the component is instantiated (either
	// at run-time, or programmatically at the attachMovie/createClassObject time).
	
	/**
	Event name for when button is put in the up  position.  Change this value
	at any time.
	@property evtUp
	*/
	[Inspectable(name="onUp Event Name", type=String, defaultValue="onUp")]
	public var evtUp:String;

	/**
	Event name for when button is put in the middle position.  Change this value
	at any time.
	@property evtMiddle
	*/
	[Inspectable(name="onMiddle Event Name", type=String, defaultValue="onMiddle")]
	public var evtMiddle:String;
	
	/**
	Event name for when button is put in the down position.  Change this value
	at any time.
	@property evtDown
	*/
	[Inspectable(name="onDown Event Name", type=String, defaultValue="onDown")]
	public var evtDown:String;
	
	/**
	Whether or not to display the hand cursor when the mouse is over the hit area.
	Defaults to true (must be set in the component property panel).
	@property showHand
	*/
	[Inspectable(name="Show Hand Cursor", type=Boolean, defaultValue=true)]
	private var showHand:Boolean;
	
	/**
	Linkage ID of the switch graphics.  Must be set in the component
	property panel only.
	@property swGraphicsID
	*/
	[Inspectable(name="Switch graphics linkage ID", type=String, defaultValue="")]
	private var swGraphicsID:String;
		
	// internal value for position ("up", "down", "middle")
	private var _position;
	
	/**
	Whether the button is in the up (unset) position -- true -- on first viewing, or
	in the down (set) position -- false.
	@property butIsUp
	*/
	[Inspectable(name="Switch position", type=List, enumeration="up,middle,down" defaultValue="middle")]
	public function set position (f) {
		_position = f;
		invalidate();
	}
	
	public function get position () {
		return _position;
	}
	
	[Inspectable(name="Auto-center?", type=Boolean, defaultValue=false)]
	public function set autoCenter (f) {
		_autoCenter = f;
		setupSwitchHandlers();
	}
	
	public function get autoCenter () {
		return _autoCenter;
	}
	private var _autoCenter;

	public var allowEvents:Boolean;
			
	// event dispatch stuff
	private var dispatchEvent:Function;
	
	// clipParameters - for backward compatibility with Flash 6 player
	var clipParameters:Object = { listener:null, evtUp:"onUp", evtDown:"onDown", evtMiddle:"onMiddle",
									showHand:true, position:"middle", autoCenter:false, swGraphicID:null };
	private static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(FMXIS3Switch.prototype.clipParameters, 
                               UIObject.prototype.clipParameters);

	
	static var switchEvents:Array = new Array("onUp", "onMiddle", "onDown", "disabled");
	
	// by default, use the event names as given by buttonEvents.  We made it a static
	// variable for space efficiency.
	private var myEvents:Array = switchEvents;
	
	// constructor
	function FMXIS3Switch () {
	}
	
	private function init (evts): Void {
		// if the user has changed any event names, make sure named listeners are handled
		if (myEvents[0] != evtUp  ||
			myEvents[1] != evtMiddle ||
			myEvents[2] != evtDown ||
		    evts != null) {
			this.myEvents = new Array(evtUp, evtMiddle, evtDown, "disabled");
		}
		if (evts != null) {
			if (!(evts instanceof Array)) {
				evts = [ evts ];
			}
			
			super.init(myEvents = myEvents.concat(evts));
			
		} else {
			super.init(myEvents);
		}
		
		this.useHandCursor = this.showHand;
		allowEvents = true;
		attachChildren();
		
	}
	
	private function attachChildren () {
		var sg;
		if (swGraphicsID == "") {
			sg = "defSwitch3Graphics";
		} else {
			sg = swGraphicsID;
		}
		attachMovie(sg, "switchGraphics", 1);
		
		setupSwitchHandlers();
	}
	
	private function draw () {
		switch (_position) {
			case "up":
				switchGraphics.swUp._visible = true;
				switchGraphics.swMid._visible = 
				switchGraphics.swDown._visible = false;
				break;
				
			case "down":
				switchGraphics.swDown._visible = true;
				switchGraphics.swMid._visible = 
				switchGraphics.swUp._visible = false;
				break;
				
			case "middle":
				switchGraphics.swMid._visible = true;
				switchGraphics.swDown._visible = 
				switchGraphics.swUp._visible = false;
				break;
		}
	}
	
	function setupSwitchHandlers () {
		switchGraphics.hUp.onPress = function (q) {
			if (!_parent._parent.allowEvents) {
				_parent._parent.eventObj.type = "disabled";
				_parent._parent.eventObj.val = _parent._parent.evtUp;
				_parent._parent.dispatchEvent(_parent._parent.eventObj);
				return;
			}

			with (_parent._parent) {
				
				
				if (_position != "up") {
					_position = "up";
					if (!q) {
						eventObj.type = evtUp;
						dispatchEvent(eventObj);
					}
					invalidate();
				}
			}
		}
		if (_autoCenter) {
			switchGraphics.hUp.onRelease = 
				switchGraphics.hUp.onReleaseOutside = flipToMiddle;
			switchGraphics.hDown.onRelease = 
				switchGraphics.hDown.onReleaseOutside = flipToMiddle;
				
			switchGraphics.hMid.onPress = undefined;
		} else {
			switchGraphics.hUp.onRelease = 
				switchGraphics.hUp.onReleaseOutside =
				switchGraphics.hDown.onRelease = 
				switchGraphics.hDown.onReleaseOutside = undefined;
				
			switchGraphics.hMid.onPress = function (q) {
				if (!_parent._parent.allowEvents) {
					_parent._parent.eventObj.type = "disabled";
					_parent._parent.eventObj.val = _parent._parent.evtMiddle;
					_parent._parent.dispatchEvent(_parent._parent.eventObj);
					return;
				}
				with (_parent._parent) {
					if (_position != "middle") {
						_position = "middle";
						if (!q) {
							eventObj.type = evtMiddle;
							dispatchEvent(eventObj);
						}
						invalidate();
					}
				}
			}
		}
		
		switchGraphics.hDown.onPress = function (q) {
			if (!_parent._parent.allowEvents) {
				_parent._parent.eventObj.type = "disabled";
				_parent._parent.eventObj.val = _parent._parent.evtDown;
				_parent._parent.dispatchEvent(_parent._parent.eventObj);
				return;
			}
			with (_parent._parent) {
				if (_position != "down") {
					_position = "down";
					if (!q) {
						eventObj.type = evtDown;
						dispatchEvent(eventObj);
					}
					invalidate();
				}
			}
		}
	}
	
	function flipToMiddle (q) {
		if (!_parent._parent.allowEvents) {
			_parent._parent.eventObj.type = "disabled";
			_parent._parent.eventObj.val = _parent._parent.evtMiddle;
			_parent._parent.dispatchEvent(_parent._parent.eventObj);
			return;
		}
		with (_parent._parent) {
			_position = "middle";
			if (!q) {
				eventObj.type = evtMiddle;
				dispatchEvent(eventObj);
			}
			invalidate();
		}
	} 
	
	function execEvent (evtName, evtVal, q) {
		switch (evtName) {
			case myEvents[0]:
				switchGraphics.hUp.onPress(q);
				break;
				
			case myEvents[1]:
				if (!allowEvents) {
					eventObj.type = "disabled";
					eventObj.val = evtMiddle;
					dispatchEvent(eventObj);
					return;
				}

				_position = "middle";
				if (!q) {
					eventObj.type = evtMiddle;
					dispatchEvent(eventObj);
				}
				invalidate();
				break;
				
			case myEvents[2]:
				switchGraphics.hDown.onPress(q);
				break;
		}
	}
}