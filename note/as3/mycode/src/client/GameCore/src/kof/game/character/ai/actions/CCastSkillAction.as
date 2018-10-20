//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/7/21.
 * Time: 17:18
 */
package kof.game.character.ai.actions {

    import QFLib.AI.BaseNode.CBaseNode;
    import QFLib.AI.BaseNode.CBaseNodeAction;
    import QFLib.AI.CAIObject;
    import QFLib.AI.Enum.CNodeRunningStatusEnum;
    import QFLib.Foundation;

    import flash.geom.Point;

    import kof.game.character.CSkillList;
    import kof.game.character.ai.CAIComponent;
    import kof.game.character.ai.CAILog;
    import kof.game.character.ai.aiDataIO.IAIHandler;
    import kof.game.character.state.CCharacterStateBoard;
    import kof.game.core.CGameObject;

    public class CCastSkillAction extends CBaseNodeAction {
        /**技能索引*/
        protected var skillIndex : String = "";
        /**执行模式*/
        private var executeMode : String = ExecuteMode.NORMAL;
        /**执行条件*/
        protected var executeCondition : String = "";
        /**连击等待时间*/
        private var comboWaitTime : String = "";
        /**连击是否计算距离*/
        private var comboMoveToDistance : String = '1-0-0-0-0-0-0-0';
        /**技能释放类型*/
        private var useSkillType : String = "Single";
        /**普攻连击次数*/
        private var comboAttackNu : int = 3;
        /**执行概率*/
        protected var executeProbability : Number = 1;
        /**技能范围随机默认0.05*/
        protected var skillRandomRange : Number = 0.05;
        /**是否最远距离攻击*/
        private var isFarawayAttack : Boolean = false;
        /**攻击距离不够是否跑出去攻击，默认true，要过去攻击*/
        private var isRunHit : Boolean = true;
        /**没有命中是否继续攻击*/
        private var notHitButAttack : String = "";

        private var _zgap:Number=0.3;

        private var m_pBT : CAIObject = null;
        protected var m_bIsfirstInto : Boolean = false;
        protected var m_iIndexVec : Vector.<int> = new Vector.<int>();
        protected var m_sIndexConsumeVec : Vector.<String> = new Vector.<String>();
        protected var m_nTimeWaitVec:Vector.<Number>=new Vector.<Number>();
        protected var m_nComboMoveDistance : Vector.<int> = new Vector.<int>();
        protected var m_iNotHitAtkVec:Vector.<int>=new Vector.<int>();

        public function CCastSkillAction( parentNode : CBaseNode, pBt : CAIObject = null, nodeName : String = null, nodeIndex : int = -1 ) {
            super( parentNode, pBt );
            this.m_pBT = pBt;
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
            try {
                if ( m_pBT.cacheParamsDic[ name + ".skillIndex" ] ) {
                    skillIndex = m_pBT.cacheParamsDic[ name + ".skillIndex" ];
                }
                if ( m_pBT.cacheParamsDic[ name + ".executeMode" ] ) {
                    executeMode = m_pBT.cacheParamsDic[ name + ".executeMode" ];
                }
                if ( m_pBT.cacheParamsDic[ name + ".executeCondition" ] ) {
                    executeCondition = m_pBT.cacheParamsDic[ name + ".executeCondition" ];
                }
                if ( m_pBT.cacheParamsDic[ name + ".useSkillType" ] ) {
                    useSkillType = m_pBT.cacheParamsDic[ name + ".useSkillType" ];
                }
                if ( m_pBT.cacheParamsDic[ name + ".comboAttackNu" ] ) {
                    comboAttackNu = m_pBT.cacheParamsDic[ name + ".comboAttackNu" ];
                }
                if ( m_pBT.cacheParamsDic[ name + ".comboWaitTime" ] ) {
                    comboWaitTime = m_pBT.cacheParamsDic[ name + ".comboWaitTime" ];
                }
                if ( m_pBT.cacheParamsDic[ name + ".comboMoveToDistance" ] ) {
                    comboMoveToDistance = m_pBT.cacheParamsDic[ name + ".comboMoveToDistance" ];
                }
                if ( m_pBT.cacheParamsDic[ name + ".executeProbability" ] ) {
                    executeProbability = m_pBT.cacheParamsDic[ name + ".executeProbability" ];
                }
                if ( m_pBT.cacheParamsDic[ name + ".skillRandomRange" ] ) {
                    skillRandomRange = m_pBT.cacheParamsDic[ name + ".skillRandomRange" ];
                }
                if ( m_pBT.cacheParamsDic[ name + ".isFarawayAttack" ] ) {
                    isFarawayAttack = m_pBT.cacheParamsDic[ name + ".isFarawayAttack" ];
                }
                if ( m_pBT.cacheParamsDic[ name + ".notHitButAttack" ] ) {
                    notHitButAttack = m_pBT.cacheParamsDic[ name + ".notHitButAttack" ];
                }
                var arr : Array = skillIndex.split( "-" );
                for ( var i : int = 0; i < arr.length; i++ ) {
                    m_iIndexVec.push( int( arr[ i ] ) );
                    m_sIndexConsumeVec.push( "1" );
                    m_nTimeWaitVec.push(0.1);
                }

                if ( executeCondition.length > 0 ) {
                    arr = [];
                    arr = executeCondition.split( "-" );
                    var len : int = arr.length;
                    if ( len ) {
                        m_sIndexConsumeVec.splice( 0, len );
                        for ( var j : int = 0; j < len; j++ ) {
                            m_sIndexConsumeVec.push( arr[ j ] );
                        }
                    }
                }
                arr=[];
                arr=comboWaitTime.split("-");
                len=arr.length;
                if(len){
                    m_nTimeWaitVec.splice( 0, len );
                    for(var k:int=0;k<arr.length;k++){
                        m_nTimeWaitVec.push(arr[k]);
                    }
                }
                arr=[];
                arr = notHitButAttack.split("-");
                len = arr.length;
                if(len){
                    m_iNotHitAtkVec.splice(0,len);
                    for(var l:int=0;l<arr.length;l++){
                        m_iNotHitAtkVec.push(arr[l]);
                    }
                }

                arr=[];
                arr =comboMoveToDistance.split("-");
                len = arr.length;
                if(len){
                    m_nComboMoveDistance.splice(0,len);
                    for(var m:int=0;m<arr.length;m++){
                        m_nComboMoveDistance.push(arr[m]);
                    }
                }

            }
            catch ( e : Error ) {
                throw e.message;
            }

        }

        override public function _doExecute( inputData : Object ) : int {
            var dataIO : IAIHandler = inputData.handler as IAIHandler;
            var owner : CGameObject = inputData.owner as CGameObject;
            var pAIComponent : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
            CAILog.logMsg( "进入" + getName(), pAIComponent.objId , CAILog.enabledFailLog );
            if ( m_iIndexVec.length > 0 && m_iIndexVec[ 0 ] == -1 && useSkillType != "Dodge" ) {
                return CNodeRunningStatusEnum.FAIL;
            }
            if ( !pAIComponent.currentAttackable ) {
                CAILog.logMsg( "当前攻击目标为null，返回失败，退出" + getName(), pAIComponent.objId );
                return CNodeRunningStatusEnum.FAIL;
            }
            if ( dataIO.isDead( pAIComponent.currentAttackable ) ) {
                CAILog.logMsg( "当前攻击目标已经死亡，返回失败，退出" + getName(), pAIComponent.objId );
                return CNodeRunningStatusEnum.FAIL;
            }

            if ( m_bIsfirstInto && executeProbability != 1 ) {
                var rnd : Number = Math.random();
                if ( rnd > executeProbability ) {
                    CAILog.logMsg( "本次执行概率为" + rnd + "大于配置参数" + executeProbability + "，返回失败，退出" + getName(), pAIComponent.objId );
                    return CNodeRunningStatusEnum.FAIL;
                }
            }

            if ( pAIComponent.currentCastSkillNodeName == getName() ) {
                if ( pAIComponent.useSkillEnd && !m_bIsfirstInto ) {
                    CAILog.logMsg( "技能" + pAIComponent.iSkillIndex + "释放完毕，返回成功，退出" + getName(), pAIComponent.objId );
                    m_bIsfirstInto = true;
                    return CNodeRunningStatusEnum.SUCCESS;
                } else if ( pAIComponent.excutingSkill ) {
                    CAILog.logMsg( "技能" + pAIComponent.iSkillIndex + "正在释放中，返回正在执行，退出" + getName(), pAIComponent.objId , CAILog.enabledFailLog );
                    m_bIsfirstInto = false;
                    if ( dataIO.getCharacterState( owner, CCharacterStateBoard.MOVING ) ) {
                        dataIO.clearMoveFinishCallBackFunction(owner);//清除上一次移动的回调
                        if ( pAIComponent.bSkillConsume == "0" )//无视消耗
                        {
                            skillDistanceObj = dataIO.getSkillDistance( owner, pAIComponent.iSkillIndex );
                            isMove = dataIO.moveTo( owner, skillDistanceObj.x * (1 - skillRandomRange), skillDistanceObj.z * _zgap * (1 - skillRandomRange), new Point( 0, 0 ), function () : void {
                                dataIO.attackIgnoreWithSkillIdx( owner, pAIComponent.iSkillIndex );
                            }, "ToAttack" );
                            if ( isMove == false ) {
                                dataIO.attackIgnoreWithSkillIdx( owner, pAIComponent.iSkillIndex );
                            }
                        }
                        else {
                            skillDistanceObj = dataIO.getSkillDistance( owner, pAIComponent.iSkillIndex );
                            isMove = dataIO.moveTo( owner, skillDistanceObj.x * (1 - skillRandomRange), skillDistanceObj.z * _zgap * (1 - skillRandomRange), new Point( 0, 0 ), function () : void {
                                dataIO.attackWithSkillID( owner, pAIComponent.iSkillIndex );
                            }, "ToAttack" );
                            if ( isMove == false ) {
                                dataIO.attackWithSkillID( owner, pAIComponent.iSkillIndex );
                            }
                        }
                    }else if(!dataIO.getCharacterState( owner, CCharacterStateBoard.IN_ATTACK )){
                            pAIComponent.excutingSkill = false;
                            pAIComponent.useSkillEnd = true;
                    }
                    return CNodeRunningStatusEnum.EXECUTING;
                }
            }else{
                /**
                var canAttack:Boolean = true;
                canAttack = dataIO.getCharacterState( pAIComponent.currentAttackable, CCharacterStateBoard.LYING );
                if(canAttack){//目标处于倒地状态，则等待
                    CAILog.logMsg( "目标处于倒地状态，则等待" + "，所以返回失败，退出" + getName(), pAIComponent.objId );
                    return CNodeRunningStatusEnum.EXECUTING;
                }
                 */
            }

            if ( pAIComponent.excutingSkill && useSkillType == "Dodge" ) {
                CAILog.logMsg( "本次想要执行的技能是" + useSkillType + "(闪避),但是当前正在执行的技能是" + pAIComponent.iSkillIndex + "，所以返回失败，退出" + getName(), pAIComponent.objId );
                return CNodeRunningStatusEnum.FAIL;
            }

            pAIComponent.notHitButAttackVec = m_iNotHitAtkVec;

            var skillDistanceObj : Object = null;
            var isMove : Boolean = false;
            var skillId : int = 0;//技能ID
            var skillIndex : int = 0;
            switch ( useSkillType ) {
                case "Single":
                {
                    pAIComponent.eventManager.excutedSkillNu=0;
                    if ( dataIO.getCharacterState( owner, CCharacterStateBoard.IN_CONTROL ) ) {
                        if ( executeMode == ExecuteMode.RANDOM ) {
                            var vecIndex : int = int( Math.random() * m_iIndexVec.length );
                            skillIndex = m_iIndexVec[ vecIndex ];
                        }
                        else {
                            skillIndex = m_iIndexVec[ 0 ];
                        }

                        pAIComponent.useSkillType = "Single";
                        skillId = (owner.getComponentByClass( CSkillList, true ) as CSkillList).getSkillIDByIndex( skillIndex );
                        if ( skillId <= 0  ) {
                            pAIComponent.skillFailed();
                            return CNodeRunningStatusEnum.FAIL;
                        }

                        pAIComponent.iSkillIndex = skillIndex;
                        pAIComponent.eventManager.startSkillIndex = skillIndex;
                        pAIComponent.eventManager.skillBegined=false;
                        pAIComponent.iSkillCount = 1;
                        pAIComponent.piSkillIndexVec = m_iIndexVec;
                        pAIComponent.psSkillIndexConsumeVec = m_sIndexConsumeVec;

                        dataIO.clearMoveFinishCallBackFunction(owner);//清除上一次移动的回调
                        pAIComponent.bComboSkill = false;
                        if ( executeCondition == "0" )//无视消耗
                        {
                            CAILog.logMsg( "无视消耗，释放技能" + skillIndex + "技能类型" + useSkillType, pAIComponent.objId );
                            skillDistanceObj = dataIO.getSkillDistance( owner, skillIndex );
                            isMove = dataIO.moveTo( owner, skillDistanceObj.x * (1 - skillRandomRange), skillDistanceObj.z * _zgap * (1 - skillRandomRange), new Point( 0, 0 ), function () : void {
                                dataIO.attackIgnoreWithSkillIdx( owner, skillIndex );
                            }, "ToAttack" );
                            if ( isMove == false ) {
                                pAIComponent.skillBegin();
                                dataIO.attackIgnoreWithSkillIdx( owner, skillIndex );
                            } else {
                                pAIComponent.skillBegin();
                            }
                        }
                        else {
                            CAILog.logEnterSubNodeInfo(getName(),  "释放技能" + skillIndex + "技能类型" + useSkillType, pAIComponent.objId );
                            skillDistanceObj = dataIO.getSkillDistance( owner, m_iIndexVec[ 0 ] );
                            isMove = dataIO.moveTo( owner, skillDistanceObj.x * (1 - skillRandomRange), skillDistanceObj.z * _zgap * (1 - skillRandomRange), new Point( 0, 0 ), function () : void {
                                dataIO.attackWithSkillID( owner, skillIndex );
                            }, "ToAttack" );
                            if ( isMove == false ) {
                                pAIComponent.skillBegin();
                                dataIO.attackWithSkillID( owner, skillIndex );
                            } else {
                                pAIComponent.skillBegin();
                            }
                        }
                    }
                    else {
                        CAILog.logMsg( "角色处于不可控状态，技能" + skillIndex + "释放失败，技能类型" + useSkillType + "，返回失败，退出" + getName(), pAIComponent.objId );
                        pAIComponent.skillFailed();
                        return CNodeRunningStatusEnum.FAIL;
                    }
                }
                    break;
                case "ComboAttack":
                {
                    if ( dataIO.getCharacterState( owner, CCharacterStateBoard.IN_CONTROL ) ) {
                        skillIndex = m_iIndexVec[0];

                        skillId = (owner.getComponentByClass( CSkillList, true ) as CSkillList).getSkillIDByIndex( skillIndex );
                        if ( skillId == 0 ) {
                            pAIComponent.skillFailed();
                            CAILog.logMsg( "普攻技能skillId为" + skillId + "返回技能失败", pAIComponent.objId , CAILog.enabledFailLog );
                            return CNodeRunningStatusEnum.FAIL;
                        }

                        pAIComponent.useSkillType = "ComboAttack";
                        pAIComponent.iSkillIndex = m_iIndexVec[ 0 ];
                        pAIComponent.eventManager.startSkillIndex = m_iIndexVec[ 0 ];
                        pAIComponent.eventManager.skillBegined=false;
                        pAIComponent.iSkillCount = 1;
                        pAIComponent.piSkillIndexVec = m_iIndexVec;
                        pAIComponent.psSkillIndexConsumeVec = m_sIndexConsumeVec;

                        dataIO.clearMoveFinishCallBackFunction(owner);//清除上一次移动的回调
                        pAIComponent.eventManager.excutedSkillNu=0;
                        pAIComponent.bComboSkill = false;
                        CAILog.logEnterSubNodeInfo( getName() , skillIndex + "技能类型" + useSkillType, pAIComponent.objId );
                        skillDistanceObj = dataIO.getSkillDistance( owner, m_iIndexVec[ 0 ] );
                        isMove = dataIO.moveTo( owner, skillDistanceObj.x * (1 - skillRandomRange), skillDistanceObj.z * _zgap * (1 - skillRandomRange), new Point( 0, 0 ), function () : void {
                            dataIO.attackWithSkillID( owner, m_iIndexVec[ 0 ] );
                        }, "ToAttack" );
                        if ( isMove == false ) {
                            pAIComponent.skillBegin();
                            dataIO.attackWithSkillID( owner, m_iIndexVec[ 0 ] );
                        } else {
                            pAIComponent.skillBegin();
                        }
                    }
                    else {
                        CAILog.logMsg( "角色处于不可控状态，技能" + skillIndex + "释放失败，技能类型" + useSkillType + "，返回失败，退出" + getName(), pAIComponent.objId );
                        pAIComponent.skillFailed();
                        return CNodeRunningStatusEnum.FAIL;
                    }
                }
                    break;
                case "Dodge":
                {
                    //霸体状态下挨打不受身
                    if(dataIO.getCharacterState( owner, CCharacterStateBoard.PA_BODY )){
                        pAIComponent.useSkillEnd = true;
                        m_bIsfirstInto = true;
                        pAIComponent.skillFailed();
                        return CNodeRunningStatusEnum.FAIL;
                    }
                    CAILog.logMsg( "释放技能" + skillIndex + "技能类型" + useSkillType, pAIComponent.objId );
                    pAIComponent.skillBegin();
                    var bool : Boolean;
                    if ( m_sIndexConsumeVec[ 0 ] == "3" ) {
                        pAIComponent.useSkillEnd = true;
                        m_bIsfirstInto = true;
                        pAIComponent.skillComplete();
                        return CNodeRunningStatusEnum.SUCCESS;
                    }
                    //无视消耗
                    if ( m_sIndexConsumeVec[ 0 ] == "0") {
                        dataIO.dodgeIgnore( owner );
                    } else {
                        bool = dataIO.dodge( owner );
                        if ( bool == false ) {
                            CAILog.logMsg( "技能" + skillIndex + "释放失败，技能类型" + useSkillType + "，返回失败，退出" + getName(), pAIComponent.objId );
                            pAIComponent.useSkillEnd = true;
                            m_bIsfirstInto = true;
                            pAIComponent.skillFailed();
                            return CNodeRunningStatusEnum.FAIL;
                        }
                    }

                }
                    break;
                case "ComboSkill":
                {
                    if ( dataIO.getCharacterState( owner, CCharacterStateBoard.IN_CONTROL ) ) {
                        var iIndexVecLenth : int = m_iIndexVec.length;
                        pAIComponent.iSkillCount = 0;
                        pAIComponent.eventManager.excutedSkillNu=0;
                        for ( var i : int = 0; i < iIndexVecLenth; i++ ) {
                            pAIComponent.iSkillCount++;
                            skillIndex= m_iIndexVec[ i ];
                            skillId = (owner.getComponentByClass( CSkillList, true ) as CSkillList).getSkillIDByIndex( skillIndex );// pAIComponent.iSkillIndex );
                            if ( skillId != 0 ) {
                                break;
                            }
                        }
                        if ( skillId == 0 ) {
                            pAIComponent.skillFailed();
                            CAILog.logMsg( "[!!!] " + pAIComponent.iSkillIndex + ",对应的技能id为" + skillId + "返回技能失败", pAIComponent.objId , CAILog.enabledFailLog );
                            return CNodeRunningStatusEnum.FAIL;
                        }
                        pAIComponent.bSkillFailed=false;
                        pAIComponent.bSkillCompleteBeforeSkillFailed = false;
                        pAIComponent.useSkillType = "ComboSkill";
                        pAIComponent.iSkillIndex = skillIndex;
                        pAIComponent.eventManager.startSkillIndex = skillIndex;
                        pAIComponent.eventManager.skillBegined=false;
                        pAIComponent.piSkillIndexVec = m_iIndexVec;
                        pAIComponent.psSkillIndexConsumeVec = m_sIndexConsumeVec;
                        pAIComponent.pnSkillWaitTimeVec =m_nTimeWaitVec;
                        pAIComponent.pnSkillMoveToDistance = m_nComboMoveDistance;
                        if(m_iIndexVec.length>1)
                        {
                            pAIComponent.bComboSkill = true;
                        }else{
                            pAIComponent.bComboSkill = false;
                        }
                        if ( i >= m_sIndexConsumeVec.length ) {
                            i = m_sIndexConsumeVec.length - 1;
                        }
                        pAIComponent.iPreSkillIndex = pAIComponent.iSkillIndex;//重置上一个记录的技能索引
                        dataIO.clearMoveFinishCallBackFunction(owner);//清除上一次移动的回调
                        //获取攻击距离
                        skillDistanceObj = dataIO.getSkillDistance( owner, pAIComponent.iSkillIndex );
                        var runHit : Boolean = dataIO.judegeDistanceAttack( skillDistanceObj.x, skillDistanceObj.z, owner );
                        if ( m_sIndexConsumeVec[ i ] == "0" )//无视消耗
                        {
                            CAILog.logMsg( "[!!!]" + pAIComponent.iSkillIndex + " 技能类型" + useSkillType, pAIComponent.objId ,CAILog.enabledFailLog );
                            //如果不跑过去攻击，就判断是否在攻击距离内
                            if ( !isRunHit ) {
                                if ( runHit ) {
                                    isMove = dataIO.moveTo( owner, skillDistanceObj.x * (1 - skillRandomRange), skillDistanceObj.z * _zgap * (1 - skillRandomRange), new Point( 0, 0 ), function () : void {
                                            dataIO.attackIgnoreWithSkillIdx( owner, skillIndex );
                                       CAILog.logComboSkillInfo( "", pAIComponent.objId , pAIComponent.iSkillCount , pAIComponent.iSkillIndex , getName() );
                                    }, "ToAttack" );
                                    if ( isMove == false ) {
                                        pAIComponent.skillBegin();
                                        dataIO.attackIgnoreWithSkillIdx( owner, skillIndex );

                                        CAILog.logComboSkillInfo( "", pAIComponent.objId , pAIComponent.iSkillCount , pAIComponent.iSkillIndex , getName() );
                                    } else {
                                        pAIComponent.skillBegin();
                                    }
                                }
                                else {
                                    CAILog.logMsg( "是否跑过去攻击为false,技能释放失败，返回失败，退出" + getName(), pAIComponent.objId , CAILog.enabledFailLog  );
                                    return CNodeRunningStatusEnum.FAIL;
                                }
                            } else {
                                isMove = dataIO.moveTo( owner, skillDistanceObj.x * (1 - skillRandomRange), skillDistanceObj.z * _zgap * (1 - skillRandomRange), new Point( 0, 0 ), function () : void {
                                    dataIO.attackIgnoreWithSkillIdx( owner, skillIndex );
                                    CAILog.logComboSkillInfo( "", pAIComponent.objId , pAIComponent.iSkillCount , pAIComponent.iSkillIndex , getName() );
                                }, "ToAttack" );
                                if ( isMove == false ) {
                                    pAIComponent.skillBegin();
                                    dataIO.attackIgnoreWithSkillIdx( owner, skillIndex );
                                    dataIO.attackWithSkillID( owner, skillIndex );
                                    CAILog.logComboSkillInfo( "", pAIComponent.objId , pAIComponent.iSkillCount , pAIComponent.iSkillIndex , getName() );
                                } else {
                                    pAIComponent.skillBegin();
                                }
                            }
                        }
                        else {
                            CAILog.logMsg( "释放技能" + pAIComponent.iSkillIndex + "技能类型" + useSkillType, pAIComponent.objId , CAILog.enabledFailLog );
                            if ( !isRunHit ) {
                                if ( runHit ) {
                                    isMove = dataIO.moveTo( owner, skillDistanceObj.x * (1 - skillRandomRange), skillDistanceObj.z * _zgap * (1 - skillRandomRange), new Point( 0, 0 ), function () : void {
                                        dataIO.attackWithSkillID( owner, skillIndex );
                                        CAILog.logComboSkillInfo( "", pAIComponent.objId , pAIComponent.iSkillCount , pAIComponent.iSkillIndex , getName() );
                                    }, "ToAttack" );
                                    if ( isMove == false ) {
                                        pAIComponent.skillBegin();
                                        dataIO.attackWithSkillID( owner, skillIndex );
                                        CAILog.logComboSkillInfo( "", pAIComponent.objId , pAIComponent.iSkillCount , pAIComponent.iSkillIndex , getName() );
                                    } else {
                                        pAIComponent.skillBegin();
                                    }
                                } else {
                                    CAILog.logMsg( "是否跑过去攻击为false,技能释放失败，返回失败，退出" + getName(), pAIComponent.objId , CAILog.enabledFailLog );
                                    return CNodeRunningStatusEnum.FAIL;
                                }
                            } else {
                                isMove = dataIO.moveTo( owner, skillDistanceObj.x * (1 - skillRandomRange), skillDistanceObj.z * _zgap * (1 - skillRandomRange), new Point( 0, 0 ), function () : void {
                                    dataIO.attackWithSkillID( owner, skillIndex );
                                    CAILog.logComboSkillInfo( "", pAIComponent.objId , pAIComponent.iSkillCount , pAIComponent.iSkillIndex , getName() );
                                }, "ToAttack" );
                                if ( isMove == false ) {
                                    pAIComponent.skillBegin();
                                    dataIO.attackWithSkillID( owner, skillIndex );
                                    CAILog.logComboSkillInfo( "", pAIComponent.objId , pAIComponent.iSkillCount , pAIComponent.iSkillIndex , getName() );
                                } else {
                                    pAIComponent.skillBegin();
                                }
                            }
                        }
                    }
                    else {
//                        CAILog.logMsg( "角色处于不可控状态，技能" + skillIndex + "释放失败，技能类型" + useSkillType + "，返回失败，退出" + getName(), pAIComponent.objId );
                        CAILog.logExistUnSatisfyInfo( "SkillAction", getName() +  " 角色处于不可控状态，技能" + skillIndex + "释放失败，技能类型" + useSkillType + "，返回失败，退出" ,  pAIComponent.objId );
                        pAIComponent.skillFailed();
                        return CNodeRunningStatusEnum.FAIL;
                    }
                }
            }
            pAIComponent.currentCastSkillNodeName = getName();
            m_bIsfirstInto = false;
            CAILog.logMsg( "技能" + pAIComponent.iSkillIndex + "正在释放中，返回正在执行，退出" + getName(), pAIComponent.objId  , CAILog.enabledFailLog );
            return CNodeRunningStatusEnum.EXECUTING;
        }

    }
}

class ExecuteMode {
    /**等待可以执行*/
    public static const NORMAL : String = "Normal";
    public static const RANDOM : String = "Random";
}
