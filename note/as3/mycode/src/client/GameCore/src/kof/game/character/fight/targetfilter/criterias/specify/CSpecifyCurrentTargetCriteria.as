//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/11/9.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.criterias.specify {

import kof.game.character.CTarget;
import kof.game.character.fight.targetfilter.CAbstractCriteria;
import kof.game.core.CGameObject;

public class CSpecifyCurrentTargetCriteria extends CAbstractCriteria {
    public function CSpecifyCurrentTargetCriteria() {
        super();
    }

    override public function meetCriteria( target : CGameObject ) : Boolean {
        var pTargetComp : CTarget = m_pOwner.getComponentByClass( CTarget, true ) as CTarget;
        if ( pTargetComp ) {
            var pTarget : CGameObject = pTargetComp.targetObject;
            return target === pTarget
        }
        return false;
    }
}
}
