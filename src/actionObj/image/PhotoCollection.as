package actionObj.image
{
	import mx.collections.ArrayCollection;

	public class PhotoCollection extends PixObjCollection
	{
		private var photoArr:ArrayCollection = null;
		private var count:int;
		
		public function PhotoCollection(){
			photoArr=new ArrayCollection();
			super();
		}
		
		public function addPhoto(photo:FBPhoto):void{
			photoArr.addItem(photo);
			count++;
		}
		
		public function getPhoto(i:int):Photo{
			if(i > (photoArr.length -1)){
				return null;
			}
			return Photo(photoArr.getItemAt(i));
		}
		
		public function getPhotoArray():ArrayCollection{
			return photoArr;
		}
		
		public function getCount():int{
			return count;
		}
	}
}