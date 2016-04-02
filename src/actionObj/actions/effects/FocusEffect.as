package actionObj.actions.effects
{
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// File Name: actionObj.filters.FocusEffect.as - ActionScript 3.0 Component 
//												 which implements IFilter
// Author   : Brian Barry
// Date     : 2/17/13 Sunday
// File Name: FocusEffect.as
//
// Version Changes:
// - - - - - - - -
// v1.1 - x/xx/13, Made the following improvements:
//
// v1.0 - 2/17/13, Original version:
//		- FocusEffect.as now has 656 lines of code. That's 11 pages in this file.
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Methods Defined:
// ----------------
// 1. FocusEffect() - Class Constructor
// 2. setBlurValue()
// 3. getBlurValue()
// 4. setFocalPoint()
// 5. getFocalPointX()
// 6. getFocalPointY()
// 7. setMaskScaleFactor()
// 8. getMaskScaleFactor()
// 9. setCreateSquareMask()
// 10. getCreateSquareMask()
// 11. setDarkening()
// 12. getDarkening()
// 13. reset()
// 14. createBlurFilter()
// 15. calcCurves()
// 16. createRadialGradient()
// 17. apply()
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//	Sample code to apply Focus Effect to a bitmapdata image:
//  ----------------------------------------------------------
//	import actionObj.filters.FocusEffect;
//
//	var focusEffect:FocusEffect;
//	var xPercent:Number;
//	var yPercent:Number;
//	var focusEffect_maskScaleFactor:Number;
//	var focusEffect_createSquareMask:Boolean;
//
//  // Mouse events can be used to alter the focal point and mask scale factor
//  // to let the user interactively modify the Focus Effect as needed.
//	focusEffect = new FocusEffect( App.targetImageData );
//	focusEffect.setBlurValue( FocusEffect.BLUR_VALUE_DEFAULT ); );
//	xPercent = FocusEffect.USER_X_PERCENT_DEFAULT;
//	yPercent = FocusEffect.USER_Y_PERCENT_DEFAULT;
//	focusEffect.setFocalPoint( xPercent, yPercent );
//	focusEffect.setMaskScaleFactor( FocusEffect.MASK_SCALE_FACTOR_DEFAULT );
//	focusEffect.setCreateSquareMask( FocusEffect.CREATE_SQUARE_MASK_DEFAULT );
//	focusEffect.setDarkening( FocusEffect.DARKENING_DEFAULT );
//	focusEffect.apply(); // Apply Focus Effect to App.targetImageData image.
//
//  Alternate method: To apply the Focus Effect, if there's no user interaction...
//  -----------------
//	focusEffect = new FocusEffect( App.targetImageData,
//								   FocusEffect.BLUR_VALUE_DEFAULT,
//								   FocusEffect.USER_X_PERCENT_DEFAULT,
//								   FocusEffect.USER_Y_PERCENT_DEFAULT,
//								   FocusEffect.MASK_SCALE_FACTOR_DEFAULT,
//								   FocusEffect.CREATE_SQUARE_MASK_DEFAULT,
//								   FocusEffect.DARKENING_DEFAULT );
//	focusEffect.apply(); // Apply Focus Effect to App.targetImageData image.
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
/*
WARMING EFFECT:  (renamed to FocusEffect)
- Steps to implement the Warming Effect as shown in this PSD file:
	"12.1102.dual color filter.psd", 22,124 KB
  1. Gaussian Blur: 8  (very subjective)
     (looks like a Gaussian Blur of 8 pixels was the setting used in .psd file)
  2. Darken using Curves:
     RGB  : 157,93
	 Red  : 132,106
	 Green: none
	 Blue : 91,166
  3. Create a temporary image:
     - Apply this "Warming" Curves transformation on a copy 
       of the orig image, affecting the whole image equally.
       RGB  : none
	   Red  : 107,158
	   Green: none
	   Blue : 152,82
     - Next we need to merge partially selected pixels from this temporary
       "warmed" image using a radial gradient alpha mask.
  4. Merge partially selected pixels from the "warmed" image using a radial 
     gradient (centered at the focal point) (our API needs a Point input 
     argument, which will be relative to top left of image, which will define 
     the focal point. The calling function needs to set the focal point 
     to the center of the image by default).
	 - Radial Gradient info: (very subjective, must experiment with the AS 3 APIs)
       The radial gradient should fill to the full length of the shortest dimension.
	 We'll use the radial gradient image (black & white) as an alpha mask 
	 to control which pixels from the "warmed" image are merged into
	 and overwrite the fully blurred image copy from step 2.
  5. Done.

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
*/

	import actionObj.actions.IAction;
	import actionObj.actions.IInteractiveAction;
	import actionObj.actions.filters.AdjustColor;
	import actionObj.graphics.Coordinate;
	import actionObj.graphics.Polynomial;
	import actionObj.image.Image_;
	import actionObj.image.Photo;
	
	import comp.EditorActionsCanvas;
	import comp.EffectControl;
	import comp.FullImage;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import mx.controls.Image;

	// -----------------------------------------------------------------------
	public class FocusEffect extends EffectBase  
	{	
		override public function getLabel():String{
			return label;
		}
		
		override public function setLabel(_label:String):void{
			label=_label;
		}
		
		// -----------------------------------------------------------------------
		public function FocusEffect()
		{
			super();
			setDarkenLevel(160);
			label="Focus";
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
