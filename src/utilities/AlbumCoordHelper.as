package utilities
{
	import actionObj.graphics.Coordinate;
	import actionObj.image.Album;
	
	import comp.MainPageCanvas;

	public class AlbumCoordHelper
	{
		public function AlbumCoordHelper()
		{
		}
		static public var MAX_Y:int = 450;
		static public var MIN_Y:int = 0;
		static public var MID_GAP:int = 50;			
		static public var MAX_X:int = 730;
		static public var MIN_X:int = 20;
		static public var VERTICAL_HT_DIFF:int = 10;
		static public var HORIZONTAL_WIDTH_OVERLAP:int = 10;
		static public var BUTTON_DISTANCE:int = 2;
		static public var MID_IMG_Y_INCR:int = 20;
		static public var BOTTOM_IMG_Y_INCR:int = 30;
		
		//fixed coordinates
		static public var leftUpperCornerCoord:Coordinate = new Coordinate(MIN_X, MIN_Y); 
		static public var rightUpperCornerCoord:Coordinate = new Coordinate(MAX_X, MIN_Y); 
		static public var leftBottomCornerCoord:Coordinate = new Coordinate(MIN_X, MAX_Y); 
		static public var rightBottomCornerCoord:Coordinate = new Coordinate(MAX_X, MAX_Y); 
		static public var middleCoord:Coordinate = new Coordinate((MIN_X + MAX_X)/2, (MIN_Y + MAX_Y)/2); 
		//flexible coordinates
		static public var topMiddleCoord:Coordinate = new Coordinate((MAX_X)/2, MIN_Y); 
		static public var bottomMiddleCoord:Coordinate = new Coordinate((MIN_X + MAX_X)/2, MAX_Y); 
		static public var rightMiddleCoord:Coordinate = new Coordinate(MAX_X - MID_GAP, (MIN_Y + MAX_Y)/2); 
		static public var leftMiddleCoord:Coordinate = new Coordinate(MID_GAP, (MAX_Y)/2);
		
		
		private var coordMap:Object = new Object();
		private var albumCoordMap:Object = new Object();
		
		private var leftBottomCornerSet:Boolean = false;			
		private var rightBottomCornerSet:Boolean = false;
		private var leftUpperCornerSet:Boolean = false;
		private var rightUpperCornerSet:Boolean = false;
		private var middleSet:Boolean = false;
		private var topMiddleSet:Boolean = false;			
		private var bottomMiddleSet:Boolean = false;
		private var rightMiddleSet:Boolean = false;
		private var leftMiddleSet:Boolean = false;
		
		private var fixedCoordinatesUsed:Boolean = false;
		private var flexCoordinatesUsed:Boolean = false;
		
		public function getAlbumCoordMap():Object {
			return this.albumCoordMap;
		}
		
		public function getCoordMap():Object {
			return this.coordMap;
		}
		
		public function isfixedCoordUsed():Boolean {
			return this.fixedCoordinatesUsed;
		}
		
		public function isFlexCoordUsed():Boolean {
			return this.flexCoordinatesUsed;
		}
		
		public function isFixedCoord(_album:Album):Boolean {
			for (var coord:String in this.coordMap) {
				var coordAlbum:Album = this.albumCoordMap[coord]; 
				if (coordAlbum.getName()==_album.getName()) {
					if ((coord=="middle") || (coord=="leftBottomCorner") || 
						(coord== "leftUpperCorner") || (coord== "rightUpperCorner")  ||(coord=="rightBottomCorner")) {
						return true;
					}
					else {
						return false;
					}
				}
			}
			return false;
		}
				
		public function findFixedCoordinates(album:Album,  maxWidth:int, maxHeight:int):Coordinate{
			if (middleSet==false) {
				middleSet=true;
				var middleX:int = AlbumCoordHelper.middleCoord.x - maxWidth/2;
				var middleY:int = AlbumCoordHelper.middleCoord.y - maxHeight/2;
				var leftCoord:Coordinate=new Coordinate(middleX, middleY);
				var rightCoord:Coordinate=new Coordinate(middleX + maxWidth/2, 
					middleY + maxHeight/2);
				this.coordMap["middle"]= new actionObj.graphics.Rectangle(leftCoord, rightCoord);
				this.albumCoordMap["middle"]=album;
				return new Coordinate(middleX, middleY);
			}
			else if(leftUpperCornerSet==false) {
				leftUpperCornerSet=true;
				var leftCoord:Coordinate=new Coordinate(leftUpperCornerCoord.x,leftUpperCornerCoord.y );
				var rightCoord:Coordinate=new Coordinate(AlbumCoordHelper.leftUpperCornerCoord.x + maxWidth, 
					AlbumCoordHelper.leftUpperCornerCoord.y + maxHeight);
				this.coordMap["leftUpperCorner"]= new actionObj.graphics.Rectangle(leftCoord, rightCoord);
				this.albumCoordMap["leftUpperCorner"]=album;
				return AlbumCoordHelper.leftUpperCornerCoord;
			}
			else if (leftBottomCornerSet==false){
				leftBottomCornerSet=true;
				var leftBottomX:int = AlbumCoordHelper.leftBottomCornerCoord.x;
				var leftBottomY:int = AlbumCoordHelper.leftBottomCornerCoord.y - maxHeight;
				var leftCoord:Coordinate=new Coordinate(leftBottomX, leftBottomY);
				var rightCoord:Coordinate=new Coordinate(leftBottomX + maxWidth, 
					leftBottomY + maxHeight);
				this.coordMap["leftBottomCorner"]= new actionObj.graphics.Rectangle(leftCoord, rightCoord);				
				this.albumCoordMap["leftBottomCorner"]=album;
				return new Coordinate(leftBottomX, leftBottomY);
			}
			else if (rightUpperCornerSet==false){
				rightUpperCornerSet=true;
				var rightUpperX:int = AlbumCoordHelper.rightUpperCornerCoord.x - maxWidth;
				var rightUpperY:int = AlbumCoordHelper.rightUpperCornerCoord.y;
				var leftCoord:Coordinate=new Coordinate(rightUpperX, rightUpperY);
				var rightCoord:Coordinate=new Coordinate(rightUpperX + maxWidth, 
					rightUpperY + maxHeight);
				this.coordMap["rightUpperCorner"]= new actionObj.graphics.Rectangle(leftCoord, rightCoord);
				this.albumCoordMap["rightUpperCorner"]=album;
				return new Coordinate(rightUpperX, rightUpperY);
			}
			else if (rightBottomCornerSet==false){
				rightBottomCornerSet=true;
				var rightBottomX:int = AlbumCoordHelper.rightBottomCornerCoord.x - maxWidth;
				var rightBottomY:int = AlbumCoordHelper.rightBottomCornerCoord.y - maxHeight;
				var leftCoord:Coordinate=new Coordinate(rightBottomX, rightBottomY);
				var rightCoord:Coordinate=new Coordinate(rightBottomX + maxWidth, 
					rightBottomY + maxHeight);
				this.coordMap["rightBottomCorner"]= new actionObj.graphics.Rectangle(leftCoord, rightCoord);				
				this.albumCoordMap["rightBottomCorner"]=album;
				this.fixedCoordinatesUsed=true;
				return new Coordinate(rightBottomX, rightBottomY);
			}
			else {
				return null;
			}
		}
		

		public function findFlexibleCoordinates(album: Album, maxWidth:int, maxHeight:int):Coordinate{
			if(topMiddleSet==false) {
				topMiddleSet=true;
				var topMiddleX:int = topMiddleCoord.x - maxWidth/2;
				var topMiddleY:int = topMiddleCoord.y;
				var leftCoord:Coordinate=new Coordinate(topMiddleX, topMiddleCoord.y);
				var rightCoord:Coordinate=new Coordinate(topMiddleX + maxWidth/2, 
					topMiddleY + maxHeight);
				this.coordMap["topMiddle"]= new actionObj.graphics.Rectangle(leftCoord, rightCoord);				
				this.albumCoordMap['topMiddle']=album;
				return new Coordinate(topMiddleX, topMiddleY);
			}
			else if(bottomMiddleSet==false) {
				bottomMiddleSet=true;
				var bottomMiddleX:int = AlbumCoordHelper.bottomMiddleCoord.x - maxWidth/2;
				var bottomMiddleY:int = AlbumCoordHelper.bottomMiddleCoord.y - maxHeight;
				var leftCoord:Coordinate=new Coordinate(bottomMiddleX, bottomMiddleY);
				var rightCoord:Coordinate=new Coordinate(bottomMiddleX + maxWidth/2, 
					AlbumCoordHelper.bottomMiddleCoord.y);
				this.coordMap["bottomMiddle"]= new actionObj.graphics.Rectangle(leftCoord, rightCoord);				
				this.albumCoordMap['bottomMiddle']=album;
				return new Coordinate(bottomMiddleX, bottomMiddleY);
			}
			else if(leftMiddleSet==false) {
				leftMiddleSet=true;
				var leftMiddleX:int = AlbumCoordHelper.leftMiddleCoord.x;
				var leftMiddleY:int = AlbumCoordHelper.leftMiddleCoord.y - maxHeight/2;
				var leftCoord:Coordinate=new Coordinate(leftMiddleX, leftMiddleY);
				var rightCoord:Coordinate=new Coordinate(AlbumCoordHelper.leftMiddleCoord.x + maxWidth, 
					AlbumCoordHelper.leftMiddleCoord.y + maxHeight/2);
				this.coordMap["leftMiddle"]= new actionObj.graphics.Rectangle(leftCoord, rightCoord);				
				this.albumCoordMap['leftMiddle']=album;
				return new Coordinate(leftMiddleX, leftMiddleY);
			}								
			else if(rightMiddleSet==false) {
				rightMiddleSet=true;
				var rightMiddleX:int = AlbumCoordHelper.rightMiddleCoord.x - maxWidth;
				var rightMiddleY:int = AlbumCoordHelper.rightMiddleCoord.y - maxHeight/2;
				var leftCoord:Coordinate=new Coordinate(rightMiddleX, rightMiddleY);
				var rightCoord:Coordinate=new Coordinate(AlbumCoordHelper.rightMiddleCoord.x, 
					rightMiddleY + maxHeight/2);
				this.coordMap["rightMiddle"]= new actionObj.graphics.Rectangle(leftCoord, rightCoord);				
				this.albumCoordMap['rightMiddle']=album;
				this.flexCoordinatesUsed=true;
				return new Coordinate(rightMiddleX, rightMiddleY);
			}				
			else {
				return null;
			}
		}		
	}
}