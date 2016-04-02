package actionObj.image
{
	import actionObj.Consts;
	import actionObj.actions.IAction;
	import actionObj.actions.IInteractiveAction;
	import actionObj.actions.filters.CropEffect;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.JointStyle;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	
	import utilities.ImageResizerBilinear;
	import utilities.ResizeMath;
	

	public class Image_
	{
		public static const FULL:int = 0;
		public static const THUMB:int = 1;
		public static const ALBUM:int = 2;
		public static const UNKNOWN:int = 3;
		public static const full_image_height:int = 438;
		public static const full_image_width:uint = 650;
		public static const album_image_height:int = 140;
		public static const album_image_width:int = 140;//leave 5 pixels for the border
		public static const thumb_image_height:int = 77;
		public static const thumb_image_width:int = 77;//leave 2 pixels for the border
		public static const ORIG_MODE:int=0;
		public static const COMPARE_MODE:int=1;
		
		protected var src:String;
		protected var type:int;	
		protected var redChannel:Array=null;//array representing pixel values for the red channel
		protected var greenChannel:Array=null;
		protected var blueChannel:Array=null;
		private   	var imageLoader:Loader = null;
		private 	var bitMapImageOrig:Bitmap = null;//bitmap returned when the image is fetched from facebook		
		private 	var bitMapImageScaled:Bitmap = null;//bitmap scaled to the edit screen size		
		private		var bitMapDataFramed:BitmapData = null; //width and height though correspond to full image width and height and not scaled/
		private		var bitMapDataCompare:BitmapData = null;
		private		var bmdLHS:BitmapData = null;
		private		var bmdRHS:BitmapData = null;
		private		var bitMapDataRotated:BitmapData = null;
		private		var photo:Photo;
		private		var bIsPublished:Boolean=false;
		private static	const lineWidth_FullImage:int=5;
		private static	const lineWidth_AlbumImage:int=5;
		private static	const lineWidth_ThumbImage:int=2;
		private		var mode:int=ORIG_MODE;
		private 	var filter:IAction = null;
		private		var effect:IInteractiveAction = null;
		private		var crop:CropEffect = null;
		private 	var fileRef:FileReference = null;//used in loading from the disk
		private		var fileLoader:Loader = new Loader();
		private static var imageMap:Object = new Object();
		
		/**
		 *	_type can be 0: full size, 1: thumb size 2: album size 
		*/
		public function Image_(_photo:Photo, _src:String, _type:int){
			 src = _src;
			 type=_type;
			 photo=_photo;
		}
		
		/**
		 * Not used right now but should be when only one copy of an image is loaded at a time
		*/
		public static function setImage(_photo:Photo, _src:String, _type:int):Image_{
			if(imageMap[_src]==null) {
				var img:Image_ = new Image_(_photo, _src, _type);
				imageMap[_src]=img;
				return img;				
			}
			else {
				return imageMap[_src];
			}
		}

		public function setFileReference(_ref:FileReference):void{
			fileRef=_ref;
		}
		
		public function getSrc():String{
			return src;
		}
		
		public function setMode(_mode:int):void{
			mode=_mode;
		}
		
		public function getMode():int{
			return mode;
		}
		
		public function getWidth():int{
			return bitMapImageOrig.width;
		}
		
		public function getHeight():int{
			return bitMapImageOrig.height;
		}
		
		public function returnCompareSource():Bitmap{
			var bmdLH:BitmapData= getLHBitMapData(bitMapImageScaled.bitmapData);
			var bmdRH:BitmapData = null;
			bmdRH=getRHBitMapData((returnEditImage(Consts.EDIT_CROP + Consts.EDIT_EFFECT + Consts.EDIT_FILTER)).bitmapData);				
			var compSourceBMD:BitmapData = new BitmapData(bmdLH.width + bmdRH.width, bmdLH.height, true);
			for (var i:int = 0; i < bmdLH.width; i++){
				for (var j:int = 0; j < bmdLH.height; j++){
					compSourceBMD.setPixel32(i, j, bmdLH.getPixel32(i,j));
				}
			}
			for (i = 0; i < bmdRH.width; i++){
				for (j = 0; j < bmdRH.height; j++){
					compSourceBMD.setPixel32(i + compSourceBMD.width/2, j, bmdRH.getPixel32(i,j));
				}
			}
			return new Bitmap(compSourceBMD);
		}
		
		public function getLHBitMapData(bmd:BitmapData):BitmapData{
			if(bmdLHS!=null){
				bmdLHS.dispose();
			}
			bmdLHS = new BitmapData(bitMapImageScaled.bitmapData.width/2, bmd.height, true);
			for (var i:int =0; i < bitMapImageScaled.bitmapData.width/2; i++){
				for (var j:int = 0 ; j < bmd.height; j++){
					bmdLHS.setPixel32(i,j, bmd.getPixel32(i,j));
				}
			}
			return bmdLHS;
		}
		
		public function getRHBitMapData(bmd:BitmapData):BitmapData{
			if(bmdRHS!=null){
				bmdRHS.dispose();
			}
			bmdRHS = new BitmapData(bitMapImageScaled.bitmapData.width/2, bmd.height, true);
			for (var i:int =bitMapImageScaled.bitmapData.width/2 + 1; i < bitMapImageScaled.bitmapData.width ; i++){
				for (var j:int = 0 ; j < bmd.height; j++){
					bmdRHS.setPixel32(i - bitMapImageScaled.bitmapData.width/2, j, bmd.getPixel32(i,j));
				}
			}
			return bmdRHS;
		}

		public function loadImage():void{
			var imageLoader:Loader = new Loader();
			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onItemLoadComplete);
			imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioItemErrorHandler);
			imageLoader.load(new URLRequest(src),  FlexGlobals.topLevelApplication.g_loaderContext);
		}
		
		public function loadImageUsingFileRef():void{
			if(fileRef==null) return;
			fileRef.addEventListener(Event.COMPLETE, onFileLoadComplete);
			fileRef.load();
		}
		
		protected function onFileLoadComplete(event:Event):void{
			fileLoader = new Loader();
			fileLoader.loadBytes(fileRef.data);
			fileLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onUploadComplete);
		}
		
		protected function onUploadComplete(event:Event):void{
			bitMapImageOrig= Bitmap(fileLoader.content);
			photo.onLoadedSuccess(type);
		}

		protected function onItemLoadComplete(event:Event):void{
			bitMapImageOrig = event.currentTarget.content;
			photo.onLoadedSuccess(type);
		}
		
		public function getPhotoObj():Photo{
			return photo;
		}
		
		public function isEdited():Boolean{
			if ((filter==null || filter.getLabel()=="Reset") && (effect==null || effect.getLabel()=="Reset") && crop==null){
				return false;
			}
			else{
				return true;
			}
		}
		
		public function isCropped():Boolean{
			return (crop==null?false:true);
		}
		
		public function getFilter():IAction{
			return filter;
		}
		
		public function getEffect():IInteractiveAction{
			return effect;
		}
		
		public function isEffected():Boolean {
			return (effect==null?false:true);
		}
		
		public function isFiltered():Boolean{
			if(filter==null){
				return false;
			}
			else return true;
		}
		
		public function isPublished():Boolean{
			return bIsPublished;
		}
		
		public function setPublished():void{
			bIsPublished=true;
		}
		
		public function initEdits():void{
			filter=null;
			effect=null;
			crop=null;
		}
		
		/**
		 * Wrap a frame around a bitmap, rotate it if needed - no scaling
		 **/  
		public function returnFramedImage(bmImage:Bitmap, rotation:Number = 0):Bitmap{
			var uiCompImg:UIComponent = new UIComponent();
			var rotateImage:Boolean = false;
			var lineWidth:int;
			var imageShape:Shape = new Shape();

			if(rotation!=0){
				rotateImage=true;	
			}			
			if(type==FULL){
				uiCompImg.width=full_image_width;
				uiCompImg.height=full_image_height;
				bmImage.x= 0;
				bmImage.y= 0;
			}
			else if (type==ALBUM){
				lineWidth=lineWidth_AlbumImage;
				uiCompImg.width=album_image_width + 5;
				uiCompImg.height=album_image_height + 5;			
				imageShape.graphics.lineStyle(lineWidth, 0xffffff, 1 ,false, "normal", JointStyle.MITER, null);
				imageShape.graphics.drawRect(8,5,bmImage.bitmapData.width, bmImage.bitmapData.height);//aq: the rec seems to be created as an "outset"
				bmImage.x= lineWidth + 5;
				bmImage.y= lineWidth + 2;
				if(rotateImage){
					imageShape.rotation=rotation;
				}
			}
			else{//thumb
				lineWidth=lineWidth_ThumbImage;
				uiCompImg.width=album_image_width + 2;
				uiCompImg.height=album_image_height + 2;			
				imageShape.graphics.lineStyle(lineWidth, 0xffffff, 1 ,false, "normal", JointStyle.MITER, null);
				imageShape.graphics.drawRect(8,5,bmImage.bitmapData.width, bmImage.bitmapData.height);//aq: the rec seems to be created as an "outset"
				bmImage.x= 0;
				bmImage.y= 0;
				if(rotateImage){
					imageShape.rotation=rotation;
				}				
			}
			uiCompImg.addChild(bmImage);
			uiCompImg.addChild(imageShape);
			var framedImageBD:BitmapData = new BitmapData(uiCompImg.width, uiCompImg.height, true, 0);
			framedImageBD.draw(uiCompImg, null, null, null, null, true);
			var framedImageSrc:Bitmap= new Bitmap(framedImageBD);
			return framedImageSrc;			
		}
			
		public function createAlbumImageFromFullImage(_fullImg:Image_):void{
			var bmFullOrig:Bitmap=_fullImg.returnOrigImage();
			bitMapImageOrig=scaleImage(bmFullOrig.bitmapData, album_image_width - 10, album_image_height - 10);
		}
		
		public function scaleImage(origBMD:BitmapData, imageWidth:uint, imageHeight:uint ):Bitmap{
			var scaleRatio:Number = 1;
			if(origBMD.width < imageWidth && origBMD.height < imageHeight){
				scaleRatio=1;
			}
			else{
				scaleRatio = imageWidth/origBMD.width < imageHeight/origBMD.height ?
					imageWidth/origBMD.width:imageHeight/origBMD.height;
			}
			origBMD = ImageResizerBilinear.bilinearIterative(origBMD, origBMD.width * scaleRatio, origBMD.height *scaleRatio,
				ResizeMath.METHOD_PAN_AND_SCAN,false);
			var bitMapImageRet:Bitmap=new Bitmap(origBMD);
			return bitMapImageRet;			
		}
				
		/**
		 * scale the image and frame it, rotate if needed
		 * */		
		public function returnImageSource(rotation:Number = 0):Bitmap{
			var rotateImage:Boolean = false;
			var finalImageBD:BitmapData = null;
			var finalImageBM:Bitmap = null;
			if(rotation!=0){
				rotateImage=true;	
				//if(bitMapDataRotated!=null){
				//	finalImageBD= bitMapDataRotated;
				//}
			}
			else{
				if(bitMapDataFramed!=null){
					finalImageBD= bitMapDataFramed;
				}				
			}
			if(finalImageBD==null){
				if(type==FULL){
					var bitMapDataFullImg:BitmapData = null;
					bitMapDataFullImg= new BitmapData(bitMapImageOrig.width, bitMapImageOrig.height, true,0);
					bitMapDataFullImg.draw(bitMapImageOrig);
					bitMapImageScaled=scaleImage(bitMapDataFullImg, full_image_width, full_image_height);
					bitMapDataFullImg.dispose();
					finalImageBM=returnFramedImage(bitMapImageScaled, rotation);
				}
				else{
					if(bitMapImageOrig==null){
						createAlbumImageFromFullImage(photo.getFullSizedImage());
					}
					if(rotateImage){
						bitMapImageOrig.rotation=rotation;
					}
					finalImageBM=returnFramedImage(bitMapImageOrig, rotation);
				}
				finalImageBD = finalImageBM.bitmapData;
				if(rotateImage){
					bitMapDataRotated=finalImageBM.bitmapData;
				}
				else{
					bitMapDataFramed=finalImageBM.bitmapData;
				}
				bitMapImageOrig.rotation=0;
			}
			else{
				finalImageBM = new Bitmap(finalImageBD);
			}
			finalImageBM.x=0;
			finalImageBM.y=0;
			return finalImageBM;			
		}
		
		public function getScaledWidth():int{
			return bitMapImageScaled.width;
		}
		
		public function getScaledHeight():int{
			return bitMapImageScaled.height;
		}
		
		public function setFilter(_filter:IAction):void{
			if(_filter.getLabel()=="Reset"){
				filter=null;
			}
			else{
				filter=_filter;				
			}
		}
		
		public function setEffect(_effect:IInteractiveAction):void{
			if(_effect.getLabel()=="Reset"){
				effect=null;
			}
			else{
				effect=_effect;
				setMode(Image_.ORIG_MODE);
			}
		}
		
		
		public function resetCrop():void{
			crop=null;
		}
		
		public function setCropBitMapData(croppedBMD:BitmapData ,_crop:CropEffect):void{
			if(bitMapImageScaled.bitmapData!=null){
				bitMapImageScaled.bitmapData.dispose();
			}
			bitMapImageScaled=new Bitmap(croppedBMD);			
			bitMapImageScaled=scaleImage(croppedBMD, full_image_width, full_image_height);
			crop=_crop;
		}
		
		public function returnPublishImage():Bitmap{
			var editImageBMD:BitmapData = null;
			var editImageBM:Bitmap = null;
			
			if(crop!=null) {
				//editImageBM = returnScaledImage();				
				editImageBM = new Bitmap(crop.getCroppedImageRef());
			}
			else {
				editImageBM = returnOrigImage();
			}
			if(filter!=null){
				filter.initImage(editImageBM);
				filter.apply();
				editImageBMD=filter.getBitmapData();
				editImageBM=new Bitmap(editImageBMD);
			}
			if(effect!=null){
				effect.initImage(editImageBM);
				effect.apply();
				editImageBMD=effect.getBitmapData();
				editImageBM=new Bitmap(editImageBMD);
			}
			return editImageBM;
		}
		
		public function returnEditImage(flag:int):Bitmap{
			var editImageBMD:BitmapData = null;
			var editImageBM:Bitmap = null;
			
			editImageBM = returnScaledImage();
			if(flag & Consts.EDIT_FILTER){
				if(filter!=null){
					filter.initImage(editImageBM);
					filter.apply();
					editImageBMD=filter.getBitmapData();
					editImageBM=new Bitmap(editImageBMD);
				}
			}
			if(flag & Consts.EDIT_EFFECT){
				if(effect!=null){
					effect.initImage(editImageBM);
					effect.apply();
					editImageBMD=effect.getBitmapData();
					editImageBM=new Bitmap(editImageBMD);
				}
			}
			return editImageBM;
		}		
		
		public function returnScaledImage():Bitmap{
			return bitMapImageScaled;	
		}
				
		public function returnOrigImage():Bitmap{
			if(bitMapImageOrig.width <= 2048 && bitMapImageOrig.height <= 2048){
			}
			else{
				var scaleFromOrig:Number=2048/bitMapImageOrig.width < 2048/bitMapImageOrig.height ?	2048/bitMapImageOrig.width:2048/bitMapImageOrig.height;
				var bitMapImageOrigData:BitmapData = ImageResizerBilinear.bilinearIterative(bitMapImageOrig.bitmapData, bitMapImageOrig.width * scaleFromOrig, bitMapImageOrig.height *scaleFromOrig,
					ResizeMath.METHOD_PAN_AND_SCAN,false);
				bitMapImageOrig=new Bitmap(bitMapImageOrigData);
			}
			
			return bitMapImageOrig;
		}
				
		public function setType(_type:int):void{
			type = _type;
		}
		
		protected function ioItemErrorHandler(event:IOErrorEvent):void {
			trace("ioErrorHandler: " + event);
			photo.onLoadedFailed(type);
		}
		
		public function unload():void{
			if(bitMapImageOrig!=null){
				if(bitMapImageOrig.bitmapData!=null){
					bitMapImageOrig.bitmapData.dispose();
					bitMapImageOrig=null;
				}
			}
			if(bitMapImageScaled!=null){
				if(bitMapImageScaled.bitmapData!=null){
					bitMapImageScaled.bitmapData.dispose();
					bitMapImageScaled=null;
				}
			}
			if(bitMapDataRotated!=null){
				bitMapDataRotated.dispose();
				bitMapDataRotated=null;
			}
			if(bitMapDataFramed!=null){
				bitMapDataFramed.dispose();
				bitMapDataFramed=null;
				bitMapImageOrig=null;
			}
			if(bitMapImageOrig!=null){
				bitMapImageOrig.bitmapData.dispose();
			}
			if(bitMapImageScaled!=null){
				bitMapImageScaled.bitmapData.dispose();
			}
		}
		
		public static function compareAspectRatios(inp:Number, out:Number):int{
			if(Math.abs(inp-out)<0.1) {
				return 0; 
			}
			else{
				return 1;
			}
		}
				
	}
}