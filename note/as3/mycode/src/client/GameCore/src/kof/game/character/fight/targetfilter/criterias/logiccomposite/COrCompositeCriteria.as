//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/12/3.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.criterias.logiccomposite {

import kof.game.character.fight.targetfilter.CAbstractCompositeCriteria;
import kof.game.character.fight.targetfilter.ICriteria;
import kof.game.core.CGameObject;

public class COrCompositeCriteria extends CAbstractCompositeCriteria {
    public function COrCompositeCriteria() {
        super();
    }

    override public function meetCriteria( target : CGameObject ) : Boolean
    {
        var meetRet : Boolean = false;
        for each( var criteria : ICriteria in m_vCriterias ) {
            meetRet = criteria.meetCriteria( target ) ||  meetRet ;
        }
        return meetRet ;
    }
}
}
