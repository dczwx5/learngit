package QFLib.Graphics.RenderCore.starling.utils
{
	/**
	 * @author Jave.Lin
	 * @date 2014-12-18
	 **/
	public class SearchUtil
	{
		/** It actually, sort element by numeric, use this binary-search, precondition : sorted-vec
		 * <br/>
		 * cmp:Function = function(vec[N]):int; // <b>< 0 need to lesser, otherwise greater or equal.</b>
		 * */
		public static function binarySearch(values:*, cmp:Function, ...args):int
		{
			var min:int = 0;
			var max:int = values.length - 1;
			return binarySearch1(values, min, max, cmp, args);
		}
		
		public static function binarySearch1(values:*, min:int, max:int, cmp:Function, args:Array):int
		{
			if (!values)
			{
				throw Error("values is null!");
			}
			
			if (max <= min)
				return 0;
			
			var middle:int = (min + max) >> 1;

			var ret:int;			
			while (true)
			{
				ret = cmp(values[middle], args);
				
				if (ret < 0)
					min = middle + 1;
				else if (ret >= 0)
					max = middle;
				
				if (min == max)
					return min;
				
				middle = (min + max) >> 1;
			}
			
			// Can't happen.
			return 0;
		}
		
		/** 外部任意数组可通用的已排序二分查找法
		 * @param vec Vector.<T> 或是 Array都可以，<b>vec必须已升序排过</b>
		 * @param cmp = <b>function(e):int</b>; e是vec内的元素;
		 * 		结果：
		 * 			>0，则说明当前middile值比我们的目标要大，需要往左偏middle - 1，并作为upperIndex值;
		 * 			<0，则说明当前middile值比我们的目标要小，需要往右偏middle + 1，并作为lowerIndex值;
		 * 			==0，说明找到结果
		 * */
		public static function sortedBinarySearch(vec:*, cmp:Function):int
		{
			if (!vec || vec.length == 0)
				return -1;
			if (vec.length == 1)
				return cmp(vec[0]) == 0 ? 0 : -1;
			
			var lowerIndex:int = 0;
			var upperIndex:int = vec.length - 1;
			
			var middile:int = (lowerIndex + upperIndex) >> 1;
			var value:int;
			while (true)
			{
				value = cmp(vec[middile]);
				
				if (value > 0) 									// >0，则说明当前middile值比我们的目标要大，需要往左偏middle - 1，并作为upperIndex值;
					upperIndex = middile - 1;
				else if (value < 0) 							// <0，则说明当前middile值比我们的目标要小，需要往右偏middle + 1，并作为lowerIndex值;
					lowerIndex = middile + 1;
				else 												// ==0，说明找到结果
					return middile;
				
				if (lowerIndex == upperIndex)			// 有可能是一个都找不到的情况了
					return -1;
				
				middile = (lowerIndex + upperIndex) >> 1;
			}
			return -1;
		}
	}
}