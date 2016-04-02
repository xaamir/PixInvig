package actionObj.transition
{
	import mx.effects.AnimateProperty;
	
	public class ActionsScroller extends AnimateProperty
	{
		private var iterationCount:int = 0;
		private var currentCount:int = 0;

		public function ActionsScroller(target:Object=null)
		{
			super(target);
		}
		
		public function setIterationCount(count:int):void{
			iterationCount=count;
		}
		
		public function getCurrentCount():int{
			return currentCount;
		}
		
		public function incCurrentCount():void{
			currentCount++;
		}
	}
}