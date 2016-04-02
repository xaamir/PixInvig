package actionObj.image
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	
	import mx.collections.ArrayCollection;

	public class Photo
	{	
		protected 	var object_id:String;		
		protected 	var albumImage:Image_;
		protected 	var fullImage:Image_;
		protected	var bFullPicLoaded:Boolean = false;
		protected	var bFullPicLoadSuccess:Boolean =false;		
		protected	var index:int;
		protected	var album:Album;
		protected   var bIsloadedOnCanvas:Boolean=false;
		protected	var bFullPicLoading:Boolean=false;//aq: 12/22/2012: for some reason the Mouse Down event on the image happens twice. 
													//this flag basically blocks the 2nd event.
		
		
		public function enablePublishButton():Boolean{
			return fullImage.isEdited();
		}
		
		public function setLoadedOnCanvas(loaded:Boolean):void {
			bIsloadedOnCanvas=loaded;
		}
		
		public function isLoadedOnCanvas():Boolean{
			return bIsloadedOnCanvas;
		}
		
		public function Photo(_album:Album){
			album=_album;
		}
	
		public function getId():String {
			return this.object_id;
		}
		
		public function getAlbum():Album{
			return album;
		}
		
		
		public function loadFullImage():void{
			
		}
		
		public function isFullImageLoading():Boolean{
			return bFullPicLoading;
		}
		

		public function isFullPicLoaded():Boolean{
			return bFullPicLoadSuccess;
		}

		public function onLoadedFailed(_type:int):void{
			album.incAlbumImagesLoaded(this);
			bFullPicLoaded=true;
			bFullPicLoading=false;
			bFullPicLoadSuccess=false;
		}
		
		public function setIndex(indx:int):void{
			index=indx;
		}
		
		public function getIndex():int{
			return index;
		}
		
	

		public function getAlbumImage():Image_{
			if (albumImage==null && isFullPicLoaded()) {
				albumImage = new Image_(this, "", Image_.ALBUM);
				albumImage.createAlbumImageFromFullImage(getFullSizedImage());		
			}
			return albumImage;
		}		
		
		public function getFullSizedImage():Image_{
			return fullImage;
		}
		
		public function unloadFullImage():void{
			fullImage.unload();
			/*if(albumImage!=null) {
				albumImage.unload();
			}*/
			bFullPicLoaded=false;
			bFullPicLoadSuccess=false;
			
		}

		public function onLoadedSuccess(_type:int):void{
			bFullPicLoaded=true;
			bFullPicLoadSuccess=true;
			bFullPicLoading=false;
			album.incAlbumImagesLoaded(this);
		}		
	}
}