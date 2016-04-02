package actionObj.event
{
	import flash.events.Event;
	
	public class ClickEffects extends Event
	{
		public function ClickEffects(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}