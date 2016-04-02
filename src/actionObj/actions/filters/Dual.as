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
	
	public class Dual extends FilterBase
	{
		private var curves1Poly:Polynomial;
		private var curves2Poly:Polynomial;
		private var curves3Poly:Polynomial;
		private var curves4Poly:Polynomial;
		private var curves5Poly:Polynomial;
		
		public static const desc:String ="";	
		public static const label:String="Dual";
		
		
		override public function getLabel():String{
			return label;
		}
				
		public function Dual(){
			
		}
				
		override public function prepareFilters():void{
			// Steps 1-3: Darken using curves
			
			// Step 1. Curves #1. Apply color adjustments. RGB Curve: 3 points.
			curves1Poly = new Polynomial();
			var curves1CoordArr:Array=new Array();
			curves1CoordArr.push(new Coordinate(0,  0));
			curves1CoordArr.push(new Coordinate(140,110));
			curves1CoordArr.push(new Coordinate(255,255));
			curves1Poly.buildEquation(Polynomial.QUAD,curves1CoordArr);
			
			// Step 2. Curves #2. Apply color adjustments. Red Curve: 3 points.
			curves2Poly = new Polynomial();
			var curves2CoordArr:Array=new Array();
			curves2CoordArr.push(new Coordinate(0, 0));
			curves2CoordArr.push(new Coordinate(132,106));
			curves2CoordArr.push(new Coordinate(255,255));
			curves2Poly.buildEquation(Polynomial.QUAD,curves2CoordArr);
			
			// Step 3. Curves #3. Apply color adjustments. Blue Curve: 3 points.
			curves3Poly = new Polynomial();
			var curves3CoordArr:Array=new Array();
			curves3CoordArr.push(new Coordinate(0, 0));
			curves3CoordArr.push(new Coordinate(107,148));
			curves3CoordArr.push(new Coordinate(255,255));
			curves3Poly.buildEquation(Polynomial.QUAD,curves3CoordArr);
			
			
			// Steps 4-5: Apply these next 2 "Focus" Curves to a copy of the image.
			
			// Step 4. Curves #4. Apply color adjustments. Red Curve: 3 points.
			curves4Poly = new Polynomial();
			var curves4CoordArr:Array=new Array();
			curves4CoordArr.push(new Coordinate(0, 0));
			curves4CoordArr.push(new Coordinate(107,158));
			curves4CoordArr.push(new Coordinate(255,255));
			curves4Poly.buildEquation(Polynomial.QUAD,curves4CoordArr);
			
			// Step 5. Curves #5. Apply color adjustments. Blue Curve: 3 points.
			curves5Poly = new Polynomial();
			var curves5CoordArr:Array=new Array();
			curves5CoordArr.push(new Coordinate(0, 0));
			curves5CoordArr.push(new Coordinate(152,82));
			curves5CoordArr.push(new Coordinate(255,255));
			curves5Poly.buildEquation(Polynomial.QUAD,curves5CoordArr);
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
			
			// Step 1. Curves #1. Apply color adjustments. RGB Curve: 3 points.
			for (i=0; i < 256; i++){
				red[  i]=curves1Poly.getVal(i) << (8*2);
				green[i]=curves1Poly.getVal(i) << 8;
				blue[ i]=curves1Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);
			
			green=null;
			// Step 2. Curves #2. Apply color adjustments. Red Curve: 3 points.
			for (i=0; i < 256; i++){
				red[  i]=curves2Poly.getVal(i) << (8*2);
			}
			// Step 3. Curves #3. Apply color adjustments. Blue Curve: 3 points.
			for (i=0; i < 256; i++){
				blue[ i]=curves3Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,null,blue,alpha);
			
			
			// Steps 4-5: Apply these next 2 "Focus" Curves to a copy of the image.
			
			// Step 4. Curves #4. Apply color adjustments. Red Curve: 3 points.
			for (i=0; i < 256; i++){
				red[  i]=curves2Poly.getVal(i) << (8*2);
			}
			// Step 5. Curves #5. Apply color adjustments. Blue Curve: 3 points.
			for (i=0; i < 256; i++){
				blue[ i]=curves3Poly.getVal(i);
			}
			// Apply steps 4, 5 to copy of original image for "warmed" image.
			bitmapData.paletteMap( bitmapData,bitmapData.rect,new Point(0,0),red,null,blue,alpha);
			
			var focusImageData:BitmapData;
			focusImageData = new BitmapData(bitmapData.rect.width, bitmapData.rect.height, true, 0xFF000000 ); 
			focusImageData.fillRect( bitmapData.rect, 0x00000000 ); // fill with black transparent pixels
			focusImageData.copyPixels( bitmapData, bitmapData.rect, new Point( 0, 0 ));
			
			var maskData:BitmapData  = new BitmapData(bitmapData.rect.width, bitmapData.rect.height, true, 0x00FFFFFF );
			maskData.fillRect(bitmapData.rect, 0xFF000000 ); // fill with black opaque pixels						
			maskData = FilterHelper.createRadialGradient(bitmapData, maskData );
			focusImageData.copyChannel( maskData, bitmapData.rect, new Point( 0, 0 ), BitmapDataChannel.RED, BitmapDataChannel.ALPHA ); 
			bitmapData.copyPixels( focusImageData, bitmapData.rect, new Point( 0, 0 ),	focusImageData, new Point( 0, 0 ), true ); // mergeAlpha=true
		}
	}
}