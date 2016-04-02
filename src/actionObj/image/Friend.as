package actionObj.image
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	import mx.core.FlexGlobals;

	public class Friend
	{
		public var id:String;
		public var url:String;
		public var name:String;
		public var loaded:Boolean=false;
		public var bitMapImageOrig:Bitmap = null;//bitmap returned when the image is fetched from facebook		
		public var bitMapImageData:BitmapData = null;
		
		public function Friend(_name:String, _url:String, _id:String)
		{
			name=_name;
			url=_url;
			id=_id;
			loadImage();
		}
		
		protected function loadImage():void{
			var imageLoader:Loader = new Loader();
			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onItemLoadComplete);
			imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioItemErrorHandler);
			imageLoader.load(new URLRequest(url),  FlexGlobals.topLevelApplication.g_loaderContext);			
		}
		
		protected function onItemLoadComplete(event:Event):void{
			bitMapImageOrig = event.currentTarget.content;
			bitMapImageData= new BitmapData (event.currentTarget.content.width, event.currentTarget.content.height, true, 0x00ffffff);
			bitMapImageData.draw(event.currentTarget.content);
		}		
		protected function ioItemErrorHandler(event:IOErrorEvent):void {
			trace("ioErrorHandler: " + event);
		}
		public function setImage():Bitmap{
			bitMapImageOrig = new Bitmap(bitMapImageData);
			return bitMapImageOrig;			
		}
	}
}