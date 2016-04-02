package actionObj.actions
{
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.geom.Matrix;

	public class FilterHelper
	{
		public function FilterHelper()
		{
		}
		
		public static function createRadialGradient( targBD:BitmapData, maskData:BitmapData ):BitmapData
		{
			var maskShape:Shape   = new Shape();
			var maskMatrix:Matrix = new Matrix( 1, 0, 0, 1,  0, 0 ); // a,b,c,d, tx,ty
			var gradientMatrix:Matrix = new Matrix(); // needed by beginGradientFill()
			var xPercent:Number  = USER_X_PERCENT_DEFAULT;
			var yPercent:Number  = (100.0 - USER_Y_PERCENT_DEFAULT); // internal view is 
			
			const USER_X_PERCENT_DEFAULT:Number = 50.0; // User's view of x-axis (0%-left, 100%-right)
			const USER_Y_PERCENT_DEFAULT:Number = 50.0; // User's view of y-axis (0%-bottom, 100%-top of image)

			var width:int  = targBD.rect.width;
			var height:int = targBD.rect.height;
			
			var minDimension:int = width < height ? width : height;
			var boxWidth:Number;
			var boxHeight:Number;
			var boxRotation:Number = 0; // Math.PI/2; // 90°  (in radians)
			var tx:Number = 0;
			var ty:Number = 0; 
			var colors:Array = [0xffffff, 0xcccccc, 0x888888, 0x555555, 0x000000];
			var alphas:Array = [1, 1, 1, 1, 1];
			var ratios:Array = [120, 180, 220, 240, 255];
			
			var spreadMethod:String = SpreadMethod.PAD; // PAD, REFLECT, REPEAT
			var interp:String = InterpolationMethod.RGB; //LINEAR_RGB; // LINEAR_RGB, RGB
			var focalPtRatio:Number = 0;
			boxWidth  = minDimension;  // define maskShape's dimensions
			boxHeight = minDimension;
			var maskScaleFactor:Number = 1;
			boxWidth  *= maskScaleFactor;
			boxHeight *= maskScaleFactor;
			
			tx = 0;
			ty = 0;
			gradientMatrix.createGradientBox( boxWidth, boxHeight, boxRotation, tx, ty );
			// Since we're reusing the maskShape Shape object, make sure it's empty.
			maskShape.graphics.clear();
			maskShape.graphics.beginGradientFill(GradientType.RADIAL, colors, alphas, ratios,
				gradientMatrix, spreadMethod, interp, focalPtRatio );
			maskShape.graphics.drawRect( 0, 0, boxWidth, boxHeight );
			maskShape.graphics.endFill();
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
				ty = ( height - boxHeight ) / 2;
			}
			var xShift:int;
			var yShift:int;
			var xxPercent:Number;
			var yyPercent:Number;

			xxPercent = xPercent - 50.0; // Before: 0% is left edge, 100% is right edge.
			yyPercent = yPercent - 50.0; // Before: 0% is top  edge, 100% is bottom edge.
			xShift = (xxPercent/100.0) * width; // xPercent of 0--> (-width/2), xPercent of 100--> (+width/2)
			yShift = (yyPercent/100.0) * height;
			
			tx = tx + xShift; 
			ty = ty + yShift;
			maskMatrix.a  = 1.0; // Sx: x-scale factor (not used here)
			maskMatrix.b  = 0;
			maskMatrix.c  = 0;
			maskMatrix.d  = 1.0; // Sy: y-scale factor (not used here)
			maskMatrix.tx = tx;  // used to center and/or position mask at focal point
			maskMatrix.ty = ty;  // used to center and/or position mask at focal point
			maskData.draw( maskShape, maskMatrix, null,null, null, true );			
			return( maskData );
		} 	
	}
}