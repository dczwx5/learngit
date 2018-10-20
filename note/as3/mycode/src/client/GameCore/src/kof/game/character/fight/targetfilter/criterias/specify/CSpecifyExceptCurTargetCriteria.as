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

public class CSpecifyExceptCurTargetCriteria extends CAbstractCriteria {
    public function CSpecifyExceptCurTargetCriteria() {
        super();
    }

    override public function meetCriteria( target : CGameObject ) : Boolean {
        var pTargetComp : CTarget = m_pOwner.getComponentByClass( CTarget, true ) as CTarget;
        if ( pTargetComp ) {
            var isCurrentTarget : Boolean;
            var pTarget : CGameObject = pTargetComp.targetObject;

            isCurrentTarget = target === pTarget;
            return isCurrentTarget;
        }
        return true;
    }
}
}
