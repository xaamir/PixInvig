package actionObj.image
{
	import actionObj.Consts;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	
	import utilities.Utils;

	public class FBPhoto extends Photo
	{
		private var created:Number;
		private var comment_count:int;
		private var like_count:int;
		private var images:ArrayCollection;
		private var imagesCount:int=0;
		private var aspectRatio:Number=0;
		
		public function FBPhoto(_obj:Object, _album:Album)
		{
			super(_album);
			if(_obj){
				object_id=_obj['id'];
				created=_obj['created_time'];
				var comment_info:Object = _obj['comment_info'];
				if (comment_info!=null) {
					comment_count=comment_info['comment_count'];
				}
				var like_info:Object= _obj['like_info'];
				if (like_info!=null) {
					like_count=like_info['like_count'];
				}
				fullImage = new Image_(this, _obj['images'][0].source, Image_.FULL);
			}
		}

	
		override public function loadFullImage():void{
			if(!bFullPicLoaded){
				fullImage.loadImage();
				bFullPicLoading=true;
			}
			else{
			}
		}
	}	
}