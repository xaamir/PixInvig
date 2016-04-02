package actionObj.actions.filters
{
	import actionObj.Consts;
	import actionObj.actions.IAction;
	import actionObj.image.Image_;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	public class FilterBase implements IAction
	{
		protected var bitmapData:BitmapData;
		protected var isPreview:Boolean = false;

		public function FilterBase()
		{
		}
		
		public function getBitmapData(img:Image_=null):BitmapData{
			return bitmapData;
		}
		
		public function setImageObj(img:Image_):void{
			img.setFilter(this);
		}

		public function apply():void
		{
		}
				
		public function initImage(scaledImg:Bitmap):void
		{
			if(bitmapData!=null && !isPreview){
				bitmapData.dispose();
			}
			bitmapData = new BitmapData(scaledImg.width, scaledImg.height,true,0);
			bitmapData.draw(scaledImg);
			prepareFilters();			
		}
		
		public function initPreview(bmd:BitmapData):void{
			isPreview=true;
			bitmapData=bmd;
			prepareFilters();
		}
		
		public function prepareFilters():void{
			
		}
		
		public function getLabel():String
		{
			return null;
		}
	}
}