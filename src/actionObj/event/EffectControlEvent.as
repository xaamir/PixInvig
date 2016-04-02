package actionObj.event
{
	import actionObj.actions.IAction;
	import actionObj.image.Photo;
	
	import flash.events.Event;
	
	import mx.events.SliderEvent;
	
	public class EffectControlEvent extends Event
	{		
		public var _sliderEvent:SliderEvent;		
		public function EffectControlEvent(type:String, _event:SliderEvent, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			_sliderEvent=_event;
			super(type, bubbles, cancelable);
		}
	}
}