//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/12/3.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.criterias.entity {

import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.fight.targetfilter.CAbstractCriteria;
import kof.game.core.CGameObject;

public class CEntityPlayerCriteria extends CAbstractCriteria {
    public function CEntityPlayerCriteria() {
        super();
    }

    override public function meetCriteria( target : CGameObject ) : Boolean
    {
        var objType : int = CCharacterDataDescriptor.getType( target.data );
        if( objType == CCharacterDataDescriptor.TYPE_PLAYER )
        {
            return true;
        }

        return false;
    }
}
}
