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

	public class SepiaHighContrast extends FilterBase
	{
		private var curves1Poly:Polynomial;
		private var curves2Poly:Polynomial;
		private var curves3Poly:Polynomial;
		private var canvas_:Canvas;
	
		public static const desc:String =
			"Sepia High Contrast: This filter almost desaturates the images and adds a sepia tint to it."
			+ " Contrast is also heightened for a grungy, bleach bypass look.";

		public static const label:String="Grunge";
		
		override public function getLabel():String{
			return label;
		}

		
		public function SepiaHighContrast(){
			
		}
		
		
		override public function prepareFilters():void{
			// Step 1. Curves #1. Increase contrast. RGB Curve: 4 points.
			curves1Poly = new Polynomial();
			var curves1CoordArr:Array=new Array();
			curves1CoordArr.push(new Coordinate(10, 0));
			curves1CoordArr.push(new Coordinate(61,37));
			curves1CoordArr.push(new Coordinate(192,216));
			curves1CoordArr.push(new Coordinate(255,248));
			curves1Poly.buildEquation(Polynomial.CUBIC,curves1CoordArr); 			
			
			// Step 2. Saturation: -85. ColorMatrixFilter used here, Polynomial not needed for this step.
			
			// Step 3A. Curves #2. Apply sepia color cast. Red Curve: 3 points.
			curves2Poly = new Polynomial();
			var curves2CoordArr:Array=new Array();
			curves2CoordArr.push(new Coordinate(0, 0));
			curves2CoordArr.push(new Coordinate(118,133));
			curves2CoordArr.push(new Coordinate(255,255));
			curves2Poly.buildEquation(Polynomial.QUAD,curves2CoordArr); 
			
			// Step 3B. Curves #2. Apply sepia color cast. Blue Curve: 3 points.
			curves3Poly = new Polynomial();
			var curves3CoordArr:Array=new Array();
			curves3CoordArr.push(new Coordinate(0, 0));
			curves3CoordArr.push(new Coordinate(138,113));
			curves3CoordArr.push(new Coordinate(255,255));
			curves3Poly.buildEquation(Polynomial.QUAD,curves3CoordArr); 
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
		
			// Step 1. Curves #1. Increase contrast. RGB Curve: 4 points.
			for (i=0; i < 256; i++){
				red[  i]=curves1Poly.getVal(i) << (8*2);
				green[i]=curves1Poly.getVal(i) << 8;
				blue[ i]=curves1Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);

			// Step 2. Saturation: -85
			adjustColor = new AdjustColor();
			adjustColor.brightness = 0;     // -100 .. +100
			adjustColor.contrast   = 0;     // -100 .. +100
			adjustColor.saturation = -85;   // -100 .. +100
			adjustColor.hue        = 0;     // -180 .. +180
			combinedFilter = new ColorMatrixFilter( adjustColor.CalculateFinalFlatArray() );
			bitmapData.applyFilter( bitmapData, bitmapData.rect, new Point(0,0),
				combinedFilter );

			// Step 3A. Curves #2. Apply sepia color cast. Red Curve: 3 points.
			green=null; // Leave green channel unmodified for Step 3.
			for (i=0; i < 256; i++){
				red[  i]=curves2Poly.getVal(i) << (8*2);
			}
			// Step 3B. Curves #2. Apply sepia color cast. Blue Curve: 3 points.
			for (i=0; i < 256; i++){
				blue[ i]=curves3Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);
		}
	}
}