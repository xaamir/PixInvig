package actionObj.image
{
	import actionObj.Consts;
	
	import comp.AlbumNameButton;
	
	import flash.display.Bitmap;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	
	public class Album
	{
		protected var object_id:String;		
		protected var photoCollection:PhotoCollection = null;
		protected var name:String;
		protected var photo_count:int;
		protected var albumImagesLoadedCount:int;
		protected var bAlbumImagesLoaded:Boolean=false;
		protected var albumCollection:AlbumCollection = null;
		protected var pageArr:Array=null;
		protected var page_no:int=1;
		protected var albumNameBtn:AlbumNameButton = null;
		
		
		public function setButton(_albumNameButton:AlbumNameButton){
			albumNameBtn=_albumNameButton;
		}
		
		public function getButton(): AlbumNameButton {
			return albumNameBtn;
		}
		
		public function Album(_albumCollection:AlbumCollection){
			albumCollection = _albumCollection;
		}
				
		public function preInitLoad():void{
			
		}
				
		public function loadPage():void{
			
		}
		
		public function loadPageNum(num:int):void{
			
		}
		
		public function getBottomImage():Image_{
			return null;	
		}

		public function getTopImage():Image_{
			return null;	
		}
		
		public function getMidImage():Image_{
			return null;
		}
		
		
		public function getPhoto(index:int):Photo {
			return null;
		}
		
		public function getPage():Array{
			return null;
		}
			
		public function getTopImageSrc(rotation:int):Bitmap{
			return null;
		}
		
		public function getMidImageSrc(rotation:int):Bitmap{
			return null;
		}
		
		public function getBottomImageSrc(rotation:int):Bitmap{
			return null;
		}
		
		public function getTotalPages():int{
			return 0;
		}
		
		public function decAlbumImagesLoaded():void{
		
		}

		public function nextPage():void{
		}
		
		public function prevPage():void{
		}

		public function getPageNo():int{
			return 0;
		}
		
		public function getName():String{
			if(photoCollection.getCount() > 0){
				return name;
			}
			else{
				return null;
			}
		}
		
		public function getPhotoCollection():PhotoCollection{
			return photoCollection;
		}
		
		public function incAlbumImagesLoaded(photo:Photo):void{
		}

		public function unloadAlbum():void{
			
		}
	}
}