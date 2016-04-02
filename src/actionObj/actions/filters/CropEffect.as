package actionObj.actions.filters
{
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// File Name: actionObj.filters.CropEffect.as - ActionScript 3.0 Component 
//												which implements IFilter
// Author   : Brian Barry
// Date     : 6/6/13 Thursday
// File Name: CropEffect.as
//
// Version Changes:
// - - - - - - - -
// v1.0 - 6/6/13, Original version:
//		- CropEffect.as now has 528 lines of code. That's 9 pages in this file.
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Methods Defined:
// ----------------
// 1.  CropEffect() - Class Constructor
// 2.  setDarkenFlag()
// 3.  getDarkenFlag()
// 4.  setDarkenLevel()
// 5.  getDarkenLevel()
// 6.  reset()
// 7.  createUniformlyDarkenedImage()
// 8.  createDoubleDashHoriz()
// 9.  createDoubleDashVert()
// 10. drawCropBox()
// 11. drawEightHandlesOnCropBox()
// 12. apply()
// 13. getCroppedImageRef()
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//	Sample code to apply Crop Effect to a bitmapdata image:
//  --------------------------------------------------------
//	import actionObj.filters.CropEffect;
//
//	var cropEffect:CropEffect;
//	var xPercent:Number;
//	var yPercent:Number;
//	var cropEffect_maskScaleFactor:Number;
//
//  // Mouse events can be used to alter the focal point and mask scale factor
//  // to let the user interactively modify the Crop Effect as needed.
//
//	cropEffect = new CropEffect( App.targetImageData );
//	xPercent = CropEffect.USER_X_PERCENT_DEFAULT;
//	yPercent = CropEffect.USER_Y_PERCENT_DEFAULT;
//	cropEffect.setFocalPoint( xPercent, yPercent );
//
//	cropEffect.setDarkenFlag(  CropEffect.DARKEN_FLAG_DEFAULT  );
//	cropEffect.setDarkenLevel( CropEffect.DARKEN_LEVEL_DEFAULT );
//				Range: 0 < N < 255. 0:fully black pixels, 64:darkened orig image (default), 255:orig image
//
//	cropEffect.apply(); // Apply Crop Effect to App.targetImageData image.
//
//  Alternate method: To apply the Crop Effect once, if there's no user interaction...
//  -----------------
//	cropEffect = new CropEffect( App.targetImageData,
//								   CropEffect.USER_X_PERCENT_DEFAULT,
//								   CropEffect.USER_Y_PERCENT_DEFAULT,
//								   CropEffect.DARKEN_FLAG_DEFAULT,
//								   CropEffect.DARKEN_LEVEL_DEFAULT );
//	cropEffect.apply(); // Apply Crop Effect to App.targetImageData image.
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	import actionObj.Consts;
	import actionObj.image.Image_;
	import actionObj.image.Photo;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;

	// -----------------------------------------------------------------------
	public class CropEffect
	{
		private var targImageBD:BitmapData;
		private var cropImageBD:BitmapData;
		private var darkenedImageBD:BitmapData;
		private var croppedTargImageBD:BitmapData = null;

		private var point0:Point = new Point( 0, 0 );
		private var point1:Point = new Point( 0, 0 );
		public static const MOUSE_DOWN_SELECT_LINE_NONE:int = 0;
		
		public static const MOUSE_DOWN_SELECT_TOP_LEFT_CORNER:int = 1;
		public static const MOUSE_DOWN_SELECT_TOP_RIGHT_CORNER:int = 2;
		public static const MOUSE_DOWN_SELECT_BOTTOM_RIGHT_CORNER:int = 3;
		public static const MOUSE_DOWN_SELECT_BOTTOM_LEFT_CORNER:int = 4;
		
		public static const MOUSE_DOWN_SELECT_TOP_LINE:int = 5;
		public static const MOUSE_DOWN_SELECT_RIGHT_LINE:int = 6;
		public static const MOUSE_DOWN_SELECT_BOTTOM_LINE:int = 7;
		public static const MOUSE_DOWN_SELECT_LEFT_LINE:int = 8

		public static const CROPBOX_SELECTION_PIXEL_TOLERANCE_X:int = 4;
		public static const CROPBOX_SELECTION_PIXEL_TOLERANCE_Y:int = 4;			

		public static const CROPBOX_MIN_WIDTH:int = 6;
		public static const CROPBOX_MIN_HEIGHT:int = 6;
		
		// Caller can use this constant to set the initial size of 
		// the cropbox rectangle relative to the image to be cropped.
		public static const INITIAL_CROP_BOX_SCALE_FACTOR:Number = 0.50;

		public static const DARKEN_FLAG_DEFAULT:Boolean = true;
		public static const DARKEN_LEVEL_DEFAULT:int    = 0x90; // 0x30 was too dark
		// Range: 0 < N < 255. 0:fully black pixels, 90:darkened orig image (default), 255:orig image

		private var darkenFlag:Boolean = DARKEN_FLAG_DEFAULT;

		// darkenLevel is used in an alpha channel to (partially) select pixels
		// from the original image to mix with a completely black background image, 
		// as a way to darken the original image (without using curves or polynomials).
		// - 0x00 selects nothing of the pixel from orig image leaving only the black background
		// - 0x40 selects part of the pixel (0x40==64) from orig image leaving a mix of
		//   orig pixel and black pixel, but mostly uses the black pixel because
		//   0x3C is < 50% (a 50% mix of orig pixel with black would be 255/2 = 127 or 0x7F).
		// - 0xFF selects entire pixel from orig image leaving only the orig image.
		private var darkenLevel:int  = DARKEN_LEVEL_DEFAULT; // 0x30 was too dark

		private var cropShape:Shape   = new Shape();
		private var cropMatrix:Matrix = new Matrix( 1, 0, 0, 1,  0, 0 ); // a,b,c,d, tx,ty
		private var dashColorOne:uint = 0xFF000000; // black color for creating dashed line
		private var dashColorTwo:uint = 0xFFFFFFFF; // white color for creating dashed line

		private var curCropBoxRect:Rectangle;
		private var cropBoxRect:Rectangle = new Rectangle( 0, 0, 0, 0 );
		private var mouseDownX:int;
		private var mouseDownY:int;
		private var mouseDownSelectLine:int=CropEffect.MOUSE_DOWN_SELECT_LINE_NONE;
		private var cropBoxColorFlg:Boolean = true;
		private var cropBoxColorFlgCounter:int = 0;
		private var xMarginPx:int=CropEffect.CROPBOX_SELECTION_PIXEL_TOLERANCE_X;
		private var yMarginPx:int=CropEffect.CROPBOX_SELECTION_PIXEL_TOLERANCE_Y;		
		private var mouseDownCropBoxRect:Rectangle = new Rectangle( 0, 0, 0, 0 );
		private var mouseDownCropBoxX_rightEdge:int=0;
		private var mouseDownCropBoxY_bottomEdge:int = 0;
		public static const desc:String = "Crop Effect, v1.0 (5/31/13)";
		private var photo:Photo;

		public function CropEffect(_photo:Photo, _darkenFlag:Boolean = DARKEN_FLAG_DEFAULT, _darkenLevel:int = DARKEN_LEVEL_DEFAULT ){
			photo=_photo;
			targImageBD = new BitmapData(photo.getFullSizedImage().returnScaledImage().width,
				photo.getFullSizedImage().returnScaledImage().height, true, 0);
			targImageBD.draw(photo.getFullSizedImage().returnEditImage(Consts.EDIT_FILTER + Consts.EDIT_EFFECT));
			// Create a temporary image to hold the "Crop Effect" that
			// we'll create in apply() below on the current (unblurred) target image. 
			// 0x00 - fully transparent (alpha), 0x000000 - black (A,R,G,B: 0x00000000)
			cropImageBD = new BitmapData( targImageBD.rect.width,
				targImageBD.rect.height, true, 0x00000000 ); // fill with transparent black pixels (0x00==black)
			
			darkenedImageBD = new BitmapData( targImageBD.rect.width, targImageBD.rect.height,
				true, 0xFF000000 ); // fill with opaque black pixels (0x00==black)			
			curCropBoxRect = new Rectangle( 0, 0, 0, 0 );
			cropReset();
			setDarkenFlag(  _darkenFlag );
			setDarkenLevel( _darkenLevel );			
		}
		
		public function cropReset():void{
			resetCropBoxToDefault();
			cropImageBD = new BitmapData(getBitmapData().rect.width,getBitmapData().rect.height, true, 0xFF000000);
			drawCropBox(cropImageBD, cropBoxRect,  dashColorOne, dashColorTwo );
		}
		
		public function cropCancel():void{
			cropBoxRect.x+=50;					
			drawCropBox(cropImageBD,  cropBoxRect,  dashColorOne, dashColorTwo );				
		}
		
		private function resetCropBoxToDefault():void
		{
			cropBoxRect.width  = getBitmapData().rect.width  
				* CropEffect.INITIAL_CROP_BOX_SCALE_FACTOR;
			cropBoxRect.height = getBitmapData().rect.height 
				* CropEffect.INITIAL_CROP_BOX_SCALE_FACTOR;
			// Make sure that the width,height values are integral Numbers (no fractions)
			cropBoxRect.width  = Number( int( cropBoxRect.width ) );
			cropBoxRect.height = Number( int( cropBoxRect.height ) );
			
			// Center the cropbox on the working image.
			cropBoxRect.x = (getBitmapData().rect.width  - cropBoxRect.width ) / 2.0;
			cropBoxRect.y = (getBitmapData().rect.height - cropBoxRect.height) / 2.0;
			
			// Make sure that the x,y values are integral Numbers (no fractions)
			cropBoxRect.x = Number( int( cropBoxRect.x ) );
			cropBoxRect.y = Number( int( cropBoxRect.y ) );
			
		} // END OF ... private function resetCropBoxToDefault( cropBoxRect:Rectangle ):void
		
		
		public function getBitmapData(img:Image_=null):BitmapData{
			return targImageBD;		
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
			if( _darkenLevel < 0   ) {  _darkenLevel = 0;    }
			if( _darkenLevel > 255 ) {  _darkenLevel = 255;  }
			darkenLevel = _darkenLevel;
		}
		public function getDarkenLevel():int
		{
			return( darkenLevel );
		}

		// -----------------------------------------------------------------------
		public function reset():void  // Set back to defaults.
		{
			setDarkenFlag(  DARKEN_FLAG_DEFAULT );
			setDarkenLevel( DARKEN_LEVEL_DEFAULT );
		}

		public function onMouseMove(event:MouseEvent, mouseDown:Boolean):void{
			var mouseX:int;
			var mouseY:int;
			var graphX:int;
			var graphY:int;
			
			var tn1ImgHt:int = getBitmapData().height;
			mouseX = event.localX;			
			mouseY = event.localY;
			graphX = mouseX - 1;
			graphY = mouseY - 1;	
			
			var mouseIsInsideCropBox:Boolean;			
			mouseIsInsideCropBox = isMouseInsideCropBox( graphX, graphY,
				xMarginPx, yMarginPx, cropBoxRect );
			// Only move the Crop Effect around in the thumbnail image
			// if the mouse is still "down".
			if( mouseDown == false )
			{
				// User is moving the mouse and it's not down
				if( mouseIsInsideCropBox )
				{	Mouse.cursor="hand";	}
				else
				{
					// Mouse is not down and isn't inside the crop box. 
					// Maybe the mouse is on a crop box line?
					var mouseDownSelectLineTemp:int;
					
					mouseDownSelectLineTemp = convertMouseXYToSelectedLine( 
						graphX, graphY,
						xMarginPx, yMarginPx, cropBoxRect );
					
					if( mouseDownSelectLineTemp != CropEffect.MOUSE_DOWN_SELECT_LINE_NONE )
					{
						// The mouse is on one of the crop box lines, use the hand mouse cursor.
						Mouse.cursor="button";
					}
					else
					{
						// The mouse is NOT on any crop box line, use the arrow mouse cursor.
						Mouse.cursor="auto";
					}
				}
			}

			if( ( mouseDown == true ) 
				&& ( mouseIsInsideCropBox == false )
				&& ( mouseDownSelectLine == CropEffect.MOUSE_DOWN_SELECT_LINE_NONE ) )
			{
				// Mouse is down, is outside the crop box, and isn't on a crop box line,
				//  so don't move the crop box nor update the crop box boundary lines.
				Mouse.cursor="arrow";
			}
			if( ( mouseDown == true )
				&& (    ( mouseIsInsideCropBox == true )
					|| ( mouseDownSelectLine != CropEffect.MOUSE_DOWN_SELECT_LINE_NONE ) ) ){
				// Mouse is down, is either inside the crop box, or is on a crop box line,
				//  so let's move the crop box or update one of the crop box boundary lines.
				
				if( mouseDownSelectLine != CropEffect.MOUSE_DOWN_SELECT_LINE_NONE )
				{
					// Mouse is on one of the Crop Box lines, change mouse cursor to a button.
					Mouse.cursor="button";
				}
				else
				{
					// Mouse is inside the Crop Box (not on a line), change mouse cursor to a hand.
					Mouse.cursor="hand";
				}
				cropImageBD.fillRect(getBitmapData().rect, 0xFF000000 ); // fill with black opaque pixels
				var origCopy:BitmapData = new BitmapData(photo.getFullSizedImage().returnScaledImage().width,
					photo.getFullSizedImage().returnScaledImage().height, true, 0);			
				origCopy.draw(photo.getFullSizedImage().returnScaledImage());
				// Only swap the crop box dash colors on every 2nd mouse over event.
				// Each dash is actually made up of a black dash following by 
				// a white dash (or vice versa).
				if( ++cropBoxColorFlgCounter == 2 )
				{
					cropBoxColorFlgCounter = 0;
					if( cropBoxColorFlg == true )
					{
						dashColorOne = 0xFF000000; // opaque black
						dashColorTwo = 0xFFFFFFFF; // opaque white
						cropBoxColorFlg = false;
					}
					else
					{
						dashColorOne = 0xFFFFFFFF; // opaque white
						dashColorTwo = 0xFF000000; // opaque black
						cropBoxColorFlg = true;
					}
				}
				var mouseMovementX:int=0;
				var mouseMovementY:int=0;
				
				if( graphX > (getBitmapData().rect.x + getBitmapData().rect.width - 1 ) )
				{
					graphX = getBitmapData().rect.x + getBitmapData().rect.width - 1;
				}
				
				// This will drag the cropbox around on the image as the mouse moves.
				mouseMovementX = graphX - mouseDownX;
				mouseMovementY = graphY - mouseDownY;
				
				adjustCropBoxDueToMouseMovement( cropBoxRect, mouseDownCropBoxRect, 
					mouseDownCropBoxX_rightEdge, mouseDownCropBoxY_bottomEdge,
					mouseDownSelectLine,
					mouseMovementX, mouseMovementY,
					CropEffect.CROPBOX_MIN_WIDTH, CropEffect.CROPBOX_MIN_HEIGHT );
				drawCropBox(cropImageBD,  cropBoxRect,  dashColorOne, dashColorTwo );
			}
		}
		
		public function onMouseDown(event:MouseEvent):void{
			var mouseX:int;
			var mouseY:int;
			var graphX:int;
			var graphY:int;
			var tn1ImgHt:int  = getBitmapData().height;
			var fullImg:Image_=photo.getFullSizedImage();
			// mouseX and mouseY vary from 1..256
			mouseX = event.localX;
			mouseY = event.localY;
			// graphX and graphY vary from 0..255. We subtract 1 to use as index into array.
			graphX = mouseX - 1;
			graphY = mouseY - 1;
			
			// Remember where the user clicked the mouse down, for dragging/moving the crop box.
			mouseDownX = graphX;
			mouseDownY = graphY;
			
			//_____ Check for mouse on the LEFT LINE to possibly reposition it.
			// trace( "cropBoxRect.x: " + cropBoxRect.x + ", cropBoxRect.y: " + cropBoxRect.y );
			
			mouseDownSelectLine = CropEffect.MOUSE_DOWN_SELECT_LINE_NONE;
			
			// Determine which line (left, top, right, bottom) the mouse is "on",
			// or which line intersection (top-left, top-right, bottom-right, bottom-left)
			// the mouse is "on". If the mouse isn't within xMarginPx or yMarginPx
			// of these lines, then return MOUSE_DOWN_SELECT_LINE_NONE.
			mouseDownSelectLine = convertMouseXYToSelectedLine( mouseDownX, mouseDownY,
				xMarginPx, yMarginPx, cropBoxRect );
			if( mouseDownSelectLine == CropEffect.MOUSE_DOWN_SELECT_LINE_NONE )
			{
				// Use the arrow cursor when the mouse is not on any cropbox boundary lines.
				flash.ui.Mouse.cursor="arrow";
			}			
			cropImageBD.fillRect(getBitmapData().rect, 0xFF000000 ); // fill with black opaque pixels
			// Remember the current cropbox's settings from which to make
			// cropbox adjustments if the user moves the mouse while it's down.
			mouseDownCropBoxRect.x = cropBoxRect.x;
			mouseDownCropBoxRect.y = cropBoxRect.y;
			mouseDownCropBoxRect.width  = cropBoxRect.width;
			mouseDownCropBoxRect.height = cropBoxRect.height;
			
			mouseDownCropBoxX_rightEdge  = cropBoxRect.x + cropBoxRect.width;
			mouseDownCropBoxY_bottomEdge = cropBoxRect.y + cropBoxRect.height;
			var origCopy:BitmapData = new BitmapData(photo.getFullSizedImage().returnScaledImage().width,
				photo.getFullSizedImage().returnScaledImage().height, true, 0);			
			origCopy.draw(photo.getFullSizedImage().returnScaledImage());
			drawCropBox(cropImageBD,  cropBoxRect,  dashColorOne, dashColorTwo );				
		}
		
		// -----------------------------------------------------------------------
		// Create a uniformly darkened copy of the original image in the
		// darkenedImageBD bitmapdata object. This is done by mixing a copy of
		// the original image pixels in _origImageBD into a completely black
		// background. The specified _darkenLevel is used as the alpha channel
		// value for every pixel of the original image when mixing the original
		// image pixels into the black background. If the _darkenLevel is 0x30,
		// for example, less of the original image pixels are mixed with the
		// black background and the result is very dark. If the _darkenLevel is 0x90,
		// for example, more of the original image pixels are mixed with the
		// black background and the the darkening is much less. This method reuses
		// the darkenedImageBD bitmapdata object and returns a reference to it. 
		// - Return a reference to the updated darkenedImageBD image object
		//   which contains the original image mixed into a black background
		//   using the specified _darkenLevel as the alpha channel value 
		//   for every pixel from the original image. 
		// Example call:
		//   var darkenLevel:int = 0x90; // 0x30 was too dark
		//   targImageBD = createUniformlyDarkenedImage( _targImageBD, _darkenLevel, 
		//												 _origImageData );
		private function createUniformlyDarkenedImage( _targImageBD:BitmapData,
						 _darkenLevel:int, _origImageBD:BitmapData ):BitmapData
		{
			var colorVal:int;

			// Reuse the darkenedImageBD image object (allocated in the constructor)

			// Fill darkenedImageBD with opaque 0x90 darkenLevel levels stored 
			// into the ALPHA channel. We'll use the contents of the ALPHA channel 
			// below as a constant mask to control how much of the orig image 
			// we'll mix into a completely black background to create a uniformly 
			// darkened image.

			// Store _darkenLevel (eg: 0x90) in ALPHA chnl, eg: 0x90000000.
			// We'll shift the darkenLevel level left 24 bits to store it in the top byte.
			colorVal = _darkenLevel << 24; // store darkenLevel in the ALPHA chnl for each pixel.
			darkenedImageBD.fillRect( _targImageBD.rect, colorVal ); // eg: 0x90000000 for every pixel

			// Next, fill the target image with all black opaque pixels that
			// we'll mix the original image pixels into using the alpha channel.
			_targImageBD.fillRect( _targImageBD.rect, 0xFF000000 ); // fill with black opaque pixels

			// Copy the original image pixels, partially selected by an alpha mask,
			// and mix those pixels into a completely black opaque background image
			// to create a uniformly darkened image, mixed with black according to 
			// the specified alpha channel darkenLevel level stored in darkenedImageBD.
			// _targImageBD[ pixel ] = _targImageBD[ pixel ] (contains black opaque pixels)
			//							mixed with _origImageBD[ pixel ]
			//							using the ALPHA chnl in darkenedImageBD (eg: 0x90000000)
			_targImageBD.copyPixels( _origImageBD, _targImageBD.rect, point0,
									 darkenedImageBD, point0, true ); // mergeAlpha=true

			return( _targImageBD );

		} // END OF ... private function createUniformlyDarkenedImage( _targImageBD:BitmapData,
		  //							 _darkenLevel:int, _origImageBD:BitmapData ):BitmapData

		public function isMouseInsideCropBox( mouseX:int, mouseY:int,
											  xMarginPx:int, yMarginPx:int,
											  cropBoxRect:Rectangle ):Boolean
		{
			var mouseIsInsideCropBox:Boolean = false;
			
			if( ( mouseX > ( cropBoxRect.x + xMarginPx ) )
				&& ( mouseX < ( cropBoxRect.x - xMarginPx + cropBoxRect.width - 1 ) )
				&& ( mouseY > ( cropBoxRect.y + yMarginPx ) )
				&& ( mouseY < ( cropBoxRect.y - yMarginPx + cropBoxRect.height - 1 ) ) )
			{
				// Mouse is inside the Crop Box and not on any of its boundary lines.
				mouseIsInsideCropBox = true;
			}
			return( mouseIsInsideCropBox );
		}
		
		//----------------------------------------------------------------------
		// Determine which line (left, top, right, bottom) the mouse is "on",
		// or which line intersection (top-left, top-right, bottom-right, bottom-left)
		// the mouse is "on". If the mouse isn't within xMarginPx or yMarginPx
		// of these lines, then return MOUSE_DOWN_SELECT_LINE_NONE.
		public function convertMouseXYToSelectedLine( mouseDownX:int, mouseDownY:int,
													   xMarginPx:int, yMarginPx:int,
													   cropBoxRect:Rectangle):int
		{
			var mouseDownSelectLine:int = MOUSE_DOWN_SELECT_LINE_NONE;
			
			//_____ Check for mouse in the TOP LEFT CORNER to possibly reposition
			//		both the Left Line and the Top Line.
			if( ( Math.abs( mouseDownX - cropBoxRect.x ) < xMarginPx ) // Is mouse within +- 4px horizontally of left edge of cropbox?
				&& ( mouseDownY > (cropBoxRect.y-yMarginPx) ) // Is mouse below the (top of the cropbox - 4px, going up) ?
				&& ( mouseDownY < (cropBoxRect.y+cropBoxRect.height+yMarginPx) ) // Is mouse above the (bottom of the cropbox + 4px, going down) ?
				
				&& ( Math.abs( mouseDownY - cropBoxRect.y ) < yMarginPx ) // Is mouse within +- 4px horizontally of top edge of cropbox?
				&& ( mouseDownX > (cropBoxRect.x-xMarginPx) ) // Is mouse to right of the (left edge of the cropbox - 4px, going to left) ?
				&& ( mouseDownX < (cropBoxRect.x+cropBoxRect.width+xMarginPx) ) ) // Is mouse to left of the (right edge of the cropbox + 4px, going to right) ?
			{
				// The user clicked within 10 pixels of the top left corner of the cropbox.
				mouseDownSelectLine = MOUSE_DOWN_SELECT_TOP_LEFT_CORNER;
				// trace( "Yes. Top Left Corner. Left Line and Top line.");
			}
			else
				//_____ Check for mouse in the TOP RIGHT CORNER to possibly reposition
				//		both the Top Line and the Right Line.
				if( ( Math.abs( mouseDownX - (cropBoxRect.x + cropBoxRect.width) ) < xMarginPx ) // Is mouse within +- 6px horizontally of right edge of cropbox?
					&& ( mouseDownY > (cropBoxRect.y-yMarginPx) ) // Is mouse below the (top of the cropbox - 6px, going up) ?
					&& ( mouseDownY < (cropBoxRect.y+cropBoxRect.height+yMarginPx) ) // Is mouse above the (bottom of the cropbox + 6px, going down) ?
					
					&& ( Math.abs( mouseDownY - cropBoxRect.y ) < yMarginPx ) // Is mouse within +- 4px horizontally of top edge of cropbox?
					&& ( mouseDownX > (cropBoxRect.x-xMarginPx) ) // Is mouse to right of the (left edge of the cropbox - 4px, going to left) ?
					&& ( mouseDownX < (cropBoxRect.x+cropBoxRect.width+xMarginPx) ) ) // Is mouse to left of the (right edge of the cropbox + 4px, going to right) ?
				{
					// The user clicked within 10 pixels of the top right corner of the cropbox.
					mouseDownSelectLine = MOUSE_DOWN_SELECT_TOP_RIGHT_CORNER;
					// trace( "Yes. Top Right Corner. Top Line and Right line.");
				}
				else
					//_____ Check for mouse in the BOTTOM RIGHT CORNER to possibly reposition
					//		both the Bottom Line and the Right Line.
					if( ( Math.abs( mouseDownY - (cropBoxRect.y + cropBoxRect.height) ) < yMarginPx ) // Is mouse within +- 4px horizontally of bottom edge of cropbox?
						&& ( mouseDownX > (cropBoxRect.x-xMarginPx) ) // Is mouse to right of the (left edge of the cropbox - 4px, going to left) ?
						&& ( mouseDownX < (cropBoxRect.x+cropBoxRect.width+xMarginPx) ) // Is mouse to left of the (right edge of the cropbox + 4px, going to right) ?
						
						&& ( Math.abs( mouseDownX - (cropBoxRect.x + cropBoxRect.width) ) < xMarginPx ) // Is mouse within +- 6px horizontally of right edge of cropbox?
						&& ( mouseDownY > (cropBoxRect.y-yMarginPx) ) // Is mouse below the (top of the cropbox - 6px, going up) ?
						&& ( mouseDownY < (cropBoxRect.y+cropBoxRect.height+yMarginPx) ) ) // Is mouse above the (bottom of the cropbox + 6px, going down) ?
					{
						// The user clicked within 10 pixels of the bottom right corner of the cropbox.
						mouseDownSelectLine = MOUSE_DOWN_SELECT_BOTTOM_RIGHT_CORNER;
						// trace( "Yes. Bottom Right Corner. Bottom Line and Right line.");
					}
					else
						//_____ Check for mouse in the BOTTOM LEFT CORNER to possibly reposition
						//		both the Bottom Line and the Left Line.
						if( ( Math.abs( mouseDownY - (cropBoxRect.y + cropBoxRect.height) ) < yMarginPx ) // Is mouse within +- 4px horizontally of bottom edge of cropbox?
							&& ( mouseDownX > (cropBoxRect.x-xMarginPx) ) // Is mouse to right of the (left edge of the cropbox - 4px, going to left) ?
							&& ( mouseDownX < (cropBoxRect.x+cropBoxRect.width+xMarginPx) ) // Is mouse to left of the (right edge of the cropbox + 4px, going to right) ?
							
							&& ( Math.abs( mouseDownX - cropBoxRect.x ) < xMarginPx ) // Is mouse within +- 4px horizontally of left edge of cropbox?
							&& ( mouseDownY > (cropBoxRect.y-yMarginPx) ) // Is mouse below the (top of the cropbox - 4px, going up) ?
							&& ( mouseDownY < (cropBoxRect.y+cropBoxRect.height+yMarginPx) ) ) // Is mouse above the (bottom of the cropbox + 4px, going down) ?
						{
							// The user clicked within 10 pixels of the bottom left corner of the cropbox.
							mouseDownSelectLine = MOUSE_DOWN_SELECT_BOTTOM_LEFT_CORNER;
							// trace( "Yes. Bottom Left Corner. Bottom Line and Left line.");
						}
							
						else
							
							if( ( Math.abs( mouseDownX - cropBoxRect.x ) < xMarginPx ) // Is mouse within +- 4px horizontally of left edge of cropbox?
								&& ( mouseDownY > (cropBoxRect.y-yMarginPx) ) // Is mouse below the (top of the cropbox - 4px, going up) ?
								&& ( mouseDownY < (cropBoxRect.y+cropBoxRect.height+yMarginPx) ) ) // Is mouse above the (bottom of the cropbox + 4px, going down) ?
							{
								// The user clicked within 10 pixels of the left edge of the cropbox.
								mouseDownSelectLine = MOUSE_DOWN_SELECT_LEFT_LINE;
								// trace( "Yes. Left Line.");
							}
							else
								//_____ Check for mouse on the TOP LINE to possibly reposition it.
								if( ( Math.abs( mouseDownY - cropBoxRect.y ) < yMarginPx ) // Is mouse within +- 4px horizontally of top edge of cropbox?
									&& ( mouseDownX > (cropBoxRect.x-xMarginPx) ) // Is mouse to right of the (left edge of the cropbox - 4px, going to left) ?
									&& ( mouseDownX < (cropBoxRect.x+cropBoxRect.width+xMarginPx) ) ) // Is mouse to left of the (right edge of the cropbox + 4px, going to right) ?
								{
									// The user clicked within 10 pixels of the left edge of the cropbox.
									mouseDownSelectLine = MOUSE_DOWN_SELECT_TOP_LINE;
									// trace( "Yes. Top Line.");
								}
								else
									//_____ Check for mouse on the RIGHT LINE to possibly reposition it.
									if( ( Math.abs( mouseDownX - (cropBoxRect.x + cropBoxRect.width) ) < xMarginPx ) // Is mouse within +- 6px horizontally of right edge of cropbox?
										&& ( mouseDownY > (cropBoxRect.y-yMarginPx) ) // Is mouse below the (top of the cropbox - 6px, going up) ?
										&& ( mouseDownY < (cropBoxRect.y+cropBoxRect.height+yMarginPx) ) ) // Is mouse above the (bottom of the cropbox + 6px, going down) ?
									{
										// The user clicked within 10 pixels of the right edge of the cropbox.
										mouseDownSelectLine = MOUSE_DOWN_SELECT_RIGHT_LINE;
										// trace( "Yes. Right Line.");
									}
									else
										//_____ Check for mouse on the BOTTOM LINE to possibly reposition it.
										if( ( Math.abs( mouseDownY - (cropBoxRect.y + cropBoxRect.height) ) < yMarginPx ) // Is mouse within +- 4px horizontally of bottom edge of cropbox?
											&& ( mouseDownX > (cropBoxRect.x-xMarginPx) ) // Is mouse to right of the (left edge of the cropbox - 4px, going to left) ?
											&& ( mouseDownX < (cropBoxRect.x+cropBoxRect.width+xMarginPx) ) ) // Is mouse to left of the (right edge of the cropbox + 4px, going to right) ?
										{
											// The user clicked within 10 pixels of the left edge of the cropbox.
											mouseDownSelectLine = MOUSE_DOWN_SELECT_BOTTOM_LINE;
											// trace( "Yes. Bottom Line.");
										}
			return( mouseDownSelectLine );
			
		} // END OF ... private function convertMouseXYToSelectedLine( mouseDownX:int, mouseDownY:int,
		
		
		//----------------------------------------------------------------------
		public function adjustCropBoxDueToMouseMovement( cropBoxRect:Rectangle,
														  mouseDownCropBoxRect:Rectangle, 
														  mouseDownCropBoxX_rightEdge:int,
														  mouseDownCropBoxY_bottomEdge:int,
														  mouseDownSelectLine:int,
														  mouseMovementX:int, mouseMovementY:int,
														  cropBoxMinWidth:int, cropBoxMinHeight:int ):void
		{
			var newWidthPx:int;
			var newHeightPx:int;
			
			switch( mouseDownSelectLine )
			{
				case MOUSE_DOWN_SELECT_LINE_NONE:
					// Move the entire cropbox across the image, 
					// without changing its width or height.
					// Make sure that the x,y values are integral Numbers (no fractions)
					// Reposition the top left corner (x,y) position of the cropbox to
					// reflect how much the user has moved the mouse since clicking down.
					cropBoxRect.x = Number( mouseDownCropBoxRect.x + mouseMovementX );
					cropBoxRect.y = Number( mouseDownCropBoxRect.y + mouseMovementY );
					break;
				
				case MOUSE_DOWN_SELECT_TOP_LEFT_CORNER:
					// First, handle moving the Left Line.
					// User is moving left edge of cropbox to change the width.
					// We must keep the right edge stationary, varying only 
					// the X position of the left edge. So we will compute
					// the new X position of the left edge by subtracting 
					// the varying width value from the right edge's X position.
					// This will keep the right edge stationary while 
					// moving only the left edge.
					newWidthPx = mouseDownCropBoxRect.width - mouseMovementX;
					if( newWidthPx >= cropBoxMinWidth )
					{
						// Cropbox >= min width.
						// Reposition left edge, keeping right edge stationary.
						cropBoxRect.x = mouseDownCropBoxX_rightEdge - newWidthPx;
						cropBoxRect.width = newWidthPx;
					}
					else
					{
						// Cropbox < min width.
						// Set cropbox width to the minimum width, then recalc
						// the X position of the left edge to be the minimum
						// width pixels to the left of the right edge.
						newWidthPx = cropBoxMinWidth;
						cropBoxRect.width = newWidthPx;
						// Recalc x position of cropbox shifted right, at minimum width.
						cropBoxRect.x = mouseDownCropBoxX_rightEdge - newWidthPx;
					}
					
					// Second, handle moving the Top Line.
					// User is moving top edge of cropbox to change the height.
					// We must keep the bottom edge stationary, varying only 
					// the Y position of the top edge. So we will compute
					// the new Y position of the top edge by subtracting 
					// the varying width value from the bottom edge's Y position.
					// This will keep the bottom edge stationary while 
					// moving only the top edge.
					newHeightPx = mouseDownCropBoxRect.height - mouseMovementY;
					if( newHeightPx >= cropBoxMinHeight )
					{
						// Cropbox >= min height.
						// Reposition top edge, keeping bottom edge stationary.
						cropBoxRect.y = mouseDownCropBoxY_bottomEdge - newHeightPx;
						cropBoxRect.height = newHeightPx;
					}
					else
					{
						// Cropbox < min height.
						// Set cropbox width to the minimum height, then recalc
						// the Y position of the top edge to be the minimum
						// height pixels above the bottom edge.
						newHeightPx = cropBoxMinHeight;
						cropBoxRect.height = newHeightPx;
						// Recalc y position of cropbox shifted down, at minimum height.
						cropBoxRect.y = mouseDownCropBoxY_bottomEdge - newHeightPx;
					}
					break;
				
				case MOUSE_DOWN_SELECT_TOP_RIGHT_CORNER:
					// First, handle moving the Top Line.
					// User is moving top edge of cropbox to change the height.
					// We must keep the bottom edge stationary, varying only 
					// the Y position of the top edge. So we will compute
					// the new Y position of the top edge by subtracting 
					// the varying width value from the bottom edge's Y position.
					// This will keep the bottom edge stationary while 
					// moving only the top edge.
					newHeightPx = mouseDownCropBoxRect.height - mouseMovementY;
					if( newHeightPx >= cropBoxMinHeight )
					{
						// Cropbox >= min height.
						// Reposition top edge, keeping bottom edge stationary.
						cropBoxRect.y = mouseDownCropBoxY_bottomEdge - newHeightPx;
						cropBoxRect.height = newHeightPx;
					}
					else
					{
						// Cropbox < min height.
						// Set cropbox width to the minimum height, then recalc
						// the Y position of the top edge to be the minimum
						// height pixels above the bottom edge.
						newHeightPx = cropBoxMinHeight;
						cropBoxRect.height = newHeightPx;
						// Recalc y position of cropbox shifted down, at minimum height.
						cropBoxRect.y = mouseDownCropBoxY_bottomEdge - newHeightPx;
					}
					
					// Second, handle moving the Right Line.
					// User is moving right edge of cropbox to change the width.
					// We must keep the left edge stationary, varying only 
					// the X position of the right edge. So we will compute
					// the new X position of the right edge by adding the varying 
					// width value to the left edge's X position. This will keep 
					// the left edge stationary while moving only the right edge.
					// Since the right edge is defined by the left edge X position
					// plus the width, all we have to do is change the cropbox width.
					newWidthPx = mouseDownCropBoxRect.width + mouseMovementX;
					if( newWidthPx >= cropBoxMinWidth )
					{
						// Cropbox >= min width.
						// Reposition right edge, keeping left edge stationary.
						cropBoxRect.width = newWidthPx;
					}
					else
					{
						// Cropbox < min width.
						// Set cropbox width to the minimum width, then recalc
						// the X position of the right edge to be the minimum
						// width pixels added to the left edge.
						newWidthPx = cropBoxMinWidth;
						cropBoxRect.width = newWidthPx;
					}
					break;
				
				case MOUSE_DOWN_SELECT_BOTTOM_RIGHT_CORNER:
					// First, handle moving the Bottom Line.
					// User is moving bottom edge of cropbox to change the height.
					// We must keep the top edge stationary, varying only 
					// the Y position of the bottom edge. So we will compute
					// the new Y position of the bottom edge by adding the varying 
					// width value to the top edge's Y position. This will keep 
					// the top edge stationary while moving only the bottom edge.
					// Since the bottom edge is defined by the top edge Y position
					// plus the height, all we have to do is change the cropbox height.
					newHeightPx = mouseDownCropBoxRect.height + mouseMovementY;
					if( newHeightPx >= cropBoxMinHeight )
					{
						// Cropbox >= min height.
						// Reposition bottom edge, keeping top edge stationary.
						cropBoxRect.height = newHeightPx;
					}
					else
					{
						// Cropbox < min height.
						// Set cropbox height to the minimum height, then recalc
						// the Y position of the bottom edge to be the minimum
						// height pixels added to the top edge.
						newHeightPx = cropBoxMinHeight;
						cropBoxRect.height = newHeightPx;
					}
					
					// Second, handle moving the Right Line.
					// User is moving right edge of cropbox to change the width.
					// We must keep the left edge stationary, varying only 
					// the X position of the right edge. So we will compute
					// the new X position of the right edge by adding the varying 
					// width value to the left edge's X position. This will keep 
					// the left edge stationary while moving only the right edge.
					// Since the right edge is defined by the left edge X position
					// plus the width, all we have to do is change the cropbox width.
					newWidthPx = mouseDownCropBoxRect.width + mouseMovementX;
					if( newWidthPx >= cropBoxMinWidth )
					{
						// Cropbox >= min width.
						// Reposition right edge, keeping left edge stationary.
						cropBoxRect.width = newWidthPx;
					}
					else
					{
						// Cropbox < min width.
						// Set cropbox width to the minimum width, then recalc
						// the X position of the right edge to be the minimum
						// width pixels added to the left edge.
						newWidthPx = cropBoxMinWidth;
						cropBoxRect.width = newWidthPx;
					}
					break;
				
				case MOUSE_DOWN_SELECT_BOTTOM_LEFT_CORNER:
					// First, handle moving the Bottom Line.
					// User is moving bottom edge of cropbox to change the height.
					// We must keep the top edge stationary, varying only 
					// the Y position of the bottom edge. So we will compute
					// the new Y position of the bottom edge by adding the varying 
					// width value to the top edge's Y position. This will keep 
					// the top edge stationary while moving only the bottom edge.
					// Since the bottom edge is defined by the top edge Y position
					// plus the height, all we have to do is change the cropbox height.
					newHeightPx = mouseDownCropBoxRect.height + mouseMovementY;
					if( newHeightPx >= cropBoxMinHeight )
					{
						// Cropbox >= min height.
						// Reposition bottom edge, keeping top edge stationary.
						cropBoxRect.height = newHeightPx;
					}
					else
					{
						// Cropbox < min height.
						// Set cropbox height to the minimum height, then recalc
						// the Y position of the bottom edge to be the minimum
						// height pixels added to the top edge.
						newHeightPx = cropBoxMinHeight;
						cropBoxRect.height = newHeightPx;
					}
					
					// Second, handle moving the Left Line.
					// User is moving left edge of cropbox to change the width.
					// We must keep the right edge stationary, varying only 
					// the X position of the left edge. So we will compute
					// the new X position of the left edge by subtracting 
					// the varying width value from the right edge's X position.
					// This will keep the right edge stationary while 
					// moving only the left edge.
					newWidthPx = mouseDownCropBoxRect.width - mouseMovementX;
					if( newWidthPx >= cropBoxMinWidth )
					{
						// Cropbox >= min width.
						// Reposition left edge, keeping right edge stationary.
						cropBoxRect.x = mouseDownCropBoxX_rightEdge - newWidthPx;
						cropBoxRect.width = newWidthPx;
					}
					else
					{
						// Cropbox < min width.
						// Set cropbox width to the minimum width, then recalc
						// the X position of the left edge to be the minimum
						// width pixels to the left of the right edge.
						newWidthPx = cropBoxMinWidth;
						cropBoxRect.width = newWidthPx;
						// Recalc x position of cropbox shifted right, at minimum width.
						cropBoxRect.x = mouseDownCropBoxX_rightEdge - newWidthPx;
					}
					break;
				
				
				case MOUSE_DOWN_SELECT_LEFT_LINE:
					// User is moving left edge of cropbox to change the width.
					// We must keep the right edge stationary, varying only 
					// the X position of the left edge. So we will compute
					// the new X position of the left edge by subtracting 
					// the varying width value from the right edge's X position.
					// This will keep the right edge stationary while 
					// moving only the left edge.
					newWidthPx = mouseDownCropBoxRect.width - mouseMovementX;
					if( newWidthPx >= cropBoxMinWidth )
					{
						// Cropbox >= min width.
						// Reposition left edge, keeping right edge stationary.
						cropBoxRect.x = mouseDownCropBoxX_rightEdge - newWidthPx;
						cropBoxRect.width = newWidthPx;
					}
					else
					{
						// Cropbox < min width.
						// Set cropbox width to the minimum width, then recalc
						// the X position of the left edge to be the minimum
						// width pixels to the left of the right edge.
						newWidthPx = cropBoxMinWidth;
						cropBoxRect.width = newWidthPx;
						// Recalc x position of cropbox shifted right, at minimum width.
						cropBoxRect.x = mouseDownCropBoxX_rightEdge - newWidthPx;
					}
					break;
				
				case MOUSE_DOWN_SELECT_TOP_LINE:
					// User is moving top edge of cropbox to change the height.
					// We must keep the bottom edge stationary, varying only 
					// the Y position of the top edge. So we will compute
					// the new Y position of the top edge by subtracting 
					// the varying width value from the bottom edge's Y position.
					// This will keep the bottom edge stationary while 
					// moving only the top edge.
					newHeightPx = mouseDownCropBoxRect.height - mouseMovementY;
					if( newHeightPx >= cropBoxMinHeight )
					{
						// Cropbox >= min height.
						// Reposition top edge, keeping bottom edge stationary.
						cropBoxRect.y = mouseDownCropBoxY_bottomEdge - newHeightPx;
						cropBoxRect.height = newHeightPx;
					}
					else
					{
						// Cropbox < min height.
						// Set cropbox width to the minimum height, then recalc
						// the Y position of the top edge to be the minimum
						// height pixels above the bottom edge.
						newHeightPx = cropBoxMinHeight;
						cropBoxRect.height = newHeightPx;
						// Recalc y position of cropbox shifted down, at minimum height.
						cropBoxRect.y = mouseDownCropBoxY_bottomEdge - newHeightPx;
					}
					break;
				
				case MOUSE_DOWN_SELECT_RIGHT_LINE:
					// User is moving right edge of cropbox to change the width.
					// We must keep the left edge stationary, varying only 
					// the X position of the right edge. So we will compute
					// the new X position of the right edge by adding the varying 
					// width value to the left edge's X position. This will keep 
					// the left edge stationary while moving only the right edge.
					// Since the right edge is defined by the left edge X position
					// plus the width, all we have to do is change the cropbox width.
					newWidthPx = mouseDownCropBoxRect.width + mouseMovementX;
					if( newWidthPx >= cropBoxMinWidth )
					{
						// Cropbox >= min width.
						// Reposition right edge, keeping left edge stationary.
						cropBoxRect.width = newWidthPx;
					}
					else
					{
						// Cropbox < min width.
						// Set cropbox width to the minimum width, then recalc
						// the X position of the right edge to be the minimum
						// width pixels added to the left edge.
						newWidthPx = cropBoxMinWidth;
						cropBoxRect.width = newWidthPx;
					}
					break;
				
				case MOUSE_DOWN_SELECT_BOTTOM_LINE:
					// User is moving bottom edge of cropbox to change the height.
					// We must keep the top edge stationary, varying only 
					// the Y position of the bottom edge. So we will compute
					// the new Y position of the bottom edge by adding the varying 
					// width value to the top edge's Y position. This will keep 
					// the top edge stationary while moving only the bottom edge.
					// Since the bottom edge is defined by the top edge Y position
					// plus the height, all we have to do is change the cropbox height.
					newHeightPx = mouseDownCropBoxRect.height + mouseMovementY;
					if( newHeightPx >= cropBoxMinHeight )
					{
						// Cropbox >= min height.
						// Reposition bottom edge, keeping top edge stationary.
						cropBoxRect.height = newHeightPx;
					}
					else
					{
						// Cropbox < min height.
						// Set cropbox height to the minimum height, then recalc
						// the Y position of the bottom edge to be the minimum
						// height pixels added to the top edge.
						newHeightPx = cropBoxMinHeight;
						cropBoxRect.height = newHeightPx;
					}
					break;
			}
			
		} // END OF ... private function adjustCropBoxDueToMouseMovement( cropBoxRect:Rectangle,
		
		// -----------------------------------------------------------------------
		private function createDoubleDashHoriz( doubleDashHorizBD:BitmapData,
												horizDashWidth:int, horizDashHeight:int,
												dashColorOne:uint, dashColorTwo:uint ):BitmapData
		{
			var xOffset:int = horizDashWidth;
			var dashOneRect:Rectangle = new Rectangle( 0,       0, horizDashWidth, horizDashHeight ); // x,y, width,height
			var dashTwoRect:Rectangle = new Rectangle( xOffset, 0, horizDashWidth, horizDashHeight ); // x,y, width,height

			doubleDashHorizBD.fillRect( dashOneRect, dashColorOne ); // opaque black dash (0xFF000000)
			doubleDashHorizBD.fillRect( dashTwoRect, dashColorTwo ); // opaque white dash (0xFFFFFFFF)
			return( doubleDashHorizBD );
		}

		private function createDoubleDashVert( doubleDashVertBD:BitmapData,
											   vertDashWidth:int, vertDashHeight:int,
											   dashColorOne:uint, dashColorTwo:uint ):BitmapData
		{
			var yOffset:int = vertDashHeight;
			var dashOneRect:Rectangle = new Rectangle( 0, 0,       vertDashWidth, vertDashHeight ); // x,y, width,height
			var dashTwoRect:Rectangle = new Rectangle( 0, yOffset, vertDashWidth, vertDashHeight ); // x,y, width,height

			doubleDashVertBD.fillRect( dashOneRect, dashColorOne ); // opaque black dash (0xFF000000)
			doubleDashVertBD.fillRect( dashTwoRect, dashColorTwo ); // opaque white dash (0xFFFFFFFF)
			return( doubleDashVertBD );
		}

		// -----------------------------------------------------------------------
		// Draw the Cropbox onto the cropImageBD bitmapdata object,
		// using targ1ImgBD as the background image (optionally darkened).
		// drawCropBox() modifies the x,y values of cropBoxRect
		// if their values might cause the cropbox to go off the image.
		public function drawCropBox( cropImageBD:BitmapData, 
									 cropBoxRect:Rectangle,
									 dashColorOne:uint, dashColorTwo:uint ): void
		{
			var width:Number  = targImageBD.rect.width;
			var height:Number = targImageBD.rect.height;
			var darkenLevelValue:int;
			var horizDashWidth:int  = 4;
			var horizDashHeight:int = 1;
			var vertDashWidth:int   = 1;
			var vertDashHeight:int  = 4;
			var repeat:Boolean;
			var handleLineColor:uint;
			var tx:int;
			var ty:int;

			var doubleDashHorizBD:BitmapData = new BitmapData( 
											   2 * horizDashWidth, horizDashHeight, true );
			var doubleDashVertBD:BitmapData  = new BitmapData( 
											   vertDashWidth, 2 * vertDashHeight, true );
			var maxCropBoxX:Number = targImageBD.rect.width  - cropBoxRect.width  - 1;
			var maxCropBoxY:Number = targImageBD.rect.height - cropBoxRect.height - 1;

			// Don't let the cropbox go off the image. 
			// Modify caller's x,y values so cropbox is always on the image.
			if( cropBoxRect.x < 0 ) {  cropBoxRect.x = 0;  }
			if( cropBoxRect.y < 0 ) {  cropBoxRect.y = 0;  }

			if( cropBoxRect.x > maxCropBoxX )
			{	cropBoxRect.x = maxCropBoxX;	}
			if( cropBoxRect.y > maxCropBoxY )
			{	cropBoxRect.y = maxCropBoxY;	}

			// 1. Create an optionally darkened version of the image in cropImageBD to start.
			// 2. Define the origin point and the rectangle within cropImageBD
			//    where we will copy the original image.
			// 3. Copy the original image into cropImageBD within the crop box rectangle.
			// 4. Define the horizontal and vertical dashes for drawing crop box.
			// 5. Draw two horizontal crop box lines on cropImageBD bitmapdata object.
			// 6. Draw two vertical crop box lines on cropImageBD bitmapdata object.

			// 1. Create an optionally darkened version of the image to start.
			//    Then we will copy the orig image into the area defined by the crop box 
			//    so that crop box contains the original image, outside is the darkened image.

			if( darkenFlag )
			{
				// Create a uniformly darkened image in a copy of targBD using 
				// the specified darkenLevel in an alpha channel to mix a copy of 
				// the original image pixels into a black background. This makes 
				// the cropbox easier for the user to see, and also lets the user 
				// interactively create a vignette effect if desired.
				darkenLevelValue = darkenLevel; // eg: 0x90 (0x30 was too dark)
				cropImageBD = createUniformlyDarkenedImage( cropImageBD, 
															darkenLevelValue, targImageBD );
			}
			else
			{
				// Use the original image (not darkened) as the background image
				// upon which we'll draw the cropbox horizontal and vertical lines.
				cropImageBD.copyPixels( targImageBD, targImageBD.rect, point0,
										  null, null, true ); // mergeAlpha=true
			}

			// 2. Define the origin point and the rectangle within cropImageBD
			//    where we will copy the original image.
			point1.x = cropBoxRect.x;
			point1.y = cropBoxRect.y;

			// 3. Copy the original image into cropImageBD within the crop box rectangle.
			cropImageBD.copyPixels(targImageBD, cropBoxRect, point1 );

			// 4. Define the horizontal and vertical dashes for drawing crop box.
			doubleDashHorizBD = createDoubleDashHoriz( doubleDashHorizBD, horizDashWidth, horizDashHeight,
										   			   dashColorOne, dashColorTwo );
			doubleDashVertBD  = createDoubleDashVert(  doubleDashVertBD, vertDashWidth, vertDashHeight,
													   dashColorOne, dashColorTwo );
			repeat = true;

			// 5. Draw two horizontal crop box lines on cropImageBD bitmapdata object.
			cropShape.graphics.clear();
			cropShape.graphics.beginBitmapFill( doubleDashHorizBD, null, repeat );
			cropShape.graphics.drawRect( cropBoxRect.x, cropBoxRect.y,
										 cropBoxRect.width, horizDashHeight );
			cropShape.graphics.endFill();

			tx = 0;
			ty = 0;
			cropMatrix = new Matrix( 1, 0, 0, 1,  tx, ty ); // a,b,c,d, tx,ty
			cropImageBD.draw( cropShape, cropMatrix, null,null, null, true );

			tx = 0;
			ty = cropBoxRect.height;
			cropMatrix = new Matrix( 1, 0, 0, 1,  tx, ty ); // a,b,c,d, tx,ty
			cropImageBD.draw( cropShape, cropMatrix, null,null, null, true );

			// 6. Draw two vertical crop box lines on cropImageBD bitmapdata object.
			cropShape.graphics.clear();
			cropShape.graphics.beginBitmapFill( doubleDashVertBD, null, repeat );
			cropShape.graphics.drawRect( cropBoxRect.x, cropBoxRect.y,
										 vertDashWidth, cropBoxRect.height );
			cropShape.graphics.endFill();

			tx = 0;
			ty = 0;
			cropMatrix = new Matrix( 1, 0, 0, 1,  tx, ty ); // a,b,c,d, tx,ty
			cropImageBD.draw( cropShape, cropMatrix, null,null, null, true );

			tx = cropBoxRect.width;
			ty = 0;
			cropMatrix = new Matrix( 1, 0, 0, 1,  tx, ty ); // a,b,c,d, tx,ty
			cropImageBD.draw( cropShape, cropMatrix, null,null, null, true );

			handleLineColor = 0xFFFFFF; // draw each handle box in white
			drawEightHandlesOnCropBox( cropImageBD, cropBoxRect, handleLineColor );

			// Remember the current cropBox setting for the final
			// apply() operation to crop the original image.
			curCropBoxRect.x = cropBoxRect.x;
			curCropBoxRect.y = cropBoxRect.y;
			curCropBoxRect.width  = cropBoxRect.width;
			curCropBoxRect.height = cropBoxRect.height;

		} // private function drawCropBox( cropImageBD:BitmapData, targBD:BitmapData,
		  //							   cropBoxRect:Rectangle,
		  //							   dashColorOne:uint, dashColorTwo:uint ):BitmapData


		// -----------------------------------------------------------------------
		// Draw 8 mouse handle boxes all around the cropbox as visual cues to
		// the user for where to click the mouse to adjust the cropbox dimensions.
		// -----------------------------------------------------------------------
		private function drawEightHandlesOnCropBox( cropImageBD:BitmapData,
												    cropBoxRect:Rectangle,
												    handleLineColor:uint ):void
		{
			var tx:int;
			var ty:int;

			var handleBoxWidth:int = 7; // use odd number so handle straddles the cropbox lines evenly.
			var handleBoxHalfWidth:int = 3;

			// A1. Drop cropbox handle in top-left corner.
			cropShape.graphics.clear();
			cropShape.graphics.lineStyle( 1, handleLineColor ); // thin black line
			cropShape.graphics.drawRect( cropBoxRect.x - handleBoxHalfWidth,
										 cropBoxRect.y - handleBoxHalfWidth,
										 handleBoxWidth,
										 handleBoxWidth );
			cropShape.graphics.endFill();
			tx = 0;
			ty = 0;
			cropMatrix = new Matrix( 1, 0, 0, 1,  tx, ty ); // a,b,c,d, tx,ty
			cropImageBD.draw( cropShape, cropMatrix, null,null, null, true );

			// A2. Drop cropbox handle in middle of the top line.
			cropShape.graphics.clear();
			cropShape.graphics.lineStyle( 1, handleLineColor ); // thin black line
			cropShape.graphics.drawRect( cropBoxRect.x + (cropBoxRect.width/2) - handleBoxHalfWidth,
										 cropBoxRect.y - handleBoxHalfWidth,
										 handleBoxWidth,
										 handleBoxWidth );
			cropShape.graphics.endFill();
			tx = 0;
			ty = 0;
			cropMatrix = new Matrix( 1, 0, 0, 1,  tx, ty ); // a,b,c,d, tx,ty
			cropImageBD.draw( cropShape, cropMatrix, null,null, null, true );


			// B1. Drop cropbox handle in top-right corner.
			cropShape.graphics.clear();
			cropShape.graphics.lineStyle( 1, handleLineColor ); // thin black line
			cropShape.graphics.drawRect( cropBoxRect.x + cropBoxRect.width - handleBoxHalfWidth,
										 cropBoxRect.y - handleBoxHalfWidth,
										 handleBoxWidth,
										 handleBoxWidth );
			cropShape.graphics.endFill();
			tx = 0;
			ty = 0;
			cropMatrix = new Matrix( 1, 0, 0, 1,  tx, ty ); // a,b,c,d, tx,ty
			cropImageBD.draw( cropShape, cropMatrix, null,null, null, true );

			// B2. Drop cropbox handle in middle of right-most line.
			cropShape.graphics.clear();
			cropShape.graphics.lineStyle( 1, handleLineColor ); // thin black line
			cropShape.graphics.drawRect( cropBoxRect.x + cropBoxRect.width - handleBoxHalfWidth,
										 cropBoxRect.y + (cropBoxRect.height/2) - handleBoxHalfWidth,
										 handleBoxWidth,
										 handleBoxWidth );
			cropShape.graphics.endFill();
			tx = 0;
			ty = 0;
			cropMatrix = new Matrix( 1, 0, 0, 1,  tx, ty ); // a,b,c,d, tx,ty
			cropImageBD.draw( cropShape, cropMatrix, null,null, null, true );


			// C1. Drop cropbox handle in bottom-right corner.
			cropShape.graphics.clear();
			cropShape.graphics.lineStyle( 1, handleLineColor ); // thin black line
			cropShape.graphics.drawRect( cropBoxRect.x + cropBoxRect.width - handleBoxHalfWidth,
										 cropBoxRect.y + cropBoxRect.height - handleBoxHalfWidth,
										 handleBoxWidth,
										 handleBoxWidth );
			cropShape.graphics.endFill();
			tx = 0;
			ty = 0;
			cropMatrix = new Matrix( 1, 0, 0, 1,  tx, ty ); // a,b,c,d, tx,ty
			cropImageBD.draw( cropShape, cropMatrix, null,null, null, true );

			// C2. Drop cropbox handle in middle of the bottom line.
			cropShape.graphics.clear();
			cropShape.graphics.lineStyle( 1, handleLineColor ); // thin black line
			cropShape.graphics.drawRect( cropBoxRect.x + (cropBoxRect.width/2) - handleBoxHalfWidth,
										 cropBoxRect.y + cropBoxRect.height - handleBoxHalfWidth,
										 handleBoxWidth,
										 handleBoxWidth );
			cropShape.graphics.endFill();
			tx = 0;
			ty = 0;
			cropMatrix = new Matrix( 1, 0, 0, 1,  tx, ty ); // a,b,c,d, tx,ty
			cropImageBD.draw( cropShape, cropMatrix, null,null, null, true );


			// D1. Drop cropbox handle in bottom-left corner.
			cropShape.graphics.clear();
			cropShape.graphics.lineStyle( 1, handleLineColor ); // thin black line
			cropShape.graphics.drawRect( cropBoxRect.x - handleBoxHalfWidth,
										 cropBoxRect.y + cropBoxRect.height - handleBoxHalfWidth,
										 handleBoxWidth,
										 handleBoxWidth );
			cropShape.graphics.endFill();
			tx = 0;
			ty = 0;
			cropMatrix = new Matrix( 1, 0, 0, 1,  tx, ty ); // a,b,c,d, tx,ty
			cropImageBD.draw( cropShape, cropMatrix, null,null, null, true );

			// D2. Drop cropbox handle in middle of left-most line.
			cropShape.graphics.clear();
			cropShape.graphics.lineStyle( 1, handleLineColor ); // thin black line
			cropShape.graphics.drawRect( cropBoxRect.x - handleBoxHalfWidth,
										 cropBoxRect.y + (cropBoxRect.height/2) - handleBoxHalfWidth,
										 handleBoxWidth,
										 handleBoxWidth );
			cropShape.graphics.endFill();
			tx = 0;
			ty = 0;
			cropMatrix = new Matrix( 1, 0, 0, 1,  tx, ty ); // a,b,c,d, tx,ty
			cropImageBD.draw( cropShape, cropMatrix, null,null, null, true );

		} // END OF ... private function drawEightHandlesOnCropBox( cropImageBD:BitmapData,
		  //						     cropBoxRect:Rectangle,
		  // 						     handleLineColor:uint ):void

		// -----------------------------------------------------------------------
		private function apply():void
		{
			// Create a new image that's the exact same dimensions as the cropbox.
			croppedTargImageBD = new BitmapData( curCropBoxRect.width, curCropBoxRect.height,
								  true, 0xFF000000 ); // fill with opaque black pixels (0x00==black)

			// Copy only pixels from orig image (targImageBD) within curCropBoxRect
			// and copy them to the top-left corner of croppedTargImageBD (point0).
			croppedTargImageBD.copyPixels( targImageBD, curCropBoxRect, point0 );

		} // END OF ... public function apply():void
		
		public function applyComplete():void{	
			var xRatio:Number = curCropBoxRect.x/targImageBD.width;
			var yRatio:Number = curCropBoxRect.y/targImageBD.height;
			var widthRatio:Number = curCropBoxRect.width/targImageBD.width;
			var heightRatio:Number = curCropBoxRect.height/targImageBD.height;
			var img:Image_=photo.getFullSizedImage();
			targImageBD = new BitmapData(img.returnOrigImage().width, img.returnOrigImage().height, true, 0);
			targImageBD.draw(img.returnOrigImage());
			curCropBoxRect.x=targImageBD.width * xRatio;
			curCropBoxRect.y=targImageBD.height * yRatio;
			curCropBoxRect.width=targImageBD.width * widthRatio;
			curCropBoxRect.height=targImageBD.height * heightRatio;
			apply();
			img.setCropBitMapData(getCroppedImageRef(), this);			
		}		
		
		// -----------------------------------------------------------------------
		public  function getCroppedImageRef():BitmapData
		{
			// If apply() has not yet been called, croppedTargImageBD can be null.
			return( croppedTargImageBD );
		}
		
		public function getCropBitmapData():BitmapData{
			return cropImageBD;
		}
	
	} // END OF ... public class CropEffect implements IFilter

} // END OF ... package actionObj.filters
