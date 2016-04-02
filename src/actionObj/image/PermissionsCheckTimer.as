package actionObj.image
{
	import flash.utils.Timer;
	
	import mx.core.FlexGlobals;

	public class PermissionsCheckTimer extends Timer
	{
		public var encodedImage:String;
		public var photo:Photo;
		public function PermissionsCheckTimer(delay:Number, repeat:int, _encodedImage:String, _photo:Photo)
		{
			encodedImage=_encodedImage;
			photo=_photo;
			super(delay, repeat);
		}
		
		public function postFBPic():void{
			FlexGlobals.topLevelApplication.postFBPic(encodedImage, photo);			
		}
	}
}