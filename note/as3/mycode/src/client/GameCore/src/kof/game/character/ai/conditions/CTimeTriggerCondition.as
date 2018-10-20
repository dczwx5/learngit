//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/7/21.
 * Time: 12:07
 */
package kof.game.character.ai.conditions {

    import QFLib.AI.BaseNode.CBaseNodeCondition;
    import QFLib.AI.CAIObject;
    import QFLib.AI.events.CAIEvent;

    import kof.game.character.ai.CAIComponent;
import kof.game.character.ai.CAILog;
import kof.game.character.ai.CAILog;
import kof.game.character.ai.actions.CDoTriggerAction;

import kof.game.character.ai.aiDataIO.IAIHandler;

    import kof.game.core.CGameObject;

public class CTimeTriggerCondition extends CBaseNodeCondition {
    protected var m_pBT:CAIObject=null;
    protected var m_isfirstInto:Boolean = true;

        protected var timeId:int = 0;
    protected var timeDelay:String="0.5";
    protected var repeatCount:int=0;
    protected var timeProbability:Number=1;
    protected var timePriority:int = 50;
    protected var timeEventCanBreakOtherAction:String = BreakAction.YES;
    protected var initNotExcute:Boolean = false;//等于true初始化时不执行

    protected var m_elapsedTime:Number = 0;
    protected var m_counter:Number = 0;
    protected var m_timeDelayArr:Array = []; //目前支持配置两个时间，第一次成功执行后，会用第二个时间进行判断
    protected var m_timeDelay: Number = 0;
    protected var m_pAIComponent : CAIComponent;

        public function CTimeTriggerCondition( pBt:Object=null, nodeName:String=null,nodeIndex:int=-1) {
            super();
            this.m_pBT = pBt as CAIObject;
            if(nodeIndex>-1)
            {
                setTemplateIndex(nodeIndex);
                setName(nodeIndex+"_"+nodeName);
            }
            else
            {
                setName(nodeName);
            }
            _initNodeData();
        }

    private function _initNodeData():void
    {
        var name:String = getName();
        if(name==null)return;
        if(m_pBT.cacheParamsDic[name+".timeId"])
        {
            timeId = m_pBT.cacheParamsDic[name+".timeId"];
        }
        if(m_pBT.cacheParamsDic[name+".timeDelay"])
        {
            timeDelay = m_pBT.cacheParamsDic[name+".timeDelay"];
        }
        if(m_pBT.cacheParamsDic[name+".repeatCount"])
        {
            repeatCount = m_pBT.cacheParamsDic[name+".repeatCount"];
        }
        if(m_pBT.cacheParamsDic[name+".timeProbability"])
        {
            timeProbability = m_pBT.cacheParamsDic[name+".timeProbability"];
        }
        if(m_pBT.cacheParamsDic[name+".timePriority"])
        {
            timePriority = m_pBT.cacheParamsDic[name+".timePriority"];
        }
        if(m_pBT.cacheParamsDic[name+".timeEventCanBreakOtherAction"])
        {
            timeEventCanBreakOtherAction = m_pBT.cacheParamsDic[name+".timeEventCanBreakOtherAction"];
        }
        if(m_pBT.cacheParamsDic[name+".initNotExcute"])
        {
            initNotExcute = m_pBT.cacheParamsDic[name+".initNotExcute"];
        }
        m_timeDelayArr = [];
        m_timeDelayArr = timeDelay.split("-");
        m_timeDelay = m_timeDelayArr[0];
    }

        override protected function externalCondition(inputData:Object):Boolean
        {
            var dataIO:IAIHandler=inputData.handler as IAIHandler;
            var owner:CGameObject=inputData.owner as CGameObject;
            var pAIComponent:CAIComponent = owner.getComponentByClass(CAIComponent,true) as CAIComponent;
            CAILog.logMsg("进入"+getName(),pAIComponent.objId , CAILog.enabledFailLog );
            m_pAIComponent = pAIComponent;

            if( !pAIComponent.delayTimeMap.find(m_index))
                pAIComponent.delayTimeMap.add( m_index , m_timeDelay , true);

            //先判断该时间事件是否处于开启状态
            if(pAIComponent.dicIdToEventNodeState[timeId])
            {
                if(pAIComponent.dicIdToEventNodeState[timeId]==CDoTriggerAction.CLOSE)
                {
                    m_elapsedTime = 0;
                    CAILog.logMsg("本次事件处于关闭状态，事件id为"+timeId+"，返回false，退出"+getName(),pAIComponent.objId);
                    return false;
                }
            }

            //首次进入不判断时间
            if(m_isfirstInto&&!initNotExcute)
            {
                m_isfirstInto = false;
            }
            else
            {
                if(pAIComponent.bWheatherTriggerEvent&&pAIComponent.currentEventNodeName==getName())
                {

                    CAILog.logEnterInfo(getName(),pAIComponent.objId , "" );
                    pAIComponent.isOverrideAction = false;
                    pAIComponent.iCrrentEventPriority = timePriority;
                    pAIComponent.bWheatherTriggerEvent = true;
                    m_counter++;
                    return true;
                }
                m_elapsedTime += inputData.deltaTime;
                if(executable)
                {
                    CAILog.logMsg("执行时间间隔为"+timeDelay+"当前经过的时间为"+m_elapsedTime
                            +"所以返回true，当前time名"+getName(),pAIComponent.objId , CAILog.enabledFailLog);

                    m_elapsedTime-=m_timeDelay;
                    if(m_timeDelayArr.length>1){
                        m_timeDelay = m_timeDelayArr[1];
                    }
                }
                else
                {
                    CAILog.logMsg("执行时间间隔为"+timeDelay+"当前经过的时间为"+m_elapsedTime
                            +"所以返回false，退出"+getName(),pAIComponent.objId , CAILog.enabledFailLog );
                    return false;
                }
            }
            if((repeatCount!=0&&m_counter>=repeatCount))
            {
                CAILog.logMsg("已经执行的次数"+m_counter+"，允许执行的次数为"+repeatCount+"，返回false，退出"+getName(),pAIComponent.objId );//, CAILog.enabledFailLog);
                return false;
            }
            //计算概率
            var nu:Number = Math.random();
            if(nu>this.timeProbability)
            {
                CAILog.logMsg("事件执行概率为"+timeProbability+"，本次随机概率为"
                        +nu+"，返回false,退出"+getName(),pAIComponent.objId , CAILog.enabledFailLog);
                return false;
            }
            //是否会打断其他事件
            if(timeEventCanBreakOtherAction==BreakAction.YES)
            {
                if(pAIComponent.bWheatherTriggerEvent)
                {
                    if(pAIComponent.iCrrentEventPriority>=timePriority)
                    {
                        CAILog.logMsg("当前正在执行事件的优先级为"+pAIComponent.iCrrentEventPriority+"大于本次执行优先级"
                                +timePriority+"，所以返回false，退出"+getName(),pAIComponent.objId , CAILog.enabledFailLog);
                        return false;
                    }
                    else
                    {
                        var prevTemplateIndex : int = int(pAIComponent.currentEventNodeName.charAt( 0 ));
                        pAIComponent.currentEventNodeName = getName();
                        CAILog.logMsg("本次优先级："+timePriority+"大于"+pAIComponent.iCrrentEventPriority
                                +",发送行为覆盖事件，当前行为模板序号为，"+getTemplateIndex()+"，重置其他模板的复合节点序号",pAIComponent.objId);
                        aiObj.dispatchEvent(new CAIEvent(CAIEvent.OVERRIDE_ACTION,{tempIndex:getTemplateIndex(), prevIndex : prevTemplateIndex}));
                    }
                }

                pAIComponent.currentEventNodeName = getName();
                pAIComponent.iCrrentEventPriority = timePriority;
                pAIComponent.bWheatherTriggerEvent = true;
            }
            CAILog.logEnterInfo(getName(),pAIComponent.objId , "" );
            m_counter++;
            return true;
        }

        protected function get executable():Boolean
        {
//            return m_elapsedTime - m_timeDelay>=0;
            var nodeIndex : int = getTemplateIndex();
            var coolTime : Number;

            coolTime = m_pAIComponent.getNodeCoolTime( nodeIndex );
            if( !m_pAIComponent.findNodeCoolTime( nodeIndex )){
                m_pAIComponent.addNodeCoolTime( nodeIndex , m_timeDelay );
                CAILog.logEnterSubNodeInfo( nodeIndex + "-Next Cool Time" , "下一次冷却CD为：" + m_timeDelay , m_pAIComponent.objId );
                return false;
            }

            if( coolTime <= 0.0 ) {
                return true;
            }
            return false
        }
    }
}


class BreakAction
{
    public static const YES:String = "Yes";
    public static const NO:String = "No";
}