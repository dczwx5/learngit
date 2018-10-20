//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/12/3.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.criterias.camp {

import kof.game.character.fight.targetfilter.CAbstractCriteria;
import kof.game.core.CGameObject;

public class CCampNeuCriteria extends CAbstractCriteria {
    public function CCampNeuCriteria() {
        super();
    }

    /**
     * fixme the neutrality camp has not implement!!
     * @param target
     * @return
     */
    override public function meetCriteria( target : CGameObject ) : Boolean
    {
        return false;
    }
}
}
