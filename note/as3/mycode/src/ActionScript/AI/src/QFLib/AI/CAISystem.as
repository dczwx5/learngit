/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/7/15.
 * Time: 18:16
 */
package QFLib.AI
{

	import avmplus.getQualifiedClassName;

	import flash.net.registerClassAlias;
	import flash.utils.Dictionary;

	public class CAISystem
	{
		public function CAISystem()
		{
		}

		public function dispose():void
		{
			for(var i:* in m_dicAIObj)
			{
				m_dicAIObj[i] = null;
				delete m_dicAIObj[i];
			}
			m_dicAIObj = null;
			for(var j:* in m_elapsedTimeDic)
			{
				m_elapsedTimeDic[j] = null;
				delete m_elapsedTimeDic[j];
			}
			m_elapsedTimeDic = null;
		}

		public function addAIObj(aiObj:CAIObject,updateTime:Number):void
		{
			m_AIObjToTime[aiObj] = updateTime;
		}
		public function updateAIObj(aiObj:CAIObject,delayTime:Number,deltaTime:Number):void
		{
			if(aiObj==null)return;
			aiObj.update( delayTime, deltaTime );
		}

		public function removeAIObj(aiObj:CAIObject):void
		{
			m_AIObjToTime[aiObj] = null;
			delete m_AIObjToTime[aiObj];
		}

		public function get AIObjDic():Dictionary
		{
			return m_AIObjToTime;
		}
		/**
		 * 按更新频率，将相同频率的AIObj放在同一个集合里边
		 * */
		public function addAIObjToBatch(aiObj:CAIObject,updateTime:Number = 0.5):void
		{
			if(m_dicAIObj[updateTime])
			{
				m_dicAIObj[updateTime].push(aiObj);
			}
			else
			{
				m_dicAIObj[updateTime] = new Vector.<CAIObject>();
				m_dicAIObj[updateTime].push(aiObj);
				m_elapsedTimeDic[updateTime] = 0;
			}
		}
		/**批量更新思路
		 *
		 * 将所有obj按照更新频率进行分类，
		 * 当时间增量达到设置的时间，则将
		 * 该时间对应的批次全部update()
		 *
		 * */
		public function updateAIObjBatch(deltaTime:Number=0):void
		{
			m_deltaTime=deltaTime;
			for(var time:Number in m_dicAIObj)
			{
				m_elapsedTimeDic[time] += deltaTime;
				var bool:Boolean = _executable(m_elapsedTimeDic[time],time);
				if(bool)
				{
					m_dicAIObj[time].forEach(_updateAIObj);
					m_elapsedTimeDic[time]-=time;
				}
			}
		}

		private function _updateAIObj(item:CAIObject,index:int,vector:Vector.<CAIObject>):void
		{
//			item.update(m_deltaTime);废弃，没有用到这个了
		}

		public function removeAIObjInBatch(aiObj:CAIObject,updateTime:Number):void
		{
			var index:int = m_dicAIObj[updateTime].indexOf(aiObj);
			m_dicAIObj[updateTime].splice(index);
		}

		private function _executable(elapsedTime:Number,delayTime:Number):Boolean
		{
			return elapsedTime - delayTime>=0;
		}

		public function registerAction(classVecoter:Vector.<Class>):void
		{
			for each (var cls:Class in classVecoter)
			{
				var name:String = getQualifiedClassName(cls).split("::")[1];
				registerClassAlias("aiSystem.actions."+name,cls);
			}
		}

		public function registerCondition(classVecoter:Vector.<Class>):void
		{
			for each (var cls:Class in classVecoter)
			{
				var name:String = getQualifiedClassName(cls).split("::")[1];
				registerClassAlias("aiSystem.conditions."+name,cls);
			}
		}

		private var m_elapsedTimeDic:Dictionary = new Dictionary();
		private var m_dicAIObj:Dictionary = new Dictionary();
		private var m_deltaTime:Number=0;
		private var m_AIObjToTime:Dictionary = new Dictionary();
	}
}
