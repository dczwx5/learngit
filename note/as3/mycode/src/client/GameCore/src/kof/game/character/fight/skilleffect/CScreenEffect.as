//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/10/22.
//----------------------------------------------------------------------
package kof.game.character.fight.skilleffect {

import QFLib.Foundation;
import QFLib.Interface.IUpdatable;

import flash.utils.Timer;

import kof.game.character.fight.skill.CSkillDebugLog;

import kof.game.character.fight.skilleffect.util.CSkillScreenIns;

import kof.game.core.CGameObject;

public class CScreenEffect extends CAbstractSkillEffect implements IUpdatable{
    public function CScreenEffect( id : int, startFrame : Number, hitEvent : String, etype : int, des : String = "" ) {
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

        if( m_elapseTime >= this.effectStartTime && !m_boShake ) {
            CSkillScreenIns.getSkillScreenEffIns().playSceneShakeEffect( m_owner, effectID );
            m_boShake = true;
        }

    }

    override public function initData( ... args ) : void
    {
        CONFIG::debug {CSkillDebugLog.logTraceMsg( "**@CSkillScreenEffect： 初始化镜头屏幕效果 其中ID= " + effectID );}
        if( null == args || args.length <= 0) return ;
        m_owner = args[0] as CGameObject;
    }

    private var m_elapseTime : Number = 0.0;
    private var m_owner : CGameObject;
    private var m_boShake : Boolean;

}
}
