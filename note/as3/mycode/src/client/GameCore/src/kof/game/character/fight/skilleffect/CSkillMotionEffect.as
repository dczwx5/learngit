//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/8/5.
//----------------------------------------------------------------------
package kof.game.character.fight.skilleffect {

import QFLib.Foundation;
import QFLib.Foundation.CTimeDog;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CVector3;

import flash.geom.Point;

import kof.game.character.CCharacterDataDescriptor;

import kof.game.character.animation.IAnimation;
import kof.game.character.fight.emitter.CMasterCompomnent;

import kof.game.character.fight.skill.CComponentUtility;

import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skill.CSkillCasterContext;
import kof.game.character.fight.skill.CSkillDataBase;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.skill.CSkillMotionAssembly;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;
import kof.game.core.ITransform;
import kof.table.Motion;
import kof.table.Motion.ETransWay;

public class CSkillMotionEffect extends CAbstractSkillEffect implements IUpdatable {

    public function CSkillMotionEffect( id : int, startFrame : Number, hitEvent : String, etype : int, des : String = "" ) {
        super( id, startFrame, hitEvent, etype, des );

    }

    override public function dispose() : void {
        super.dispose();

        this.exitMotion();

        if ( null != m_motionFacade )
            m_motionFacade.dispose();

        m_motionFacade = null;
        m_motionData = null;

        m_pContainer.removeSkillEffect( this );
    }

    public function setDirX( dirX : int ) : void {
        m_dirX = dirX;
    }

    private function doMotion() : void {
        m_boInMoveing = true;
        var pStateBoard : CCharacterStateBoard = m_skillCtx.owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
        var dir : Point = pStateBoard.getValue( CCharacterStateBoard.DIRECTION );

        m_motionFacade.iDirectionX = m_dirX || dir.x;
        var aliasPos : CVector3;
        if ( m_motionData.TransWay == ETransWay.AWAY_SPELLER || m_motionData.TransWay == ETransWay.TO_SPELLER ) {
            var spellerTransform : ITransform;
            var speller : CGameObject;
            var masterComponent : CMasterCompomnent = owner.getComponentByClass( CMasterCompomnent, true ) as CMasterCompomnent;
            if ( masterComponent ) {
                speller = masterComponent.master;
                if ( speller ) {
                     spellerTransform =  speller.getComponentByClass( ITransform, true ) as ITransform;
                    aliasPos = new CVector3(spellerTransform.position.x,spellerTransform.position.y,spellerTransform.position.z );
                }
            }
        }
        m_motionFacade.subscribeDoMotion( m_motionData, aliasPos, null );
        CONFIG::debug {
            Foundation.Log.logTraceMsg( "**@CSkillMotionEffect：*** 位移效果开始执行 其中ID= " + effectID + " Time At : " + m_elapsTime );
        }
    }

    private function exitMotion() : void {
        m_boInMoveing = false;
        CONFIG::debug {
            Foundation.Log.logTraceMsg( "**@CSkillMotionEffect：*** 退出位移效果 其中ID= " + effectID + " Time At :" + m_elapsTime );
        }
        if ( m_motionFacade )
            m_motionFacade.unSubscribeDoMotion();

        m_elapsTime = NaN;

    }

    override public function initData( ... args ) : void {
        CONFIG::debug {
            Foundation.Log.logTraceMsg( "**@CSkillMotionEffect： 初始化位移效果 其中ID= " + effectID );
        };
        super.initData(null);
        m_motionData = CSkillCaster.skillDB.getMotionDataByID( effectID, CCharacterDataDescriptor.getSimpleDes( owner.data ) );
        if ( m_motionData == null ) CSkillDebugLog.logErrorMsg( "Can not find the Motion Effect in Table which ID = " + effectID );
        if ( null == args || args.length <= 0 ) {
            return;
        }

        var skillContext : CComponentUtility = args[ 0 ] as CComponentUtility;
        m_skillCtx = skillContext;
        m_motionFacade = new CSkillMotionAssembly( m_skillCtx.owner, true );
        m_elapsTime = 0.0;
    }

    override public function update( delta : Number ) : void {
        super.update( delta );

        if ( isNaN( m_elapsTime ) )
            return;

        m_elapsTime = m_elapsTime + delta;

        if ( effectStartTime <= m_elapsTime && !m_boInMoveing ) {
            doMotion();
        }

        if ( m_boInMoveing && null != m_motionFacade ) {
            m_motionFacade.firstUpdate( delta );
        }

    }

    override public function lastUpdate( delta : Number ) : void {
        super.lastUpdate( delta );
        if ( m_elapsTime >= endMotionTime && m_boInMoveing ) {
            exitMotion();
//            var pAnimation : IAnimation = m_skillCtx.cAnimation;
//            if ( pAnimation ) {
//                pAnimation.resetCharacterGravityAcc();
//            }
        }

        if ( m_motionFacade && m_boInMoveing )
            m_motionFacade.lastUpdate( delta );
    }

    override public function get isRunning() : Boolean {
        return m_boInMoveing;
    }

    //这里的持续时间又是以秒来配置了
    final  public function get endMotionTime() : Number {
        if ( m_motionData )
            return effectStartTime + m_motionData.Duration;
        return effectStartTime;
    }

    override public function get effectDuarationTime() : Number {
        return m_motionData.Duration;
    }


    private var m_motionData : Motion;
    private var m_motionFacade : CSkillMotionAssembly;
    private var m_elapsTime : Number = NaN;
    private var m_boInMoveing : Boolean;
    private var m_skillCtx : CComponentUtility;//CSkillCasterContext;
    private var m_dirX : int;
}
}
