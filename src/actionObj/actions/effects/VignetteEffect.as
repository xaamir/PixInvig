package actionObj.actions.effects
{
	import comp.EffectControl;

	public class VignetteEffect extends EffectBase
	{
		public function VignetteEffect(_blurValue:Number=BLUR_VALUE_DEFAULT, _xPercent:Number=USER_X_PERCENT_DEFAULT, _yPercent:Number=USER_Y_PERCENT_DEFAULT, _gradientStyle:int=RADIAL_GRADIENT_STYLE, _maskScaleFactor:Number=RADIAL_MASK_SCALE_FACTOR_DEFAULT, _createSquareMask:Boolean=CREATE_SQUARE_MASK_DEFAULT, _curvesFlag:Boolean=CURVES_FLAG_DEFAULT, _darkenFlag:Boolean=DARKEN_FLAG_DEFAULT, _darkenLevel:int=DARKEN_LEVEL_DEFAULT, _desatFlag:Boolean=DESAT_FLAG_DEFAULT, _blurFlag:Boolean=BLUR_FLAG_DEFAULT)
		{
			super(_blurValue, _xPercent, _yPercent, _gradientStyle, _maskScaleFactor, _createSquareMask, _curvesFlag, _darkenFlag, _darkenLevel, _desatFlag, _blurFlag);
			setDarkenLevel(60);
			setDarkenFlag(true);
			setBlurFlag(false); 
			label="Vignette";
			setMaskScaleFactor((RADIAL_MASK_SCALE_FACTOR_DEFAULT - RADIAL_MASK_SCALE_FACTOR_MIN)/1.5);
		}
		
		override public function getLabel():String{
			return label;
		}
		
		override public function setLabel(_label:String):void{
			label=_label;
		}
		
		override public function setDarkenFlag(flag:Boolean):void{
			if(!getDarkenFlag()){//do not reset the darken flag to false
				super.setDarkenFlag(flag);
			}
		}
		
		override public function setMaskScaleFactorFromRatio (_maskScaleFactorRatio:Number):void
		{
			var gradialInc:Number;
			gradialInc = (RADIAL_MASK_SCALE_FACTOR_MAX - RADIAL_MASK_SCALE_FACTOR_MIN)/10;
			setMaskScaleFactor((EffectControl.MAX - _maskScaleFactorRatio) * gradialInc);
		}
		
		override public function setMaskScaleFactor(_maskScaleFactor:Number):void{
			setGradientStyleAndMaskScaleFactor(RADIAL_GRADIENT_STYLE, _maskScaleFactor);
		}	
		
	}
}