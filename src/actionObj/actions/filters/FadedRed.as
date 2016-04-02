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
	
	public class FadedRed extends FilterBase
	{
		private var curves1Poly:Polynomial;
		private var curves2Poly:Polynomial;
		private var curves3Poly:Polynomial;
		private var curves4Poly:Polynomial;
		private var curves5Poly:Polynomial;
		private var curves6Poly:Polynomial;
		private var curves7Poly:Polynomial;
		
		public static const desc:String =
			"";
		
		public static const label:String="Relive";
		
		override public function getLabel():String{
			return label;
		}
				
		public function FadedRed(){
			
		}
				
		override public function prepareFilters():void{
			// Step 1. Curves #1. Red Curve
			curves1Poly = new Polynomial();
			var curves1CoordArr:Array=new Array();
			curves1CoordArr.push(new Coordinate(0,  0));
			curves1CoordArr.push(new Coordinate(111, 166));
			curves1CoordArr.push(new Coordinate(255,255));
			curves1Poly.buildEquation(Polynomial.QUAD,curves1CoordArr);
			
			// Step 2. Curves #2. Increase brightness. RGB Curve: 3 points.
			curves2Poly = new Polynomial();
			var curves2CoordArr:Array=new Array();
			curves2CoordArr.push(new Coordinate(0, 73));
			curves2CoordArr.push(new Coordinate(111,180));
			curves2CoordArr.push(new Coordinate(255,215));
			curves2Poly.buildEquation(Polynomial.QUAD,curves2CoordArr);
					
			// Step 3. deSaturation: -57. ColorMatrixFilter used here, Polynomial not needed for this step.
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
			
			// Step 1. Curves #2. Red curve.
			blue=null;  
			green=null; 
			for (i=0; i < 256; i++){
				red[  i]=curves1Poly.getVal(i) << (8*2);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);

			// Step 2. Curves #1. RGB Curve
			green = [];
			blue = [];
			for (i=0; i < 256; i++){
				red[  i]=curves2Poly.getVal(i) << (8*2);
				green[i]=curves2Poly.getVal(i) << 8;
				blue[ i]=curves2Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);
			
			// Step 3. Saturation: -57. ColorMatrixFilter used here, Polynomial not needed for this step.
			adjustColor = new AdjustColor();
			adjustColor.brightness = 0;     // -100 .. +100
			adjustColor.contrast   = 0;     // -100 .. +100
			adjustColor.saturation = -57;    // -100 .. +100
			adjustColor.hue        = 0;     // -180 .. +180
			combinedFilter = new ColorMatrixFilter( adjustColor.CalculateFinalFlatArray() );
			bitmapData.applyFilter( bitmapData, bitmapData.rect, new Point(0,0),
				combinedFilter );
			
		}
	}
}