//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/6/8.
//----------------------------------------------------------------------
package kof.game.character.fight.skill {

import QFLib.Foundation;
import QFLib.Interface.IUpdatable;

import kof.framework.IDatabase;
import kof.game.character.CFacadeMediator;
import kof.game.character.CSkillList;
import kof.game.character.animation.IAnimation;
import kof.game.character.collision.CCollisionComponent;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.movement.CMovement;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;
import kof.game.core.ITransform;
import kof.table.ActionSeq;
import kof.table.Hit;
import kof.table.Motion;
import kof.table.Skill;

public class CSkillCasterContext implements IUpdatable {

    public function CSkillCasterContext( owner : CGameObject ) {
        m_owner = owner;

        if ( null == m_animtionPlayer ) {
            m_animtionPlayer = new CSkillActionsPlayer( skillCaster );
        }

    }

    public function dispose() : void {
        if ( null != m_animtionPlayer )
            m_animtionPlayer.dispose();
        m_animtionPlayer = null;

    }

    public function update( delta : Number ) : void {
        m_animtionPlayer.update( delta );
    }

    public function lastUpdate( delta : Number ) : void {
        if ( m_animtionPlayer )
            m_animtionPlayer.lastUpdate( delta );
    }

    final public function get skillID() : int {
        return skillCaster.skillID;
    }

    public function initWithSkillID( pDatabase : IDatabase, skillID : uint ) : Boolean {
        m_pDBSys = pDatabase;
        return buildUpAll();
    }

    private function buildUpAll() : Boolean {
        m_skillData = CSkillCaster.skillDB.getSkillDataByID( skillID );

        if ( null == m_skillData ) {
            CONFIG::debug {
                Foundation.Log.logTraceMsg( "**获取技能数据失败，没有找到对应的技能配置** ID ：" + skillID );
            }
            return false;
        }
        else {
            var pSkillInfoRes : ISkillInfoRes = owner.getComponentByClass( ISkillInfoRes, true ) as ISkillInfoRes;
            if ( pSkillInfoRes )
                actionData = pSkillInfoRes.getSkillActionsByActionFlag( m_skillData.ActionFlag );

            CONFIG::debug {
                if ( actionData == null )Foundation.Log.logTraceMsg( "**获取技能动作数据失败，没有找到对应的动作配置** ：" + m_skillData.ActionFlag );
                else
                    Foundation.Log.logTraceMsg( "**获取技能动作数据成功，对应的动作配置**  ：" + m_skillData.ActionFlag );
            }

        }
        /**
         * 开始组装各种技能数据
         */
            //技能动作数据；
        buildUpActionPlayer();
        return true;
    }

    public function resetSkill() : Boolean {
        m_animtionPlayer.reset();
        return true;
    }

    //手动触发的技能链是否在等待状态 ，这个给释放技能的时候，则进入技能链的逻辑 不释放技能
    public function boInWaitManualChain() : Boolean {
        return false;
    }

    public function cancelSkill() : void {
        this.resetSkill();
    }

    /**
     * 创建动作串联
     */
    private function buildUpActionPlayer() : void {
        m_animtionPlayer.init( m_skillData );//m_actionData);
    }

    final public function get skillCastType() : int {
        return m_skillData.CastType;
    }

    final public function get owner() : CGameObject {
        return m_owner;
    }

    final public function get collisionComponent() : CCollisionComponent {
        return m_owner.getComponentByClass( CCollisionComponent, true ) as CCollisionComponent;
    }

    final public function get stateBoard() : CCharacterStateBoard {
        return m_owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
    }

    final public function get cAnimation() : IAnimation {
        return m_owner.getComponentByClass( IAnimation, true ) as IAnimation;
    }

    final public function get movementCmp() : CMovement {
        return m_owner.getComponentByClass( CMovement, true ) as CMovement;
    }

    final public function get tranformCmp() : ITransform {
        return m_owner.getComponentByClass( ITransform, true ) as ITransform;
    }

    final public function get skillCaster() : CSkillCaster {
        return m_owner.getComponentByClass( CSkillCaster, true ) as CSkillCaster;
    }

    final public function get fightTriggle() : CCharacterFightTriggle {
        return m_owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
    }

    final public function get skillList() : CSkillList {
        return m_owner.getComponentByClass( CSkillList, true ) as CSkillList;
    }

    /**
     final internal function get skillEndCB() : Function {

        return skillCaster.skillAnimationEndCB;
    }*/

    final public function get facadeMediator() : CFacadeMediator {
        return m_owner.getComponentByClass( CFacadeMediator, true ) as CFacadeMediator;
    }

    final public function get actionData() : ActionSeq {
        return m_actionData;
    }

    final public function set actionData( value : ActionSeq ) : void {
        m_actionData = value;
    }

    public function get boNeedRefreshHit() : Boolean {
        return m_boNeedRefreshHit;
    }

    public function set boNeedRefreshHit( value : Boolean ) : void {
        m_boNeedRefreshHit = value;
    }

    public function get boHitEventDispacte() : Boolean {
        return m_boHitEventDispacte;
    }

    public function set boHitEventDispacte( value : Boolean ) : void {
        m_boHitEventDispacte = value;
    }

    public function get skillData() : Skill {
        return m_skillData;
    }

    internal function get AnimationSeqTime() : Number {
        if ( m_animtionPlayer )
            return m_animtionPlayer.tickTime;
        return 0.0;
    }

    private var m_owner : CGameObject;
    private var m_pDBSys : IDatabase;

    //数据相关
    private var m_skillData : Skill;
    private var m_actionData : ActionSeq;
    private var m_hitData : Hit;
    private var m_motionData : Motion;

    //组件相关
    private var m_animtionPlayer : CSkillActionsPlayer;
    /**一些内部状态 */
    //打击需要刷新
    private var m_boNeedRefreshHit : Boolean;
    //一个技能周期内击打事件是否已派发,也就是有没有击中目标
    private var m_boHitEventDispacte : Boolean;
}
}
