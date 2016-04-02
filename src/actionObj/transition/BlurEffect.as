package actionObj.transition
{
	import com.jumpeye.flashEff2.symbol.blur.FESBlur;
	
	import mx.core.UIComponent;

	public class BlurEffect
	{
		private var targetImage:UIComponent;
		
		public function BlurEffect(_showImage:UIComponent){
			targetImage=_showImage;
		}
		
		public function play(fe:FlashEff2Flex):void{
			fe.showAutoPlay=true;
			fe.visible=true;			
			var pattern4:FESBlur = new FESBlur();
			pattern4.blurX=25;
			pattern4.blurY=25;
			pattern4.blurQuality=2;
			pattern4.tweenDuration=1.0;
			pattern4.tweenType='Strong';
			pattern4.easeType='easeInOut';
			fe.showTransition=pattern4;		
			fe.target=targetImage;
		}
	}
}