package actionObj.actions.effects
{
	import actionObj.Consts;
	import actionObj.actions.IAction;
	import actionObj.actions.IInteractiveAction;
	import actionObj.image.Image_;
	
	import comp.FullImage;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.controls.Image;
	
	public class Normal extends EffectBase
	{
		public var bitMapData:BitmapData;
		
		public function Normal()
		{ 
		}
		
		override public function apply():void
		{
		}
		
		override public function getBitmapData(img:Image_=null):BitmapData{
			return bitMapData;
		}
		
		override public  function initPreview(bmd:BitmapData):void{
			bitMapData=bmd;
		}
		
		
		override public function initImage(scaledImg:Bitmap):void
		{
			bitMapData = new BitmapData(scaledImg.width, scaledImg.height,true,0);
			bitMapData.draw(scaledImg);
		}
		
		override public function getLabel():String
		{
			return "Reset";
		}
						
		public function onMouseDown(event:MouseEvent):void{
		}
		
		public function  onMouseUp(event:MouseEvent):void{
		}
		
		public function  onMouseOver(event:MouseEvent):void{
		}
		
		public function onMouseOut(event:MouseEvent):void{
			return;			
		}			
	}
}