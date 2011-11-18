/**
This class implements a simple bar plot.
  
<p>The class generates no events, but it inherits from FMXISBase for consistency with the component
library.</p>

@class FMXISBar
@codehint _bar
@author Jonathan Kaye (FlashSim.com)
@tooltip Simple bar plot
*/ 
/*
This code was developed by Jonathan Kaye and Amethyst Interactive LLC,
Copyright 2002-2004, all rights reserved.
v2.0, February, 2004
This component: Sept, 2004
*/
import mx.core.UIObject;
import mx.fmxis.FMXISBase;

[IconFile("bar.png")]
[InspectableList("nBars", "barSpace", "barColors", "barColorRange", "minVal", "maxVal", "val")]

class mx.fmxis.FMXISBar extends FMXISBase {

	// bounding box for this button component
	private var boundingBox_mc:MovieClip;
	private var bcOn:MovieClip;
	private var bcOff:MovieClip;

	private var bcArray:Array;
	private var bcOffArray:Array;
	private var bcColorArray:Array;
	
	// coefficient used to compute chip's value when chips represent uniform increments
	private var barValCoeff:Number;
	
	private var origChipHeight:Number;
	private var origChipWidth:Number;
			
	var className:String = "FMXISBar";
	static var symbolOwner:Object = FMXISBar;
	static var symbolName:String = "FMXISBar";
	
	[Inspectable(name="Number of bars", type=Number, defaultValue="10")]
	public function set nBars (v) {
		if (v != undefined) {
			_nBars = v;
			resetChips();
			size();
			invalidate();
		}
	}
	public function get nBars () {
		return _nBars;
	}
	private var _nBars:Number;
		
	[Inspectable(name="Bar spacing", type=Number, defaultValue="2")]
	public function set barSpace (v) {
		_barSpace = v;
		size();
		invalidate();
	}
	public function get barSpace () {
		return _barSpace;
	}
	private var _barSpace:Number;
		
	[Inspectable(name="Bar colors", type=Array, defaultValue="0x00FF00")]
	public function set barColors (p) {
		_barColors = p;
		resetChipColors();
		invalidate();
	}
	public function get barColors () {
		return _barColors;
	}
	private var _barColors:Array;
	
	[Inspectable(name="Bar color range", type=Array, defaultValue="100")]
	public function set barColorRange (p) {
		_barColorRange = p;
		resetChipColors();
		invalidate();
	}
	public function get barColorRange () {
		return _barColorRange;
	}
	private var _barColorRange:Array;

	
	[Inspectable(name="Minimum value", type=Number, defaultValue="0")]
	public function set minVal (v) {
		_oldMin = _minVal;
		_minVal = v;
		resetBarCoeff();
		invalidate();
	}
	public function get minVal () {
		return _minVal;
	}
	private var _minVal:Number;
	private var _oldMin:Number;

	[Inspectable(name="Maximum value", type=Number, defaultValue="100")]
	public function set maxVal (v) {
		_oldMax = _maxVal;
		_maxVal = v;
		resetBarCoeff();
		invalidate();
	}
	public function get maxVal () {
		return _maxVal;
	}
	private var _oldMax:Number;
	private var _maxVal:Number;
	
	[Inspectable(name="Starting value", type=Number, defaultValue="0")]
	public function set val (v) {
		_val = v;
		invalidate();
	}
	public function get val () {
		return _val;
	}
	private var _val:Number;


	// *************************	
	
	// clipParameters - for backward compatibility with Flash 6 player
	var clipParameters:Object = { nBars:10, barSpace:2, barColors:[0x00FF00], barColorRange:[100],
								  minVal:0, maxVal:100, val:0, listener:null };
	private static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(FMXISBar.prototype.clipParameters, 
                               UIObject.prototype.clipParameters);

	
	// constructor
	function FMXISBar () {
		size();
	}
	
	private function init (evts) {
		super.init(evts);
		boundingBox_mc._visible = false;
	}
	
	private function createChildren () {
		attachMovie("defBarChip", "bcOff", 1);
		
		bcArray = new Array();
		bcOffArray = new Array();
		bcColorArray = new Array();
		
		origChipHeight = bcOff._height;
		origChipWidth = bcOff._width;
		
		for (var i=0; i<_nBars; i++) {
			if (i == 0) {
				bcOffArray[0] = bcOff;
				bcOff.duplicateMovieClip("bcOn", i+2);
				bcArray[0] = bcOn;
				bcColorArray[0] = new Color(bcArray[0]);
			} else {
				bcOn.duplicateMovieClip("bn" + i, 2*i+3);
				bcOff.duplicateMovieClip("bf" + i, 2*i+2);
				bcArray[i] = this["bn" + i];
				bcOffArray[i] = this["bf" + i];
				bcColorArray[i] = new Color(bcArray[i]);
			}
		}
		resetBarCoeff();
		resetChipColors();
	}
	
	private function resetChips () {
		
		if (_barColors.length == 0) {
			return;
		}

		for (var i=0; i<bcArray.length; i++) {
			bcArray[i].removeMovieClip();
			delete bcColorArray[i];
			if (i != 0)
				bcOffArray[i].removeMovieClip();
		}
		
		for (var i=0; i<_nBars; i++) {
			if (i == 0) {
				bcOffArray[0] = bcOff;
				bcOff.duplicateMovieClip("bcOn", i+2);
				bcArray[0] = bcOn;
				bcColorArray[0] = new Color(bcArray[0]);
			} else {
				bcOn.duplicateMovieClip("bn" + i, 2*i+3);
				bcOff.duplicateMovieClip("bf" + i, 2*i+2);
				bcArray[i] = this["bn" + i];
				bcOffArray[i] = this["bf" + i];
				bcColorArray[i] = new Color(bcArray[i]);
			}
		}
	}
	
	private function resetChipColors () {
		var chipVal;
		
		if (_barColorRange.length == 0) {
			return;
		}

		for (var i=0; i<_nBars; i++) {
			chipVal = _minVal + (i+1) * barValCoeff;
			if (_barColorRange.length > 0) {
				for (var j=0; j<_barColorRange.length && chipVal > barColorRange[j]; j++)
					;
				bcColorArray[i].setRGB(_barColors[j]);
			}
		}
	}
	
	private function resetBarCoeff () {
		barValCoeff = ((_maxVal - _minVal) / _nBars);
	}
	
	private function draw () {
		var barVal:Number;
		
		for (var i=0; i<_nBars; i++) {
			barVal = _minVal + (i+1) * barValCoeff;
			bcArray[i]._visible = _val >= barVal;
		}
	}
		
	private function size () {
		if (height == undefined)
			return;
			
		_yscale = 100;
		_xscale = 100;
		// Number of pixels occupied by space between chips
		var spacePixels = _barSpace * (_nBars - 1);
		var chipHeight = (height - spacePixels) / _nBars;
		for (var i=0; i<_nBars; i++) {
			bcOffArray[i]._yscale = bcArray[i]._yscale = 100 * chipHeight / origChipHeight;
			bcOffArray[i]._xscale = bcArray[i]._xscale = 100 * width / origChipWidth;
			bcOffArray[i]._x = bcArray[i]._x = 0;
			bcOffArray[i]._y = bcArray[i]._y = height  -(i+1)*(chipHeight + _barSpace) + _barSpace;
		}
	}	
}