//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/12/3.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.criterias.logiccomposite {

import kof.game.character.fight.targetfilter.*;
import kof.game.core.CGameObject;

public class CAndCompositeCriteria extends CAbstractCompositeCriteria {
    public function CAndCompositeCriteria() {
        super();
    }

    override public function meetCriteria( target : CGameObject ) : Boolean
    {
        var meetRet : Boolean = true ;
        for each( var criteria : ICriteria in m_vCriterias ) {
            meetRet = criteria.meetCriteria( target ) && meetRet ;
            if( !meetRet )break;
        }
        return meetRet ;
    }

}
}
