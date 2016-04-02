package ActionList
{
	import actionObj.actions.IAction;
	import actionObj.actions.filters.BlueShadows;
	import actionObj.actions.filters.CyanDark;
	import actionObj.actions.filters.Dual;
	import actionObj.actions.filters.Dual2;
	import actionObj.actions.filters.Highlights;
	import actionObj.actions.filters.Indoors;
	import actionObj.actions.filters.MonochromeSplitTone;
	import actionObj.actions.filters.Vintage;
	import actionObj.image.ActionImageData;
	import actionObj.image.Photo;
	import actionObj.transition.SlideEffect;
	
	import comp.EditorActionsCanvas;
	import comp.ImageHScroller;
	
	import flash.display.DisplayObject;
	import flash.utils.getDefinitionByName;
	
	import mx.containers.Canvas;
	import mx.controls.List;
	import mx.effects.Effect;

	public class FilterList implements IActionList
	{
		public var actionsList:Array;
		public var actionListControl:ImageHScroller;
		public var photo:Photo;
		
		public var filterClassNames:Array = ["Normal", "MagentaShadow","BWModerateContrast", "Dual", "Highlights", "Dual2",  
			"BlueShadows", "CyanTonedLowContrast", "ColdBlue","FadedColorPrint",  "Indoors", "SepiaHighContrast", "SepiaLowContrast", "CyanDark", "Vintage", "MonochromeSplitTone",
			"FadedRed"];

		
		public function FilterList(listControl_:ImageHScroller, photo_:Photo)
		{
			actionListControl=listControl_;
			photo=photo_;
		}
		
		public function getClassNamesArray():Array{
			return filterClassNames;
		}
				
		public function prepareActionsList():void{
			if(actionsList==null){
				var bwm:actionObj.actions.filters.BWModerateContrast;
				var ctl:actionObj.actions.filters.CyanTonedLowContrast;
				var fcp:actionObj.actions.filters.FadedColorPrint;
				var sph:actionObj.actions.filters.SepiaHighContrast;
				var spl:actionObj.actions.filters.SepiaLowContrast;
				var ybs:actionObj.actions.filters.YellowBlueSplitToning;
				var mbs:MonochromeSplitTone;
				var cd:CyanDark;
				var dual2:Dual2;
				var high:Highlights;					
				var cb:actionObj.actions.filters.ColdBlue;
				var ms:actionObj.actions.filters.MagentaShadow;
				var nor:actionObj.actions.filters.Normal;
				var fr:actionObj.actions.filters.FadedRed;
				var bs:actionObj.actions.filters.BlueShadows;
				var dual:Dual;
				var ind:actionObj.actions.filters.Indoors;
				var vn:Vintage;
				
				actionsList = new Array(filterClassNames.length);
				var currentFilter:IAction = photo.getFullSizedImage().getFilter();
				for (var i:int = 0; i < filterClassNames.length; i++){
					//try{
					var filterClass:Class = getDefinitionByName("actionObj.actions.filters." + filterClassNames[i]) as Class;
					var filter:IAction = new filterClass();
					var actionImageData:ActionImageData = new ActionImageData("", filter, photo);
					if(currentFilter!=null){
						if(currentFilter.getLabel()==filter.getLabel()){
							actionImageData.setSelected(true);
						}
					}					
					actionImageData.setImage();
					actionsList[i]=actionImageData;
					//}
					//catch (e:Error){
					//	Trace(e.toString());
					//}
				}
			}
		}
		
		public function setListData():void{
			var actionData:ActionImageData=null;
			prepareActionsList();
			if(actionsList==null){
				return;
			}
			for (var j:int = 0; j < filterClassNames.length; j++){
				actionData= actionsList[j];
				actionData.setImage();
			}
			actionListControl.setHorizontalSpace(8);			
			actionListControl.dataProvider=actionsList;
		}
	}
}