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
	
	public class Highlights extends FilterBase
	{
		private var curves1Poly:Polynomial;
		private var curves2Poly:Polynomial;
		private var curves3Poly:Polynomial;
		private var curves4Poly:Polynomial;
		
		public static const desc:String ="";
		public static const label:String="Fly";
		
		override public function getLabel():String{
			return label;
		}
		
		
		public function Highlights(){
			
		}
				
		override public function prepareFilters():void{
			// Step 1. Curves #1. RBG Curve: 3 points.
			curves1Poly = new Polynomial();
			var curves1CoordArr:Array=new Array();
			curves1CoordArr.push(new Coordinate(20, 0));
			curves1CoordArr.push(new Coordinate(120, 168));
			curves1CoordArr.push(new Coordinate(255,240));
			curves1Poly.buildEquation(Polynomial.QUAD,curves1CoordArr);
			
			// Step 2a. Curves #2. Red Curve.
			curves2Poly = new Polynomial();
			var curves2CoordArr:Array=new Array();
			curves2CoordArr.push(new Coordinate(0, 0));
			curves2CoordArr.push(new Coordinate(113,138));
			curves2CoordArr.push(new Coordinate(255,255));
			curves2Poly.buildEquation(Polynomial.QUAD,curves2CoordArr);
			
			// Step 2b. Curves #2. Blue.
			curves3Poly = new Polynomial();
			var curves3CoordArr:Array=new Array();
			curves3CoordArr.push(new Coordinate(0, 0));
			curves3CoordArr.push(new Coordinate(162,80));
			curves3CoordArr.push(new Coordinate(255,215));
			curves3Poly.buildEquation(Polynomial.QUAD,curves3CoordArr);

			// Step 2c. Curves #2. RBG.
			curves4Poly = new Polynomial();
			var curves4CoordArr:Array=new Array();
			curves4CoordArr.push(new Coordinate(0, 12));
			curves4CoordArr.push(new Coordinate(120,129));
			curves4CoordArr.push(new Coordinate(255,182));
			curves4Poly.buildEquation(Polynomial.QUAD,curves4CoordArr);			
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

			// Step 1. Curves #1. RGB Curve.
			for (i=0; i < 256; i++){
				red[  i]=curves1Poly.getVal(i) << (8*2);
				green[i]=curves1Poly.getVal(i) << 8;
				blue[ i]=curves1Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);
			
			// Step 2A. Curves #2. Red Curve:.
			green=null; // Leave green channel unmodified for Step 2.
			for (i=0; i < 256; i++){
				red[  i]=curves2Poly.getVal(i) << (8*2);
			}
			// Step 2B. Curves #2. Blue Curve: 3 points.
			for (i=0; i < 256; i++){
				blue[ i]=curves3Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);
			green = []; // Allocate a new green array (it was null above)
			// Step 2c. Curves #2. RGB Curve.
			for (i=0; i < 256; i++){
				red[  i]=curves1Poly.getVal(i) << (8*2);
				green[i]=curves1Poly.getVal(i) << 8;
				blue[ i]=curves1Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);
		}
	}
}