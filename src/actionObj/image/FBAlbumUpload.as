package actionObj.image
{
	import actionObj.Consts;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;

	public class FBAlbumUpload extends FBAlbum
	{
		public function FBAlbumUpload(_albumCollection:AlbumCollection)
		{
			photoCollection = new PhotoCollection();
			name="Uploads";
			super(null, _albumCollection);
		}

		public function addPhoto(photo:FBPhoto):void{
			photo_count++;
			photoCollection.addPhoto(photo);
			photo.setIndex(photoCollection.getCount() - 1);
			//photo.loadFullImage();
		}
		
		override public function incAlbumImagesLoaded(photo:Photo):void{
			albumImagesLoadedCount++;
			FlexGlobals.topLevelApplication.returnAlbumCollection().addUploadAlbum(this);				
		}
		
		override public function unloadAlbum():void{//no op: never unload the album for uploads
		}		
	}
}