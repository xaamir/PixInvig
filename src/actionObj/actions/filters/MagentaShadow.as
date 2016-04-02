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
	
	public class MagentaShadow extends FilterBase
	{
		private var curves1Poly:Polynomial;
		private var curves2Poly:Polynomial;
		private var curves3Poly:Polynomial;
		private var curves4Poly:Polynomial;
		private var curves5Poly:Polynomial;
		private var curves6Poly:Polynomial;		
		private var curves7Poly:Polynomial;
		public static const desc:String ="";		
		public static const label:String="Shadows";
		
		override public function getLabel():String{
			return label;
		}
				
		public function MagentaShadow(){
			
		}
		
		override public function prepareFilters():void{
			// Step 1. Curves #1. increase brightness. RGB Curve: 3 points.
			curves1Poly = new Polynomial();
			var curves1CoordArr:Array=new Array();
			curves1CoordArr.push(new Coordinate(0, 0));
			curves1CoordArr.push(new Coordinate(118,155));
			curves1CoordArr.push(new Coordinate(255,255));
			curves1Poly.buildEquation(Polynomial.QUAD,curves1CoordArr); 			
			
			// Step 2. RGB
			curves2Poly = new Polynomial();
			var curves2CoordArr:Array=new Array();
			curves2CoordArr.push(new Coordinate(26, 0));
			curves2CoordArr.push(new Coordinate(255,243));
			curves2Poly.buildEquation(Polynomial.LINEAR,curves2CoordArr); 
			
			// Step 3a. Green
			curves3Poly = new Polynomial();
			var curves3CoordArr:Array=new Array();
			curves3CoordArr.push(new Coordinate(0, 0));
			curves3CoordArr.push(new Coordinate(137,99));
			curves3CoordArr.push(new Coordinate(255,255));
			curves3Poly.buildEquation(Polynomial.QUAD,curves3CoordArr); 
			
			// Step 3a. Blue
			curves4Poly = new Polynomial();
			var curves4CoordArr:Array=new Array();
			curves4CoordArr.push(new Coordinate(0, 58));
			curves4CoordArr.push(new Coordinate(255,186));
			curves4Poly.buildEquation(Polynomial.LINEAR,curves2CoordArr); 
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
			// Step 2.
			for (i=0; i < 256; i++){
				red[  i]=curves2Poly.getVal(i) << (8*2);
				green[i]=curves2Poly.getVal(i) << 8;
				blue[ i]=curves2Poly.getVal(i);
			}
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);			

			red=null;
			// Step 3
			for (i=0; i < 256; i++){
				green[  i]=curves2Poly.getVal(i) << (8);
			}
			for (i=0; i < 256; i++){
				blue[  i]=curves3Poly.getVal(i);
			}	
			bitmapData.paletteMap(bitmapData,bitmapData.rect,new Point(0,0),red,green,blue,alpha);
		}
	}
}