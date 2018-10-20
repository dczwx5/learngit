//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/7/21.
 * Time: 17:33
 */
package kof.game.character.ai.conditions {

    import QFLib.AI.BaseNode.CBaseNodeCondition;
    import QFLib.AI.CAIObject;
    import QFLib.AI.events.CAIEvent;

    import flash.events.Event;

    import kof.game.character.ai.CAIComponent;

    import kof.game.character.ai.CAIEvent;
    import kof.game.character.ai.CAILog;
    import kof.game.character.ai.actions.CDoTriggerAction;
    import kof.game.character.ai.aiDataIO.IAIHandler;
    import kof.game.character.fight.event.CFightTriggleEvent;
    import kof.game.character.fight.skillchain.CCharacterFightTriggle;
    import kof.game.character.property.interfaces.ICharacterProperty;
    import kof.game.core.CGameObject;

    public class CEventTriggerCondition extends CBaseNodeCondition {
        protected var m_pBT : CAIObject = null;

        protected var eventId : int = 0; //id标识符
        protected var eventDelay : int = 0; //间隔多久一次
        protected var eventCount : int = 0; //触发次数，0为无限次
        protected var eventProbability : Number = 0; //概率
        protected var eventPriority : int = 30; //优先级
        protected var eventType : String = EventType.ENTER_ATTACK;
        protected var eventTargetType : String = TargetType.TARGET;
        protected var eventPropertyValue : Number = 0;

        protected var m_isTargetBeginAttack : Boolean = false;
        protected var m_count : int = 0;//记录触发了多少次
        protected var m_elapsedTime : Number = 0;
        protected var m_preEventType : String = "";
        private var m_TimeAlreadyElapsed : Boolean = true;

        public function CEventTriggerCondition( pBt : Object = null, nodeName : String = null, nodeIndex : int = -1 ) {
            super();
            this.m_pBT = pBt as CAIObject;
            if ( nodeIndex > -1 ) {
                setTemplateIndex( nodeIndex );
                setName( nodeIndex + "_" + nodeName );
            }
            else {
                setName( nodeName );
            }
            _initNodeData();
        }

        private function _initNodeData() : void {
            var name : String = getName();
            if ( name == null )return;
            if ( m_pBT.cacheParamsDic[ name + ".eventType" ] ) {
                eventType = m_pBT.cacheParamsDic[ name + ".eventType" ];
            }
            if ( m_pBT.cacheParamsDic[ name + ".eventProbability" ] ) {
                eventProbability = m_pBT.cacheParamsDic[ name + ".eventProbability" ];
            }
            if ( m_pBT.cacheParamsDic[ name + ".eventId" ] ) {
                eventId = m_pBT.cacheParamsDic[ name + ".eventId" ];
            }
            if ( m_pBT.cacheParamsDic[ name + ".eventDelay" ] ) {
                eventDelay = m_pBT.cacheParamsDic[ name + ".eventDelay" ];
            }
            if ( m_pBT.cacheParamsDic[ name + ".eventCount" ] ) {
                eventCount = m_pBT.cacheParamsDic[ name + ".eventCount" ];
            }
            if ( m_pBT.cacheParamsDic[ name + ".eventPriority" ] ) {
                eventPriority = m_pBT.cacheParamsDic[ name + ".eventPriority" ];
            }
            if ( m_pBT.cacheParamsDic[ name + ".eventTargetType" ] ) {
                eventTargetType = m_pBT.cacheParamsDic[ name + ".eventTargetType" ];
            }
            if ( m_pBT.cacheParamsDic[ name + ".eventPropertyValue" ] ) {
                eventPropertyValue = m_pBT.cacheParamsDic[ name + ".eventPropertyValue" ];
            }
        }

        override protected function externalCondition( inputData : Object ) : Boolean {
            var owner : CGameObject = inputData.owner as CGameObject;
            var dataIO : IAIHandler = inputData.handler as IAIHandler;
            var pAIComponent : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
            var nu : Number = Math.random();
            var isOpen : Boolean = true;
            CAILog.logMsg( "进入" + getName(), pAIComponent.objId , CAILog.enabledFailLog);
            m_pAIComponent =  pAIComponent;

            if( !pAIComponent.delayTimeMap.find(m_index)); {
                pAIComponent.delayTimeMap.add(m_index, eventDelay, true );
            }

            if ( pAIComponent.bWheatherTriggerEvent && pAIComponent.currentEventNodeName == getName() ) {
                CAILog.logMsg( "正在执行，返回true，退出" + getName(), pAIComponent.objId , CAILog.enabledFailLog );
                pAIComponent.iCrrentEventPriority = eventPriority;
                pAIComponent.bWheatherTriggerEvent = true;
                m_count++;
                pAIComponent.isOverrideAction = true;
                return true;
            }

            if(!m_TimeAlreadyElapsed){
                m_elapsedTime += inputData.deltaTime;
                if ( executable ) {
                    m_TimeAlreadyElapsed = true;
                    m_elapsedTime = 0;
                }
                else {
                    CAILog.logMsg( "执行时间间隔为" + eventDelay + "当前经过的时间为" + m_elapsedTime + "所以返回false，退出" + getName(), pAIComponent.objId , CAILog.enabledFailLog);
                    return false;
                }
            }

            var priorityTrriger : Boolean = false;
            if ( pAIComponent.bWheatherTriggerEvent ) {
                if ( pAIComponent.iCrrentEventPriority >= eventPriority ) {
                    CAILog.logMsg( "当前正在执行事件的优先级为" + pAIComponent.iCrrentEventPriority + "大于本次执行优先级" + eventPriority + "，所以返回false，退出" + getName(), pAIComponent.objId , CAILog.enabledFailLog);
                    return false;
                }
            }
            priorityTrriger = true;

            if ( pAIComponent.dicIdToEventNodeState[ eventId ] ) {
                if ( pAIComponent.dicIdToEventNodeState[ eventId ] == CDoTriggerAction.OPEN ) {
                    isOpen = true;
                }
                else {
                    isOpen = false;
                }
            }
            var pFacadeProperty : ICharacterProperty = null;
            var bool : Boolean;
            if ( eventCount > 0 && m_count < eventCount || eventCount == 0 ) {
                var prevTemplateIndex : int = int(pAIComponent.currentEventNodeName.charAt( 0 ));
                switch ( eventType ) {
                    case EventType.ENTER_ATTACK: //目标攻击
                        if ( m_preEventType == EventType.ENTER_ATTACK ) {
                            CAILog.logMsg( "本次事件类型" + eventType + "，上次事件类型" + m_preEventType + "，返回true,退出" + getName(), pAIComponent.objId );
                            m_preEventType = "";
                            pAIComponent.currentEventNodeName == getName();
                            if ( priorityTrriger ) {
                                aiObj.dispatchEvent( new QFLib.AI.events.CAIEvent( QFLib.AI.events.CAIEvent.OVERRIDE_ACTION, {tempIndex : getTemplateIndex(),prevIndex : prevTemplateIndex} ) );
                            }
                            pAIComponent.bWheatherTriggerEvent = true;
                            if ( m_TimeAlreadyElapsed ) {
                                CAILog.logMsg( "事件类型:" + eventType + "事件执行概率为" + eventProbability + "，本次随机概率为" + nu + "，返回true,退出" + getName(), pAIComponent.objId );
                                m_elapsedTime = 0;
                                m_TimeAlreadyElapsed = false;
                                return true;
                            } else {
                                CAILog.logMsg( "事件类型:" + eventType + "距上一次时间不足:" + eventDelay + "，返回false,退出" + getName(), pAIComponent.objId );
                                return false;
                            }
                        }
                        if ( pAIComponent.bTargetAttack && isOpen ) {
                            if ( nu <= eventProbability ) {
                                CAILog.logMsg( "事件类型:" + eventType + "，事件执行概率为" + eventProbability + "，本次随机概率为" + nu + "，返回true,退出" + getName(), pAIComponent.objId );
                                pAIComponent.currentEventNodeName = getName();
                                pAIComponent.bWheatherTriggerEvent = true;
                                pAIComponent.iCrrentEventPriority = eventPriority;
                                if ( eventCount > 0 ) {
                                    m_count++;
                                }
                                m_preEventType = EventType.ENTER_ATTACK;
                                if ( priorityTrriger ) {
                                    aiObj.dispatchEvent( new QFLib.AI.events.CAIEvent( QFLib.AI.events.CAIEvent.OVERRIDE_ACTION, {tempIndex : getTemplateIndex(), prevIndex : prevTemplateIndex} ) );
                                }
                                if ( m_TimeAlreadyElapsed ) {
                                    CAILog.logMsg( "事件类型:" + eventType + "事件执行概率为" + eventProbability + "，本次随机概率为" + nu + "，返回true,退出" + getName(), pAIComponent.objId );
                                    m_elapsedTime = 0;
                                    m_TimeAlreadyElapsed = false;
                                    return true;
                                } else {
                                    CAILog.logMsg( "事件类型:" + eventType + "距上一次时间不足:" + eventDelay + "，返回false,退出" + getName(), pAIComponent.objId );
                                    return false;
                                }
                            }
                            else {
                                CAILog.logMsg( "事件类型:" + eventType + "事件执行概率为" + eventProbability + "，本次随机概率为" + nu + "，false,退出" + getName(), pAIComponent.objId,CAILog.enabledFailLog );
                                m_preEventType = "";
                                return false;
                            }
                        }
                        break;
                    case EventType.BE_INJURED: //受伤状态判断
                        var isInjuredBool : Boolean;
                        if ( eventTargetType == "Self" ) {
                            isInjuredBool = dataIO.isHurting( owner );
                        }
                        else if ( eventTargetType == "Target" ) {
                            if ( pAIComponent.currentAttackable ) {
                                isInjuredBool = dataIO.isHurting( pAIComponent.currentAttackable );
                            }
                        }
                        if ( isInjuredBool && isOpen ) {

                            if ( nu <= eventProbability ) {
                                pAIComponent.currentEventNodeName = getName();
                                pAIComponent.bWheatherTriggerEvent = true;
                                pAIComponent.iCrrentEventPriority = eventPriority;
                                pAIComponent.bTargetAttack = false;
                                if ( eventCount > 0 ) {
                                    m_count++;
                                }
                                if ( priorityTrriger ) {
                                    aiObj.dispatchEvent( new QFLib.AI.events.CAIEvent( QFLib.AI.events.CAIEvent.OVERRIDE_ACTION, {tempIndex : getTemplateIndex()  , prevIndex : prevTemplateIndex} ) );
                                }
                                if ( m_TimeAlreadyElapsed ) {
                                    CAILog.logMsg( "事件类型:" + eventType + "事件执行概率为" + eventProbability + "，本次随机概率为" + nu + "，返回true,退出" + getName(), pAIComponent.objId );
                                    m_elapsedTime = 0;
                                    m_TimeAlreadyElapsed = false;
                                    return true;
                                } else {
                                    CAILog.logMsg( "事件类型:" + eventType + "距上一次时间不足:" + eventDelay + "，返回false,退出" + getName(), pAIComponent.objId );
                                    return false;
                                }
                            }
                            else {
                                CAILog.logMsg( "事件类型:" + eventType + "事件执行概率为" + eventProbability + "，本次随机概率为" + nu + "，返回false,退出" + getName(), pAIComponent.objId );
                                pAIComponent.bTargetAttack = false;
                                return false;
                            }
                        }
                        break;
                    case EventType.BE_ATTACKED: //自身处于防御状态
                        if ( pAIComponent.isBeAttacked && isOpen ) {
                            pAIComponent.isBeAttacked = false;
                            if ( nu <= eventProbability ) {
                                pAIComponent.currentEventNodeName = getName();
                                pAIComponent.bWheatherTriggerEvent = true;
                                pAIComponent.iCrrentEventPriority = eventPriority;
                                pFacadeProperty = owner.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
                                pAIComponent.recordCurHP = pFacadeProperty.HP;
                                if ( eventCount > 0 ) {
                                    m_count++;
                                }
                                if ( priorityTrriger ) {
                                    aiObj.dispatchEvent( new QFLib.AI.events.CAIEvent( QFLib.AI.events.CAIEvent.OVERRIDE_ACTION, {tempIndex : getTemplateIndex(), prevIndex : prevTemplateIndex} ) );
                                }
                                if ( m_TimeAlreadyElapsed ) {
                                    CAILog.logMsg( "事件类型:" + eventType + "事件执行概率为" + eventProbability + "，本次随机概率为" + nu + "，返回true,退出" + getName(), pAIComponent.objId );
                                    m_elapsedTime = 0;
                                    m_TimeAlreadyElapsed=false;
                                    return true;
                                } else {
                                    CAILog.logMsg( "事件类型:" + eventType + "距上一次时间不足:" + eventDelay + "，返回false,退出" + getName(), pAIComponent.objId );
                                    return false;
                                }
                            }
                            else {
                                CAILog.logMsg( "事件类型:" + eventType + "事件执行概率为" + eventProbability + "，本次随机概率为" + nu + "，返回false,退出" + getName(), pAIComponent.objId );
                            }
                        }
                        break;
                    case EventType.TARGET_MOVE:
                        if ( eventTargetType == "Master" ) {
                            if ( pAIComponent.currentMaster ) {
                                bool = dataIO.isMoving( pAIComponent.currentMaster );
                            }
                        }
                        else {
                            if ( pAIComponent.currentAttackable ) {
                                bool = dataIO.isMoving( pAIComponent.currentAttackable );
                            }
                        }
                        if ( isOpen ) {
                            if ( bool ) {
                                if ( nu <= eventProbability ) {
                                    pAIComponent.currentEventNodeName = getName();
                                    pAIComponent.bWheatherTriggerEvent = true;
                                    pAIComponent.iCrrentEventPriority = eventPriority;
                                    if ( eventCount > 0 ) {
                                        m_count++;
                                    }
                                    if ( priorityTrriger ) {
                                        aiObj.dispatchEvent( new QFLib.AI.events.CAIEvent( QFLib.AI.events.CAIEvent.OVERRIDE_ACTION, {tempIndex : getTemplateIndex(), prevIndex : prevTemplateIndex} ) );
                                    }
                                    if ( m_TimeAlreadyElapsed ) {
                                        CAILog.logMsg( "事件类型:" + eventType + "事件执行概率为" + eventProbability + "，本次随机概率为" + nu + "，返回true,退出" + getName(), pAIComponent.objId );
                                        m_elapsedTime = 0;
                                        m_TimeAlreadyElapsed=false;
                                        return true;
                                    } else {
                                        CAILog.logMsg( "事件类型:" + eventType + "距上一次时间不足:" + eventDelay + "，返回false,退出" + getName(), pAIComponent.objId ,CAILog.enabledFailLog);
                                        return false;
                                    }
                                }
                                else {
                                    CAILog.logMsg( "事件类型:" + eventType + "事件执行概率为" + eventProbability + "，本次随机概率为" + nu + "，返回false,退出" + getName(), pAIComponent.objId , CAILog.enabledFailLog);
                                }
                            }
                            else {
                                CAILog.logMsg( "事件类型:" + eventType + "目标类型：" + eventTargetType + "没有处于移动状态，返回false,退出" + getName(), pAIComponent.objId , CAILog.enabledFailLog );
                            }
                        }
                        else {
                            CAILog.logMsg( "事件类型:" + eventType + "，事件处于关闭状态，返回false,退出" + getName(), pAIComponent.objId , CAILog.enabledFailLog );
                        }

                        break;
                    case EventType.HAS_NOT_DEFENSE:
                        if ( eventTargetType == "Self" ) {
                            pFacadeProperty = owner.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;

                        } else if ( eventType == "Target" ) {
                            pFacadeProperty = pAIComponent.currentAttackable.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
                        }
                        var dCur : Number = pFacadeProperty.DefensePower / pFacadeProperty.MaxDefensePower;
                        var dtarget : Number = eventPropertyValue / 100;
                        if ( dCur <= dtarget ) {
                            if ( nu <= eventProbability ) {
                                pAIComponent.currentEventNodeName = getName();
                                pAIComponent.bWheatherTriggerEvent = true;
                                pAIComponent.iCrrentEventPriority = eventPriority;
                                if ( eventCount > 0 ) {
                                    m_count++;
                                }
                                if ( priorityTrriger ) {
                                    aiObj.dispatchEvent( new QFLib.AI.events.CAIEvent( QFLib.AI.events.CAIEvent.OVERRIDE_ACTION, {tempIndex : getTemplateIndex(), prevIndex : prevTemplateIndex} ) );
                                }
                                if ( m_TimeAlreadyElapsed ) {
                                    CAILog.logMsg( "事件类型:" + eventType + "事件执行概率为" + eventProbability + "，本次随机概率为" + nu + "，返回true,退出" + getName(), pAIComponent.objId );
                                    m_elapsedTime = 0;
                                    m_TimeAlreadyElapsed=false;
                                    return true;
                                } else {
                                    CAILog.logMsg( "事件类型:" + eventType + "距上一次时间不足:" + eventDelay + "，返回false,退出" + getName(), pAIComponent.objId , CAILog.enabledFailLog );
                                    return false;
                                }
                            }
                        }
                        else {
                            CAILog.logMsg( "事件执行目标：" + eventTargetType + "事件类型:" + eventType + "自身没破防,返回true,退出" + getName(), pAIComponent.objId ,CAILog.enabledFailLog);
                            return false;
                        }
                        break;
                    case EventType.HAS_NOT_ATTACK:
                        if ( eventTargetType == "Self" ) {
                            pFacadeProperty = owner.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
                            var aCur : Number = pFacadeProperty.AttackPower / pFacadeProperty.MaxAttackPower;
                            var atarget : Number = eventPropertyValue / 100;
                            if ( aCur <= atarget ) {
                                if ( nu <= eventProbability ) {
                                    pAIComponent.currentEventNodeName = getName();
                                    pAIComponent.bWheatherTriggerEvent = true;
                                    pAIComponent.iCrrentEventPriority = eventPriority;
                                    if ( eventCount > 0 ) {
                                        m_count++;
                                    }
                                    if ( m_TimeAlreadyElapsed ) {
                                        CAILog.logMsg( "事件类型:" + eventType + "事件执行概率为" + eventProbability + "，本次随机概率为" + nu + "，返回true,退出" + getName(), pAIComponent.objId );
                                        m_elapsedTime = 0;
                                        m_TimeAlreadyElapsed=false;
                                        pAIComponent.bComboSkill=false;
                                        aiObj.dispatchEvent( new QFLib.AI.events.CAIEvent( QFLib.AI.events.CAIEvent.OVERRIDE_ACTION, {tempIndex : getTemplateIndex(), prevIndex : prevTemplateIndex} ) );
//                                        pAIComponent.eventManager.resetCastComboSkillCountTime();
                                        return true;
                                    } else {
                                        CAILog.logMsg( "事件类型:" + eventType + "距上一次时间不足:" + eventDelay + "，返回false,退出" + getName(), pAIComponent.objId , CAILog.enabledFailLog );
                                        return false;
                                    }
                                }
                            }
                            else {
                                CAILog.logMsg( "事件执行目标：" + eventTargetType + "事件类型:" + eventType + "自身没破防,返回true,退出" + getName(), pAIComponent.objId , CAILog.enabledFailLog );
                                return false;
                            }
                        }
                        break;
                    case EventType.DEBARRASS:
                        var gameObj : Vector.<CGameObject> = dataIO.findTeammateObj( owner );
                        for each ( var obj : CGameObject in gameObj ) {
                            if ( dataIO.isLaying( obj ) ) {
                                if ( dataIO.findNuOfEnemyObjInRange( obj, eventPropertyValue, 3 ) ) {
                                    if ( nu <= eventProbability ) {
                                        pAIComponent.currentEventNodeName = getName();
                                        pAIComponent.bWheatherTriggerEvent = true;
                                        pAIComponent.iCrrentEventPriority = eventPriority;
                                        if ( eventCount > 0 ) {
                                            m_count++;
                                        }
                                        if ( priorityTrriger ) {
                                            aiObj.dispatchEvent( new QFLib.AI.events.CAIEvent( QFLib.AI.events.CAIEvent.OVERRIDE_ACTION, {tempIndex : getTemplateIndex(), prevIndex : prevTemplateIndex} ) );
                                        }
                                        pAIComponent.currentMaster = obj;
                                        if ( m_TimeAlreadyElapsed ) {
                                            CAILog.logMsg( "事件类型:" + eventType + "事件执行概率为" + eventProbability + "，本次随机概率为" + nu + "，返回true,退出" + getName(), pAIComponent.objId );
                                            m_elapsedTime = 0;
                                            m_TimeAlreadyElapsed=false;
                                            return true;
                                        } else {
                                            CAILog.logMsg( "事件类型:" + eventType + "距上一次时间不足:" + eventDelay + "，返回false,退出" + getName(), pAIComponent.objId , CAILog.enabledFailLog );
                                            return false;
                                        }
                                    }
                                }
                            }
                        }
                        CAILog.logMsg( "事件类型:" + eventType + "事件执行概率为" + eventProbability + "不满足友方倒地，周围敌人超过3人，返回false，退出" + getName(), pAIComponent.objId , CAILog.enabledFailLog );
                        return false;
                    case EventType.RESCUE:
                        var r_gameObj : Vector.<CGameObject> = dataIO.findTeammateObj( owner );
                        for each ( var robj : CGameObject in r_gameObj ) {
                            if ( robj == owner )continue;
                            pFacadeProperty = owner.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
                            var lCur : Number = pFacadeProperty.HP / pFacadeProperty.MaxHP;
                            var ltarget : Number = eventPropertyValue / 100;
                            if ( lCur <= ltarget ) {
                                if ( nu <= eventProbability ) {
                                    pAIComponent.currentEventNodeName = getName();
                                    pAIComponent.bWheatherTriggerEvent = true;
                                    pAIComponent.iCrrentEventPriority = eventPriority;
                                    if ( eventCount > 0 ) {
                                        m_count++;
                                    }
                                    if ( priorityTrriger ) {
                                        aiObj.dispatchEvent( new QFLib.AI.events.CAIEvent( QFLib.AI.events.CAIEvent.OVERRIDE_ACTION, {tempIndex : getTemplateIndex(), prevIndex : prevTemplateIndex} ) );
                                    }
                                    pAIComponent.currentMaster = robj;
                                    if ( m_TimeAlreadyElapsed ) {
                                        CAILog.logMsg( "事件类型:" + eventType + "事件执行概率为" + eventProbability + "，本次随机概率为" + nu + "，返回true,退出" + getName(), pAIComponent.objId );
                                        m_elapsedTime = 0;
                                        m_TimeAlreadyElapsed=false;
                                        return true;
                                    } else {
                                        CAILog.logMsg( "事件类型:" + eventType + "距上一次时间不足:" + eventDelay + "，返回false,退出" + getName(), pAIComponent.objId , CAILog.enabledFailLog );
                                        return false;
                                    }
                                }
                            }
                        }
                        CAILog.logMsg( "事件类型:" + eventType + "事件执行概率为" + eventProbability + "不满足友方生命值低于" + ltarget + "返回false，退出" + getName(), pAIComponent.objId , CAILog.enabledFailLog );
                        return false;
                    case EventType.Laying:
                        var boolLaying : Boolean;
                        if ( eventTargetType == "Self" ) {
                            boolLaying = dataIO.isLaying( owner );
                        } else if ( eventType == "Target" ) {
                            boolLaying = dataIO.isLaying( pAIComponent.currentAttackable );
                        }
                        if ( boolLaying ) {
                            pAIComponent.currentEventNodeName == getName();
                            pAIComponent.bWheatherTriggerEvent = true;
                            if ( m_TimeAlreadyElapsed ) {
                                CAILog.logMsg( "事件类型:" + eventType + "事件执行概率为" + eventProbability + "，本次随机概率为" + nu + "，返回true,退出" + getName(), pAIComponent.objId );
                                m_elapsedTime = 0;
                                m_TimeAlreadyElapsed=false;
                                return true;
                            } else {
                                CAILog.logMsg( "事件类型:" + eventType + "距上一次时间不足:" + eventDelay + "，返回false,退出" + getName(), pAIComponent.objId , CAILog.enabledFailLog );
                                return false;
                            }
                        }
                        else {
                            CAILog.logMsg( "事件类型:" + eventType + "事件执行概率为" + eventProbability + "，本次随机概率为" + nu + "，目标没倒地，返回false,退出" + getName(), pAIComponent.objId,CAILog.enabledFailLog );
                            return false;
                        }
                        break;
                    case EventType.SELF_MOVE:
                        bool = dataIO.isMoving( owner );
                        if ( isOpen ) {
                            if ( bool ) {
                                if ( nu <= eventProbability ) {
                                    pAIComponent.currentEventNodeName = getName();
                                    pAIComponent.bWheatherTriggerEvent = true;
                                    pAIComponent.iCrrentEventPriority = eventPriority;
                                    if ( eventCount > 0 ) {
                                        m_count++;
                                    }
                                    if ( priorityTrriger ) {
                                        aiObj.dispatchEvent( new QFLib.AI.events.CAIEvent( QFLib.AI.events.CAIEvent.OVERRIDE_ACTION, {tempIndex : getTemplateIndex(), prevIndex : prevTemplateIndex} ) );
                                    }
                                    if ( m_TimeAlreadyElapsed ) {
                                        CAILog.logMsg( "事件类型:" + eventType + "事件执行概率为" + eventProbability + "，本次随机概率为" + nu + "，返回true,退出" + getName(), pAIComponent.objId );
                                        m_elapsedTime = 0;
                                        m_TimeAlreadyElapsed=false;
                                        return true;
                                    } else {
                                        CAILog.logMsg( "事件类型:" + eventType + "距上一次时间不足:" + eventDelay + "，返回false,退出" + getName(), pAIComponent.objId , CAILog.enabledFailLog );
                                        return false;
                                    }
                                }
                                else {
                                    CAILog.logMsg( "事件类型:" + eventType + "事件执行概率为" + eventProbability + "，本次随机概率为" + nu + "，返回false,退出" + getName(), pAIComponent.objId , CAILog.enabledFailLog );
                                }
                            }
                            else {
                                CAILog.logMsg( "事件类型:" + eventType + "目标类型：" + eventTargetType + "没有处于移动状态，返回false,退出" + getName(), pAIComponent.objId , CAILog.enabledFailLog );
                            }
                        }
                        else {
                            CAILog.logMsg( "事件类型:" + eventType + "，事件处于关闭状态，返回false,退出" + getName(), pAIComponent.objId , CAILog.enabledFailLog );
                        }
                        break;
                    case EventType.GET_UP:
                        if ( pAIComponent.isTrrigerGetUp ) {
                            pAIComponent.isTrrigerGetUp = false;
                            if ( nu <= eventProbability ) {
                                if ( eventCount > 0 ) {
                                    m_count++;
                                }
                                if ( m_TimeAlreadyElapsed ) {
                                    if ( priorityTrriger ) {
                                        aiObj.dispatchEvent( new QFLib.AI.events.CAIEvent( QFLib.AI.events.CAIEvent.OVERRIDE_ACTION, {tempIndex : getTemplateIndex(), prevIndex : prevTemplateIndex} ) );
                                    }
                                    pAIComponent.currentEventNodeName = getName();
                                    pAIComponent.bWheatherTriggerEvent = true;
                                    pAIComponent.iCrrentEventPriority = eventPriority;
                                    CAILog.logMsg( "事件类型:" + eventType + "事件执行概率为" + eventProbability + "，本次随机概率为" + nu + "，返回true,退出" + getName(), pAIComponent.objId );
                                    m_elapsedTime = 0;
                                    m_TimeAlreadyElapsed=false;
                                    return true;
                                } else {
                                    CAILog.logMsg( "事件类型:" + eventType + "距上一次时间不足:" + eventDelay + "，返回false,退出" + getName(), pAIComponent.objId , CAILog.enabledFailLog );
                                    return false;
                                }
                            }
                            else {
                                CAILog.logMsg( "事件类型:" + eventType + "事件执行概率为" + eventProbability + "，本次随机概率为" + nu + "，返回false,退出" + getName(), pAIComponent.objId , CAILog.enabledFailLog );
                                return false;
                            }
                        } else {
                            CAILog.logMsg( "事件类型:" + eventType + "事件执行概率为" + eventProbability + "，本次随机概率为" + nu + ",没有触发起身，返回false,退出" + getName(), pAIComponent.objId , CAILog.enabledFailLog );
                            return false;
                        }
                        break;
                    case EventType.SERVER_TRRIGGER:
                        if(pAIComponent.isServerTrrigger){
                            pAIComponent.isServerTrrigger = false;
                            if ( nu <= eventProbability ) {
                                if ( eventCount > 0 ) {
                                    m_count++;
                                }
                                if ( m_TimeAlreadyElapsed ) {
                                    if ( priorityTrriger ) {
                                        aiObj.dispatchEvent( new QFLib.AI.events.CAIEvent( QFLib.AI.events.CAIEvent.OVERRIDE_ACTION, {tempIndex : getTemplateIndex(), prevIndex : prevTemplateIndex} ) );
                                    }
                                    pAIComponent.currentEventNodeName = getName();
                                    pAIComponent.bWheatherTriggerEvent = true;
                                    pAIComponent.iCrrentEventPriority = eventPriority;
                                    CAILog.logMsg( "事件类型:" + eventType + "事件执行概率为" + eventProbability + "，本次随机概率为" + nu + "，返回true,退出" + getName(), pAIComponent.objId );
                                    m_elapsedTime = 0;
                                    m_TimeAlreadyElapsed=false;
                                    return true;
                                } else {
                                    CAILog.logMsg( "事件类型:" + eventType + "距上一次时间不足:" + eventDelay + "，返回false,退出" + getName(), pAIComponent.objId , CAILog.enabledFailLog );
                                    return false;
                                }
                            }
                            else {
                                CAILog.logMsg( "事件类型:" + eventType + "事件执行概率为" + eventProbability + "，本次随机概率为" + nu + "，返回false,退出" + getName(), pAIComponent.objId , CAILog.enabledFailLog );
                                return false;
                            }
                        }else {
                            CAILog.logMsg( "事件类型:" + eventType + "事件执行概率为" + eventProbability + "，本次随机概率为" + nu + ",服务器没有触发，返回false,退出" + getName(), pAIComponent.objId , CAILog.enabledFailLog );
                            return false;
                        }
                }
            }
            CAILog.logMsg( "事件类型:" + eventType + "事件执行概率为" + eventProbability + "，本次随机概率为" + nu + "，返回false,退出" + getName(), pAIComponent.objId , CAILog.enabledFailLog );
            return false;
        }

        private function get executable() : Boolean {
//            return m_elapsedTime - eventDelay >= 0;
            var nodeIndex : int = getTemplateIndex();
            var coolTime : Number;
            coolTime = m_pAIComponent.getNodeCoolTime( nodeIndex );
            if( !m_pAIComponent.findNodeCoolTime( nodeIndex )){
                m_pAIComponent.addNodeCoolTime( nodeIndex , eventDelay);
                CAILog.logEnterSubNodeInfo( nodeIndex + "-Next Cool Time" , "下一次冷却CD为：" +  eventDelay, m_pAIComponent.objId );
                return false;
            }

            if( coolTime <= 0.0 ) {
                return true;
            }
            return false
        }

        private var m_pAIComponent : CAIComponent;
    }
}

class EventType {
    /**进入攻击*/
    public static const ENTER_ATTACK : String = "EnterAttack";
    /**击中*/
    public static const ATTACK_HIT : String = "AttackHit";
    /**被攻击*/
    public static const BE_ATTACKED : String = "BeAttacked";
    /**受伤*/
    public static const BE_INJURED : String = "BeInjured";
    /**死亡*/
    public static const DEAD : String = "Dead";
    /**计数器*/
    public static const COUNT : String = "Count";
    /**目标移动*/
    public static const TARGET_MOVE : String = "TargetMove";
    /**破防*/
    public static const HAS_NOT_DEFENSE : String = "HasNotDefense";
    /**没攻击值*/
    public static const HAS_NOT_ATTACK : String = "HasNotAttack";
    /**解围*/
    public static const DEBARRASS : String = "Debarrass";
    /**救援*/
    public static const RESCUE : String = "Rescue";
    /**倒地*/
    public static const Laying : String = "Laying";
    /**自身移动*/
    public static const SELF_MOVE : String = "SelfMove";
    /**起身*/
    public static const GET_UP : String = "GetUp";
    /**服务器触发*/
    public static const SERVER_TRRIGGER:String = "ServerTrrigger";
}

class TargetType {
    /**自己*/
    public static const SELF : String = "Self";
    /**目标*/
    public static const TARGET : String = "Target";
    /**队友*/
    public static const TEAMMATE : String = "Teammate";
    /**敌人boss*/
    public static const ENEMYBOSS : String = "EnemyBoss";
}
