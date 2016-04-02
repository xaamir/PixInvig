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

	public class FadedColorPrint extends FilterBase
	{
		private var curves1Poly:Polynomial;
		private var curves2Poly:Polynomial;
		private var curves3Poly:Polynomial;
		private var curves4Poly:Polynomial;
		private var curves5Poly:Polynomial;
		private var curves6Poly:Polynomial;

		public static const desc:String =
			  "Faded Color Print: This filter remaps the black and white points in an image"
			+ " for an effect similar to a faded old-style color print.";
		public static const label:String="Hint";
		
		override public function getLabel():String{
			return label;
		}
		
		public function FadedColorPrint(){	
		}
				
		override public function prepareFilters():void{			
			// Step 1. Curves #1. Increase brightness. RGB Curve: 3 points.
			curves1Poly = new Polynomial();
			var curves1CoordArr:Array=new Array();
			curves1CoordArr.push(new Coordinate(0,  0));
			curves1CoordArr.push(new Coordinate(119,138));
			curves1CoordArr.push(new Coordinate(255,255));
			curves1Poly.buildEquation(Polynomial.QUAD,curves1CoordArr);
			
			// Step 2. Curves #2. RGB Curve: 4 points, S-curve.
			curves2Poly = new Polynomial();
			var curves2CoordArr:Array=new Array();
			curves2CoordArr.push(new Coordinate(0,  0));
			curves2CoordArr.push(new Coordinate(67, 53));
			curves2CoordArr.push(new Coordinate(189,205));
			curves2CoordArr.push(new Coordinate(255,255));
			curves2Poly.buildEquation(Polynomial.CUBIC,curves2CoordArr);
			
			// Step 3. Curves #3. Remap black and white. RGB Curve: 2 points.
			curves3Poly = new Polynomial();
			var curves3CoordArr:Array=new Array();
			curves3CoordArr.push(new Coordinate(0, 75));
			curves3CoordArr.push(new Coordinate(255,217));
			curves3Poly.buildEquation(Polynomial.LINEAR,curves3CoordArr);
			
			// Step 4A. Curves #4. Apply color adjustments. Red Curve: 3 points.
			curves4Poly = new Polynomial();
			var curves4CoordArr:Array=new Array();
			curves4CoordArr.push(new Coordinate(0, 0));
			curves4CoordArr.push(new Coordinate(155,104));
			curves4CoordArr.push(new Coordinate(255,255));
			curves4Poly.buildEquation(Polynomial.QUAD,curves4CoordArr);
			
			// Step 4B. Curves #4. Apply color adjustments. Green Curve: 3 points.
			curves5Poly = new Polynomial();
			var curves5CoordArr:Array=new Array();
			curves5CoordArr.push(new Coordinate(0, 0));
			curves5CoordArr.push(new Coordinate(100,40));
			curves5CoordArr.push(new Coordinate(255,204));
			curves5Poly.buildEquation(Polynomial.QUAD,curves5CoordArr);
			
			// Step 4C. Curves #4. Apply color adjustments. Blue Curve: 3 points.
			curves6Poly = new Polynomial();
			var curves6CoordArr:Array=new Array();
			curves6CoordArr.push(new Coordinate(0, 0));
			curves6CoordArr.push(new Coordinate(135,108));
			curves6CoordArr.push(new Coordinate(255,255));
			curves6Poly.buildEquation(Polynomial.QUAD,curves6CoordArr);
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


			// Step 1. Curves #1. Increase brightness. RGB Curve: 3 points.
			for (i=0; i < 256; i++){
				red[  i]=curves1Poly.getVal(i) << (8*2);
				green[i]=curves1Poly.getVal(i) << 8;
				blue[ i]=curves1Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);

			
			// Step 2. Curves #2. RGB Curve: 4 points, S-curve.
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

			
			// Step 4A. Curves #4. Apply color adjustments. Red Curve: 3 points.
			for (i=0; i < 256; i++){
				red[  i]=curves4Poly.getVal(i) << (8*2);
			}
			// Step 4B. Curves #4. Apply color adjustments. Green Curve: 3 points.
			for (i=0; i < 256; i++){
				green[i]=curves5Poly.getVal(i) << 8;
			}
			// Step 4C. Curves #4. Apply color adjustments. Blue Curve: 3 points.
			for (i=0; i < 256; i++){
				blue[ i]=curves6Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);
		}
	}
}