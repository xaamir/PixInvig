package actionObj.actions.effects
{
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// File Name: actionObj.filters.FocusEffect.as - ActionScript 3.0 Component 
//												 which implements IFilter
// Author   : Brian Barry
// Date     : 3/24/13 Sunday
// File Name: FocusEffect.as
//
// Version Changes:
// - - - - - - - -
// v1.1 - x/xx/13, Made the following improvements:
//
// v1.0 - 3/24/13, Original version:
//		- FocusEffect.as now has 1171 lines of code. That's 20 pages in this file.
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
//
// 7. setGradientStyleAndMaskScaleFactor
// 8. getGradientStyle()
// 9. getMaskScaleFactor()
//
// 10. setCreateSquareMask() // - ignored if using linear gradient mask style
// 11. getCreateSquareMask()
//
// 13. setCurvesFlag()
// 14. getCurvesFlag()
// 15. setDarkenFlag()
// 16. getDarkenFlag()
// 17. setDarkenLevel()
// 18. getDarkenLevel()
//
// 19. setDesatFlag()
// 20. getDesatFlag()
// 21. setBlurFlag()
// 22. getBlurFlag()
//
// 23. reset()
// 24. createBlurFilter()
// 25. calcCurves()
// 26. createRadialGradient()
// 27. createUniformlyDarkenedImage()
// 28. apply()
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//	Sample code to apply Focus Effect to a bitmapdata image:
//  --------------------------------------------------------
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
//
//	focusEffect = new FocusEffect( App.targetImageData );
//	focusEffect.setBlurValue( FocusEffect.BLUR_VALUE_DEFAULT ); );
//	xPercent = FocusEffect.USER_X_PERCENT_DEFAULT;
//	yPercent = FocusEffect.USER_Y_PERCENT_DEFAULT;
//	focusEffect.setFocalPoint( xPercent, yPercent );
//	focusEffect.setGradientStyleAndMaskScaleFactor(
//					FocusEffect.RADIAL_GRADIENT_STYLE,
//					FocusEffect.RADIAL_MASK_SCALE_FACTOR_DEFAULT );
//	focusEffect.setCreateSquareMask( FocusEffect.CREATE_SQUARE_MASK_DEFAULT );
//
//	focusEffect.setCurvesFlag(  FocusEffect.CURVES_FLAG_DEFAULT  );
//	focusEffect.setDarkenFlag(  FocusEffect.DARKEN_FLAG_DEFAULT  );
//	focusEffect.setDarkenLevel( FocusEffect.DARKEN_LEVEL_DEFAULT );
//				Range: 0 < N < 255. 0:fully black pixels, 64:darkened orig image (default), 255:orig image
//	focusEffect.setDesatFlag(   FocusEffect.DESAT_FLAG_DEFAULT   );
//	focusEffect.setBlurFlag(    FocusEffect.BLUR_FLAG_DEFAULT    );
//
//	focusEffect.apply(); // Apply Focus Effect to App.targetImageData image.
//
//  Alternate method: To apply the Focus Effect once, if there's no user interaction...
//  -----------------
//	focusEffect = new FocusEffect( App.targetImageData,
//								   FocusEffect.BLUR_VALUE_DEFAULT,
//								   FocusEffect.USER_X_PERCENT_DEFAULT,
//								   FocusEffect.USER_Y_PERCENT_DEFAULT,
//								   FocusEffect.RADIAL_GRADIENT_STYLE,
//								   FocusEffect.RADIAL_MASK_SCALE_FACTOR_DEFAULT,
//								   FocusEffect.CREATE_SQUARE_MASK_DEFAULT,
//								   FocusEffect.CURVES_FLAG_DEFAULT,
//								   FocusEffect.DARKEN_FLAG_DEFAULT,
//								   FocusEffect.DARKEN_LEVEL_DEFAULT,
//								   FocusEffect.DESAT_FLAG_DEFAULT,
//								   FocusEffect.BLUR_FLAG_DEFAULT );
//	focusEffect.apply(); // Apply Focus Effect to App.targetImageData image.
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
/*
WARMING EFFECT: Description from orig meeting notes (renamed to FocusEffect)
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

	import actionObj.Consts;
	import actionObj.actions.IInteractiveAction;
	import actionObj.actions.filters.AdjustColor;
	import actionObj.graphics.Coordinate;
	import actionObj.graphics.Polynomial;
	import actionObj.image.Image_;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	// -----------------------------------------------------------------------
	public class EffectBase implements IInteractiveAction
	{
		private var targImageData:BitmapData;
		private var focusImageData:BitmapData;
		private var maskData:BitmapData;
		private var darkenMaskData:BitmapData;
				

		// Create two special bitmapdata objects used only for
		// building the linear gradient mask which is built in two parts.
		private var mergedLinearMaskData:BitmapData; // used only for linear gradient mask

		private var curves1Poly:Polynomial;
		private var curves2Poly:Polynomial;
		private var curves3Poly:Polynomial;
		private var curves4Poly:Polynomial;
		private var curves5Poly:Polynomial;
		private var curves6Poly:Polynomial;

		private var blurFilter:BlurFilter;

		private var point0:Point = new Point( 0, 0 );

		public static const BLUR_VALUE_DEFAULT:Number = 0.04;
		public static const USER_X_PERCENT_DEFAULT:Number = 50.0; // User's view of x-axis (0%-left, 100%-right)
		public static const USER_Y_PERCENT_DEFAULT:Number = 50.0; // User's view of y-axis (0%-bottom, 100%-top of image)
		public static const CREATE_SQUARE_MASK_DEFAULT:Boolean = false;

		public static const RADIAL_GRADIENT_STYLE:int = 0;
		public static const LINEAR_GRADIENT_STYLE:int = 1;

		public static const RADIAL_MASK_SCALE_FACTOR_DEFAULT:Number = 1.0;
		public static const RADIAL_MASK_SCALE_FACTOR_MIN:Number = 0.10;
		public static const RADIAL_MASK_SCALE_FACTOR_MAX:Number = 2.0;

		public static const LINEAR_MASK_SCALE_FACTOR_DEFAULT:Number = 1.0;
		public static const LINEAR_MASK_SCALE_FACTOR_MIN:Number = 0.35;
		public static const LINEAR_MASK_SCALE_FACTOR_MAX:Number = 2.5;

		public static const CURVES_FLAG_DEFAULT:Boolean = false;

		public static const DARKEN_FLAG_DEFAULT:Boolean = false;
		public static const DARKEN_LEVEL_DEFAULT:int    = 0x40; // 0x30 was too dark, 0x70 wasn't dark enough
		// Range: 0 < N < 255. 0:fully black pixels, 64:darkened orig image (default), 255:orig image

		public static const DESAT_FLAG_DEFAULT:Boolean  = false;
		public static const BLUR_FLAG_DEFAULT:Boolean   = true;

		protected var blurValue:Number = BLUR_VALUE_DEFAULT;
		protected var xPercent:Number  = USER_X_PERCENT_DEFAULT;
		// Internal view of y-axis has 0% at top, 100% at bottom of image.
		// But 50.0 is in the middle, so actually, (100.0 - Y_PERCENT_VALUE)
		// is what is needed here to be technically correct, but it's the same numerical value.
		private var yPercent:Number  = (100.0 - USER_Y_PERCENT_DEFAULT); // internal view is 

		private var maskScaleFactor:Number   = RADIAL_MASK_SCALE_FACTOR_DEFAULT; // default to radial gradient mask
		private var createSquareMask:Boolean = CREATE_SQUARE_MASK_DEFAULT;

		private var gradientStyle:int  = RADIAL_GRADIENT_STYLE; // default to radial gradient mask

		private var curvesFlag:Boolean = CURVES_FLAG_DEFAULT;
		private var darkenFlag:Boolean = DARKEN_FLAG_DEFAULT;
		private var desatFlag:Boolean  = DESAT_FLAG_DEFAULT;
		private var blurFlag:Boolean   = BLUR_FLAG_DEFAULT;

		// darkenLevel is used in an alpha channel to (partially) select pixels
		// from the original image to mix with a completely black background image, 
		// as a way to darken the original image (without using curves or polynomials).
		// - 0x00 selects nothing of the pixel from orig image leaving only the black background
		// - 0x40 selects part of the pixel (0x40==64) from orig image leaving a mix of
		//   orig pixel and black pixel, but mostly uses the black pixel because
		//   0x3C is < 50% (a 50% mix of orig pixel with black would be 255/2 = 127 or 0x7F).
		// - 0xFF selects entire pixel from orig image leaving only the orig image.
		private var darkenLevel:int  = DARKEN_LEVEL_DEFAULT; // 0x30 was too dark, 0x70 wasn't dark enough

		private var maskShape:Shape   = new Shape();
		private var maskMatrix:Matrix = new Matrix( 1, 0, 0, 1,  0, 0 ); // a,b,c,d, tx,ty
		private var gradientMatrix:Matrix = new Matrix(); // needed by beginGradientFill()

		// Used only for creating the linear gradient mask, built from two parts using clipping.
		private var maskForBottomShape:Shape = new Shape(); // used only for linear gradient mask
		private var maskForTopShape:Shape    = new Shape(); // used only for linear gradient mask

		// Used only for creating the linear gradient mask, built from two parts using clipping.
		private var clipRect:Rectangle = new Rectangle( 0, 0, 0, 0 );
		public var label:String="Focus B";


		// -----------------------------------------------------------------------
		public function EffectBase( 
									 _blurValue:Number = BLUR_VALUE_DEFAULT,
									 _xPercent:Number  = USER_X_PERCENT_DEFAULT, 
									 _yPercent:Number  = USER_Y_PERCENT_DEFAULT,

									 _gradientStyle:int  = RADIAL_GRADIENT_STYLE,
									 _maskScaleFactor:Number   = RADIAL_MASK_SCALE_FACTOR_DEFAULT,
									 _createSquareMask:Boolean = CREATE_SQUARE_MASK_DEFAULT,

									 _curvesFlag:Boolean = CURVES_FLAG_DEFAULT,
									 _darkenFlag:Boolean = DARKEN_FLAG_DEFAULT,
									 _darkenLevel:int    = DARKEN_LEVEL_DEFAULT,
									 _desatFlag:Boolean  = DESAT_FLAG_DEFAULT,
									 _blurFlag:Boolean   = BLUR_FLAG_DEFAULT )
		{
			// Initialize this Focus Effect's parameters.
			blurValue = _blurValue;
			blurFilter = createBlurFilter( blurValue );
			setFocalPoint( _xPercent, _yPercent );

			setGradientStyleAndMaskScaleFactor( _gradientStyle, _maskScaleFactor );
			setCreateSquareMask( _createSquareMask );

			setCurvesFlag(  _curvesFlag );
			setDarkenFlag(  _darkenFlag );
			setDarkenLevel( _darkenLevel );
			setDesatFlag(   _desatFlag );
			setBlurFlag(    _blurFlag );
		}

		public function prepareFilters():void{
			
		}
		
		public function getLabel():String{
			return label;
		}
		
		public function setLabel(_label:String):void{
			label=_label;
		}
		
		public function getBitmapData(img:Image_=null):BitmapData{
			return targImageData;
		}
		 
		public function setImageObj(img:Image_):void{
			img.setEffect(this);
		}
		
		public function initImage(scaledImg:Bitmap):void
		{
			targImageData = new BitmapData(scaledImg.width, scaledImg.height,true,0);
			targImageData.draw(scaledImg);
			initTempImage();
			focusImageData = new BitmapData(targImageData.rect.width, targImageData.rect.height, true, 0xFF000000 ); // black, opaque			
		}
				
		public function initPreview(_targImageData:BitmapData):void{
			targImageData = _targImageData;
			initTempImage();
		}
				
		private function initTempImage():void{
			// Create a temporary image to hold the "Focus Effect" that
			// we'll create in apply() below on the current (unblurred) target image. 
			// 0x00 - fully transparent (alpha), 0x000000 - black (A,R,G,B: 0x00000000)
			focusImageData = new BitmapData( targImageData.rect.width,
				targImageData.rect.height, true, 0x00000000 ); // fill with transparent black pixels (0x00==black)
			
			// Create Focus Effects copy mask bitmapdata object as an RGB image. 
			maskData       = new BitmapData( targImageData.rect.width, targImageData.rect.height,
				true, 0x00FFFFFF ); // fill with transparent black pixels (0x00==black)
			darkenMaskData = new BitmapData( targImageData.rect.width, targImageData.rect.height,
				true, 0xFF000000 ); // fill with opaque black pixels (0x00==black)			
			// Create two special bitmapdata objects used for building
			// the linear gradient mask which unlike the radial gradient mask,
			// the linear mask is built in two parts.
			mergedLinearMaskData = new BitmapData( targImageData.rect.width, targImageData.rect.height,
				true, 0x00FFFFFF ); // fill with transparent black pixels (0x00==black)
		}
				
		
		// -----------------------------------------------------------------------
		public function setBlurValue( _blurValue:Number ):void
		{
			blurValue  = _blurValue; // valid range: 0..1
			blurFilter = createBlurFilter( blurValue );
		}
		public function getBlurValue():Number
		{
			return( blurValue );
		}

		// -----------------------------------------------------------------------
		// User's view of focal point orientation:
		// _xPercent: 0 is left   of image, 100% is right of image.
		// _yPercent: 0 is bottom of image, 100% is top   of image.
		public function setFocalPoint( _xPercent:Number, _yPercent:Number ):void
		{
			if( _xPercent < 0.0   )	{	_xPercent = 0.0;	}
			if( _xPercent > 100.0 )	{	_xPercent = 100.0;	}
			if( _yPercent < 0.0   )	{	_yPercent = 0.0;	}
			if( _yPercent > 100.0 )	{	_yPercent = 100.0;	}

			xPercent = _xPercent;
			// Note: For Y, matrix algorithms need 0% at the top, 100% at the bottom.
			yPercent = 100.0 - _yPercent; // flip Y-axis so 0% is at the top for internal use.
		}
		public function getFocalPointX():Number
		{
			return( xPercent );
		}
		public function getFocalPointY():Number
		{
			return( 100.0 - yPercent ); // flip Y-axis back so 0% is at the bottom for user.
		}

		// -----------------------------------------------------------------------
		public function setGradientStyleAndMaskScaleFactor( _gradientStyle:int,
														    _maskScaleFactor:Number ):void
		{
			if( ( _gradientStyle < RADIAL_GRADIENT_STYLE )
			 || ( _gradientStyle > LINEAR_GRADIENT_STYLE ) )
			 {
			 	_gradientStyle = RADIAL_GRADIENT_STYLE; // default to radial gradient mask
			 }
			gradientStyle = _gradientStyle;

			if( gradientStyle == RADIAL_GRADIENT_STYLE )
			{
				if( _maskScaleFactor < RADIAL_MASK_SCALE_FACTOR_MIN )
				{	_maskScaleFactor = RADIAL_MASK_SCALE_FACTOR_MIN;	}
				if( _maskScaleFactor > RADIAL_MASK_SCALE_FACTOR_MAX )
				{	_maskScaleFactor = RADIAL_MASK_SCALE_FACTOR_MAX;	}
			}
			else
			{
				if( _maskScaleFactor < LINEAR_MASK_SCALE_FACTOR_MIN )
				{	_maskScaleFactor = LINEAR_MASK_SCALE_FACTOR_MIN;	}
				if( _maskScaleFactor > LINEAR_MASK_SCALE_FACTOR_MAX )
				{	_maskScaleFactor = LINEAR_MASK_SCALE_FACTOR_MAX;	}
			}
			maskScaleFactor = _maskScaleFactor;
		}
		public function getGradientStyle():int
		{
			return( gradientStyle );
		}
		
		public function setMaskScaleFactorFromRatio (_maskScaleFactorRatio:Number):void
		{
			var gradialInc:Number;
			if(gradientStyle==RADIAL_GRADIENT_STYLE){
		 		gradialInc = (RADIAL_MASK_SCALE_FACTOR_MAX - RADIAL_MASK_SCALE_FACTOR_MIN)/10;
			}
			else{
				gradialInc = (LINEAR_MASK_SCALE_FACTOR_MAX - LINEAR_MASK_SCALE_FACTOR_MIN)/10;				
			}
			setMaskScaleFactor(_maskScaleFactorRatio * gradialInc);
		}
		
		public function getSliderValFromMaskScaleFactor ():Number
		{
			var gradialInc:Number;
			var sliderVal:Number;
			if(gradientStyle==RADIAL_GRADIENT_STYLE){
				gradialInc = (RADIAL_MASK_SCALE_FACTOR_MAX - RADIAL_MASK_SCALE_FACTOR_MIN)/10;
			}
			else{
				gradialInc = (LINEAR_MASK_SCALE_FACTOR_MAX - LINEAR_MASK_SCALE_FACTOR_MIN)/10;				
			}
			sliderVal=maskScaleFactor/gradialInc;
			return sliderVal;
		}

		public function setMaskScaleFactor( _maskScaleFactor:Number ):void
		{
			maskScaleFactor = _maskScaleFactor;
		}
		
		public function getMaskScaleFactor():Number
		{
			return( maskScaleFactor );
		}

		// -----------------------------------------------------------------------
		public function setCreateSquareMask( _createSquareMask:Boolean ):void
		{
			createSquareMask = _createSquareMask;
		}
		public function getCreateSquareMask( _createSquareMask:Boolean ):Boolean
		{
			return( createSquareMask );
		}

		// -----------------------------------------------------------------------
		public function setCurvesFlag( _curvesFlag:Boolean ):void
		{
			curvesFlag = _curvesFlag;
		}
		public function getCurvesFlag():Boolean
		{
			return( curvesFlag );
		}

		// -----------------------------------------------------------------------
		public function setDarkenFlag( _darkenFlag:Boolean ):void
		{
			darkenFlag = _darkenFlag;
		}
		public function getDarkenFlag():Boolean
		{
			return( darkenFlag );
		}
		public function setDarkenLevel( _darkenLevel:int ):void
		{
			// Note: default set to 0x40 (0x30 was too dark, 0x70 wasn't dark enough)
			if( _darkenLevel < 0   ) {  _darkenLevel = 0;    }
			if( _darkenLevel > 255 ) {  _darkenLevel = 255;  }
			darkenLevel = _darkenLevel;
		}
		public function getDarkenLevel():int
		{
			return( darkenLevel );
		}


		// -----------------------------------------------------------------------
		public function setDesatFlag( _desatFlag:Boolean ):void
		{
			desatFlag  = _desatFlag;
		}
		public function getDesatFlag():Boolean
		{
			return( desatFlag );
		}

		// -----------------------------------------------------------------------
		public function setBlurFlag( _blurFlag:Boolean ):void
		{
			blurFlag  = _blurFlag;
		}
		public function getBlurFlag():Boolean
		{
			return( blurFlag );
		}

		// -----------------------------------------------------------------------
		public function reset():void  // Set back to defaults.
		{
			blurValue = BLUR_VALUE_DEFAULT; // valid range: 0..1
			setBlurValue( blurValue ); // creates the blur filter as well

			// User's view is of Y-axis is where 0% is at bottom, 100% is at top of image.
			setFocalPoint( USER_X_PERCENT_DEFAULT, USER_Y_PERCENT_DEFAULT );

			// Default to radial gradient mask
			setGradientStyleAndMaskScaleFactor( RADIAL_GRADIENT_STYLE,
												RADIAL_MASK_SCALE_FACTOR_DEFAULT );

			setCreateSquareMask( CREATE_SQUARE_MASK_DEFAULT );

			setCurvesFlag( CURVES_FLAG_DEFAULT );
			setDarkenFlag( DARKEN_FLAG_DEFAULT );
			setDarkenLevel( DARKEN_LEVEL_DEFAULT );
			setDesatFlag( DESAT_FLAG_DEFAULT );
			setBlurFlag( BLUR_FLAG_DEFAULT );
		}

		// -----------------------------------------------------------------------
		protected function createBlurFilter( blurVal:Number ):BlurFilter
		{
			var filter:BlurFilter;
			var blurQuality:int;
			var blurX:Number;
			var blurY:Number;

			blurQuality = BitmapFilterQuality.HIGH; // MEDIUM or LOW (quality of the blur)
													// Todd Yard says that HIGH quality is
													// similary in quality to Gaussian Blur.
			// blurVal value varies from 0..1
			blurX = blurY = ( 255 * blurVal ); // blurX,blurY varies from 0..255

			filter = new BlurFilter( blurX, blurY, blurQuality );
			return( filter );
			
		} // END OF ... private function createBlurFilter( blurVal:Number ):BlurFilter


		// -----------------------------------------------------------------------
		private function calcCurves():void
		{
			// Steps 1-3: Darken using curves

			// Step 1. Curves #1. Apply color adjustments. RGB Curve: 3 points.
			curves1Poly = new Polynomial();
			var curves1CoordArr:Array=new Array();
			curves1CoordArr.push(new Coordinate(0,  0));
			curves1CoordArr.push(new Coordinate(157,93));
			curves1CoordArr.push(new Coordinate(255,255));
			curves1Poly.buildEquation(Polynomial.QUAD,curves1CoordArr);

			// Step 2. Curves #2. Apply color adjustments. Red Curve: 3 points.
			curves2Poly = new Polynomial();
			var curves2CoordArr:Array=new Array();
			curves2CoordArr.push(new Coordinate(0, 0));
			curves2CoordArr.push(new Coordinate(132,106));
			curves2CoordArr.push(new Coordinate(255,255));
			curves2Poly.buildEquation(Polynomial.QUAD,curves2CoordArr);

			// Step 3. Curves #3. Apply color adjustments. Blue Curve: 3 points.
			curves3Poly = new Polynomial();
			var curves3CoordArr:Array=new Array();
			curves3CoordArr.push(new Coordinate(0, 0));
			curves3CoordArr.push(new Coordinate(91,166));
			curves3CoordArr.push(new Coordinate(255,255));
			curves3Poly.buildEquation(Polynomial.QUAD,curves3CoordArr);


			// Steps 4-5: Apply these next 2 "Focus" Curves to a copy of the image.

			// Step 4. Curves #4. Apply color adjustments. Red Curve: 3 points.
			curves4Poly = new Polynomial();
			var curves4CoordArr:Array=new Array();
			curves4CoordArr.push(new Coordinate(0, 0));
			curves4CoordArr.push(new Coordinate(107,158));
			curves4CoordArr.push(new Coordinate(255,255));
			curves4Poly.buildEquation(Polynomial.QUAD,curves4CoordArr);

			// Step 5. Curves #5. Apply color adjustments. Blue Curve: 3 points.
			curves5Poly = new Polynomial();
			var curves5CoordArr:Array=new Array();
			curves5CoordArr.push(new Coordinate(0, 0));
			curves5CoordArr.push(new Coordinate(152,82));
			curves5CoordArr.push(new Coordinate(255,255));
			curves5Poly.buildEquation(Polynomial.QUAD,curves5CoordArr);

		} // END OF ... private function calcCurves()


		// -----------------------------------------------------------------------
		public function createRadialGradient( targBD:BitmapData, maskData:BitmapData ):BitmapData
		{
// http://help.adobe.com/en_US/ActionScript/3.0_ProgrammingAS3/WS5b3ccc516d4fbf351e63e3d118a9b90204-7dd7.html
			var width:int  = targBD.rect.width;
			var height:int = targBD.rect.height;

			// Set minDimension to the smallest of width and height
			var minDimension:int = width < height ? width : height;
			// Set maxDimension to the largest of width and height
//			var maxDimension:int = width > height ? width : height;

			// Define parameters needed by createGradientBox()
			var boxWidth:Number;
			var boxHeight:Number;
			var boxRotation:Number = 0; // Math.PI/2; // 90°  (in radians)
			var tx:Number = 0;
			var ty:Number = 0; 

			// Define parameters needed by beginGradientFill()
			var type:String  = GradientType.RADIAL; // GradientType.LINEAR or GradientType.RADIAL.

			// 0xFFFFFF==White is in the center of image, fading outward to: 0x000000==Black
			var colors:Array = [0xffffff, 0xcccccc, 0x888888, 0x555555, 0x000000];
			var alphas:Array = [1, 1, 1, 1, 1];
			var ratios:Array = [120, 180, 220, 240, 255];

			var spreadMethod:String = SpreadMethod.PAD; // PAD, REFLECT, REPEAT
			var interp:String = InterpolationMethod.RGB; //LINEAR_RGB; // LINEAR_RGB, RGB
			// Position focal point within radial gradient. ( -1 .. 0 .. +1 )
			//  0 == focal point is in center of radial gradient
			// -1 == focal point is at far left of radial gradient
			// +1 == focal point is at far right of radial gradient
			var focalPtRatio:Number = 0;

			// ----------------------------------------------------------------------
			// Step 1. Create a radial gradient mask that fits within a gradient box.
			//		   Make the gradient box either square or landscape or portrait
			//		   depending on the setting of createSquareMask. If true, make
			//		   the gradient box square. If false, make the gradient box the
			//		   same dimensions as the original image (square,landscape,portrait).
			// Step 2. Apply a scale factor to the gradient box, if specified.
			//		   This could make box dimensions much larger than the original image.
			//		   This won't be a problem because the mask will get clipped to
			//		   the original image's dimension in the final draw() step.
			// Step 3. Draw the gradient box containing the mask into a maskShape
			//		   object to create the white on black radial gradient image.
			// Step 4. Draw the maskShape object (which contains the radial gradient 
			//		   mask centered within it) into a maskData bitmapdata object,
			//		   clipping the maskShape Shape object to fit exactly within the
			//		   maskData bitmapdata object. The user-specified focal point
			//		   (expressed as an X,Y percentage pair) will be used to 
			//		   shift the maskShape image so that the mask is centered
			//		   at the X,Y focal point in the bitmapdata object.
			// ----------------------------------------------------------------------

			// ----------------------------------------------------------------------
			// Step 1. Create a radial gradient mask that fits within a gradient box.
			//		   Make the gradient box either square or landscape or portrait
			//		   depending on the setting of createSquareMask. If true, make
			//		   the gradient box square. If false, make the gradient box the
			//		   same dimensions as the original image (square,landscape,portrait).
			// ----------------------------------------------------------------------
			if( createSquareMask == false )
			{
				// We'll create a maskShape that matches the original image aspect ratio,
				// by using the original image dimensions for the box that will contain
				// the mask. We won't need to shift the maskShape image to center it
				// within the new bitmapdata image because the dimensions of the 
				// maskShape image match the original image. We're setting it here.
				// Note that the mask could be either square (width == height) or 
				// elliptical (width != height).
				boxWidth  = width;  // define maskShape's dimensions
				boxHeight = height;
			}
			else
			{
				// We'll create a circular mask, not an elliptical mask, ignoring
				// the original image's aspect ratio. We'll do this by creating
				// a square maskShape that uses the smaller of the original image's
				// X and Y dimensions, so that the circular mask image (not elliptical)
				// stays within the original image's boundaries. But we will need to
				// center the maskShape within the new bitmapdata image if the bitmapdata
				// image is either landscape (width > height) or portrait (width < height).
				// - If the original image is a landscape image (width > height), 
				//   we'll need to shift the maskShape image to the right to center
				//   the mask in the bitmapdata image along the x-axis.
				// - If the original image is square (width == height), the maskShape 
				//   will match its dimensions, so there'll be no need to shift 
				//   the maskShape image to center it.
				// - If the original image is a portrait image (width < height),
				//   we'll need to shift the maskShape image down to center
				//   the mask in the bitmapdata image along the y-axis.
				boxWidth  = minDimension;  // define maskShape's dimensions
				boxHeight = minDimension;
			}

			// ----------------------------------------------------------------------
			// Step 2. Apply a scale factor to the gradient box, if specified.
			//		   This could make box dimensions much larger than the original image.
			//		   This won't be a problem because the mask will get clipped to
			//		   the original image's dimension in the final draw() step.
			// ----------------------------------------------------------------------
			if( maskScaleFactor < RADIAL_MASK_SCALE_FACTOR_MIN )
			{	maskScaleFactor = RADIAL_MASK_SCALE_FACTOR_MIN;		}
			if( maskScaleFactor > RADIAL_MASK_SCALE_FACTOR_MAX )
			{	maskScaleFactor = RADIAL_MASK_SCALE_FACTOR_MAX;		}

			boxWidth  *= maskScaleFactor;
			boxHeight *= maskScaleFactor;

			// ----------------------------------------------------------------------
			// Step 3. Draw the gradient box containing the mask into a maskShape
			//		   object to create the white on black radial gradient image.
			// ----------------------------------------------------------------------
			// Note: The gradient box, which defines the dimensions of the
			// radial gradient mask won't match the original image's dimensions
			// if useOrigAspectRatio == false (we'll create a square mask) and the
			// original image isn't square. In that case, tx or ty has been set above 
			// to center the square mask that's in the gradient box within the 
			// non-square maskShape image (before we copy it to the new bitmapdata image).
			tx = 0;
			ty = 0;
			gradientMatrix.createGradientBox( boxWidth, boxHeight, boxRotation, tx, ty );
			// Since we're reusing the maskShape Shape object, make sure it's empty.
			maskShape.graphics.clear();
			maskShape.graphics.beginGradientFill( type, colors, alphas, ratios,
								gradientMatrix, spreadMethod, interp, focalPtRatio );
			maskShape.graphics.drawRect( 0, 0, boxWidth, boxHeight );
			maskShape.graphics.endFill();

			// ----------------------------------------------------------------------
			// Step 4. Draw the maskShape object (which contains the radial gradient 
			//		   mask centered within it) into a maskData bitmapdata object,
			//		   clipping the maskShape Shape object to fit exactly within the
			//		   maskData bitmapdata object. The user-specified focal point
			//		   (expressed as an X,Y percentage pair) will be used to 
			//		   shift the maskShape image so that the mask is centered
			//		   at the X,Y focal point in the bitmapdata object.
			// ----------------------------------------------------------------------

			tx = 0;
			ty = 0;
			if( ( boxWidth < width )   // Has the Gradient Box above been scaled down?
									   // (or we're creating a square mask for a landscape image?)
			 || ( boxWidth > width ) ) // Has Gradient Box above been scaled up?
			{
				// If scaled up, will be negative, shifting mask left, what we want.
				// If square, will be positive, shifting mask right, what we want.
				tx = ( width - boxWidth ) / 2; 
			}
			if( ( boxHeight < height )   // Has the Gradient Box above been scaled down?
										 // (or we're creating a square mask for a portrait image?)
			 || ( boxHeight > height ) ) // Has the Gradient Box above been scaled up?
			{
				// If scaled up, will be negative, shifting mask up, what we want.
				// If square, will be positive, shifting mask down, what we want.
				ty = ( height - boxHeight ) / 2;
			}

			// Now account for the movement of the mouse to reposition 
			// the focal point of the mask. xPercent, yPercent now contain
			// the focal point for the thumbnail image.
			var xShift:int;
			var yShift:int;
			var xxPercent:Number;
			var yyPercent:Number;

			// Before:   0% is left edge, 100% is right edge.
			// After : -50% is left edge, +50% is right edge.
			xxPercent = xPercent - 50.0; // Before: 0% is left edge, 100% is right edge.
			yyPercent = yPercent - 50.0; // Before: 0% is top  edge, 100% is bottom edge.
			xShift = (xxPercent/100.0) * width; // xPercent of 0--> (-width/2), xPercent of 100--> (+width/2)
			yShift = (yyPercent/100.0) * height;

			tx = tx + xShift; 
			ty = ty + yShift;

			// [  a  c  tx  ] -- Transformation matrix (2-dimensional)
			// [  b  d  ty  ]
			// [  u  v  w   ] (u,v,w can't be specified here in this matrix)
			// Scaling    :  a == Sx, d == Sy  (not used here)
			// Translation:  tx, ty (used to center and/or position mask at focal point)
			// Rotation   :  a == cos(q), b == sin(q), c == -sin(q), d == cos(q)
			// No need for the x,y scale factors because scaling the maskScaleFactor
			// is used above to scale the gradient box's boxWidth,boxHeight which 
			// then scales the mask image.
			maskMatrix.a  = 1.0; // Sx: x-scale factor (not used here)
			maskMatrix.b  = 0;
			maskMatrix.c  = 0;
			maskMatrix.d  = 1.0; // Sy: y-scale factor (not used here)
			maskMatrix.tx = tx;  // used to center and/or position mask at focal point
			maskMatrix.ty = ty;  // used to center and/or position mask at focal point

//			maskData.draw( maskShape, maskMatrix, colorTransform, blendModeStr, clipRect, smoothing );
			// No need to use the clipping rectangle, because clipping of the
			// maskShape to the bitmapdata object dimensions is done automatically
			// by the draw() method. The clipping rectangle is for additional clipping.
			maskData.draw( maskShape, maskMatrix, null,null, null, true );

			return( maskData );

		} // END OF ... public function createRadialGradient( targBD:BitmapData, maskData:BitmapData )


		// -----------------------------------------------------------------------
		public function createLinearGradient( targBD:BitmapData, finalMaskData:BitmapData ):BitmapData
		{
// http://help.adobe.com/en_US/ActionScript/3.0_ProgrammingAS3/WS5b3ccc516d4fbf351e63e3d118a9b90204-7dd7.html
			var width:int  = targBD.rect.width;
			var height:int = targBD.rect.height;

			// Declare the parameters needed by createGradientBox()
			var boxWidth:Number;
			var boxHeight:Number;
			var boxRotation:Number = 0; // Math.PI/2; // 90°  (in radians)
			var tx:Number = 0;
			var ty:Number = 0; 

//			var xShift:int;
			var yShift:int;
//			var xxPercent:Number;
			var yyPercent:Number;

			// Define parameters needed by beginGradientFill()
			var type:String  = GradientType.LINEAR; // GradientType.LINEAR or GradientType.RADIAL.

			// 0xFFFFFF==White is at the bottom of the image, fading updwards to: 0x000000==Black
			var colors:Array = [0xffffff, 0xbbbbbb, 0x000000, 0x000000];
			var alphas:Array = [1, 1, 1, 1 ];
			var ratios:Array = [0, 175, 225, 255];

			var spreadMethod:String = SpreadMethod.PAD; // PAD, REFLECT, REPEAT
			var interp:String = InterpolationMethod.RGB; //LINEAR_RGB; // LINEAR_RGB, RGB
			// Position focal point ratio within radial gradient. ( -1 .. 0 .. +1 )
			//  0 == focal point ratio is in center of radial gradient
			// -1 == focal point ratio is at far left of radial gradient
			// +1 == focal point ratio is at far right of radial gradient
			// The X,Y "focal point ratio" used by this component is always the center 
			// of the mask and has nothing to do with the "focal point" term 
			// used by beginGradientFill(). The focal point ratio refers to 
			// "the eye of the eye ball" (eg: for a circular gradient).
			var focalPtRatio:Number = 0; // 0 means put the focal point at the center
										 // of the mask (the "eye of the eye ball").

			// ------------------------------------------------------------------------
			// Step 1. Restrict the user's maskScaleFactor to stay within working range.
			// Step 2. Create mask in maskForBottomShape for bottom half of final image.
			// Step 3. Align bottom mask shape at image top (y==0) so vertical scaling works.
			// Step 4. Prepare mask image for holding masks by filling with opaque white.
			// Step 5. Draw bottom mask into temp mask bitmapdata image (no need to crop).
			// Step 6. Create mask in maskForTopShape for the top half of image.
			// Step 7. Since y==0 is at image top, vertical scaling works as needed.
			// Step 8. Draw/merge/crop top mask into temp mask image with bottom mask.
			// Step 9. Reposition temp image into final mask at user-specified focal point.
			// ------------------------------------------------------------------------

			// ------------------------------------------------------------------------
			// Step 1. Restrict the user's maskScaleFactor to stay within working range,
			// so that the two linear gradient masks that will be put into
			// the bottom half of the image and the top half of the image both 
			// expand and contract so the two masks act as one mask seamlessly.
			// ------------------------------------------------------------------------
			// Keep the maskScaleFactor within a restricted range so that the
			// maskForBottomShape can be combined with a vertically flipped version of
			// itself, maskForTopShape, without any mask artifacts (gaps between them, etc).
			// By restricting the scale factor, the 2 masks can be seamlessly cropped
			// at the image half way point and merged together prior to repositioning
			// the final mask at the user's mouse down point. This will work
			// for any size image because it's based on percentage, not pixels.
			// For example, the range is: [ 0.35 .. 2.5 ]  (see above for exact values)
			if( maskScaleFactor < LINEAR_MASK_SCALE_FACTOR_MIN )
			{	maskScaleFactor = LINEAR_MASK_SCALE_FACTOR_MIN;		}
			if( maskScaleFactor > LINEAR_MASK_SCALE_FACTOR_MAX )
			{	maskScaleFactor = LINEAR_MASK_SCALE_FACTOR_MAX;		}

			// ------------------------------------------------------------------------
			// Step 2. Create mask in maskForBottomShape for bottom half of final image.
			// Black at bottom fading upwards to white at half way point in image.
			// With masks, white pixels in the alpha channel select pixels to be copied.
			// If the gradient box holding the mask has been scaled down,
			// the gradient box holding the mask will be shorter than the bottom half
			// of the final image (or taller than the bottom half if scaled up).
			// ------------------------------------------------------------------------
			boxWidth  = width;  // define maskShape's dimensions
			boxHeight = height * maskScaleFactor;

			boxRotation = Math.PI/2; // Math.PI/2; // 90°  (in radians)
			tx = 0;		ty = 0;
			gradientMatrix.createGradientBox( boxWidth, boxHeight, boxRotation, tx, ty );
			// Since we're continually reusing the maskForBottomShape Shape object, 
			// make sure it's empty of any previous linear gradient we've written to it.
			maskForBottomShape.graphics.clear();
			maskForBottomShape.graphics.beginGradientFill( type, colors, alphas, ratios,
								gradientMatrix, spreadMethod, interp, focalPtRatio );
			// Draw rectangle containing the linear gradient mask (black to white going up)
			// The boxHeight can be larger or smaller than the bottom half of final image.
			maskForBottomShape.graphics.drawRect( 0, 0, boxWidth, boxHeight );
			maskForBottomShape.graphics.endFill();

			// ------------------------------------------------------------------------
			// Step 3. Align bottom mask shape at image top (y==0) so vertical scaling works.
			// ------------------------------------------------------------------------
			tx = 0; // 0 == linear gradient mask is fixed along the x-axis
			ty = 0;
			if( ( boxHeight < height )   // Has the Gradient Box above been scaled down?
			 || ( boxHeight > height ) ) // Has the Gradient Box above been scaled up?
			{
				// Keep top of scaled gradient box aligned at top of image (prior to
				// cropping and merging with top mask in other half of image) so that
				// we're moving the shape's bottom half, where the gradient is,
				// up towards the center of the image (when scaling up). We only need
				// to do this vertical translation, using ty, for the shape's bottom
				// half because of how scaling interacts with y==0 (top of an image).
				// The mask for image top half will already be aligned at the top. 
				ty = height - boxHeight;
			}

			// NOTE: We can't use ty to reposition the mask yet at this step 
			// (by adding in an additional yShift value) because we first have to 
			// crop it into the lower half of the final image, then merge it 
			// with the reflected mask we'll create for the top half of the image
			// before we can reposition the combined mask image.

			maskMatrix.a  = 1.0; // Sx: x-scale factor (not used here)
			maskMatrix.b  = 0;
			maskMatrix.c  = 0;
			maskMatrix.d  = 1.0; // Sy: y-scale factor (not used here)
			maskMatrix.tx = 0;   // not used here
			maskMatrix.ty = ty;  // keep top of scaled gradient box aligned at top of
								 // image prior to cropping and merging with top mask.

			// ------------------------------------------------------------------------
			// Step 4. Prepare mask image for holding masks by filling with opaque white.
			// ------------------------------------------------------------------------
			// Fill the temp bitmapdata image, mergedMaskData, with white opaque pixels
			// so that when we write the bottom and top half masks into this temp image 
			// object, pixels not covered by the top or bottom half masks (due to being
			// scaled down smaller than half the image) will be white, showing no gaps.
			// If the user contracts the mask, the top and bottom halves will separate
			// and move apart, opening up a gap between them. We must make the pixels
			// in this gap (in the mergedMaskData bitmapdata image) opaque white since
			// that's what the pixels are at the edge of the separating top and bottom 
			// masks. In this way, the 2 masks (top and bottom) will combine seamlessly.
			// Then we'll reposition at user-specified focal point in the final mask image.
			mergedLinearMaskData.fillRect( targBD.rect, 0xFFFFFFFF ); // fill with white opaque pixels

			// ------------------------------------------------------------------------
			// Step 5. Draw bottom mask into temp mask bitmapdata image (no need to crop).
			// ------------------------------------------------------------------------
// parms:	mergedLinearMaskData.draw( maskForBottomShape, maskMatrix, colorTransform, blendModeStr, clipRect, smoothing );
			mergedLinearMaskData.draw( maskForBottomShape, maskMatrix, null,null,null, true ); 

			// ------------------------------------------------------------------------
			// Step 6. Create mask in maskForTopShape for the top half of image.
			// Black at top fading downwards to white at half way point in image.
			// With masks, white pixels in the alpha channel select pixels to be copied.
			// If the gradient box holding the mask has been scaled down,
			// the gradient box holding the mask will be shorter than the top half
			// of the final image (or taller than the top half if scaled up).
			// ------------------------------------------------------------------------
			// Flip the linear gradient orientation by 180 degrees (3*PI/2) from
			// the bottom linear gradient mask to place the next mask in the top half 
			// of the final image (instead of bottom half, as we did above).
			boxRotation = 3.0 * Math.PI/2; // Math.PI/2; // 90°  (in radians)
			tx = 0; // 0 == linear gradient mask is fixed along the x-axis
			ty = 0;
			gradientMatrix.createGradientBox( boxWidth, boxHeight, boxRotation, tx, ty );
			// Since we're reusing the maskForTopShape Shape object, make sure it's empty.
			maskForTopShape.graphics.clear();

			maskMatrix.a  = 1.0; // Sx: x-scale factor (not used here)
			maskMatrix.b  = 0;
			maskMatrix.c  = 0;
			maskMatrix.d  = 1.0; // Sy: y-scale factor (not used here)
			maskMatrix.tx = 0;   // not used here (reposition mask at focal point below)
			maskMatrix.ty = 0;   // not used here (reposition mask at focal point below)
			maskForTopShape.graphics.beginGradientFill( type, colors, alphas, ratios,
								gradientMatrix, spreadMethod, interp, focalPtRatio );
			maskForTopShape.graphics.drawRect( 0, 0, boxWidth, boxHeight );
			maskForTopShape.graphics.endFill();

			// ------------------------------------------------------------------------
			// Step 7. Since y==0 is at image top, vertical scaling works as needed.
			// ------------------------------------------------------------------------

			// ------------------------------------------------------------------------
			// Step 8. Draw/merge/crop top mask into temp mask image with bottom mask.
			// Draw top mask into temp mask image, cropping to top half of the
			// final mask image, overwriting unneeded part of bottom mask that
			// may have extended above image half-way point due to scaling up.
			// ------------------------------------------------------------------------
			// Note: for the clipping rectangle, y==0 is at the top of the image,
			//       and y==height is at the bottom of the image.
			//		 Specifying y==0 puts the clipping rectangle at the top of the image. 
			//		 y==height puts the clipping rectangle's top edge at the very bottom 
			//		 of the image, with the rest of it extending below the image, out of sight.

			// We must clip the top mask (to a rectangle in the top half of the image)
			// while we draw here so that if the mask has been scaled up (beyond 50%)
			// so that it goes down below the image half-way point, the crop operation 
			// will prevent it from overwriting the mask in the bottom half 
			// of the final mask image.
			clipRect.x = 0;
			clipRect.y = 0; // y==0 is at the top of the image.
			clipRect.width  = targBD.rect.width;
			clipRect.height = height/2; // mask goes from image top down to half-way point.

// parms:	mergedLinearMaskData.draw( maskForTopShape, maskMatrix, colorTransform, blendModeStr, clipRect, smoothing );
			mergedLinearMaskData.draw( maskForTopShape, maskMatrix, null,null, clipRect, true );


			// ------------------------------------------------------------------------
			// Step 9. Reposition temp image into final mask at user-specified focal point.
			// ------------------------------------------------------------------------
			// Handle Mouse repositioning of the DepthEffect X,Y focal point:
			// Before:   0% is left edge, 100% is right edge.
			// After : -50% is left edge, +50% is right edge.
//			xxPercent = xPercent - 50.0; // Before:   0% is left edge, 100% is right edge.
			yyPercent = yPercent - 50.0; // Before:   0% is top  edge, 100% is bottom edge.
										 // After : -50% is top  edge, +50% is bottom edge.
			yShift = (yyPercent/100.0) * height;
//			tx = xShift;
			tx = 0;
			ty = yShift;
//trace( "Depth: linGrad: yyPercent: " + yyPercent + ", yShift: " + yShift );

			maskMatrix.a  = 1.0; // Sx: x-scale factor (not used here)
			maskMatrix.b  = 0;
			maskMatrix.c  = 0;
			maskMatrix.d  = 1.0; // Sy: y-scale factor (not used here)
			maskMatrix.tx = tx;  // Reposition mask at user-specified mouse focal point
			maskMatrix.ty = ty;  // Reposition mask at user-specified mouse focal point

			// Fill final mask image with black opaque pixels so that 
			// when the user moves the combined mask image off center (vertically only),
			// this will reveal the black pixels "underneath", which will match
			// the black pixels at the top and bottom edges of the combined mask.
			finalMaskData.fillRect( targBD.rect, 0xFF000000 ); // fill with black opaque pixels

			// NOTE: No clipping rectangle is used here because whatever part of the
			// merged mask goes beyond the border of the finalMaskData bitmapdata image
			// will be automatically clipped by it's draw() method.
// parms:	finalMaskData.draw( mergedLinearMaskData, maskMatrix, colorTransform, blendModeStr, clipRect, smoothing );
			finalMaskData.draw( mergedLinearMaskData, maskMatrix, null,null,null, true );


			return( finalMaskData );

		} // END OF ... public function createLinearGradient( targBD:BitmapData, finalMaskData:BitmapData )


		// -----------------------------------------------------------------------
		// Create a uniformly darkened image in targImageData using the specified 
		// darkenLevel in an alpha channel to mix a copy of the original image pixels 
		// in origImageData into a black background. Darkening makes the mask easier 
		// for the user to see, and also lets the user interactively create 
		// a vignette effect if desired.
		// Return a reference to the updated targImageData image object.
		// Example call:
		//   var darkenLevel:int = 0x40; // 0x30 was too dark, 0x70 wasn't dark enough
		//   targImageData = createUniformlyDarkenedImage( targImageData, darkenLevel, 
		//												   focusImageData );
		private function createUniformlyDarkenedImage( targImageData:BitmapData,
						 darkenLevel:int, origImageData:BitmapData ):BitmapData
		{
			var colorVal:int;

			// Reuse the darkenMaskData image object (allocated in the constructor)

			// Fill darkenMaskData with opaque 0x3C darkenLevel levels stored into the ALPHA channel.
			// We'll use the contents of the ALPHA channel below as a constant mask to control 
			// how much of the orig image we'll mix into a completely black background to
			// create a uniformly darkened image (doesn't matter which chnl (R,G,B) we use).

			// Store darkenLevel (eg: 0x40) in ALPHA chnl, eg: 0x3C000000.
			// (We'll shift the darkenLevel level left 24 bits to store it in the top byte).
			colorVal = darkenLevel << 24; // store darkenLevel in the ALPHA chnl for each pixel.
			darkenMaskData.fillRect( targImageData.rect, colorVal ); // eg: 0x3C000000 for every pixel

			// Next, fill the target image with all black opaque pixels that
			// we'll mix the original image pixels into using the darken mask's alpha channel.
			targImageData.fillRect( targImageData.rect, 0xFF000000 ); // fill with black opaque pixels

			// Copy the original image pixels, partially selected by an alpha mask,
			// and mix those pixels into a completely black opaque background image
			// to create a uniformly darkened image, mixed with black according to 
			// the specified alpha channel darkenLevel level stored in darkenMaskData.
			// targImageData[ pixel ] = targImageData[ pixel ] (contains black opaque pixels)
			//							mixed with origImageData[ pixel ]
			//							using the ALPHA chnl in darkenMaskData (eg: 0x3C000000)
			targImageData.copyPixels( origImageData, targImageData.rect, point0,
									  darkenMaskData, point0, true ); // mergeAlpha=true

			return( targImageData );

		} // END OF ... private function createUniformlyDarkenedImage( targImageData:BitmapData,
		  //							 darkenLevel:int, origImageData:BitmapData ):BitmapData


		// -----------------------------------------------------------------------
		public function apply():void
		{
			var red  : Array = [];
			var green: Array = [];
			var blue : Array = [];
			var alpha: Array = null;
			var i:int;

			var srcChannel:uint;
			var destChannel:uint;
			var darkenLevelValue:int;

			// Create a temporary image to hold the "Focus Effect" (optional Curves applied)
			// that we'll create below on the current (unblurred) target image.
			// 0x00 - fully transparent (alpha), 0x000000 - black (A,R,G,B: 0x00000000)
			// So we make a copy of the original image into focusImageData 
			// before we blur it below.

			focusImageData.fillRect( targImageData.rect, 0x00000000 ); // fill with black transparent pixels

			// Create this temp image by copying over all 32-bit ARGB pixel data 
			// from the current target image.
			focusImageData.copyPixels( targImageData, targImageData.rect, point0 );


			if( curvesFlag == true )
			{
				// Step 1. Curves #1. Apply color adjustments. RGB Curve: 3 points.
				for (i=0; i < 256; i++){
					red[  i]=curves1Poly.getVal(i) << (8*2);
					green[i]=curves1Poly.getVal(i) << 8;
					blue[ i]=curves1Poly.getVal(i);
				}
				targImageData.paletteMap(targImageData,targImageData.rect,point0,red,green,blue,alpha);

				// Step 2. Curves #2. Apply color adjustments. Red Curve: 3 points.
				for (i=0; i < 256; i++){
					red[  i]=curves2Poly.getVal(i) << (8*2);
				}
				// Step 3. Curves #3. Apply color adjustments. Blue Curve: 3 points.
				for (i=0; i < 256; i++){
					blue[ i]=curves3Poly.getVal(i);
				}
				targImageData.paletteMap(targImageData,targImageData.rect,point0,red,null,blue,alpha);


				// Steps 4-5: Apply these next 2 "Focus" Curves to a copy of the image.

				// Step 4. Curves #4. Apply color adjustments. Red Curve: 3 points.
				for (i=0; i < 256; i++){
					red[  i]=curves2Poly.getVal(i) << (8*2);
				}
				// Step 5. Curves #5. Apply color adjustments. Blue Curve: 3 points.
				for (i=0; i < 256; i++){
					blue[ i]=curves3Poly.getVal(i);
				}
				// Apply steps 4, 5 to copy of original image for "warmed" image.
				focusImageData.paletteMap( focusImageData,focusImageData.rect,point0,red,null,blue,alpha);

			} // END OF ... if( curvesFlag == true )

			if( darkenFlag == true )
			{
				// Create a uniformly darkened image in targImageData using the specified 
				// darkenLevel in an alpha channel to mix a copy of the original image pixels 
				// into a black background. This makes the mask easier for the user to see,
				// and also lets the user interactively create a vignette effect if desired.
				darkenLevelValue = darkenLevel; // eg: 0x40 (0x30 was too dark, 0x70 wasn't dark enough)
				targImageData = createUniformlyDarkenedImage( targImageData, darkenLevelValue,
															  focusImageData );
			}

			if( desatFlag == true )
			{
				/* The following code requires these 3 Classes from Adobe Flash CS4 */
				/* to be in the same directory: AdjustColor.as, ColorMatrix.as, DynamicMatrix.as. */
				var combinedFilterDesat:ColorMatrixFilter;
				var adjustColor:AdjustColor;

				adjustColor = new AdjustColor();
				adjustColor.brightness = 0.0;    /* brightnessSliderVal:  -100 .. +100 */
				adjustColor.contrast   = 0.0;    /* contrastSliderVal  :  -100 .. +100 */
				adjustColor.saturation = -100.0; /* saturationSliderVal:  -100 .. +100 */
				adjustColor.hue        = 0.0;    /* hueSliderVal       :  -180 .. +180 */
				combinedFilterDesat = new ColorMatrixFilter( adjustColor.CalculateFinalFlatArray() );
				/* image.filters = [ new ColorMatrixFilter( color.CalculateFinalFlatArray() ) ]; */
				targImageData.applyFilter( targImageData,
										   targImageData.rect, 
										   point0, combinedFilterDesat );
			}

			if( blurFlag == true )
			{
				// Blur the entire targetImageData object.
				// Apply the Blur filter to the image in place.
				targImageData.applyFilter( targImageData, targImageData.rect, point0, blurFilter );
			}


			// Create Focus Effect's copy mask bitmapdata object as an RGB image.
			maskData.fillRect( targImageData.rect, 0xFF000000 ); // fill with black opaque pixels

			if( gradientStyle == RADIAL_GRADIENT_STYLE )
			{
				// Create the radial gradient mask that we'll use to control
				// which pixels will be merged from the original image into
				// a fully blurred (or uniformly darkened, etc.) copy of the original image.
				maskData = createRadialGradient( targImageData, maskData );
			}
			else
			{
				// Create the linear gradient mask that we'll use to control
				// which pixels will be merged from the original image into
				// a fully blurred (or uniformly darkened, etc.) copy of the original image.
				maskData = createLinearGradient( targImageData, maskData );
			}

			// Any pixel data channel will work (R,G or B) because the mask image
			// was created as a black and white image (so R == G == B) (but we can't 
			// use the Alpha chnl because the mask image is an opaque image 
			// so its Alpha channel must be all 0xFF's).

			// Copy the maskData pixels into the original image's alpha chnl for the next step.
			// Copy the Red channel pixel data from maskData (pick either R, G or B since R==G==B)
			//    to the alpha channel of the focusImageData object which
			//    contains a copy of the filtered but unblurred image.
			// focusImageData [Alpha channel] = maskData [Red channel].
			focusImageData.copyChannel( maskData, targImageData.rect, point0,
									    BitmapDataChannel.RED, // any of R,G,B chnls will do (R==G==B)
									    BitmapDataChannel.ALPHA ); // srcChnl, destChnl

			// Merge the unblurred focusImageData object, which has the Focus Effect
			// mask's pixel data as its alpha channel, into the blurred or darkened
			// targImageData. In this way, we are using the maskData to control 
			// what unblurred original pixels are merged into the blurred or darkened
			// targImageData image. Only pixels in the focusImageData object 
			// whose alpha values are > 0 will be merged into the targImageData object.

			targImageData.copyPixels( focusImageData, targImageData.rect, point0,
									  focusImageData, point0, true ); // mergeAlpha=true

		} // END OF ... public function apply():void
	
		public function applyComplete(img:Image_):void{
			var editBM:Bitmap= img.returnEditImage(Consts.EDIT_FILTER);
			initImage(editBM);
			apply();
		}
	} // END OF ... public class FocusEffect implements IFilter

} // END OF ... package actionObj.filters
