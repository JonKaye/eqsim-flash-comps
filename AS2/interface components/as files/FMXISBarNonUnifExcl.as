import mx.core.UIObject;
import mx.fmxis.FMXISBarNonUnif;

[IconFile("bar.png")]
[InspectableList("nBars", "barSpace", "barColors", "barColorRange", "chipUnits", "val", "exclus")]

class mx.fmxis.FMXISBarNonUnifExcl extends FMXISBarNonUnif {
	var className:String = "FMXISBarNonUnifExcl";
	static var symbolOwner:Object = FMXISBarNonUnifExcl;
	static var symbolName:String = "FMXISBarNonUnifExcl";
	
	
	[Inspectable(name="Bar color range exclusive?", type=Array, defaultValue="")]
	public var exclus:Array;

	// *************************	
	// clipParameters - for backward compatibility with Flash 6 player
	var clipParameters:Object = { chipUnits:[1, 2, 3, 4, 5, 6, 7, 8, 9, 10], nBars:10, barSpace:2, barColors:[0x00FF00], barColorRange:[100],
								  minVal:0, maxVal:100, val:0, listener:null, exclus:null };
	private static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(FMXISBarNonUnifExcl.prototype.clipParameters, 
                               UIObject.prototype.clipParameters);
	
	// constructor
	function FMXISBarNonUnifExcl () {
		super();
	}
	
	private function draw () {
		var i, c, lastChip = _nBars - 1, targColRange = 0, inExclRange;
		
		// first determine which color range the value is in
		for (i=_barColorRange.length-1; i>=0; i--) {
			if (_val > _barColorRange[i]) {
				break;
			}
		}
		targColRange = i;
		
		// Now that we know the color range, see if the value falls
		// between a point at which we change colors.  If so, we
		// need to show the lower set of values.  For example, if we have
		// greens up to 10, and the first yellow chip at 11, we need to
		// keep the green chips lit for values such as 10.5, 10.6, etc.,
		// up to any value less than 11.
		// We do this by detecting the situation and then adjusting our
		// color range to be the lower range.
		i = 0;
		while (_barColorRange[targColRange] >= _chipUnits[i] && i<_nBars) {
			i++;
		}
		if (_val < _chipUnits[i] && i<_nBars) {
			targColRange--;
		}

		// Set a flag as to whether the current value is in an exclusive value
		// range.  If so, we don't want to show any values from non-exclusive ranges.
		inExclRange = exclus[targColRange+1];
		
		// now light the appropriate chips
		for (i=0, c=0; i<_nBars; i++) {
			while (_chipUnits[i] > _barColorRange[c]) {
				c++;
			}
			// We can light the chip if the chip's value is less than
			// the current value to display and one of the following conditions 
			// (at least) are true:
			// 1. The color range is not exclusive
			// 2. We're at the bottom of the scale
			// 3. The chip unit is part of the exclusive color range
			bcArray[i]._visible = (_val >= _chipUnits[i] &&
								   ((!exclus[c] && !inExclRange) ||
								    targColRange == -1 ||
								   (_chipUnits[i] > _barColorRange[targColRange])));
		}
	}	
}