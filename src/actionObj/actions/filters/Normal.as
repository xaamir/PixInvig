package actionObj.actions.filters
{
	import actionObj.Consts;
	import actionObj.actions.IAction;
	import actionObj.image.Image_;
	
	import comp.FullImage;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	
	import mx.containers.Canvas;
	import mx.controls.Image;
	
	public class Normal extends FilterBase
	{
		
		public function Normal()
		{
		}
		
		override public function apply():void
		{
		}
		
		override public function getBitmapData(img:Image_=null):BitmapData{
			return bitmapData;
		}

		override public  function initPreview(bmd:BitmapData):void{
			bitmapData=bmd;
		}
		
		
		override public function initImage(scaledImg:Bitmap):void
		{
			bitmapData = new BitmapData(scaledImg.width, scaledImg.height,true,0);
			bitmapData.draw(scaledImg);
		}
		
		override public function getLabel():String
		{
			return "Reset";
		}
		
	}
}