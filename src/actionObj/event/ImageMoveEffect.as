package actionObj.event
{
	import actionObj.image.Album;
	
	import flash.events.Event;
	
	import mx.effects.Move;
	
	public class ImageMoveEffect extends Move
	{
		public var album:Album;
		public function setAlbum(_album:Album):void
		{
			album=_album;
		}
	
		public function getAlbum():Album {
			return album;
		}
		
		public function ImageMoveEffect(target:Object = null)
		{
			super(target);			
		}		
		//public function ImageMoveEffect( 
	}
}