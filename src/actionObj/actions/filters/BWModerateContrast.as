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

	public class BWModerateContrast  extends FilterBase
	{
		private var curves1Poly:Polynomial;
		private var curves2Poly:Polynomial;
		private var curves3Poly:Polynomial;
		private var curves4Poly:Polynomial;

		public static const desc:String =
			  "Black and White Moderate Contrast: This filter desaturates the image and produces a black and white"
			+ " image with moderate contrast while retaining some tonality in the white and black points.";
		public static const label:String = "Mono";

		public function BWModerateContrast(){
			
		}
						
		override public function getLabel():String{
			return label;
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

			// Step 4. Saturation: -100
			adjustColor = new AdjustColor();
			adjustColor.brightness = 0;     // -100 .. +100
			adjustColor.contrast   = 0;     // -100 .. +100
			adjustColor.saturation = -100;  // -100 .. +100
			adjustColor.hue        = 0;     // -180 .. +180
			combinedFilter = new ColorMatrixFilter( adjustColor.CalculateFinalFlatArray() );
			bitmapData.applyFilter( bitmapData, bitmapData.rect, new Point(0,0),
				combinedFilter );
		}
	}
}