package actionObj.actions.filters
{
	import actionObj.graphics.Coordinate;
	import actionObj.graphics.Polynomial;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import actionObj.actions.IAction;
	
	public class LineOffSet implements IAction
	{
		private var polynomial:Polynomial;
		private var bitMapData:BitmapData;		
		
		public static const label:String="Line";
		
		public function getLabel():String{
			return label;
		}
		
		public function getBitmapData():BitmapData{
			return bitMapData;
		}
		
		public function LineOffSet(){
			
		}
			
		public function initImage(_bitMapData:BitmapData):void
		{
			bitMapData=_bitMapData;
			polynomial = new Polynomial();
			var coordArr:Array=new Array();
			var coord1:Coordinate = new Coordinate(50, 0);
			var coord2:Coordinate = new Coordinate(200,150);
			coordArr.push(coord1);
			coordArr.push(coord2);
			polynomial.buildEquation(Polynomial.LINEAR,coordArr); 
		}
		
		public function apply():void
		{
			var red: Array = [];
			var green: Array = [];
			var blue: Array = [];
			var alpha:Array = null;
			for (var i:int = 0; i < 256; i++){
				red[i]=polynomial.getVal(i) << (8*2);
				green[i]=polynomial.getVal(i) << 8;
				blue[i]=polynomial.getVal(i);
			}
			bitMapData.paletteMap(bitMapData, bitMapData.rect, new Point(0,0), red, green, blue, alpha);
		}
	}
}