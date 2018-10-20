//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/5/7.
 * Time: 11:37
 */
package QFLib.AI.Composites
{

import QFLib.AI.BaseNode.CBaseNode;
	import QFLib.AI.BaseNode.CBaseNodeComposites;
	import QFLib.AI.BaseNode.CBaseNodeCondition;
import QFLib.AI.CAIObject;
import QFLib.AI.Enum.CNodeRunningStatusEnum;

public class CNodeLoop extends CBaseNodeComposites
	{
		public static const INFINITELOOP:int=-1;
		/**总循环的次数*/
		private var m_iLoopCount:int;
		/**当前循环的次数*/
		private var m_iCurrentCount:int;
	private var m_lastNodeState:int=-1;
	/*当前节点索引*/
	private var m_currentNodeIndex:int;
	private var m_pBT:CAIObject=null;

		public function CNodeLoop(parentNode:CBaseNode,pBt:CAIObject=null,nodeName:String=null)
		{
			super(parentNode);
			this.m_pBT = pBt;
			setName(nodeName);
			_initNodeData();
		}

	private function _initNodeData():void
	{
		var name:String = getName();
		if(name==null)return;
			if(m_pBT.cacheParamsDic[name+".loopCount"])
			{
				m_iLoopCount = m_pBT.cacheParamsDic[name+".loopCount"];
			}
	}
		override protected function _doEvaluate(input:Object):Boolean
		{
			return true;
		}
		override protected function _doTransition(input:Object):void
		{
//			if(_checkIndex(0))
//			{
//				var node:CBaseNode=m_childNodeVec[0];
//				node.transition(input);
//			}
//			m_iCurrentCount=0;
		}
	//加个循环，才能持续执行下去
		override protected function _doTick(input:Object):int
		{
			var isFinish:int=CNodeRunningStatusEnum.SUCCESS;
			var node:CBaseNode = null;
			if(m_iCurrentCount>=m_iLoopCount)
			{
				m_iCurrentCount = 0;
			}
			if(m_iLoopCount==0){
				for (var k:int = m_currentNodeIndex;k<m_childNodeCount;k++)
				{
					if(_checkIndex(k))
					{
						node=m_childNodeVec[k];
						if(m_lastNodeState = CNodeRunningStatusEnum.EXECUTING){
							isFinish=node.tick(input);
						}else{
							if(node.evaluate(input))
							{
								isFinish=node.tick(input);
							}
							else
							{
								m_currentNodeIndex=0;
								isFinish = CNodeRunningStatusEnum.FAIL;
								m_lastNodeState = CNodeRunningStatusEnum.FAIL;
								break;
							}
						}
						if(isFinish == CNodeRunningStatusEnum.SUCCESS)
						{
							m_lastNodeState = CNodeRunningStatusEnum.SUCCESS;
							continue;
						}

						if(isFinish == CNodeRunningStatusEnum.FAIL)
						{
							m_currentNodeIndex=0;
							m_lastNodeState = CNodeRunningStatusEnum.FAIL;
							break;
						}
						if(isFinish == CNodeRunningStatusEnum.EXECUTING)
						{
							m_currentNodeIndex = k;
							m_lastNodeState = CNodeRunningStatusEnum.EXECUTING;
							return CNodeRunningStatusEnum.EXECUTING;
						}
					}
				}
				m_currentNodeIndex=0;
				return CNodeRunningStatusEnum.EXECUTING
			}


			for(var i:int = m_iCurrentCount;i<m_iLoopCount;i++)
			{
				for (var j:int = m_currentNodeIndex;j<m_childNodeCount;j++)
				{
					if(_checkIndex(j))
					{
						node=m_childNodeVec[j];
                        if(m_lastNodeState == CNodeRunningStatusEnum.EXECUTING){
                            isFinish=node.tick(input);
                        }else{
                            if(node.evaluate(input))
                            {
                                isFinish=node.tick(input);
                            }
                            else
                            {
                                m_currentNodeIndex=0;
                                isFinish = CNodeRunningStatusEnum.FAIL;
                                m_lastNodeState = CNodeRunningStatusEnum.FAIL;
                                break;
                            }
                        }
						if(isFinish == CNodeRunningStatusEnum.SUCCESS)
						{
                            m_lastNodeState = CNodeRunningStatusEnum.SUCCESS;
							continue;
						}

						if(isFinish == CNodeRunningStatusEnum.FAIL)
						{
							m_currentNodeIndex=0;
                            m_lastNodeState = CNodeRunningStatusEnum.FAIL;
							break;
						}
						if(isFinish == CNodeRunningStatusEnum.EXECUTING)
						{
							m_currentNodeIndex = j;
                            m_lastNodeState = CNodeRunningStatusEnum.EXECUTING;
							break;
						}
					}
				}
				if(isFinish==CNodeRunningStatusEnum.EXECUTING)
				{
					m_iCurrentCount = i;
					return CNodeRunningStatusEnum.EXECUTING;
				}
				if(isFinish == CNodeRunningStatusEnum.FAIL||isFinish == CNodeRunningStatusEnum.SUCCESS)
				{
					continue;
				}
			}


			if(isFinish==CNodeRunningStatusEnum.FAIL)
			{
				m_iCurrentCount=0;
				m_currentNodeIndex=0;
				return CNodeRunningStatusEnum.FAIL;
			}
			if(isFinish==CNodeRunningStatusEnum.SUCCESS)
			{
				m_iCurrentCount=0;
				m_currentNodeIndex=0;
				return CNodeRunningStatusEnum.SUCCESS;
			}
			return isFinish;
		}
	}
}
