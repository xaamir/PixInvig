package actionObj.event
{
	import actionObj.image.Photo;
	
	import flash.events.Event;

	public class CompareImageEvent extends Event
	{
		public var photo:Photo;	
		
		public function CompareImageEvent(type:String, _photo:Photo, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			photo=_photo;
		}
	}
}