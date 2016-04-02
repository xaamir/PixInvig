package actionObj.event
{
	import flash.events.Event;
	
	public class ScrollComplete extends Event
	{
		public function ScrollComplete(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}