/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/7/7.
 * Time: 15:27
 */
package aiDataIO
{
	import flash.display.Sprite;

	public interface IAIDataIO
	{
		function followPlayer(callBack:Function,followDistance:Number):void;
		function get data():Object;
		function set data(obj:Object):void;
	}
}
