package actionObj.actions
{
	import actionObj.image.Image_;
	import actionObj.image.Photo;
	
	import comp.EditorActionsCanvas;
	import comp.FullImage;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	
	import mx.containers.Canvas;
	import mx.controls.Image;

	public interface IAction
	{
		function apply():void;
		function setImageObj(img:Image_):void;
		function prepareFilters():void;
		function initImage(scaledImg:Bitmap):void; 
		function initPreview(_bmd:BitmapData):void; 
		function getLabel():String;
		function getBitmapData(img:Image_=null):BitmapData;
	}
}