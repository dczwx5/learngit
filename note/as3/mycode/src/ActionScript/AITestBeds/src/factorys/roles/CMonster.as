/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/7/7.
 * Time: 11:18
 */
package factorys.roles
{
	public class CMonster extends CBaseRole
	{
		public function CMonster(color:int)
		{
			addChild(init(color));
		}
	}
}
