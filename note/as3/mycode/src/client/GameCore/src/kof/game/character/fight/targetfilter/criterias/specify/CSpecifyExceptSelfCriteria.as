//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/9.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.criterias.specify {

import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.fight.targetfilter.CAbstractCriteria;
import kof.game.character.fight.targetfilter.ICriteria;
import kof.game.core.CGameObject;

public class CSpecifyExceptSelfCriteria extends CAbstractCriteria {
    public function CSpecifyExceptSelfCriteria() {
    }

    override public function meetCriteria( target : CGameObject ) : Boolean
    {
        var ownerID : int = CCharacterDataDescriptor.getID( m_pOwner.data );
        var ownerType : int = CCharacterDataDescriptor.getType(m_pOwner.data);
        var targetID : int = CCharacterDataDescriptor.getID( target.data );
        var targetType : int = CCharacterDataDescriptor.getType( target.data );
        if( ownerID != targetID || ownerType != targetType )
                return true;

        return false;
    }
}
}
