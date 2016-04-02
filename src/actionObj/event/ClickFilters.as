package actionObj.event
{
	import flash.events.Event;
	
	public class ClickFilters extends Event
	{
		public function ClickFilters(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}