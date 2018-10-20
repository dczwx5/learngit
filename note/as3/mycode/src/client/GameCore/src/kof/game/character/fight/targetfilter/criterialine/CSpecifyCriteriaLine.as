//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/9.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.criterialine {

import kof.game.character.fight.targetfilter.ICriteria;
import kof.game.character.fight.targetfilter.criterias.specify.CSpecifyCurrentTargetCriteria;
import kof.game.character.fight.targetfilter.criterias.specify.CSpecifyExceptCurTargetCriteria;
import kof.game.character.fight.targetfilter.criterias.specify.CSpecifyExceptSelfCriteria;
import kof.game.character.fight.targetfilter.criterias.specify.CSpecifyRandomCriteria;
import kof.game.character.fight.targetfilter.criterias.specify.CSpecifySelfCriteria;
import kof.game.character.fight.targetfilter.criterias.specify.CSpecifySpellerCriteria;
import kof.game.character.fight.targetfilter.filterenum.EFilterSpecifyTargetType;
import kof.game.character.fight.targetfilter.filterenum.EFilterStateType;

public class CSpecifyCriteriaLine extends CBasicFilterLine {
    public function CSpecifyCriteriaLine() {
        super("SpecifyLine");
    }
    override public function setCriteriaMask( value : int ) : void
    {
        var criteria : ICriteria;

        if( (EFilterStateType.STATE_ALL & value ) != 0 )
            return;

        if( ( EFilterSpecifyTargetType.SPECIFY_EXCEPT_SELF & value)  != 0 )
        {
            criteria = new CSpecifyExceptSelfCriteria();
            _addCriteria( criteria );
        }

        if( ( EFilterSpecifyTargetType.SPECIFY_RANDOM  & value ) != 0 )
        {
            criteria = new CSpecifyRandomCriteria();
            _addCriteria( criteria );
        }

        if( ( EFilterSpecifyTargetType.SPECIFY_SELF & value ) != 0 )
        {
            criteria = new CSpecifySelfCriteria();
            _addCriteria( criteria );
        }

        if( ( EFilterSpecifyTargetType.SPECIFY_ONLY_CURRENT_TARGET & value ) != 0 )
        {
            criteria = new CSpecifyCurrentTargetCriteria();
            _addCriteria( criteria );
        }

        if( ( EFilterSpecifyTargetType.SPECIFY_EXCEPT_CURRENT_TARGET & value) != 0 )
        {
            criteria = new CSpecifyExceptCurTargetCriteria();
            _addCriteria( criteria );
        }

        if( ( EFilterSpecifyTargetType.SPECIFY_SPELLER & value ) != 0)
        {
            criteria = new CSpecifySpellerCriteria();
            _addCriteria( criteria );
        }


    }
}
}
