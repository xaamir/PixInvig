package actionObj.graphics
{
	import mx.collections.ArrayList;

	public class Polynomial
	{
		public static const LINEAR:int=0;
		public static const QUAD:int=1;
		public static const CUBIC:int=2;
		public static const QUART:int=3;
	
		private var a:Number=0;
		private var b:Number=0;
		private var c:Number=0;
		private var d:Number=0;
		private var e:Number=0;
		private var polType:int=0;
		private var lowLimit:int=0;
		private var highLimit:int=255;
		
		
		public function Polynomial(){
		}
		
		public function getVal(x:int):int{
			var y:Number=-9999;
			switch (polType){
				case LINEAR:
					y = a*x + b;
					break;
				case QUAD:
					var y1:Number =a*Math.pow(x,2);
					var y2:Number =b*x;
					y = y1 + y2 + c;
					break;
				case CUBIC:
					y = a*Math.pow(x,3) + b*Math.pow(x,2) + c*x +d;
					break;
				case QUART:
					y = a*Math.pow(x,4) + b*Math.pow(x,3) + c*Math.pow(x,2) + d*x + e;
					break;
				default:
					break;
			}
			if(y < lowLimit){
				y=lowLimit;
			}
			if(y > highLimit){
				y=highLimit;
			}
			y=y>0?y:0;
			y=y>255?255:y;
			return y;
		}
		
		public function findMinY(coordArr:Array):int{
			var sortedArr:Array = coordArr;
			sortedArr.sortOn("x", Array.NUMERIC);
			return sortedArr[0].y;
		}
		
		public function findMaxY(coordArr:Array):int{
			var sortedArr:Array = coordArr;
			sortedArr.sortOn("x", Array.NUMERIC|Array.DESCENDING);
			return sortedArr[0].y;			
		}

		public function buildEquation(degree:int, coordArr:Array):void{
			var coord1:Coordinate, coord2:Coordinate, coord3:Coordinate, coord4:Coordinate, coord5:Coordinate;
			var x1:int, x2:int, x3:int, x4:int, x5:int, y1:int, y2:int, y3:int, y4:int, y5:int;
			switch (degree){
				case LINEAR:
					polType=LINEAR;
					coord1 = coordArr[0];
					coord2 = coordArr[1];
					x1 = coord1.x;
					x2 = coord2.x;
					y1 = coord1.y;
					y2 = coord2.y;
					a= -((-y1 + y2)/(x1-x2));
					b= -((x2*y1 - x1*y2)/(x1-x2));
					if(x1 < x2){
						lowLimit=y1;
						highLimit=y2;
					}
					else{
						lowLimit=y2;
						highLimit=y1;
					}
					break;
				case QUAD:
					polType=QUAD;
					coord1 = coordArr[0];
					coord2 = coordArr[1];
					coord3 = coordArr[2];
					x1 = coord1.x;
					x2 = coord2.x;
					x3 = coord3.x;
					y1 = coord1.y;
					y2 = coord2.y;
					y3 = coord3.y;
					var numerator:Number = -(x2*y1) + x3*y1 + x1*y2 - x3*y2 - x1*y3 + x2*y3;
					var denom:Number = ((x2 - x3)*(Math.pow(x1,2) - x1*x2 - x1*x3 + x2*x3));
					a = -(numerator/denom);
					numerator=Math.pow(x2,2)*y1 - Math.pow(x3,2)*y1 - Math.pow(x1,2)*y2 + Math.pow(x3,2)*y2 + Math.pow(x1,2)*y3 - Math.pow(x2,2)*y3;
					denom=(x1 - x2)*(x1 - x3)*(x2 - x3);
					b = -(numerator/denom);
					numerator=-(Math.pow(x2,2)*x3*y1) + x2*Math.pow(x3,2)*y1 + Math.pow(x1,2)*x3*y2 - x1*Math.pow(x3,2)*y2 - Math.pow(x1,2)*x2*y3 + x1*Math.pow(x2,2)*y3;
					denom=(x1 - x2)*(x1 - x3)*(x2 - x3);
					c = -(numerator/denom);
					lowLimit=findMinY(coordArr);
					highLimit=findMaxY(coordArr);
					break;
				case CUBIC:
					polType=CUBIC;
					coord1 = coordArr[0];
					coord2 = coordArr[1];
					coord3 = coordArr[2];
					coord4 = coordArr[3];
					x1 = coord1.x;
					x2 = coord2.x;
					x3 = coord3.x;
					y1 = coord1.y;
					y2 = coord2.y;
					y3 = coord3.y;
					x4 = coord4.x;
					y4 = coord4.y;
					//-((-(x2^2*x3*y1) + x2*x3^2*y1 + x2^2*x4*y1 - x3^2*x4*y1 
					//- x2*x4^2*y1 + x3*x4^2*y1 + x1^2*x3*y2 - x1*x3^2*y2 
					//- x1^2*x4*y2 + x3^2*x4*y2 + x1*x4^2*y2 - x3*x4^2*y2 
					//- x1^2*x2*y3 + x1*x2^2*y3 + x1^2*x4*y3 -x2^2*x4*y3 
					//- x1*x4^2*y3 + x2*x4^2*y3 + x1^2*x2*y4 - x1*x2^2*y4 
					//- x1^2*x3*y4 + x2^2*x3*y4 + x1*x3^2*y4 - x2*x3^2*y4)/

					//((x1 - x2)*(x3 - x4)*(x1^2 - x1*x3 - x1*x4 + x3*x4)*(x2^2 - x2*x3 - x2*x4 + x3*x4))), 
					var cubicNumerator:Number = (-(Math.pow(x2,2)*x3*y1) + x2*Math.pow(x3,2)*y1 + Math.pow(x2,2)*x4*y1 - Math.pow(x3,2)*x4*y1- 
						x2*Math.pow(x4,2)*y1 + x3*Math.pow(x4,2)*y1 + Math.pow(x1,2)*x3*y2 - x1*Math.pow(x3,2)*y2 - 
						Math.pow(x1,2)*x4*y2 + Math.pow(x3,2)*x4*y2 + x1*Math.pow(x4,2)*y2 -x3*Math.pow(x4,2)*y2 - 
						Math.pow(x1,2)*x2*y3 + x1*Math.pow(x2,2)*y3 + Math.pow(x1,2)*x4*y3 -Math.pow(x2,2)*x4*y3 - 
						x1*Math.pow(x4,2)*y3 + x2*Math.pow(x4,2)*y3 + Math.pow(x1,2)*x2*y4 -x1*Math.pow(x2,2)*y4 - 
						Math.pow(x1,2)*x3*y4 + Math.pow(x2,2)*x3*y4 + x1*Math.pow(x3,2)*y4 -x2*Math.pow(x3,2)*y4);
					var cubicDenom:Number = ((x1 - x2)*(x3 - x4)*(Math.pow(x1,2) - x1*x3 - x1*x4 + x3*x4)*(Math.pow(x2,2) -
						x2*x3 - x2*x4 + x3*x4));
					a = -(cubicNumerator/cubicDenom);
					
					//-((x2^3*x3*y1 - x2*x3^3*y1 - x2^3*x4*y1 + x3^3*x4*y1 
					//+ x2*x4^3*y1 - x3*x4^3*y1 - x1^3*x3*y2 + x1*x3^3*y2 
					//+ x1^3*x4*y2 - x3^3*x4*y2 - x1*x4^3*y2 + x3*x4^3*y2 
					//+ x1^3*x2*y3 - x1*x2^3*y3 - x1^3*x4*y3 + x2^3*x4*y3 
					//+ x1*x4^3*y3 - x2*x4^3*y3 - x1^3*x2*y4 + x1*x2^3*y4 
					//+ x1^3*x3*y4 - x2^3*x3*y4 - x1*x3^3*y4 + x2*x3^3*y4)/
					
					//((-x1 + x2)*(x2 - x3)*(-x1 + x3)*(x1 - x4)*(x2 - x4)*(x3 - x4))), 
					cubicNumerator=(Math.pow(x2,3)*x3*y1 - x2*Math.pow(x3,3)*y1 - Math.pow(x2,3)*x4*y1 + Math.pow(x3,3)*x4*y1 + 
						x2*Math.pow(x4,3)*y1 - x3*Math.pow(x4,3)*y1 - Math.pow(x1,3)*x3*y2 + x1*Math.pow(x3,3)*y2 +
						Math.pow(x1,3)*x4*y2 - Math.pow(x3,3)*x4*y2 - x1*Math.pow(x4,3)*y2 + x3*Math.pow(x4,3)*y2 + 
						Math.pow(x1,3)*x2*y3 - x1*Math.pow(x2,3)*y3 - Math.pow(x1,3)*x4*y3 + Math.pow(x2,3)*x4*y3 +
						x1*Math.pow(x4,3)*y3 - x2*Math.pow(x4,3)*y3 - Math.pow(x1,3)*x2*y4 + x1*Math.pow(x2,3)*y4 + 
						Math.pow(x1,3)*x3*y4 - Math.pow(x2,3)*x3*y4 - x1*Math.pow(x3,3)*y4 + x2*Math.pow(x3,3)*y4);
					cubicDenom=((-x1 + x2)*(x2 - x3)*(-x1 + x3)*(x1 - x4)*(x2 - x4)*(x3 - x4));
					b = -(cubicNumerator/cubicDenom);
					
					//-((-(x2^3*x3^2*y1) + x2^2*x3^3*y1 + x2^3*x4^2*y1 - x3^3*x4^2*y1 
					//- x2^2*x4^3*y1 + x3^2*x4^3*y1 + x1^3*x3^2*y2 -x1^2*x3^3*y2 
					//- x1^3*x4^2*y2 + x3^3*x4^2*y2 + x1^2*x4^3*y2 - x3^2*x4^3*y2 
					//- x1^3*x2^2*y3 + x1^2*x2^3*y3 + x1^3*x4^2*y3 - x2^3*x4^2*y3 
					//- x1^2*x4^3*y3 + x2^2*x4^3*y3 + x1^3*x2^2*y4 - x1^2*x2^3*y4 
					//- x1^3*x3^2*y4 + x2^3*x3^2*y4 + x1^2*x3^3*y4 - x2^2*x3^3*y4)/
					//((x1 - x2)*(x1 - x3)*(x2 - x3)*(x1 - x4)*(x2 - x4)*(x3 - x4))), 
					
					cubicNumerator=(-(Math.pow(x2,3)*Math.pow(x3,2)*y1) + Math.pow(x2,2)*Math.pow(x3,3)*y1 + 
						Math.pow(x2,3)*Math.pow(x4,2)*y1 - Math.pow(x3,3)*Math.pow(x4,2)*y1 - 
						Math.pow(x2,2)*Math.pow(x4,3)*y1 + Math.pow(x3,2)*Math.pow(x4,3)*y1 + 
						Math.pow(x1,3)*Math.pow(x3,2)*y2 - Math.pow(x1,2)*Math.pow(x3,3)*y2 - 
						Math.pow(x1,3)*Math.pow(x4,2)*y2 + Math.pow(x3,3)*Math.pow(x4,2)*y2 + 
						Math.pow(x1,2)*Math.pow(x4,3)*y2 - Math.pow(x3,2)*Math.pow(x4,3)*y2 - 
						Math.pow(x1,3)*Math.pow(x2,2)*y3 + Math.pow(x1,2)*Math.pow(x2,3)*y3 +
						Math.pow(x1,3)*Math.pow(x4,2)*y3 - Math.pow(x2,3)*Math.pow(x4,2)*y3 - 
						Math.pow(x1,2)*Math.pow(x4,3)*y3 + Math.pow(x2,2)*Math.pow(x4,3)*y3 + 
						Math.pow(x1,3)*Math.pow(x2,2)*y4 - Math.pow(x1,2)*Math.pow(x2,3)*y4 - 
						Math.pow(x1,3)*Math.pow(x3,2)*y4 + Math.pow(x2,3)*Math.pow(x3,2)*y4 + 
						Math.pow(x1,2)*Math.pow(x3,3)*y4 - Math.pow(x2,2)*Math.pow(x3,3)*y4);	
					cubicDenom=((x1 - x2)*(x1 - x3)*(x2 - x3)*(x1 - x4)*(x2 - x4)*(x3 - x4));
					c = -(cubicNumerator/cubicDenom);

					//-((x2^3*x3^2*x4*y1 - x2^2*x3^3*x4*y1 - x2^3*x3*x4^2*y1 + x2*x3^3*x4^2*y1 
					//+ x2^2*x3*x4^3*y1 - x2*x3^2*x4^3*y1 - x1^3*x3^2*x4*y2 + x1^2*x3^3*x4*y2 
					//+ x1^3*x3*x4^2*y2 - x1*x3^3*x4^2*y2 - x1^2*x3*x4^3*y2 + x1*x3^2*x4^3*y2 
					//+ x1^3*x2^2*x4*y3 - x1^2*x2^3*x4*y3 - x1^3*x2*x4^2*y3 + x1*x2^3*x4^2*y3 
					//+ x1^2*x2*x4^3*y3 - x1*x2^2*x4^3*y3 - x1^3*x2^2*x3*y4 + x1^2*x2^3*x3*y4 
					//+ x1^3*x2*x3^2*y4 - x1*x2^3*x3^2*y4 - x1^2*x2*x3^3*y4 + x1*x2^2*x3^3*y4)
					
					///((x1 - x2)*(x1 - x3)*(x2 - x3)*(x1 - x4)*(x2 - x4)*(x3 - x4)))					
					cubicNumerator=(Math.pow(x2,3)*Math.pow(x3,2)*x4*y1 - Math.pow(x2,2)*Math.pow(x3,3)*x4*y1 - 
						Math.pow(x2,3)*x3*Math.pow(x4,2)*y1 + x2*Math.pow(x3,3)*Math.pow(x4,2)*y1 + 
						Math.pow(x2,2)*x3*Math.pow(x4,3)*y1 - x2*Math.pow(x3,2)*Math.pow(x4,3)*y1 - 
						Math.pow(x1,3)*Math.pow(x3,2)*x4*y2 + Math.pow(x1,2)*Math.pow(x3,3)*x4*y2 + 
						Math.pow(x1,3)*x3*Math.pow(x4,2)*y2 - x1*Math.pow(x3,3)*Math.pow(x4,2)*y2 - 
						Math.pow(x1,2)*x3*Math.pow(x4,3)*y2 + x1*Math.pow(x3,2)*Math.pow(x4,3)*y2 + 
						Math.pow(x1,3)*Math.pow(x2,2)*x4*y3 - Math.pow(x1,2)*Math.pow(x2,3)*x4*y3 - 
						Math.pow(x1,3)*x2*Math.pow(x4,2)*y3 + x1*Math.pow(x2,3)*Math.pow(x4,2)*y3 + 
						Math.pow(x1,2)*x2*Math.pow(x4,3)*y3 - x1*Math.pow(x2,2)*Math.pow(x4,3)*y3 - 
						Math.pow(x1,3)*Math.pow(x2,2)*x3*y4 + Math.pow(x1,2)*Math.pow(x2,3)*x3*y4 + 
						Math.pow(x1,3)*x2*Math.pow(x3,2)*y4 - x1*Math.pow(x2,3)*Math.pow(x3,2)*y4 - 
						Math.pow(x1,2)*x2*Math.pow(x3,3)*y4 + x1*Math.pow(x2,2)*Math.pow(x3,3)*y4);	
					cubicDenom=((x1 - x2)*(x1 - x3)*(x2 - x3)*(x1 - x4)*(x2 - x4)*(x3 - x4));
					d = -(cubicNumerator/cubicDenom);
					lowLimit=findMinY(coordArr);
					highLimit=findMaxY(coordArr);
					break;
			}
		}
	}
}