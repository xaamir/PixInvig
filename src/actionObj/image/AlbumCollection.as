package actionObj.image
{
	import actionObj.Consts;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;

	public class AlbumCollection extends PixObjCollection
	{
		private var albumArr:ArrayCollection = null;
		private var albumLoadedArr:ArrayCollection = null;
		private var albumCount:int = 0;
		private  var isAlbumsPreLoaded:Boolean=false;
		private  var albumsPreloaded:int=0;	
		private	var albumPageNo:int = 1;
		public var albumPageArr:ArrayCollection = null;
		private var uploadAlbumAdded:Boolean=false;
		
		public function AlbumCollection(_collection:ArrayCollection){
			albumArr=new ArrayCollection();
			albumLoadedArr=new ArrayCollection();
			for each (var _album:Object in _collection){
				var album:FBAlbum = new FBAlbum(_album,this);
				albumArr.addItem(album);//adds at the end of the list
				albumCount++;
				if (album.getName()=="bosnia hike") {
					albumCount;
				}
				album.preInitLoad();
			}
		}
		
		public function getLoadedAlbums():ArrayCollection{
			return albumLoadedArr;
		}
		
		public function getPageNo():int{
			return albumPageNo;
		}
		
		public function getTotalPages():int{
			if ((albumsPreloaded % Consts.ALBUMS_DISPLAY_COUNT) == 0){
				return albumsPreloaded/Consts.ALBUMS_DISPLAY_COUNT;
			}
			else{
				return albumsPreloaded/Consts.ALBUMS_DISPLAY_COUNT + 1;					
			}
		}
		
		public function nextPage():void{
			var clickArr:Array = new Array();
			clickArr["type"]=Consts.CLICK_ALBUM_COLLECTIONS_NEXT;
			FlexGlobals.topLevelApplication.recordClickData(clickArr);						
			if(albumPageNo==getTotalPages()) return;
			albumPageNo++;
		}

		public function prevPage():void{
			var clickArr:Array = new Array();
			clickArr["type"]=Consts.CLICK_ALBUM_COLLECTIONS_PREV;
			FlexGlobals.topLevelApplication.recordClickData(clickArr);						
			if(albumPageNo==1) return;
			albumPageNo--;
		}
		
		public function getAlbumPageArr():ArrayCollection{
			if(albumsPreloaded < 1) return null;
			var albumBegIndex:int = (albumPageNo - 1) * Consts.ALBUMS_DISPLAY_COUNT;
			var albumEndIndex:int = albumPageNo *Consts. ALBUMS_DISPLAY_COUNT;
			albumEndIndex =  albumEndIndex > albumsPreloaded ? albumsPreloaded: albumEndIndex;
			var i:int = 0;
			albumPageArr = new ArrayCollection();
			for (i = 0; i < albumEndIndex - albumBegIndex; i++){
				albumPageArr.addItemAt(albumLoadedArr[albumBegIndex + i], i);
			}
			return albumPageArr;
		}
		
		public function getAlbumArr():ArrayCollection{
			return albumArr;
		}
		
		public function addUploadAlbum(uploadAlbum:FBAlbumUpload):void{
			if(uploadAlbumAdded==false){
				if(albumLoadedArr.length < 2) {
					albumLoadedArr.addItemAt(uploadAlbum, 0);
				}
				else {
					albumLoadedArr.addItemAt(uploadAlbum, 1);					
				}
				albumsPreloaded++;
				uploadAlbumAdded=true;
			}
		}
		
		public function incAlbumPreloaded(albumPreLoaded:Album, photo:Photo):void{
			albumsPreloaded++;
			albumLoadedArr.addItem(albumPreLoaded);								
			if(!this.isAlbumsPreLoaded){
				this.isAlbumsPreLoaded=true;
				FlexGlobals.topLevelApplication.onAlbumsPreloaded(albumPreLoaded);
			}
			FlexGlobals.topLevelApplication.onAlbumPreloaded(photo);
		}
	}
}