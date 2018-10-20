//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/9.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.groupcriterias {

import kof.game.character.fight.targetfilter.IGroupCriteria;
import kof.game.character.fight.targetfilter.filterenum.EFilterPickPerConditionType;
import kof.game.character.fight.targetfilter.groupcriterias.groupcriteria.CGroupLessHpCri;
import kof.game.character.fight.targetfilter.groupcriterias.groupcriteria.CGroupXFarCriteria;
import kof.game.character.fight.targetfilter.groupcriterias.groupcriteria.CGroupXNearCriteria;
import kof.game.character.fight.targetfilter.groupcriterias.groupcriteria.CGroupZFarCriteria;
import kof.game.character.fight.targetfilter.groupcriterias.groupcriteria.CGroupZNearCriteria;
import kof.game.core.CGameObject;

public class CGroupAssemblyLine {
    public function CGroupAssemblyLine() {
    }

    public static function GetGroupCriteria( mask  : int ) : IGroupCriteria
    {
        var groupCriteria : IGroupCriteria;
        if( (EFilterPickPerConditionType.OTHER_ALL & mask ) != 0 )
            groupCriteria = new CGroupAllCriteria();

        if( (EFilterPickPerConditionType.OTHER_LESS_HP & mask ) != 0 )
            groupCriteria = new CGroupLessHpCri();

        if( (EFilterPickPerConditionType.OTHER_X_NEARESE & mask ) != 0 ||
                (EFilterPickPerConditionType.OTHER_NEAR & mask) != 0 )
            groupCriteria = new CGroupXNearCriteria();

        if( (EFilterPickPerConditionType.OTHER_Z_NEARESE & mask ) != 0 )
            groupCriteria = new CGroupZNearCriteria();

        if( (EFilterPickPerConditionType.OTHER_X_FAR & mask ) != 0 ||
                (EFilterPickPerConditionType.OTHER_FAR & mask) != 0)
            groupCriteria = new CGroupXFarCriteria();

        if( (EFilterPickPerConditionType.OTHER_Z_FAR & mask ) != 0 )
            groupCriteria = new CGroupZFarCriteria();

        return groupCriteria;
    }

}
}
