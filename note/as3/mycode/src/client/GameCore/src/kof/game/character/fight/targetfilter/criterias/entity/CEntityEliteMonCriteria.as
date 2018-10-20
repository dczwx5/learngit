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
import kof.game.character.property.CMonsterProperty;
import kof.game.core.CGameObject;
import kof.table.Monster.EMonsterType;

public class CEntityEliteMonCriteria extends CAbstractCriteria {
    public function CEntityEliteMonCriteria() {
        super();
    }

    override public function meetCriteria( target : CGameObject ) : Boolean
    {
        var objType : int = CCharacterDataDescriptor.getType( target.data );
        if( objType == CCharacterDataDescriptor.TYPE_MONSTER )
        {
            var pMonProperty : CMonsterProperty = target.getComponentByClass( CMonsterProperty , true  ) as CMonsterProperty;
            if( pMonProperty && pMonProperty.monsterType == EMonsterType.UNIQUE )
                return true;
            return false;
        }else{
            return false;
        }

    }
}
}
