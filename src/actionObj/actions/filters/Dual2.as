package actionObj.actions.filters
{
	import actionObj.actions.FilterHelper;
	import actionObj.actions.IAction;
	import actionObj.actions.filters.AdjustColor;
	import actionObj.graphics.Coordinate;
	import actionObj.graphics.Polynomial;
	import actionObj.image.Image_;
	
	import comp.FullImage;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.DisplayObject;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	
	import mx.containers.Canvas;
	import mx.controls.Image;
	
	public class Dual2 extends FilterBase
	{
		private var curves1Poly:Polynomial;
		private var curves2Poly:Polynomial;
		private var curves3Poly:Polynomial;
		private var curves4Poly:Polynomial;
		private var curves5Poly:Polynomial;
		
		public static const desc:String ="";	
		public static const label:String="Dual2";
		
		
		override public function getLabel():String{
			return label;
		}
		
		
		public function Dual2(){
			
		}
		
		override public function prepareFilters():void{
			// Step 1. Curves #1. Apply color adjustments. Red Curve: 3 points.
			curves1Poly = new Polynomial();
			var curves1CoordArr:Array=new Array();
			curves1CoordArr.push(new Coordinate(0, 0));
			curves1CoordArr.push(new Coordinate(137,113));
			curves1CoordArr.push(new Coordinate(255,255));
			curves1Poly.buildEquation(Polynomial.QUAD,curves1CoordArr);
			
			// Step 1. Curves #2. Apply color adjustments. Blue Curve: 3 points.
			curves2Poly = new Polynomial();
			var curves2CoordArr:Array=new Array();
			curves2CoordArr.push(new Coordinate(0, 0));
			curves2CoordArr.push(new Coordinate(123,133));
			curves2CoordArr.push(new Coordinate(255,255));
			curves2Poly.buildEquation(Polynomial.QUAD,curves2CoordArr);
			
			// Step 2. Curves #1. Apply color adjustments. Red Curve: 3 points.
			curves3Poly = new Polynomial();
			var curves3CoordArr:Array=new Array();
			curves3CoordArr.push(new Coordinate(0, 0));
			curves3CoordArr.push(new Coordinate(115,138));
			curves3CoordArr.push(new Coordinate(255,255));
			curves3Poly.buildEquation(Polynomial.QUAD,curves3CoordArr);
			
			// Step 2. Curves #2. Apply color adjustments. Blue Curve: 3 points.
			curves4Poly = new Polynomial();
			var curves4CoordArr:Array=new Array();
			curves4CoordArr.push(new Coordinate(0, 0));
			curves4CoordArr.push(new Coordinate(165,184));
			curves4CoordArr.push(new Coordinate(255,255));
			curves4Poly.buildEquation(Polynomial.QUAD,curves4CoordArr);

			// Step 2. Curves #3. Apply color adjustments. rbg: 4 points.
			curves5Poly = new Polynomial();
			var curves5CoordArr:Array=new Array();
			curves5CoordArr.push(new Coordinate(0, 0));
			curves5CoordArr.push(new Coordinate(67,67));
			curves5CoordArr.push(new Coordinate(118,141));
			curves5CoordArr.push(new Coordinate(255,255));
			curves5Poly.buildEquation(Polynomial.CUBIC,curves5CoordArr);
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

			var origImageData:BitmapData;
			origImageData = new BitmapData(bitmapData.rect.width, bitmapData.rect.height, true, 0xFF000000 ); 
			origImageData.fillRect( bitmapData.rect, 0x00000000 ); // fill with black transparent pixels
			origImageData.copyPixels( bitmapData, bitmapData.rect, new Point( 0, 0 ));
						
			green=null;
			// Step1. Curves #1. Apply color adjustments. Red Curve: 3 points.
			for (i=0; i < 256; i++){
				red[  i]=curves1Poly.getVal(i) << (8*2);
			}
			// Step 1. Curves #2. Apply color adjustments. Blue Curve: 3 points.
			for (i=0; i < 256; i++){
				blue[ i]=curves2Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,null,blue,alpha);
			
			for (i=0; i < 256; i++){
				red[  i]=curves3Poly.getVal(i) << (8*2);
			}
			for (i=0; i < 256; i++){
				blue[ i]=curves4Poly.getVal(i);
			}
			bitmapData.paletteMap( bitmapData,bitmapData.rect,new Point(0,0),red,null,blue,alpha);

			green = [];
			for (i=0; i < 256; i++){
				red[  i]=curves5Poly.getVal(i) << (8*2);
				green[i]=curves5Poly.getVal(i) << 8;
				blue[ i]=curves5Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);


			var maskData:BitmapData  = new BitmapData(bitmapData.rect.width, bitmapData.rect.height, true, 0x00FFFFFF );
			maskData.fillRect(bitmapData.rect, 0xFF000000 ); // fill with black opaque pixels			
			maskData = FilterHelper.createRadialGradient(bitmapData, maskData );
			origImageData.copyChannel( maskData, bitmapData.rect, new Point( 0, 0 ), BitmapDataChannel.RED, BitmapDataChannel.ALPHA ); 
			bitmapData.copyPixels( origImageData, bitmapData.rect, new Point( 0, 0 ),	origImageData, new Point( 0, 0 ), true ); // mergeAlpha=true
		}
	}
}