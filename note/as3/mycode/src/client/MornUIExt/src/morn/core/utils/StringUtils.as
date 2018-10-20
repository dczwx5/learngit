/**
 * Morn UI Version 3.0 http://www.mornui.com/
 * Feedback yungzhu@gmail.com http://weibo.com/newyung
 */
package morn.core.utils {
	import flash.geom.Rectangle;
	
	/**文本工具集*/
	public class StringUtils {
		
		/**用字符串填充数组，并返回数组副本*/
		public static function fillArray(arr:Array, str:String, type:Class = null):Array {
            // XXX(Jeremy): MornUI使用ObjectUtils.clone会造成严重的GC问题，以下优化使用递归赋值方式降低GC压力
			var temp:Array = [];
            var i:int, n:int;
			for (i = 0, n = arr.length; i < n; i++) {
                temp[i] = arr[i];
			}

			// var temp:Array = ObjectUtils.clone(arr);
			if (Boolean(str)) {
				var a:Array = str.split(",");
				for (i = 0, n = Math.min(temp.length, a.length); i < n; i++) {
					var value:String = a[i];
					temp[i] = (value == "true" ? true : (value == "false" ? false : value));
					if (type != null) {
						temp[i] = type(value);
					}
				}
			}
			return temp;
		}
		
		/**转换Rectangle为逗号间隔的字符串*/
		public static function rectToString(rect:Rectangle):String {
			if (rect) {
				return rect.x + "," + rect.y + "," + rect.width + "," + rect.height;
			}
			return null;
		}
	}
}