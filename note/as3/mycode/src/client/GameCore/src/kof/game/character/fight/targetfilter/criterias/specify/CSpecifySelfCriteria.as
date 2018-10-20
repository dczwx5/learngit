//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/4/5.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.criterias.specify {

import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.fight.targetfilter.CAbstractCriteria;
import kof.game.core.CGameObject;

public class CSpecifySelfCriteria extends CAbstractCriteria {
    public function CSpecifySelfCriteria() {
        super();
    }

    override public function meetCriteria( target : CGameObject ) : Boolean
    {
        var ownerID : int = CCharacterDataDescriptor.getID( m_pOwner.data );
        var targetID : int = CCharacterDataDescriptor.getID( target.data );
        var targetType : int = CCharacterDataDescriptor.getType( target.data );
        var ownerType : int = CCharacterDataDescriptor.getType( m_pOwner.data );
        if( ownerID == targetID && targetType == ownerType )
            return true;

        return false;
    }

}
}
