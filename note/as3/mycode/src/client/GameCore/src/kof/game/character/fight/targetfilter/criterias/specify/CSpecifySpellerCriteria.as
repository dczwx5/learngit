//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/11/9.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.criterias.specify {

import kof.game.character.fight.emitter.CMasterCompomnent;
import kof.game.character.fight.targetfilter.CAbstractCriteria;
import kof.game.core.CGameObject;

public class CSpecifySpellerCriteria extends CAbstractCriteria {
    public function CSpecifySpellerCriteria() {
        super();
    }

    override public function meetCriteria( target : CGameObject ) : Boolean{
        var masterComponent : CMasterCompomnent = m_pOwner.getComponentByClass( CMasterCompomnent , true ) as CMasterCompomnent;
        if( masterComponent ) {
            var master : CGameObject = masterComponent.master;
            if( master ) {
                return master === target;
            }

            return false;
        }
        //如果自己不是子弹，buff 则筛选条件失效的
        return false;
    }
}
}
