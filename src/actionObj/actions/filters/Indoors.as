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
	
	public class Indoors extends FilterBase
	{
		private var curves1Poly:Polynomial;
		private var curves2Poly:Polynomial;
		private var curves3Poly:Polynomial;
		private var curves4Poly:Polynomial;
		private var curves5Poly:Polynomial;
		private var curves6Poly:Polynomial;
		
		public static const desc:String =
			"";
		
		public static const label:String="Ray";
		
		override public function getLabel():String{
			return label;
		}
				
		public function Indoors(){
			
		}
				
		override public function prepareFilters():void{
			curves1Poly = new Polynomial();
			
			var curves1CoordArr:Array=new Array();
			curves1CoordArr.push(new Coordinate(26, 33));
			//curves1CoordArr.push(new Coordinate(41, 26));
			curves1CoordArr.push(new Coordinate(117,160));
			curves1CoordArr.push(new Coordinate(230,230));
			curves1Poly.buildEquation(Polynomial.QUAD,curves1CoordArr); 			
			
			// Step 2 rgb.
			curves2Poly = new Polynomial();
			var curves2CoordArr:Array=new Array();
			curves2CoordArr.push(new Coordinate(0, 0));
			curves2CoordArr.push(new Coordinate(61,94));
			curves2CoordArr.push(new Coordinate(160,201));
			curves2CoordArr.push(new Coordinate(255,255));
			curves2Poly.buildEquation(Polynomial.CUBIC,curves2CoordArr); 
			
			//step 3a: rgb
			curves3Poly = new Polynomial();
			var curves3CoordArr:Array=new Array();
			curves3CoordArr.push(new Coordinate(0, 0));
			curves3CoordArr.push(new Coordinate(133,118));
			curves3CoordArr.push(new Coordinate(255,255));
			curves3Poly.buildEquation(Polynomial.QUAD,curves3CoordArr); 		
			
			// Step 3b red.
			curves4Poly = new Polynomial();
			var curves4CoordArr:Array=new Array();
			curves4CoordArr.push(new Coordinate(20, 56)); 
			curves4CoordArr.push(new Coordinate(255,255));
			curves4Poly.buildEquation(Polynomial.LINEAR,curves4CoordArr); 
			// Step 3c blue.
			curves5Poly = new Polynomial();
			var curves5CoordArr:Array=new Array(); 
			curves5CoordArr.push(new Coordinate(0, 0));
			curves5CoordArr.push(new Coordinate(243,211));
			curves5Poly.buildEquation(Polynomial.LINEAR,curves5CoordArr); 			

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
			
			// Step 2. rgb curve.
			for (i=0; i < 256; i++){
				red[  i]=curves2Poly.getVal(i) << (8*2);
				green[i]=curves2Poly.getVal(i) << 8;
				blue[ i]=curves2Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);

			// Step 3. rgb curve.
			for (i=0; i < 256; i++){
				red[  i]=curves3Poly.getVal(i) << (8*2);
				green[i]=curves3Poly.getVal(i) << 8;
				blue[ i]=curves3Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);

			// Step 3b. red curve 
			green=null; 
			for (i=0; i < 256; i++){
				red[  i]=curves4Poly.getVal(i) << (8*2);
			}
			// Step 3c. blue curve 
			for (i=0; i < 256; i++){
				blue[  i]=curves5Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);
		}
	}
}