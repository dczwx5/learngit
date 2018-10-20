//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/5/30.
//----------------------------------------------------------------------
package kof.game.character.fight.sync.synctimeline.base.action {

import kof.message.CAbstractPackMessage;
import kof.message.kof_message;

use namespace kof_message;

public class CBaseFighterKeyAction implements IFighterKeyAction {
    public function CBaseFighterKeyAction( type : int = -1 ) {
        m_nType = type;
    }

    public function replay() : void {

    }

    public function clear() : void {

    }

    public function get actionData() : CAbstractPackMessage {
        return m_pActionData;
    }

    public function set actionData( msg : CAbstractPackMessage ) : void {
        m_pActionData = msg;
        setAction( msg );
    }

    virtual protected function setAction( msg : CAbstractPackMessage ) : void {
        actionCategory = msg.kof_message::category;
        if ( actionCategory == CAbstractPackMessage.REQUEST ) {
            setRequestInfo( msg );
        }
        if ( actionCategory == CAbstractPackMessage.RESPONSE ) {
            setResponseInfo( msg );
        }
    }

    virtual protected function setRequestInfo( msg : CAbstractPackMessage ) : void {

    }

    virtual protected function setResponseInfo( msg : CAbstractPackMessage ) : void {

    }

    public function get type() : int {
        return m_nType;
    }

    public function get actionCategory() : int {
        return m_iCategory;
    }

    public function set actionCategory( cat : int ) : void {
        m_iCategory = cat;
    }

    private var m_iCategory : int;
    private var m_pActionData : CAbstractPackMessage;
    private var m_nType : int;
}
}
