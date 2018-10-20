//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/9.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.criterialine {

import kof.game.character.fight.targetfilter.ICriteria;
import kof.game.character.fight.targetfilter.criterias.state.CStateBeCatchCriteria;
import kof.game.character.fight.targetfilter.criterias.state.CStateInHurtCriteria;
import kof.game.character.fight.targetfilter.criterias.state.CStateLyingCriteria;
import kof.game.character.fight.targetfilter.criterias.state.CStateNormalCriteria;
import kof.game.character.fight.targetfilter.criterias.state.CStateNotInCatchCriteria;
import kof.game.character.fight.targetfilter.criterias.state.CStateNotLyingCriteria;
import kof.game.character.fight.targetfilter.criterias.state.CStateOnGroundCriteria;
import kof.game.character.fight.targetfilter.filterenum.EFilterStateType;

public class CStateCriteriaLine extends CBasicFilterLine {
    public function CStateCriteriaLine() {
        super( "StateLine" );
    }

    override public function setCriteriaMask( value : int ) : void
    {
        var criteria : ICriteria;

        if( (EFilterStateType.STATE_ALL & value ) != 0 )
                return;

        if( ( EFilterStateType.STATE_LYING & value)  != 0 )
        {
            criteria = new CStateLyingCriteria();
            _addCriteria( criteria );
        }

        if( ( EFilterStateType.STATE_NO_LYING & value ) != 0 )
        {
            criteria = new CStateNotLyingCriteria();
            _addCriteria( criteria );
        }

        if( ( EFilterStateType.STATE_BE_CATCHED & value ) != 0 )
        {
            criteria = new CStateBeCatchCriteria();
            _addCriteria( criteria );
        }

        if( ( EFilterStateType.STATE_NO_BE_CATCHED & value ) != 0 )
        {
            criteria = new CStateNotInCatchCriteria();
            _addCriteria( criteria );
        }

        if( ( EFilterStateType.STATE_BE_IN_HURT & value ) != 0 )
        {
            criteria = new CStateInHurtCriteria();
            _addCriteria( criteria );
        }

        if( ( EFilterStateType.STATE_BE_NORMAL & value ) != 0 )
        {
             criteria = new CStateNormalCriteria();
            _addCriteria( criteria );
        }
    }
}
}
