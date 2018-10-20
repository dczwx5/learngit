//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/12/3.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.criterias.entity {

import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.fight.emitter.CMissile;
import kof.game.character.fight.targetfilter.CAbstractCriteria;
import kof.game.core.CGameObject;

public class CEntityMissileCriteria extends CAbstractCriteria {
    public function CEntityMissileCriteria() {
        super();
    }

    override public function meetCriteria( target : CGameObject ) : Boolean
    {
        var bMissile : Boolean = CCharacterDataDescriptor.isMissile( target.data );
        return bMissile;
//        var missile : CMissile = target as CMissile;
//
//        if( missile )
//        {
//            return true;
//        }
//
//        return false;
    }
}
}
