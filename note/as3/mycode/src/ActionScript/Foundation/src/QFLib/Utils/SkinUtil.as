////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

package QFLib.Utils
{
	/**
	 * @author traimen
	 * @data 2015-3-12
	 **/
	public class SkinUtil
	{
		public function SkinUtil()
		{
		}
		
		/** 从父组件skin中，获取第一个名字为a_name的子组件的skin */
		public static function getSkinByName(a_parentSkin:Object, a_name:String):Object{
			var len:int = a_parentSkin.children.length;
			var child:Object;
			var result:Object;
			for(var i:int = 0; i < len; i++){
				child = a_parentSkin.children[i];
				if(child.name == a_name){
					return child;
				}
				else{
					result = getSkinByName(child, a_name);
					if(result != null){
						return result;
					}
				}
			}
			return result;
		}
	}
}