//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/9.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.criterialine {

import kof.game.character.fight.targetfilter.ICriteria;
import kof.game.character.fight.targetfilter.criterias.entity.CEntityBossMonCriteria;
import kof.game.character.fight.targetfilter.criterias.entity.CEntityEliteMonCriteria;
import kof.game.character.fight.targetfilter.criterias.entity.CEntityMissileCriteria;
import kof.game.character.fight.targetfilter.criterias.entity.CEntityNormalMonCriteria;
import kof.game.character.fight.targetfilter.criterias.entity.CEntityPlayerCriteria;
import kof.game.character.fight.targetfilter.filterenum.EFilterEntityType;

public class CEntityCriteriaLine extends CBasicFilterLine {
    public function CEntityCriteriaLine() {
        super("EntityLine");
    }
    override public function setCriteriaMask( value : int ) : void
    {
        var criteria : ICriteria;
        if( ( EFilterEntityType.ENTITY_ALL & value ) != 0 )
                return;

        if( (EFilterEntityType.ENTITY_BOSS_MONSTER & value ) != 0 )
        {
            criteria = new CEntityBossMonCriteria();
            _addCriteria( criteria );
        }

        if( (EFilterEntityType.ENTITY_ELITE_MONSTER & value ) != 0 )
        {
            criteria = new CEntityEliteMonCriteria();
            _addCriteria( criteria );
        }

        if( ( EFilterEntityType.ENTITY_MISSILE & value ) != 0 )
        {
            criteria = new CEntityMissileCriteria();
            _addCriteria( criteria );
        }

        if( ( EFilterEntityType.ENTITY_NORMAL_MONSTER & value ) != 0 )
        {
            criteria = new CEntityNormalMonCriteria();
            _addCriteria( criteria );
        }

        if( ( EFilterEntityType.ENTITY_PLAYER & value ) != 0 )
        {
            criteria = new CEntityPlayerCriteria();
            _addCriteria( criteria );
        }

    }
}
}
