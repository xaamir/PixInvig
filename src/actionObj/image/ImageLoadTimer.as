package actionObj.image
{
	import flash.utils.Timer;
	
	public class ImageLoadTimer extends Timer
	{
		public var photo:Photo;
		public function ImageLoadTimer(delay:Number, repeat:int, _photo:Photo)
		{
			super(delay, repeat);
			photo=_photo;
		}
	}
}