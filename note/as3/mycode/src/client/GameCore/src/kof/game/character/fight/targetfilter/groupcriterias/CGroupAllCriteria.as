//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/9.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.groupcriterias {

import kof.game.character.fight.targetfilter.IGroupCriteria;
import kof.game.core.CGameObject;

public class CGroupAllCriteria extends CAbstractGroupCriteria{
    public function CGroupAllCriteria() {
    }

    override public function meetCriteria(  targetList : Array ) : Array
    {
       return targetList;
    }
}
}
