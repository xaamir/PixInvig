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

	public class YellowBlueSplitToning extends FilterBase
	{
		private var curves1Poly:Polynomial;
		private var curves2Poly:Polynomial;
		private var curves3Poly:Polynomial;
		private var curves4Poly:Polynomial;
		private var curves5Poly:Polynomial;
		private var curves6Poly:Polynomial;
		private var curves7Poly:Polynomial;

		public static const desc:String =
			  "Yellow and Blue Split-Toning: This filter creates an image with a yellow color cast"
			+ " in the highlights and a blue tone in the shadows. Slight amount of saturation remains.";
		
		public static const label:String="High";

		override public function getLabel():String{
			return label;
		}
				
		public function YellowBlueSplitToning(){
			
		}
		
		override public function prepareFilters():void{
			
			// Step 1. Curves #1. RGB Curve: 4 points, S-curve.
			curves1Poly = new Polynomial();
			var curves1CoordArr:Array=new Array();
			curves1CoordArr.push(new Coordinate(0,  0));
			curves1CoordArr.push(new Coordinate(67, 53));
			curves1CoordArr.push(new Coordinate(189,205));
			curves1CoordArr.push(new Coordinate(255,255));
			curves1Poly.buildEquation(Polynomial.CUBIC,curves1CoordArr);
			
			// Step 2. Curves #2. Increase brightness. RGB Curve: 3 points.
			curves2Poly = new Polynomial();
			var curves2CoordArr:Array=new Array();
			curves2CoordArr.push(new Coordinate(0, 0));
			curves2CoordArr.push(new Coordinate(119,138));
			curves2CoordArr.push(new Coordinate(255,255));
			curves2Poly.buildEquation(Polynomial.QUAD,curves2CoordArr);
			
			// Step 3. Curves #3. Remap black and white. RGB Curve: 2 points.
			curves3Poly = new Polynomial();
			var curves3CoordArr:Array=new Array();
			curves3CoordArr.push(new Coordinate(0, 13));
			curves3CoordArr.push(new Coordinate(255,239));
			curves3Poly.buildEquation(Polynomial.LINEAR,curves3CoordArr);
			
			// Step 4. Curves #4. Add yellow and blue. Blue Curve: 2 points.
			curves4Poly = new Polynomial();
			var curves4CoordArr:Array=new Array();
			curves4CoordArr.push(new Coordinate(0, 33));
			curves4CoordArr.push(new Coordinate(255,193));
			curves4Poly.buildEquation(Polynomial.LINEAR,curves4CoordArr);
			
			// Step 5A. Curves #5. Apply color adjustments. Red Curve: 2 points.
			curves5Poly = new Polynomial();
			var curves5CoordArr:Array=new Array();
			curves5CoordArr.push(new Coordinate(0, 0));
			curves5CoordArr.push(new Coordinate(244,255));
			curves5Poly.buildEquation(Polynomial.LINEAR,curves5CoordArr);
			
			// Step 5B. Curves #5. Apply color adjustments. Green Curve: 2 points.
			curves6Poly = new Polynomial();
			var curves6CoordArr:Array=new Array();
			curves6CoordArr.push(new Coordinate(0, 0));
			curves6CoordArr.push(new Coordinate(187,255));
			curves6Poly.buildEquation(Polynomial.LINEAR,curves6CoordArr);
			
			// Step 5C. Curves #5. Apply color adjustments. Blue Curve: 4 points.
			curves7Poly = new Polynomial();
			var curves7CoordArr:Array=new Array();
			curves7CoordArr.push(new Coordinate(0, 0));
			curves7CoordArr.push(new Coordinate(255, 255));
			curves7CoordArr.push(new Coordinate(9,59));
			curves7CoordArr.push(new Coordinate(255, 255));
			curves7Poly.buildEquation(Polynomial.CUBIC,curves7CoordArr);
			
			// Step 6. Saturation: +47. ColorMatrixFilter used here, Polynomial not needed for this step.
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

			// Step 1. Curves #1. RGB Curve: 4 points, S-curve.
			for (i=0; i < 256; i++){
				red[  i]=curves1Poly.getVal(i) << (8*2);
				green[i]=curves1Poly.getVal(i) << 8;
				blue[ i]=curves1Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);


			// Step 2. Curves #2. Increase brightness. RGB Curve: 3 points.
			for (i=0; i < 256; i++){
				red[  i]=curves2Poly.getVal(i) << (8*2);
				green[i]=curves2Poly.getVal(i) << 8;
				blue[ i]=curves2Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);


			// Step 3. Curves #3. Remap black and white. RGB Curve: 2 points.
			for (i=0; i < 256; i++){
				red[  i]=curves3Poly.getVal(i) << (8*2);
				green[i]=curves3Poly.getVal(i) << 8;
				blue[ i]=curves3Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);


			// Step 4. Curves #4. Add yellow and blue. Blue Curve: 2 points.
			red=null;   // Leave red   channel unmodified for Step 4.
			green=null; // Leave green channel unmodified for Step 4.
			for (i=0; i < 256; i++){
				blue[ i]=curves4Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);


			// Step 5A. Curves #5. Add color adjustments. Red Curve: 2 points.
			red   = []; // Allocate a new red   array (it was null above)
			green = []; // Allocate a new green array (it was null above)
			for (i=0; i < 256; i++){
				red[  i]=curves5Poly.getVal(i) << (8*2);
			}
			// Step 5B. Curves #5. Add color adjustments. Green Curve: 2 points.
			for (i=0; i < 256; i++){
				green[i]=curves6Poly.getVal(i) << 8;
			}
			// Step 5C. Curves #5. Add color adjustments. Blue Curve: 4 points.
			for (i=0; i < 256; i++){
				blue[ i]=curves7Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);


			// Step 6. Saturation: +47. ColorMatrixFilter used here, Polynomial not needed for this step.
			adjustColor = new AdjustColor();
			adjustColor.brightness = 0;     // -100 .. +100
			adjustColor.contrast   = 0;     // -100 .. +100
			adjustColor.saturation = 47;    // -100 .. +100
			adjustColor.hue        = 0;     // -180 .. +180
			combinedFilter = new ColorMatrixFilter( adjustColor.CalculateFinalFlatArray() );
			bitmapData.applyFilter( bitmapData, bitmapData.rect, new Point(0,0),
				combinedFilter );

		}
	}
}