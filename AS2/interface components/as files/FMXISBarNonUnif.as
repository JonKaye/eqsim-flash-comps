import mx.core.UIObject;
import mx.fmxis.FMXISBar;

[IconFile("bar.png")]
[InspectableList("nBars", "barSpace", "barColors", "barColorRange", "chipUnits", "val")]

class mx.fmxis.FMXISBarNonUnif extends FMXISBar {
	var className:String = "FMXISBarNonUnif";
	static var symbolOwner:Object = FMXISBarNonUnif;
	static var symbolName:String = "FMXISBarNonUnif";
	
	
	[Inspectable(name="Chip Units", type=Array, defaultValue="10,20,30,40,50,60,70,80,90,100")]
	public function set chipUnits (p) {
		_chipUnits = p;
		invalidate();
	}
	public function get chipUnits () {
		return _chipUnits;
	}
	private var _chipUnits:Array;


	// *************************	
	// clipParameters - for backward compatibility with Flash 6 player
	var clipParameters:Object = { chipUnits:[1, 2, 3, 4, 5, 6, 7, 8, 9, 10], nBars:10, barSpace:2, barColors:[0x00FF00], barColorRange:[100],
								  minVal:0, maxVal:100, val:0, listener:null };
	private static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(FMXISBarNonUnif.prototype.clipParameters, 
                               UIObject.prototype.clipParameters);
	
	// constructor
	function FMXISBarNonUnif () {
		super();
	}
	
	private function init (evts) {
		super.init(evts);
	}
		
	private function resetChipColors () {
		var chipVal;
		
		if (_barColorRange.length == 0) {
			return;
		}

		for (var i=0; i<_nBars; i++) {
			chipVal = _chipUnits[i];
			if (_barColorRange.length > 0) {
				for (var j=0; j<_barColorRange.length && chipVal > barColorRange[j]; j++)
					;
				bcColorArray[i].setRGB(_barColors[j]);
			}
		}
	}
	
	private function draw () {
		var barVal:Number;
	
		for (var i=0; i<_nBars; i++) {
			barVal = _chipUnits[i];
			bcArray[i]._visible = _val >= barVal;
		}
	}	
}