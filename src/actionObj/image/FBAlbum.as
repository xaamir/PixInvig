package actionObj.image
{
	import actionObj.Consts;
	
	import flash.display.Bitmap;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;

	public class FBAlbum extends Album
	{
		private var modified_major:Number;
		private var created:Number;
		private var like_count:int;
		private var modified:Number;
		
		
		public function FBAlbum(_albumObj:Object, _albumCollection:AlbumCollection){
			if(_albumObj!=null){
				photoCollection = new PhotoCollection();
				name=_albumObj['name'];
				object_id=_albumObj['id'];
				modified=_albumObj['modified_major'];
				created=_albumObj['created_time'];
				var like_info:Object =_albumObj['like_info'];
				if(like_info!=null) {
					like_count=like_info['like_count'];
				}
				var photoArr:ArrayCollection = new ArrayCollection(_albumObj['photosArr']);
				photo_count=photoArr.length;
				for each (var photo:Object in photoArr){
					var fbPhoto:FBPhoto = new FBPhoto(photo, this);
					photoCollection.addPhoto(fbPhoto);
					fbPhoto.setIndex(photoCollection.getCount() - 1);
				}
			}
			super(_albumCollection);
		}
		
		override public function preInitLoad():void{
			var preLoadCount:int = photo_count < Consts.PRE_INIT_ALBUM_PHOTO_COUNT? photo_count:Consts.PRE_INIT_ALBUM_PHOTO_COUNT;
			for (var i:int = 0;  i < preLoadCount; i++){
				var photo:FBPhoto = FBPhoto(photoCollection.getPhoto(i));
				if(photo!=null){
					photo.loadFullImage();
				}
			}
		}
				
		override public function loadPageNum(pageNum:int):void{
			var begIndx:int = (pageNum - 1)*Consts.PIC_COUNT_ALBUM_COUNT + Consts.PRE_INIT_ALBUM_PHOTO_COUNT;
			var endIndx:int = (pageNum)*Consts.PIC_COUNT_ALBUM_COUNT + Consts.PRE_INIT_ALBUM_PHOTO_COUNT;
			endIndx =  endIndx < photo_count ? endIndx:photo_count;
			for (var i:int = begIndx; i < endIndx; i++){
				var photo:FBPhoto = FBPhoto(photoCollection.getPhoto(i));
				if(photo!=null){
					photo.loadFullImage();
				}
			}
		}

		override public function loadPage():void{
			loadPageNum(page_no);
		}
				
		override public function nextPage():void{
			if(page_no==getTotalPages()) return;
			page_no++;
			loadPageNum(page_no);//load the next page in memory
		}
		
		override public function prevPage():void{
			if(page_no==1) return;
			page_no--;
		}
		
		
		override public function getPage():Array{
			pageArr = new Array();
			var begIndx:int = (page_no - 1)*Consts.PIC_COUNT_ALBUM_COUNT;
			var endIndx:int = (page_no)*Consts.PIC_COUNT_ALBUM_COUNT;
			endIndx =  endIndx < photo_count ? endIndx:photo_count;			
			for (var i:int = begIndx; i < endIndx; i++){
				var photo:FBPhoto = FBPhoto(photoCollection.getPhoto(i));
				if(photo!=null){
					if( photo.getAlbumImage()!=null){
						var image:Image_ = photo.getAlbumImage();
						image.returnImageSource();
						pageArr.push(image);
					}
				}
			}
			return pageArr;
		}
		
		override public function getTotalPages():int{
			return photo_count/Consts.PIC_COUNT_ALBUM_COUNT + 1;
		}
		
		override public function getPageNo():int{
			return page_no;
		}

		override public function decAlbumImagesLoaded():void{
			albumImagesLoadedCount--;
		}
		
		override public function incAlbumImagesLoaded(photo:Photo):void{
			albumImagesLoadedCount++;//should not exceed PRE_INIT_ALBUM_PHOTO_COUNT
			if(!bAlbumImagesLoaded) {
				albumCollection.incAlbumPreloaded(this, photo);
				bAlbumImagesLoaded=true;
			}
			else{
				FlexGlobals.topLevelApplication.onPicLoaded(photo);
			}
		}
		
		override public function getTopImageSrc(rotation:int):Bitmap{
			if(photoCollection.getCount() > 0){
				var photo:Photo =  photoCollection.getPhoto(0);
				var image:Image_ = photo.getAlbumImage();
				return image.returnImageSource(rotation);
			}
			else return null;
		}
		
		override public function getPhoto(index:int):Photo{
			return photoCollection.getPhoto(index);
		}
		
		override public function getMidImageSrc(rotation:int):Bitmap{
			if(photoCollection.getCount() > 1){
				var photo:Photo =  photoCollection.getPhoto(1);
				if(photo==null) return null;
				var image:Image_ = photo.getAlbumImage();
				return image.returnImageSource(rotation);
			}
			else return null;
		}
		
		override public function getBottomImageSrc(rotation:int):Bitmap{
			if(photoCollection.getCount() > 2){
				var photo:Photo =  photoCollection.getPhoto(2);
				if(photo==null) return null;
				var image:Image_ = photo.getAlbumImage();
				return image.returnImageSource(rotation);
			}
			else return null;
		}
		
		override public function getBottomImage():Image_{
			if(photoCollection.getCount() > 2){
				var photo:Photo =  photoCollection.getPhoto(2);
				if(photo==null) return null;
				var image:Image_ = photo.getAlbumImage();
				return image;
			}
			else return null;
		}

		override public function getTopImage():Image_{
			if(photoCollection.getCount() > 0){
				var photo:Photo =  photoCollection.getPhoto(0);
				if(photo==null) return null;
				var image:Image_ = photo.getAlbumImage();
				return image;
			}
			else return null;
		}

		override public function getMidImage():Image_{
			if(photoCollection.getCount() > 1){
				var photo:Photo =  photoCollection.getPhoto(1);
				if(photo==null) return null;
				var image:Image_ = photo.getAlbumImage();
				return image;
			}
			else return null;
		}
		
		//unload bit maps for all album images except the first three
		override public function unloadAlbum():void{
			page_no=1;
			if(photo_count > 3){
				var beg:int = 3;
				var end:int = photo_count;
				for (var i:int= beg; i < photo_count; i++){
					var photo:FBPhoto = FBPhoto(photoCollection.getPhoto(i));
					if(photo==null){
						continue;
					}
					if(photo.isFullPicLoaded()==true){
						photo.unloadFullImage();
					}					
				}
			}
		}
		
	}
}