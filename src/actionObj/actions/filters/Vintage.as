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
	
	public class Vintage extends FilterBase
	{
		private var curves1Poly:Polynomial;
		private var curves2Poly:Polynomial;
		private var curves3Poly:Polynomial;
		private var curves4Poly:Polynomial;
		private var curves5Poly:Polynomial;
		private var curves6Poly:Polynomial;		
		private var curves7Poly:Polynomial;
		public static const desc:String ="";		
		public static const label:String="Recall";

		override public function getLabel():String{
			return label;
		}
				
		public function Vintage(){
			
		}
				
		override public function prepareFilters():void{
			// Step 1. Curves #1. increase brightness. RGB Curve: 3 points.
			curves1Poly = new Polynomial();
			var curves1CoordArr:Array=new Array();
			curves1CoordArr.push(new Coordinate(0, 0));
			curves1CoordArr.push(new Coordinate(117,140));
			curves1CoordArr.push(new Coordinate(255,255));
			curves1Poly.buildEquation(Polynomial.QUAD,curves1CoordArr); 			
			
			// Step 2a. Blue
			curves2Poly = new Polynomial();
			var curves2CoordArr:Array=new Array();
			curves2CoordArr.push(new Coordinate(26, 0));
			curves2CoordArr.push(new Coordinate(255,222));
			curves2Poly.buildEquation(Polynomial.LINEAR,curves2CoordArr); 
			
			// Step 2b. RGB Curve: 4 points.
			curves3Poly = new Polynomial();
			var curves3CoordArr:Array=new Array();
			curves3CoordArr.push(new Coordinate(28, 0));
			curves3CoordArr.push(new Coordinate(71,40));
			curves3CoordArr.push(new Coordinate(184,217));
			curves3CoordArr.push(new Coordinate(255,255));
			curves3Poly.buildEquation(Polynomial.CUBIC,curves3CoordArr); 			
			
			// Step 3a. Red
			curves4Poly = new Polynomial();
			var curves4CoordArr:Array=new Array();
			curves4CoordArr.push(new Coordinate(0, 0));
			curves4CoordArr.push(new Coordinate(155,104));
			curves4CoordArr.push(new Coordinate(255,255));
			curves4Poly.buildEquation(Polynomial.QUAD,curves4CoordArr); 			

			// Step 3b. Green
			curves5Poly = new Polynomial();
			var curves5CoordArr:Array=new Array();
			curves5CoordArr.push(new Coordinate(99, 41));
			curves5CoordArr.push(new Coordinate(255,203));
			curves5Poly.buildEquation(Polynomial.LINEAR,curves5CoordArr); 
			
			// Step 3c. Blue
			curves6Poly = new Polynomial();
			var curves6CoordArr:Array=new Array();
			curves6CoordArr.push(new Coordinate(0, 58));
			curves6CoordArr.push(new Coordinate(135,207));
			curves6CoordArr.push(new Coordinate(255,255));
			curves6Poly.buildEquation(Polynomial.QUAD,curves6CoordArr); 

			// Step 3d. RBG
			curves7Poly = new Polynomial();
			var curves7CoordArr:Array=new Array();
			curves7CoordArr.push(new Coordinate(0, 55));//Karim's design says 75, but we are reducing the contrast here
			curves7CoordArr.push(new Coordinate(255,217));
			curves7Poly.buildEquation(Polynomial.LINEAR,curves7CoordArr); 
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

			red=null; green = null;
			// Step 2a
			for (i=0; i < 256; i++){
				blue[  i]=curves2Poly.getVal(i);
			}	
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);

			
			// Step 2b.
			red = [];
			green = [];
			for (i=0; i < 256; i++){
				red[  i]=curves3Poly.getVal(i) << (8*2);
				green[i]=curves3Poly.getVal(i) << 8;
				blue[ i]=curves3Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);			
						
			// Step 3a-3c
			for (i=0; i < 256; i++){
				red[  i]=curves4Poly.getVal(i) << (8*2);
			}	
			for (i=0; i < 256; i++){
				green[  i]=curves5Poly.getVal(i) << (8);
			}
			for (i=0; i < 256; i++){
				blue[  i]=curves6Poly.getVal(i);
			}	
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);
			
			// Step 3d. RBG
			for (i=0; i < 256; i++){
				red[  i]=curves7Poly.getVal(i) << (8*2);
				green[i]=curves7Poly.getVal(i) << 8;
				blue[ i]=curves7Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);						
		}
	}
}