//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/9.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.criterialine {

import kof.game.character.fight.targetfilter.ICriteria;
import kof.game.character.fight.targetfilter.criterias.camp.CCampEnemyCriteria;
import kof.game.character.fight.targetfilter.criterias.camp.CCampFriendCriteria;
import kof.game.character.fight.targetfilter.criterias.camp.CCampNeuCriteria;
import kof.game.character.fight.targetfilter.criterias.camp.CCampSelfCriteria;
import kof.game.character.fight.targetfilter.filterenum.EFilterCampType;

public class CCampCriteriaLine extends CBasicFilterLine {
    public function CCampCriteriaLine() {
        super("CampLine");
    }

    override public function setCriteriaMask( value : int ) : void
    {
        var criteria : ICriteria ;
        if( (EFilterCampType.CAMP_ALL & value) != 0 )
            return ;

        if( (EFilterCampType.CAMP_ENEMIES & value) != 0 ) {
            criteria = new CCampEnemyCriteria();
            _addCriteria( criteria );
        }

        if( (EFilterCampType.CAMP_SELF & value) != 0 ) {
            criteria = new CCampSelfCriteria();
            _addCriteria( criteria );
        }

        if( (EFilterCampType.CAMP_FRIEND & value) != 0 ) {
            criteria = new CCampFriendCriteria();
            _addCriteria( criteria );
        }

        if( (EFilterCampType.CAMP_NEUTRALITY & value) != 0 ) {
            criteria = new CCampNeuCriteria();
            _addCriteria( criteria );
        }
    }
}
}
