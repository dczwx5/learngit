//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/8.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.criterias.specify {

import kof.game.character.fight.targetfilter.CAbstractCompositeCriteria;
import kof.game.character.fight.targetfilter.CAbstractCriteria;
import kof.game.character.fight.targetfilter.ICriteria;
import kof.game.core.CGameObject;

public class CSpecifyRandomCriteria extends CAbstractCriteria{
    public function CSpecifyRandomCriteria() {
    }

    override public function meetCriteria( target : CGameObject ) : Boolean
    {
        return true;
    }
}
}
