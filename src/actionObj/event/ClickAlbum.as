package actionObj.event
{
	import actionObj.image.Album;
	import flash.events.Event;
	
	public class ClickAlbum extends Event
	{
		public var _album:Album;	
		
		public function ClickAlbum(type:String, bubbles:Boolean=true, _album:Album, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}