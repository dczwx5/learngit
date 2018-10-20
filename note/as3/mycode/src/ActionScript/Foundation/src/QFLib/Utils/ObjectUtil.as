////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

package QFLib.Utils
{
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	
	/**
	 * 对象工具 
	 * @author lyman
	 * 
	 */	
	public class ObjectUtil
	{
		/**
		 * 
		 */
		public function ObjectUtil()
		{
		}
		
		/**
		 * 判断指定的Object对象是否有属性（这里只能对，Object动态属性的判断，定义类的，则需要使用反射来判断）
		 * @param obj 
		 * @return 
		 * 
		 */		
		public static function isHaveProperties(obj:Object):Boolean
		{
			for(var myAttribute:String in obj) // 如果有属性，这里至少会进一次循环，而进了循环说明有属性，那么可以直接返回true
			{
				return true;
			}
			return false; // 否则返回false
		}
		
		/**
		 * 深拷贝对象（对显示对象无效，一般用于用户自定义的纯数据model对象）
		 * @param obj
		 * @return 
		 * 
		 */		
		public static function cloneObject(obj:Object):Object
		{
			var by:ByteArray = new ByteArray();
			by.writeObject(obj);
			by.position = 0;

			var result:Object = by.readObject();
			by.clear();

			return result;
		}
		
		/** 简单的对resObj的key, value遍历赋值给targetObj，如果需要有类型判断，或是更多自定义的处理
		 * <br>
		 * 最好使用：ICopyFrom接口 + CopyFromUtil.generalCopyFrom(target:Object, dataObj:Object):void
		 * */
		public static function objectAssignment(resObj:Object,targetObj:Object):void
		{
			for(var myAttribute:String in resObj)
			{
				if(targetObj.hasOwnProperty(myAttribute))
					targetObj[myAttribute] = resObj[myAttribute];
			}
		}
		
		
		/**
		 * 
		 * @param targetObj
		 * 根据目标对象的属性列表
		 */
		public static function getObjAtts(targetObj:Object):Array
		{
			var xml:XML = describeType(targetObj);
			var xmlList:XMLList = xml.variable;
			var len:int = xmlList.length();
			var arr:Array = [];
			var att:String;
			
			for (var i:int = 0; i < len; i++) 
			{
				att = xmlList[i].@name.toString();
				arr.push(att);
			}
			
			return arr;
		}
		
		/**
		 * 
		 * @param resObj
		 * @param targetObj
		 * 根据目标对象的属性来复制数据
		 */
		public static function objectAssignmentByTargetArr(resObj:Object, targetObj:Object, targetAtts:Array):void
		{
			var att:String;
			var len:int = targetAtts.length;
			for (var i:int = 0; i < len; i++) 
			{
				att = targetAtts[i];
				
				if(resObj.hasOwnProperty(att))
				{
					targetObj[att] = resObj[att];
				}
			}
			
			
		}
		
	}
}