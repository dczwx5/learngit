//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/2/24.
//----------------------------------------------------------------------
package kof.game.character.fight.skilleffect {

import QFLib.Framework.CFX;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CVector3;

import flash.geom.Point;

import kof.game.character.fight.skill.CComponentUtility;

import kof.game.character.fight.skill.CSkillCaster;

import kof.game.character.fight.skill.CSkillDebugLog;

import kof.game.character.fight.skilleffect.CAbstractSkillEffect;
import kof.game.character.fx.CFXMediator;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;
import kof.table.ScreenEffect;

public class CScreenColorEffect extends CAbstractSkillEffect implements IUpdatable {
    public function CScreenColorEffect( id : int, startFrame : Number, hitEvent : String, etype : int, des : String = "" ) {
        super( id, startFrame, hitEvent, etype, des );
    }

    override public function dispose( ) : void
    {
        m_owner = null;
        m_elapseTime = 0;
        super.dispose();
    }

    override public function update( delta : Number ) : void
    {
        super.update(delta);
        m_elapseTime += delta;

        if( m_elapseTime >= this.effectStartTime && !m_boInEffecting ) {
            m_boInEffecting = true;
            doEffect();
        }

    }

    protected function doEffect( delta : Number = 0.0 ) : void
    {
        var pFxMediator : CFXMediator = m_owner.getComponentByClass( CFXMediator , true ) as CFXMediator;
        if( pFxMediator ){
            {
                var pStateBoard : CCharacterStateBoard = owner.getComponentByClass( CCharacterStateBoard , true ) as CCharacterStateBoard;
                var dir : Point = pStateBoard.getValue( CCharacterStateBoard.DIRECTION );

                var bPositionOverturn : Boolean;
                var bOverturn : Boolean;
                if( m_skillEffectColor.OverTurn == 1 ) {
                    bPositionOverturn = bOverturn = dir.x == -1 ? true : false;
                } else {
                    bOverturn = false;
                    bPositionOverturn = false;
                }

                var durationTime : Number = m_skillEffectColor.duration > 0?m_skillEffectColor.duration : -1;
                var position : CVector3 = new CVector3( m_skillEffectColor.PostionX , m_skillEffectColor.PostionY , m_skillEffectColor.PostionZ );
                var scale : CVector3 = new CVector3( m_skillEffectColor.ScaleX , m_skillEffectColor.ScaleY , m_skillEffectColor.ScaleZ );
                var isTopDisplay : Boolean = m_skillEffectColor.toplayer == 1;
            }
            var fx : CFX;
            if( m_skillEffectColor.Type == 0) {
                fx = pFxMediator.playSceneEffect( m_skillEffectColor.Name , durationTime );
            } else if( m_skillEffectColor.Type == 1 ) {
                fx = pFxMediator.playSceneEffect( m_skillEffectColor.Name , durationTime , false ,CFX.FULLSCREEN ,bPositionOverturn , bOverturn, null , scale ,isTopDisplay );
            }else if( m_skillEffectColor.Type == 2 ){
                fx = pFxMediator.playSceneEffect( m_skillEffectColor.Name ,durationTime, false,CFX.NOFULLSCREEN ,bPositionOverturn , bOverturn, position , scale , isTopDisplay );
            }

            if( m_skillEffectColor.EndWithSkill )
            {
                var componentUti : CComponentUtility;
                if( pSkillCaster && pSkillCaster.pComUtility) {
                    componentUti = pSkillCaster.pComUtility;
                    componentUti.addToControlledFX( fx );
                }
            }

        }
    }

    override public function initData( ... args ) : void
    {
        CONFIG::debug {CSkillDebugLog.logTraceMsg( "**@CSkillChainEffect： 初始化技能链 其中ID= " + effectID );}
        if( null == args || args.length <= 0) return ;
        m_owner = args[0] as CGameObject;
        m_skillEffectColor  = CSkillCaster.skillDB.getSceenEffectByID( effectID );
    }

    private var m_elapseTime : Number = 0.0;
    private var m_owner : CGameObject;
    private var m_boInEffecting : Boolean;
    private var m_skillEffectColor : ScreenEffect;
}
}
