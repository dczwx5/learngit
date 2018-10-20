//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/9/18.
 * Time: 18:22
 */
package kof.game.character.ai.conditions {

import QFLib.AI.events.CAIEvent;

import kof.game.character.ai.CAIComponent;
import kof.game.character.ai.CAIHandler;
import kof.game.character.ai.CAILog;
import kof.game.character.ai.actions.CDoTriggerAction;
import kof.game.character.ai.aiDataIO.IAIHandler;
import kof.game.character.ai.paramsTypeEnum.ECampType;
import kof.game.core.CGameObject;

/**
     * @author yili(guoyiligo@qq.com)
     * 2017/9/18
     * 自动通关目标是否完成的判
     */
    public class CTimeTriggerAutoPassCondition extends CTimeTriggerCondition {

        public function CTimeTriggerAutoPassCondition(pBt:Object=null, nodeName:String=null,nodeIndex:int=-1) {
            super(pBt,nodeName,nodeIndex);
        }

        override protected final function externalCondition(inputData:Object):Boolean{
            var owner : CGameObject = inputData.owner as CGameObject;
            var dataIO:IAIHandler = inputData.handler as IAIHandler;
            var pAIComponent:CAIComponent = owner.getComponentByClass(CAIComponent,true) as CAIComponent;
            m_pAIComponent = pAIComponent;
            CAILog.logMsg("进入"+getName(),pAIComponent.objId , CAILog.enabledFailLog);
            if(!dataIO.isHero(owner))return false;
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

            if(dataIO.findAttackable( owner ,ECampType.ENEMY,"All","ShortDistance","Self","-1","-1" ) != null ){
                CAILog.logMsg( "找到了可攻击的目标 ，退出自动通关行为" + getName(), pAIComponent.objId ,CAILog.enabledFailLog );
                pAIComponent.bWheatherTriggerEvent = true;
                return false;
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

                    CAILog.logMsg("正在执行，返回true，退出"+getName(),pAIComponent.objId);
                    pAIComponent.iCrrentEventPriority = timePriority;
                    pAIComponent.bWheatherTriggerEvent = true;
                    m_counter++;
                    return true;
                }
                m_elapsedTime += inputData.deltaTime;
                if(executable)
                {
                    CAILog.logMsg("执行时间间隔为"+timeDelay+"当前经过的时间为"+m_elapsedTime
                            +"所以返回true，当前time名"+getName(),pAIComponent.objId);

                    m_elapsedTime-=m_timeDelay;
                    if(m_timeDelayArr.length>1){
                        m_timeDelay = m_timeDelayArr[1];
                    }
                }
                else
                {
                    CAILog.logMsg("执行时间间隔为"+timeDelay+"当前经过的时间为"+m_elapsedTime
                            +"所以返回false，退出"+getName(),pAIComponent.objId , CAILog.enabledFailLog);
                    return false;
                }
            }
            //trunk激活 可以往传送门方向走
            if(!dataIO.bTrunkActive){
                return false
            }

            //是否会打断其他事件
            if(timeEventCanBreakOtherAction==BreakAction.YES)
            {
                if(pAIComponent.bWheatherTriggerEvent)
                {

                    if(pAIComponent.iCrrentEventPriority>timePriority)
                    {
                        CAILog.logMsg("当前正在执行事件的优先级为"+pAIComponent.iCrrentEventPriority+"大于本次执行优先级"
                                +timePriority+"，所以返回false，退出"+getName(),pAIComponent.objId);
                        return false;
                    }
                    else
                    {
                        var prevTemplateIndex : int = int(pAIComponent.currentEventNodeName.charAt( 0 ));
                        pAIComponent.currentEventNodeName = getName();
                        CAILog.logMsg("本次优先级："+timePriority+"大于"+pAIComponent.iCrrentEventPriority
                                +",发送行为覆盖事件，当前行为模板序号为，"+getTemplateIndex()+"，重置其他模板的复合节点序号",pAIComponent.objId)
                        aiObj.dispatchEvent(new CAIEvent(CAIEvent.OVERRIDE_ACTION,{tempIndex:getTemplateIndex(), prevIndex : prevTemplateIndex}));

                    }
                }

                pAIComponent.currentEventNodeName = getName();
                pAIComponent.iCrrentEventPriority = timePriority;
                pAIComponent.bWheatherTriggerEvent = true;
            }
            CAILog.logMsg("可以执行本次事件，返回true，退出"+getName(),pAIComponent.objId);
            m_counter++;
            return true;
        }

    }
}
class BreakAction
{
    public static const YES:String = "Yes";
    public static const NO:String = "No";
}