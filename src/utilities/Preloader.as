package utilities
{
		import flash.display.DisplayObject;
		import flash.display.Loader;
		import flash.display.Sprite;
		import flash.events.Event;
		import flash.events.ProgressEvent;
		import flash.events.TimerEvent;
		import flash.text.TextField;
		import flash.text.TextFormat;
		import flash.utils.ByteArray;
		import flash.utils.Timer;
		
		import mx.events.FlexEvent;
		import mx.preloaders.DownloadProgressBar;
		
		/*######################################################################### 
		Class created for http://askmeflash.com  
		get answers to all your flash, flex, FMS problems at askmeflash.com its free 
		Flash developers website http://askmeflash.com 
		##########################################################################*/  
		public class Preloader extends DownloadProgressBar {
			public static var g_app_ready:Boolean=false;  
			private var timer:Timer;  
			//progress bar   
			private var pBar:Sprite= new Sprite();  
			//Progress bar mask
			private var maskBar:Sprite= new Sprite();  
			//Text box to diplay loading percentage  
			private var txtBox:TextField =  new TextField();  
			//loader for loading swf design of progress bar   
			private var loader:Loader;  
			//Load swf file containing design of progress bar   
			[ Embed(source="greenBar.swf", mimeType="application/octet-stream") ]  
			public var WelcomeScreenGraphic:Class;  
			//background color   
			private var bgSprite:Sprite= new Sprite();  
			// Embed the background image.
			[Embed(source="assets/rementos_cover_wood.jpg")]
			[Bindable] public var embededBackgroundImage:Class;
			
			private var txtFormat:TextFormat;  
			public function Preloader():void   
			{  
				this.addChild(bgSprite);  
				timer = new Timer(100);  
				timer.addEventListener(TimerEvent.TIMER, drawProgress );  
				timer.start();  
				//loading swf file of progress bar design  
				loader= new Loader();  
				loader.loadBytes( new WelcomeScreenGraphic() as ByteArray );  
				pBar.addChild(loader);  
				var bgImg:DisplayObject = new embededBackgroundImage();
				bgImg.x = 0;
				bgImg.y = 0;
				this.addChild(bgImg);			
				this.addChild(txtBox);
				pBar.addChild(maskBar);  
				pBar.mask=maskBar;  
				//position textbox  
				txtBox.textColor=0xffffff;  
				txtFormat= new TextFormat();  
				txtFormat.font="Verdana";  
				//background color of preloader   
				bgSprite.graphics.beginFill(0xffffff);
				bgSprite.graphics.drawRect(0,0,200,200)  
				bgSprite.graphics.endFill();
			}  
			
			override public function set preloader( preloader:Sprite ):void   
			{     
				preloader.addEventListener(ProgressEvent.PROGRESS, SWFDownloadProgress);  
				preloader.addEventListener(FlexEvent.INIT_COMPLETE, initCompleteEventHandler);
				
				//position progressbar to center of stage  
				//var centerX:Number=(this.stage.stageWidth - 475) / 2;  
				//var centerY:Number=(this.stage.stageHeight - 153) / 2;  
				var centerX:Number=260;  
				var centerY:Number=135;  
				pBar.x = centerX;  
				pBar.y = centerY;
				txtBox.x=centerX+10;
				txtBox.y=centerY-10;
				txtBox.width = 400;              
				bgSprite.width=this.stage.stageWidth;  
				bgSprite.height=this.stage.stageHeight;  
				this.addChild(pBar);  
			}  
			
			// Override to set a background image.
			override public function get backgroundImage():Object{
				return embededBackgroundImage;
			}
			
			// Override to set the size of the background image to 100%.
			// The image will be automatically centered.
			override public function get backgroundSize():String{
				return "50%";
			}
			
			public function initCompleteEventHandler(event: Event):void{
				progress=100*multiplier;
				initComplete=true;
			}
						
			private var progress:Number;
			private var loaded:Boolean=false;
			private var initComplete:Boolean=false;
			private var completeEventDispatched:Boolean=false; 
			private var multiplier:Number=2;
			
			private function SWFDownloadProgress( event:ProgressEvent ):void {  
				//progress multiplied by 2 cos our progress bar design is 200 px  
				if(progress!=(100*multiplier)){
					progress=multiplier*Number(event.target.loaderInfo.bytesLoaded/event.target.loaderInfo.bytesTotal*100);
				}
			}  
			private var  currlen:Number=0;  
			
			public function drawProgress(event: Event):void{  
				//change the mask color to the color of your background  
				if(currlen<progress && !loaded){  
					currlen+=100;  
					maskBar.graphics.beginFill(0x66aaff);  
					maskBar.graphics.drawRect(0,0,currlen+10,200);  
					maskBar.graphics.endFill();  
					txtBox.text="Loading... "+Math.round(currlen/2)+"%";
					txtBox.setTextFormat(txtFormat);  
				}  
				if(currlen>=200 && !loaded){
					loaded=true;  
				}
				
				if(loaded && initComplete){//basically giving a 5 secs delay after the all the bytes have been loaded.
					currlen+=100;  
					if(currlen >= 500){
						timer.stop();  
						dispatchEvent( new Event( Event.COMPLETE ) );
					}  				
				}
			}  
			
		}  
	}  