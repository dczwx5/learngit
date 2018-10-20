//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2018/5/7.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.criterias.fightstate {

import kof.game.character.fight.targetfilter.CAbstractCriteria;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;

public class CStatePaBodyCriteria extends CAbstractCriteria {
    public function CStatePaBodyCriteria() {
        super();
    }

    override public function meetCriteria( target : CGameObject ) : Boolean
    {
        var pStateBoard : CCharacterStateBoard = target.getComponentByClass( CCharacterStateBoard , true ) as CCharacterStateBoard
        if( pStateBoard){
            return pStateBoard.getValue( CCharacterStateBoard.PA_BODY );
        }
        return false
    }
}
}
