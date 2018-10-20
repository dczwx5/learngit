//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2018/1/17.
 * Time: 15:09
 */
package kof.game.character.ai.actions {

import QFLib.AI.BaseNode.CBaseNode;
import QFLib.AI.BaseNode.CBaseNodeAction;
import QFLib.AI.CAIObject;
import QFLib.AI.Enum.CNodeRunningStatusEnum;

import flash.geom.Point;

import kof.game.character.CSkillList;

import kof.game.character.ai.CAIComponent;
import kof.game.character.ai.CAIHandler;

import kof.game.character.ai.CAILog;
import kof.game.character.ai.aiDataIO.IAIHandler;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;

/**
 * @author yili(guoyiligo@qq.com)
 * 2018/1/17
 *
 * 主控(托管)角色自动战斗放大招
 *
 */
public class CPlayerUltimateSkillAction extends CBaseNodeAction {
    /**技能索引*/
    protected var uSkillIndex : Number = 5;
    protected var uRoleType:String="All";

    /**技能范围随机默认0.05*/
    protected var skillRandomRange : Number = 0.05;

    protected var m_bIsfirstInto : Boolean = false;
    private var m_pBT : CAIObject = null;

    public function CPlayerUltimateSkillAction( parentNode : CBaseNode, pBt : CAIObject = null, nodeName : String = null, nodeIndex : int = -1 ) {
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
        if ( m_pBT.cacheParamsDic[ name + ".uSkillIndex" ] ) {
            uSkillIndex = Number(m_pBT.cacheParamsDic[ name + ".uSkillIndex" ]);
        }
        if ( m_pBT.cacheParamsDic[ name + ".uRoleType" ] ) {
            uRoleType = m_pBT.cacheParamsDic[ name + ".uRoleType" ];
        }
    }

    override public function _doExecute( inputData : Object ) : int {
        var dataIO : IAIHandler = inputData.handler as IAIHandler;
        var owner : CGameObject = inputData.owner as CGameObject;
        var pAIComponent : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
//        if(!CAIHandler(dataIO).bAutoFight){
//            return CNodeRunningStatusEnum.FAIL;
//        }
        if(uRoleType=="Hero")
        {
            if(!CAIHandler(dataIO).bAutoFight){
                return CNodeRunningStatusEnum.FAIL;
            }
            if(!dataIO.isHero(owner)){
                return CNodeRunningStatusEnum.FAIL;
            }
        }else if(uRoleType=="All"){
            if(dataIO.isTeamMate( owner ) || dataIO.isHero(owner)) {
               if(!CAIHandler(dataIO).bAutoFight){
                   return CNodeRunningStatusEnum.FAIL;
                }
            }
        }

        CAILog.logMsg( "进入" + getName(), pAIComponent.objId );
        if ( !pAIComponent.currentAttackable ) {
            CAILog.logMsg( "当前攻击目标为null，返回失败，退出" + getName(), pAIComponent.objId );
            return CNodeRunningStatusEnum.FAIL;
        }
        if ( dataIO.isDead( pAIComponent.currentAttackable ) ) {
            CAILog.logMsg( "当前攻击目标已经死亡，返回失败，退出" + getName(), pAIComponent.objId );
            return CNodeRunningStatusEnum.FAIL;
        }
        if ( pAIComponent.currentCastSkillNodeName == getName() ) {
            if ( pAIComponent.useSkillEnd && !m_bIsfirstInto ) {
                CAILog.logExistInfo(getName() , " Skill end and return SUCCEED" , pAIComponent.objId );//( "技能" + pAIComponent.iSkillIndex + "释放完毕，返回成功，退出" + getName(), pAIComponent.objId );
                m_bIsfirstInto = true;
                return CNodeRunningStatusEnum.SUCCESS;
            } else if ( pAIComponent.excutingSkill ) {
                CAILog.logMsg( "技能" + pAIComponent.iSkillIndex + "正在释放中，返回正在执行，退出" + getName(), pAIComponent.objId , CAILog.enabledFailLog );
                m_bIsfirstInto = false;
                if ( dataIO.getCharacterState( owner, CCharacterStateBoard.MOVING ) ) {
                    dataIO.clearMoveFinishCallBackFunction( owner );//清除上一次移动的回调
                    skillDistanceObj = dataIO.getSkillDistance( owner, pAIComponent.iSkillIndex );
                    isMove = dataIO.moveTo( owner, skillDistanceObj.x * (1 - skillRandomRange), skillDistanceObj.z * 0.4 * (1 - skillRandomRange), new Point( 0, 0 ), function () : void {
                        dataIO.attackWithSkillID( owner, pAIComponent.iSkillIndex );
                    }, "ToAttack" );
                    if ( isMove == false ) {
                        dataIO.attackWithSkillID( owner, pAIComponent.iSkillIndex );
                    }
                } else if ( !dataIO.getCharacterState( owner, CCharacterStateBoard.IN_ATTACK ) ) {
                    pAIComponent.excutingSkill = false;
                    pAIComponent.useSkillEnd = true;
                }
                return CNodeRunningStatusEnum.EXECUTING;
            }
        } else {
            var canAttack : Boolean = true;
            canAttack = dataIO.getCharacterState( pAIComponent.currentAttackable, CCharacterStateBoard.LYING );
            if ( canAttack ) {
                CAILog.logEnterSubNodeInfo("SuperSkillAction", getName() + "!!!目标在倒地状态，继续等待", pAIComponent.objId );
                return CNodeRunningStatusEnum.EXECUTING;
            }
        }
        var skillDistanceObj : Object = null;
        var isMove : Boolean = false;
        var skillId : int = 0;//技能ID
        if ( dataIO.getCharacterState( owner, CCharacterStateBoard.IN_CONTROL ) ) {
            pAIComponent.iSkillIndex = uSkillIndex;
            skillId = (owner.getComponentByClass( CSkillList, true ) as CSkillList).getSkillIDByIndex( pAIComponent.iSkillIndex );
            if ( skillId == 0 ) {
                pAIComponent.skillFailed();
                return CNodeRunningStatusEnum.FAIL;
            }
            dataIO.clearMoveFinishCallBackFunction( owner );//清除上一次移动的回调
            pAIComponent.bComboSkill = false;
            CAILog.logEnterSubNodeInfo("SuperSkillAction" , getName() + "cast super skill " , pAIComponent.objId );// ( "释放大招" + uSkillIndex, pAIComponent.objId );
            skillDistanceObj = dataIO.getSkillDistance( owner, uSkillIndex );
            isMove = dataIO.moveTo( owner, skillDistanceObj.x * (1 - skillRandomRange), skillDistanceObj.z * 0.4 * (1 - skillRandomRange), new Point( 0, 0 ), function () : void {
                dataIO.attackWithSkillID( owner, uSkillIndex );
            }, "ToAttack" );
            if ( isMove == false ) {
                pAIComponent.skillBegin();
                dataIO.attackWithSkillID( owner, uSkillIndex );
            } else {
                pAIComponent.skillBegin();
            }
        }
        else {
            CAILog.logExistUnSatisfyInfo( getName() , " 非可控状态下，不能释放大招" , pAIComponent.objId );//( "角色处于不可控状态，大招技能" + uSkillIndex + "释放失败，返回失败，退出" + getName(), pAIComponent.objId );
            pAIComponent.skillFailed();
            return CNodeRunningStatusEnum.FAIL;
        }
        pAIComponent.currentCastSkillNodeName = getName();
        m_bIsfirstInto = false;
        CAILog.logMsg( "技能" + pAIComponent.iSkillIndex + "正在释放中，返回正在执行，退出" + getName(), pAIComponent.objId , CAILog.enabledFailLog );
        return CNodeRunningStatusEnum.EXECUTING;
    }

}
}
