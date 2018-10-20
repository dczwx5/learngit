/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/7/7.
 * Time: 11:06
 */
package factorys.roles
{
	import flash.display.Shape;
	import flash.display.Sprite;

	public class CBaseRole extends Sprite
	{
		public function CBaseRole()
		{

		}

		public function init(color:int):Shape
		{
			var shape:Shape = new Shape();
			shape.graphics.beginFill(color);
			shape.graphics.drawCircle(-10,-10,20);
			shape.graphics.endFill();
			return shape;
		}
	}
}
