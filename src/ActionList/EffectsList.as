package ActionList
{
	import actionObj.actions.IAction;
	import actionObj.actions.effects.DepthEffect;
	import actionObj.actions.effects.DesatEffect;
	import actionObj.actions.effects.EffectBase;
	import actionObj.actions.effects.FocusEffect;
	import actionObj.actions.effects.Normal;
	import actionObj.actions.effects.VignetteEffect;
	import actionObj.image.ActionImageData;
	import actionObj.image.Photo;
	
	import comp.ImageHScroller;
	
	import flash.utils.getDefinitionByName;

	
	public class EffectsList implements IActionList
	{
		public var actionsList:Array;
		public var actionListControl:ImageHScroller;
		public var photo:Photo;
		public var effectClassNames:Array = ["Normal", "DepthEffect", "FocusEffect", "DesatEffect", "VignetteEffect"];
		
		public function EffectsList(listControl_:ImageHScroller, photo_:Photo)
		{
			actionListControl=listControl_;
			photo=photo_;
		}
		
		public function prepareActionsList():void{
			if(actionsList==null){
				var focus:FocusEffect;
				var depth:DepthEffect;
				var focusBase:EffectBase;
				var normal:Normal;
				var desat:DesatEffect;
				var vg:VignetteEffect;
				var currentEffectName:String = null;
				
				actionsList = new Array(effectClassNames.length);
				var currentEffect:IAction = photo.getFullSizedImage().getEffect();
				for (var i:int = 0; i < effectClassNames.length; i++){
					var filterClass:Class = getDefinitionByName("actionObj.actions.effects." + effectClassNames[i]) as Class;
					var filter:IAction = new filterClass();
					var actionImageData:ActionImageData = new ActionImageData("", filter, photo);
					if(currentEffect!=null){
						if(currentEffect.getLabel()==filter.getLabel()){
							actionImageData.setSelected(true);
						}
					}
					actionImageData.setImage();
					actionsList[i]=actionImageData;
				}
			}
		}
		
		
		public function setListData():void
		{
			var actionData:ActionImageData=null;
			var tempList:Array = new Array();
			
			prepareActionsList();
			for (var j:int = 0; j < effectClassNames.length; j++){
				actionData= actionsList[j];
				actionData.setImage();
			}
			actionListControl.dataProvider=actionsList;
			actionListControl.setHorizontalSpace(52);
		}
		
		
		public function getClassNamesArray():Array
		{
			return effectClassNames;
		}
		
	}
}