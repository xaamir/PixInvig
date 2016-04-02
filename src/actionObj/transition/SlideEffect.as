package actionObj.transition
{
	import com.jumpeye.flashEff2.symbol.slide.FESSlide;
	import flash.events.Event;
	import mx.containers.Canvas;
	import mx.core.UIComponent;

	public class SlideEffect
	{
		private var hideImage:UIComponent;
		private var showImage:UIComponent;
		
		public function SlideEffect(_showImage:UIComponent){
			showImage=_showImage;
		}
		
		public function play(fe:FlashEff2Flex, isFwd:Boolean=true):void{
			fe.showAutoPlay=true;
			fe.visible=true;
			
			var pattern1:FESSlide = new FESSlide();
			if(isFwd){
				pattern1.preset=2;
			}
			else{
				pattern1.preset=1;				
			}
			pattern1.positionX=-20;
			pattern1.positionY=5;
			pattern1.blurX=10;
			pattern1.blurY=10;
			pattern1.blurQuality=2;
			pattern1.tweenDuration=0.8;
			pattern1.tweenType='Linear';
			pattern1.easeType='easeNone';

			fe.showTransition=pattern1;
			fe.target=showImage;			
		}
	}
}