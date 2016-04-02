package actionObj.event
{
	import actionObj.image.Friend;
	
	import comp.FriendCanvas;
	
	import flash.events.Event;
	
	public class SelectFriendEvent extends Event
	{
		public var friend:Friend;
		public var friendCanvas:FriendCanvas;
		public function SelectFriendEvent(type:String, _canvas:FriendCanvas, _friend:Friend, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			friend=_friend;
			friendCanvas=_canvas;
		}
	}
}