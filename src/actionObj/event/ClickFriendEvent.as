package actionObj.event
{
	import actionObj.image.Friend;
	
	import comp.FriendCanvas;
	
	import flash.events.Event;
	
	public class ClickFriendEvent extends Event
	{
		public var friend:Friend;
		public var selected:Boolean;
		
		public function ClickFriendEvent(type:String, _friend:Friend, _selected:Boolean, 
										 bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			friend=_friend;
			selected=_selected;
		}
	}
}