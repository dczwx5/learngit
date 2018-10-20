/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/7/7.
 * Time: 15:51
 */
package aiDataIO
{
	import com.greensock.TweenLite;

	import flash.display.Sprite;

	public class CActionHandler implements IAIDataIO
	{
		private var m_data:Object;
		public function CActionHandler()
		{
		}

		public final function get data():Object
		{
			return m_data;
		}

		public final function set data(obj:Object):void
		{
			m_data = obj;
		}

		public final function followPlayer(callBackFunc:Function,followDistance:Number):void
		{
			var player:Sprite = m_data.player;
			var monster:Sprite = m_data.monster;
			if(player.x-monster.x>0)
			{
				if(player.y-monster.y>0)
				{
					TweenLite.to(monster,0.3,{x:player.x-30,y:player.y-30,onComplete:callBackFunc});
				}
				else
				{
					TweenLite.to(monster,0.3,{x:player.x-30,y:player.y+30,onComplete:callBackFunc});
				}

			}
			else
			{
				if(player.y-monster.y<0)
				{
					TweenLite.to(monster,0.3,{x:player.x+30,y:player.y+30,onComplete:callBackFunc});
				}
				else
				{
					TweenLite.to(monster,0.3,{x:player.x+30,y:player.y-30,onComplete:callBackFunc});
				}

			}
		}
	}
}
