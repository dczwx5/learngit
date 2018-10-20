////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

package QFLib.Utils
{
	/**
	 * 
	 * @author tanjiazhang
	 * 
	 */	
	public class ArrayUtil
	{
		public function ArrayUtil()
		{
		}
		
		/**
		 *将某个元素交换到最后一个元素，然后移除该元素（可选）
		 * 注意：在顺序无关的数据里，使用本方法来替代Array.splice 
		 * @param array
		 * @param itemIndex
		 * @param removeIt
		 * 
		 */		
		public static function swapTail(array:Object, itemIndex:int, removeIt:Boolean=true):void
		{
			var t:Object = array[itemIndex];
			array[itemIndex] = array[array.length-1];
			array[array.length-1] = t;
			if(removeIt)
			{
				array.pop();
			}
		}
		
		
		/**
		 *从数组中查找对象 
		 * @param array
		 * @param target
		 * @param cmp 第一个参数是遍历到的数组元素、第二个参数是传入的target，返回值是Boolean
		 * @return 
		 * 
		 */		
		public static function findItem(array:Object, target:Object, cmp:Function=null):int
		{
			for(var i:int=0;i<array.length;++i)
			{
				var item:Object = array[i];
				if(cmp(item, target))
				{
					return i;
				}
			}
			return -1;
		}
		
		/**
		 *从数组查找对象 
		 * @param array Array或Vector
		 * @param propName 数组元素中拿出来比较的属性
		 * @param targetValue 比较的目标值
		 * @return 
		 * 
		 */		
		public static function findItemByProp(array:Object, propName:String, targetValue:Object):int
		{
			for(var i:int=0;i<array.length;++i)
			{
				var item:Object = array[i];
				if(item!=null && item[propName]==targetValue)
				{
					return i;
				}
			}
			return -1;
		}

		// 合并两个list, 去掉重复元素
		public static function mergeList(list1:Array, list2:Array, propName:String) : Array {
			var retList:Array = list1.concat();
			var findIndex:int;
			for each (var obj2:Object in list2) {
				findIndex = findItemByProp(retList, propName, obj2[propName]);
				if (-1 == findIndex) {
					retList[retList.length] = obj2;
				}
			}
			return retList;
		}

		public static function clipSameItem(list:Array, propName:String) : Array {
			var retList:Array = new Array();
			for each (var obj:Object in list) {
				var findIndex:int;
				findIndex = findItemByProp(retList, propName, obj[propName]);
				if (-1 == findIndex) {
					retList[retList.length] = obj;
				}
			}
			return retList;
		}
	}
}