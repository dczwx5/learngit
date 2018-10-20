//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/6/1.
//----------------------------------------------------------------------
package kof.game.character.fight.sync.synctimeline.base.action {

import kof.game.character.CCharacterDataDescriptor;
import kof.game.core.CGameObject;
import kof.message.CAbstractPackMessage;
import kof.message.Fight.CatchResponse;

public class CFighterCatchAction extends CBaseFighterKeyAction {
    public function CFighterCatchAction(){
        super( EFighterActionType.E_CATCH_ACTION );
    }

    override protected function setResponseInfo( msg : CAbstractPackMessage ) : void{
        var catchResponse : CatchResponse = msg as CatchResponse;
        m_boEndCatch = catchResponse.bCatchEnd == 1;
        m_catchTargetList = catchResponse.targets;
    }

    public function findTargetInCatching( target : CGameObject ) : Boolean {
        return findCatchTarget( target ) && !m_boEndCatch ;
    }

    public function findCatchTarget( target : CGameObject ) : Boolean{
        if ( target == null ) return false;

        var targetID : Number;
        var targetType : int;
        targetID = CCharacterDataDescriptor.getID( target.data );
        targetType = CCharacterDataDescriptor.getType( target.data );

        for each( var targetInfo : Object in m_catchTargetList ) {
            if ( targetID == targetInfo[ "ID" ] && targetType == targetInfo[ "type" ] )
                return true;
        }

        return false;
    }

    private var m_catchTargetList : Array;
    private var m_boEndCatch : Boolean;
}
}
