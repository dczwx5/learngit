//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/5/29.
//----------------------------------------------------------------------
package kof.game.character.fight.sync.synctimeline.base.action {

import flash.utils.Dictionary;

public class CFighterStatusAction extends CBaseFighterKeyAction{
    public function CFighterStatusAction() {
        super( EFighterActionType.E_STATUS_ACTION );
      m_stateMap = new Dictionary( true );
    }
    override public function clear() : void{
        m_stateMap  =  null;
    }
    override public function replay() : void{


    }

    public function setState( status : Dictionary ) : void{
        for( var key : * in status )
        {
            m_stateMap[key] = status[key];
        }
    }

    public function get states() : Dictionary{
        return m_stateMap;
    }

    private var m_stateMap : Dictionary;
}
}
