package actionObj.actions.filters
{
	import actionObj.actions.IAction;
	import actionObj.actions.filters.AdjustColor;
	import actionObj.graphics.Coordinate;
	import actionObj.graphics.Polynomial;
	import actionObj.image.Image_;
	
	import comp.FullImage;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	
	import mx.containers.Canvas;
	import mx.controls.Image;

	public class CyanTonedLowContrast extends FilterBase
	{
		private var curves1Poly:Polynomial;
		private var curves2Poly:Polynomial;
		private var curves3Poly:Polynomial;
		private var curves4Poly:Polynomial;

		public static const desc:String =
			  "Cyan Toned Low Contrast: This filter almost desaturates the images and adds a cyan/bluish tint to it."
			+ " Contrast is also reduced for a more old-timey look.";
		public static const label:String="Relic";		
		
		override public function getLabel():String{
			return label;
		}
				
		public function CyanTonedLowContrast(){
			
		}
		
		override public function prepareFilters():void{
			
			// Step 1A. Curves #1. Apply sepia color cast. Red Curve: 3 points.
			curves1Poly = new Polynomial();
			var curves1CoordArr:Array=new Array();
			curves1CoordArr.push(new Coordinate(0, 0));
			curves1CoordArr.push(new Coordinate(136,110));
			curves1CoordArr.push(new Coordinate(255,255));
			curves1Poly.buildEquation(Polynomial.QUAD,curves1CoordArr);
			
			// Step 1B. Curves #1. Apply sepia color cast. Blue Curve: 3 points.
			curves2Poly = new Polynomial();
			var curves2CoordArr:Array=new Array();
			curves2CoordArr.push(new Coordinate(0, 0));
			curves2CoordArr.push(new Coordinate(107,147));
			curves2CoordArr.push(new Coordinate(255,255));
			curves2Poly.buildEquation(Polynomial.QUAD,curves2CoordArr);
			
			// Step 2. Curves #2. Reduce contrast, remap black and white points. RGB Curve: 2 points.
			curves3Poly = new Polynomial();
			var curves3CoordArr:Array=new Array();
			curves3CoordArr.push(new Coordinate(0, 66));
			curves3CoordArr.push(new Coordinate(255,233));
			curves3Poly.buildEquation(Polynomial.LINEAR,curves3CoordArr); 
			
			// Step 3. Saturation: -85. ColorMatrixFilter used here, Polynomial not needed for this step.
			
			// Step 4. Curves #3. RGB Curve: 4 points.
			curves4Poly = new Polynomial();
			var curves4CoordArr:Array=new Array();
			curves4CoordArr.push(new Coordinate(0,  0));
			curves4CoordArr.push(new Coordinate(60, 29));
			curves4CoordArr.push(new Coordinate(185,225));
			curves4CoordArr.push(new Coordinate(255,233));
			curves4Poly.buildEquation(Polynomial.CUBIC,curves4CoordArr); 			
		}

		
		override public function apply():void
		{
			var red  : Array = [];
			var green: Array = [];
			var blue : Array = [];
			var alpha: Array = null;
			var combinedFilter:ColorMatrixFilter;
			var adjustColor:AdjustColor;
			var i:int;

			// Step 1A. Curves #1. Apply bluish color cast. Red Curve: 3 points.
			green=null; // Leave green channel unmodified for Step 1.
			for (i=0; i < 256; i++){
				red[  i]=curves1Poly.getVal(i) << (8*2);
			}
			// Step 1B. Curves #1. Apply bluish color cast. Blue Curve: 3 points.
			for (i=0; i < 256; i++){
				blue[ i]=curves2Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);

			// Step 2. Curves #2. Reduce contrast, remap black and white points. RGB Curve: 2 points.
			green = []; // Allocate a new green array (it was null above)
			for (i=0; i < 256; i++){
				red[  i]=curves3Poly.getVal(i) << (8*2);
				green[i]=curves3Poly.getVal(i) << 8;
				blue[ i]=curves3Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);
			
			// Step 3. Saturation: -85
			adjustColor = new AdjustColor();
			adjustColor.brightness = 0;     // -100 .. +100
			adjustColor.contrast   = 0;     // -100 .. +100
			adjustColor.saturation = -85;   // -100 .. +100
			adjustColor.hue        = 0;     // -180 .. +180
			combinedFilter = new ColorMatrixFilter( adjustColor.CalculateFinalFlatArray() );
			bitmapData.applyFilter( bitmapData, bitmapData.rect, new Point(0,0),
				combinedFilter );

			// Step 4. Curves #3. RGB Curve: 4 points.
			for (i=0; i < 256; i++){
				red[  i]=curves4Poly.getVal(i) << (8*2);
				green[i]=curves4Poly.getVal(i) << 8;
				blue[ i]=curves4Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);
		}
	}
}