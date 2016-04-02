package actionObj.image
{
	import actionObj.actions.IAction;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;

	public class ActionImageData	{
		import mx.controls.Image;
		
		public var imageLabel:String;
		public var filter:IAction;
		public var photo:Photo;
		public var img:Image;
		public var isSelected:Boolean = false;
		
		[Embed (source="../assets/thumbs/Forest.png")]
		public static const STOCK_IMG:Class;
			
		public function ActionImageData(_label:String, _filter:IAction, _photo:Photo){
			imageLabel=_label;
			filter=_filter;
			photo=_photo;
		}
		
		public function setImage():void{
			var bm:Bitmap = new STOCK_IMG();
			var bmd:BitmapData = bm.bitmapData;
			filter.initPreview(bmd);
			filter.apply();
			img = new Image();
			img.source =new Bitmap(filter.getBitmapData());	
		}
		
		public function getLabel():String{
			return filter.getLabel();
		}
		
		public function setSelected(flag:Boolean):void{
			isSelected=flag;
		}
	}
}