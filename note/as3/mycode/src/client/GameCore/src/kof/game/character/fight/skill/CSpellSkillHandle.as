//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/6/7.
//----------------------------------------------------------------------
package kof.game.character.fight.skill {

import kof.game.core.CGameObject;
import kof.game.core.CGameSystemHandler;

public class CSpellSkillHandle extends CGameSystemHandler {

    public function CSpellSkillHandle() {
        super( CSkillCaster );
    }

    public override function tickValidate( delta : Number, obj : CGameObject ) : Boolean {
        var bValidate : Boolean = super.tickValidate( delta, obj );
        if ( !bValidate )
            return bValidate;

        var skillCaster : CSkillCaster = obj.getComponentByClass( CSkillCaster, true ) as CSkillCaster;

        if ( skillCaster.skillID != 0 ) {
            return true;
        }
        else
            return false;
    }

    public override function tickUpdate( delta : Number, obj : CGameObject ) : void {
//        var skillCaster : CSkillCaster = obj.getComponentByClass( CSkillCaster, true ) as CSkillCaster;
//        if ( skillCaster )
//            skillCaster.update( delta );
    }


}
}
