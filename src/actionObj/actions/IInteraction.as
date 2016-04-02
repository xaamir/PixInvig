package actionObj.actions
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;

	public interface IInteraction
	{
		function setFocalPoint( _xPercent:Number, _yPercent:Number ):void
		function setMaskScaleFactor(_maskScaleFactor:Number):void
		function setMaskScaleFactorFromRatio(_maskScaleFactor:Number):void
		function getMaskScaleFactor():Number
		function getSliderValFromMaskScaleFactor():Number
		function setDarkenFlag(_flag:Boolean):void
	}
}