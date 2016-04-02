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
	
	public class BlueShadows  extends FilterBase
	{
		private var curves1Poly:Polynomial;
		private var curves2Poly:Polynomial;
		private var curves3Poly:Polynomial;
		private var curves4Poly:Polynomial;
		private var curves5Poly:Polynomial;
		private var curves6Poly:Polynomial;
		
		public static const desc:String =
			"";
		
		public static const label:String="Shadows2";
		
		override public function getLabel():String{
			return label;
		}
		
		
		public function BlueShadows(){
			
		}
		
		override public  function prepareFilters():void{
			curves1Poly = new Polynomial();
			var curves1CoordArr:Array=new Array();
			curves1CoordArr.push(new Coordinate(0, 0));
			curves1CoordArr.push(new Coordinate(74, 59));
			curves1CoordArr.push(new Coordinate(174,189));
			curves1CoordArr.push(new Coordinate(255,255));
			curves1Poly.buildEquation(Polynomial.CUBIC,curves1CoordArr); 			

			//step 2a: blue
			curves2Poly = new Polynomial();
			var curves2CoordArr:Array=new Array();
			curves2CoordArr.push(new Coordinate(0, 58));
			curves2CoordArr.push(new Coordinate(122,132));
			curves2CoordArr.push(new Coordinate(255,255));
			curves2Poly.buildEquation(Polynomial.QUAD,curves2CoordArr); 
			
			// Step 2b rgb.
			curves3Poly = new Polynomial();
			var curves3CoordArr:Array=new Array();
			curves3CoordArr.push(new Coordinate(0, 0));
			curves3CoordArr.push(new Coordinate(122,141));
			curves3CoordArr.push(new Coordinate(255,255));
			curves3Poly.buildEquation(Polynomial.QUAD,curves3CoordArr); 

			// Step 3 rgb.
			curves4Poly = new Polynomial();
			var curves4CoordArr:Array=new Array();
			curves4CoordArr.push(new Coordinate(0, 0));
			curves4CoordArr.push(new Coordinate(118,143));
			curves4CoordArr.push(new Coordinate(255,255));
			curves4Poly.buildEquation(Polynomial.QUAD,curves4CoordArr); 
		
			// Step 4a blue
			curves5Poly = new Polynomial();
			var curves5CoordArr:Array=new Array();
			curves5CoordArr.push(new Coordinate(0, 0));
			curves5CoordArr.push(new Coordinate(255,186));
			curves5Poly.buildEquation(Polynomial.LINEAR,curves5CoordArr); 

			// Step 4b green
			curves6Poly = new Polynomial();
			var curves6CoordArr:Array=new Array();
			curves6CoordArr.push(new Coordinate(0, 0));
			curves6CoordArr.push(new Coordinate(255,220));
			curves6Poly.buildEquation(Polynomial.LINEAR,curves6CoordArr); 

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
			
			// Step 1. rgb curve.
			for (i=0; i < 256; i++){
				red[  i]=curves1Poly.getVal(i) << (8*2);
				green[i]=curves1Poly.getVal(i) << 8;
				blue[ i]=curves1Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);
			
			// Step 2A. blue curve 
			green=null; 
			red=null;
			for (i=0; i < 256; i++){
				blue[  i]=curves2Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);
			// Step 2b. RGB
			red = [];
			green = [];
			for (i=0; i < 256; i++){
				red[  i]=curves3Poly.getVal(i) << (8*2);
				green[i]=curves3Poly.getVal(i) << 8;
				blue[ i]=curves3Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);

			//step 3
			for (i=0; i < 256; i++){
				red[  i]=curves4Poly.getVal(i) << (8*2);
				green[i]=curves4Poly.getVal(i) << 8;
				blue[ i]=curves4Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);
			
			// Step 4A. blue curve 
			red=null;
			for (i=0; i < 256; i++){
				blue[  i]=curves5Poly.getVal(i);
			}
			// Step 4B. green curve 
			red=null;
			for (i=0; i < 256; i++){
				green[i]=curves6Poly.getVal(i) << 8;
			}
			
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);
			
		}
	}
}