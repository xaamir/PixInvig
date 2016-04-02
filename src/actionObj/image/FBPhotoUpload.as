package actionObj.image
{
	import flash.net.FileReference;
	
	import mx.core.FlexGlobals;

	public class FBPhotoUpload extends FBPhoto
	{
		public function FBPhotoUpload(_album:Album, _albumCollection:AlbumCollection, _ref:FileReference)
		{
			album=_album;
			fullImage = new Image_(this, "", Image_.FULL);
			fullImage.setFileReference(_ref);
			super(null, _album);
		}
		
		override public function onLoadedSuccess(_type:int):void{
			album.incAlbumImagesLoaded(this);
			bFullPicLoaded=true;
			bFullPicLoadSuccess=true;
			bFullPicLoading=false;
			albumImage = new Image_(this, "", Image_.ALBUM);
			albumImage.createAlbumImageFromFullImage(getFullSizedImage());
		}		
		
		override public function enablePublishButton():Boolean{
			return true;
		}
		
		override public function loadFullImage():void{
			if(!bFullPicLoaded){
				fullImage.loadImageUsingFileRef();
				bFullPicLoading=true;
			}
			else{
			}
		}		
	}
}