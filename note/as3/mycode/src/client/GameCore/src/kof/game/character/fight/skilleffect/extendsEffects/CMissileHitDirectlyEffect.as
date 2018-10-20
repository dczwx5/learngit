//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/11/22.
//----------------------------------------------------------------------
package kof.game.character.fight.skilleffect.extendsEffects {
import kof.game.character.fight.skilleffect.CSkillMissileHitEffect;

public class CMissileHitDirectlyEffect extends CSkillMissileHitEffect{
    public function CMissileHitDirectlyEffect( id : int, startFrame : Number, hitEvent : String, etype : int, des : String = "" ) {
        super( id, startFrame, hitEvent, etype, des );
    }

    override public function dispose() : void{
        super.dispose();
        if( m_directlyTargets)
                m_directlyTargets.splice( 0 , m_directlyTargets.length);
        m_directlyTargets = null;
    }

    public function doHitDirectlyToMissiles( targets : Array ,targetPositions : Array = null ) : void{
        m_directlyTargets  = targets;
    }

    override public function update( delta : Number ) : void{
       super.update( delta );
    }

    override public function lastUpdate( delta : Number ) : void{
        if( m_pContainer )
                m_pContainer.removeSkillEffect( this );
    }

    override protected function _findMissile() : Boolean{
       if( m_directlyTargets && m_directlyTargets.length > 0)
               return true;

        return false;
    }

    private var m_directlyTargets : Array;
}
}
