package actionObj.event
{
	import actionObj.actions.IAction;
	import actionObj.image.Photo;
	
	import flash.events.Event;
	
	public class EditListEvent extends Event
	{		
		public var filter:IAction;
		public var photo:Photo;	
		
		public function EditListEvent(type:String, _filter:IAction, _photo:Photo, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			filter=_filter;
			photo=_photo;
		}
	}
}