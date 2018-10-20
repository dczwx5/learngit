//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/5/29.
//----------------------------------------------------------------------
package kof.game.character.fight.sync.synctimeline.base.action {

import QFLib.Math.CVector3;

public class CFighterPositionAction extends CBaseFighterKeyAction{
    public function CFighterPositionAction() {
        super( EFighterActionType.E_POSITION_ACTION );
    }

    override public function clear() : void
    {
        m_thePosition = null;
    }

    public function setPosition( pos : CVector3 ) : void{
        m_thePosition = pos.clone();
    }

    override public function replay() : void{

    }

    public function get position() : CVector3{
        return m_thePosition;
    }

    private var m_thePosition : CVector3;
}
}
