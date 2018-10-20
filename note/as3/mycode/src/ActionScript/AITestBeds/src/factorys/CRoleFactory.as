/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/7/7.
 * Time: 11:18
 */
package factorys
{
	import flash.display.Sprite;

	import factorys.roles.*;

	public class CRoleFactory
	{
		public static const PLAYER:String = "Player";
		public static const MONSTER:String = "Monster";
		public function CRoleFactory()
		{
		}

		public static function createRole(type:String):Sprite
		{
			switch (type)
			{
				case PLAYER:
					return _createPlayer();
				break;
				case MONSTER:
					return _createMonster();
				break;
			}
			throw new Error("创建类型错误,不存在"+type+"类型!");
			return null;
		}

		private static function _createPlayer():Sprite
		{
			return new CPlayer(0xff0000);
		}

		private static function _createMonster():Sprite
		{
			return new CMonster(0x00ff00);
		}
	}
}
