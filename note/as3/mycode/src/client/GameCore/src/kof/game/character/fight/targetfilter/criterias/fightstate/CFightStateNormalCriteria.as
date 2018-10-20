//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2018/5/8.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.criterias.fightstate {

import kof.game.character.fight.targetfilter.CAbstractCriteria;
import kof.game.character.property.CMonsterProperty;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;

public class CFightStateNormalCriteria extends CAbstractCriteria {
    public function CFightStateNormalCriteria() {
        super();
    }

    override public function meetCriteria( target : CGameObject ) : Boolean
    {
        var pStateBoard : CCharacterStateBoard = target.getComponentByClass( CCharacterStateBoard , true ) as CCharacterStateBoard;
        var boBlockObj : Boolean;
        var mProperty:CMonsterProperty = target.getComponentByClass( CMonsterProperty , false ) as CMonsterProperty;
        if ( mProperty != null && mProperty.style == 1 )
            boBlockObj = true;

        if( pStateBoard){
            return !pStateBoard.getValue( CCharacterStateBoard.PA_BODY ) &&
                   ( pStateBoard.getValue( CCharacterStateBoard.CAN_BE_CATCH ) || boBlockObj )&&
                   pStateBoard.getValue( CCharacterStateBoard.CAN_BE_ATTACK );
        }
        return false
    }
}
}
