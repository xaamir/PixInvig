package utilities
{
	public class Utils
	{
		public function Utils()
		{
		}
		
		/**
		 * search for the array index such that the array[index] is less than val (passed into this function
		 * as the 2nd parameter) as well as the closest to val in this array. 
		 **/
		public static function binarySearch(array:Array, value:int, left:int, right:int):int{
			if(left > right){
				return -1;
			}
			if ((right - left)<=1){
				return left;
			}
			var middle:int = (left + right) / 2;
			if(array[middle] == value){
				return middle;
			}
			else if(array[middle] > value){
				return binarySearch(array, value, left, middle - 1);
			}
			else{
				if(right - (middle + 1) <=1){
					return middle;
				}
				else{
					return binarySearch(array, value, middle + 1, right);
				}
			}
		}
	}
}