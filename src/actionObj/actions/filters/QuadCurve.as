package actionObj.actions.filters
{
	import actionObj.graphics.Coordinate;
	import actionObj.graphics.Polynomial;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import actionObj.actions.IAction;

	public class QuadCurve implements IAction
	{
		private var polynomial:Polynomial;
		private var bitMapData:BitmapData;		
		
		public function QuadCurve(_bitMapData:BitmapData)
		{
			bitMapData=_bitMapData;
			polynomial = new Polynomial();
			var coordArr:Array=new Array();
			var coord1:Coordinate = new Coordinate(0, 0);
			var coord2:Coordinate = new Coordinate(30,72);
			var coord3:Coordinate = new Coordinate(255,255);
			coordArr.push(coord1);
			coordArr.push(coord2);
			coordArr.push(coord3);
			polynomial.buildEquation(Polynomial.QUAD,coordArr); 			
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