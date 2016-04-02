package actionObj.event
{
	import flash.events.Event;
	
	public class ClickCrop extends Event
	{
		public function ClickCrop(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}