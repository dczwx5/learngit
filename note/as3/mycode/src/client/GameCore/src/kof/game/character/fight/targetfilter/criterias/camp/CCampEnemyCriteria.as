//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/12/3.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.criterias.camp {

import kof.game.character.fight.targetfilter.CAbstractCriteria;
import kof.game.character.level.CLevelMediator;
import kof.game.core.CGameObject;

public class CCampEnemyCriteria extends CAbstractCriteria {
    public function CCampEnemyCriteria() {
        super();
    }

    override public function meetCriteria( target : CGameObject ) : Boolean
    {
        var pLevelMediator : CLevelMediator = m_pOwner.getComponentByClass( CLevelMediator , true ) as CLevelMediator;

        return pLevelMediator.isAttackable( target );
    }
}
}
