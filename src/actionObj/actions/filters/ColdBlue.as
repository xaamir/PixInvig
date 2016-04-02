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
	
	public class ColdBlue extends FilterBase
	{
		private var curves1Poly:Polynomial;
		private var curves2Poly:Polynomial;
		private var curves3Poly:Polynomial;
		private var curves4Poly:Polynomial;
		private var curves5Poly:Polynomial;
		private var curves6Poly:Polynomial;		
		private var curves7Poly:Polynomial;
		public static const desc:String ="";
		public static const label:String="Norway";		
		
		override public function getLabel():String{
			return label;
		}
				
		public function ColdBlue(){
			
		}
		
		override public function prepareFilters():void{
			// Step 1. Curves #1. increase brightness. RGB Curve: 3 points.
			curves1Poly = new Polynomial();
			var curves1CoordArr:Array=new Array();
			curves1CoordArr.push(new Coordinate(0, 0));
			curves1CoordArr.push(new Coordinate(114,146));
			curves1CoordArr.push(new Coordinate(255,255));
			curves1Poly.buildEquation(Polynomial.QUAD,curves1CoordArr); 			
			
			// Step 2A. Curves #2. Red Curve: 3 points.
			curves2Poly = new Polynomial();
			var curves2CoordArr:Array=new Array();
			curves2CoordArr.push(new Coordinate(0, 0));
			curves2CoordArr.push(new Coordinate(133,109));
			curves2CoordArr.push(new Coordinate(255,255));
			curves2Poly.buildEquation(Polynomial.QUAD,curves2CoordArr); 
			
			// Step 2B. Curves #2. Blue Curve: 3 points.
			curves3Poly = new Polynomial();
			var curves3CoordArr:Array=new Array();
			curves3CoordArr.push(new Coordinate(0, 0));
			curves3CoordArr.push(new Coordinate(64,104));
			curves3CoordArr.push(new Coordinate(255,255));
			curves3Poly.buildEquation(Polynomial.QUAD,curves3CoordArr); 
			
			// Step 2C. Curves #2. RGB Curve: 2 points.
			curves4Poly = new Polynomial();
			var curves4CoordArr:Array=new Array();
			curves4CoordArr.push(new Coordinate(0, 0));
			curves4CoordArr.push(new Coordinate(255,240));
			curves4Poly.buildEquation(Polynomial.LINEAR,curves4CoordArr); 
			
			// Step 3A. Curves #3. Red Curve: 3 points.
			curves5Poly = new Polynomial();
			var curves5CoordArr:Array=new Array();
			curves5CoordArr.push(new Coordinate(0, 0));
			curves5CoordArr.push(new Coordinate(130,114));
			curves5CoordArr.push(new Coordinate(255,255));
			curves5Poly.buildEquation(Polynomial.QUAD,curves5CoordArr); 
			
			// Step 3B. Curves #3. Blue Curve: 4 points.
			curves6Poly = new Polynomial();
			var curves6CoordArr:Array=new Array();
			curves6CoordArr.push(new Coordinate(0, 51));
			curves6CoordArr.push(new Coordinate(155,104));
			curves6CoordArr.push(new Coordinate(209,212));
			curves6CoordArr.push(new Coordinate(255,255));
			curves6Poly.buildEquation(Polynomial.CUBIC,curves6CoordArr); 
			
			// Step 3C. Curves #2. RGB Curve: 4 points.
			curves7Poly = new Polynomial();
			var curves7CoordArr:Array=new Array();
			curves7CoordArr.push(new Coordinate(0, 0));
			curves7CoordArr.push(new Coordinate(76,67));
			curves7CoordArr.push(new Coordinate(163,174));
			curves7CoordArr.push(new Coordinate(255,255));
			curves7Poly.buildEquation(Polynomial.CUBIC,curves7CoordArr); 
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
			
			
			// Step 1. Curves #1. increase brightness. RGB Curve: 3 points.
			for (i=0; i < 256; i++){
				red[  i]=curves1Poly.getVal(i) << (8*2);
				green[i]=curves1Poly.getVal(i) << 8;
				blue[ i]=curves1Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);			
			green=null;
			// Step 2A. Curves #2. Red Curve: 3 points.
			for (i=0; i < 256; i++){
				red[  i]=curves2Poly.getVal(i) << (8*2);
			}
			// Step 2B. Curves #2. Blue Curve: 3 points.
			for (i=0; i < 256; i++){
				blue[  i]=curves3Poly.getVal(i);
			}	
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);
			
			green=new Array();
			// Step 2C. Curves #2. RGB Curve: 2 points.
			for (i=0; i < 256; i++){
				red[  i]=curves4Poly.getVal(i) << (8*2);
				green[i]=curves4Poly.getVal(i) << 8;
				blue[ i]=curves4Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);
			
			// Step 3A. Curves #3. Red Curve: 3 points.
			green=null;
			for (i=0; i < 256; i++){
				red[  i]=curves5Poly.getVal(i) << (8*2);
			}
			// Step 3B. Curves #3. Blue Curve: 4 points.
			for (i=0; i < 256; i++){
				blue[  i]=curves6Poly.getVal(i);
			}	
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);
			// Step 3C. Curves #2. RGB Curve: 4 points.
			green=new Array();
			for (i=0; i < 256; i++){
				red[  i]=curves7Poly.getVal(i) << (8*2);
				green[i]=curves7Poly.getVal(i) << 8;
				blue[ i]=curves7Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);		
		}
	}
}