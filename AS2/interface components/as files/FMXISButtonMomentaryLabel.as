/**
<p>This class extends FMXISButtonMomentary (momentary button with repeat-on-down functionality)
to allow developers to add a text label placed over the button.  Users can change the
appearance by changing the <i>defaultButUp</i> and <i>defaultButDn</i> movie clips
in the Library.</p>
  

@class FMXISButtonMomentaryLabel
@codehint _bMomLabel
@author Jonathan Kaye (FlashSim.com)
@tooltip Simple momentary button with user-defined label
*/

/*
This code was developed by Jonathan Kaye and Amethyst Interactive LLC,
Copyright 2002-2004, all rights reserved.
v2.0, February, 2004
*/
import mx.core.UIObject;
import mx.fmxis.FMXISBase;
import mx.fmxis.FMXISButtonMomentary;

[IconFile("buttonMomentary.png")]

class mx.fmxis.FMXISButtonMomentaryLabel extends FMXISButtonMomentary {

	var className:String = "FMXISButtonMomentaryLabel";
	static var symbolOwner:Object = FMXISButtonMomentaryLabel;
	static var symbolName:String = "FMXISButtonMomentaryLabel";
	
	
	[Inspectable(name="Text", type=String, defaultValue="Label")]
	public function set text (text:String) {
		_text = text;
		invalidate();
	}
	public function get text ():String {
		return _text;
	}
	private var _text:String;

	[Inspectable(name="Justify", type=List, enumeration="left,center,right" defaultValue="center")]
	public function set justify (place:String) {
		_place = place;
		invalidate();
	}
	public function get justify ():String {
		return _place;
	}
	private var _place:String;
	
	[Inspectable(name="XY text-down offset", type=Number, defaultValue=4)]
	public var XYOffset:Number;
	
	[Inspectable(name="Left-Right Justify Offset", type=Number, defaultValue=0)]
	public var LROffset:Number;
	
	private var textLabel:TextField = null;
		
	var clipParameters:Object = { listener:1, evtPress:1, evtRelease:1, evtReleaseOutside:1,
								  evtRollOver:1, evtRollOut:1, evtDragOut:1, pulseFreq:1, wait4Start:1,
								  showHand:1, UpLinkID:1, DownLinkID:1, text:1, justify:1, XYOffset:1,
								   LROffset:1};
	private static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(FMXISButtonMomentaryLabel.prototype.clipParameters, 
                               UIObject.prototype.clipParameters);


	// constructor
	function FMXISButtonMomentaryLabel () {
	}
	
	private function attachChildren () {
		super.attachChildren(_ulID == "", _dlID == "");
		textLabel = createLabel("textLabel", 5);
	}
	
	private function draw () {
		super.draw();
		
		textLabel.text = _text;
		textLabel.setSize(textLabel.textWidth+3, textLabel.textHeight+3);
		setTextOffset(0);
	}
	
	private function setTextOffset (o) {
		switch (_place) {
			case "center":
				textLabel.move(-textLabel.width/2 + o, -textLabel.height/2 + o);
				break;
			case "left":
				textLabel.move(-width/2 + LROffset + o, -textLabel.height/2 + o);
				break;
			case "right":
				textLabel.move(width/2-textLabel.width - LROffset + o, - textLabel.height/2 + o);
				break;
		}
	}
	
	private function onPress () {
		super.onPress();
		if (!allowEvents) {
			return;
		}
		setTextOffset(XYOffset);
	}
	
	private function onRelease () {
		super.onRelease();
		if (!allowEvents) {
			return;
		}
		setTextOffset(0);
	}
	
	private function onReleaseOutside () {
		super.onReleaseOutside();
		if (!allowEvents) {
			return;
		}
		setTextOffset(0);
	}
	
	
	
}