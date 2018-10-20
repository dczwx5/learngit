//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2018/5/7.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.criterialine {

import kof.game.character.ai.paramsTypeEnum.EFightStateType;
import kof.game.character.fight.targetfilter.ICriteria;
import kof.game.character.fight.targetfilter.criterias.fightstate.CFightStateNormalCriteria;
import kof.game.character.fight.targetfilter.criterias.fightstate.CStateGangBodyCriteria;
import kof.game.character.fight.targetfilter.criterias.fightstate.CStatePaBodyCriteria;
import kof.game.character.fight.targetfilter.criterias.fightstate.CStateWuDiCriteria;
import kof.game.character.fight.targetfilter.criterias.state.CStateNormalCriteria;
import kof.game.character.fight.targetfilter.filterenum.EFilterFightStateType;
import kof.game.character.fight.targetfilter.filterenum.EFilterStateType;

public class CFightStateCriteriaLine extends CBasicFilterLine {
    public function CFightStateCriteriaLine( name : String = "bl" ) {
        super("FightStateLine");
    }

    override public function setCriteriaMask( value : int ) : void
    {
        var criteria : ICriteria;

        if( ( EFilterFightStateType.TYPE_ALL & value ) != 0 )
                return;

        if( (EFilterFightStateType.TYPE_NORMAL& value)  != 0 )
        {
            criteria = new CFightStateNormalCriteria();
            _addCriteria( criteria );
        }

        if( (EFilterFightStateType.TYPE_PABODY & value)  != 0 )
        {
            criteria = new CStatePaBodyCriteria();
            _addCriteria( criteria );
        }

        if( (EFilterFightStateType.TYPE_GANGBODY& value)  != 0 )
        {
            criteria = new CStateGangBodyCriteria();
            _addCriteria( criteria );
        }

        if( (EFilterFightStateType.TYPE_WUDI & value)  != 0 )
        {
            criteria = new CStateWuDiCriteria();
            _addCriteria( criteria );
        }
    }
}
}
