//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.property {

import kof.util.CObjectUtils;

public class CFromTargetProperty extends CCharacterProperty {

    private var m_pData : Object;

    public function CFromTargetProperty( data : Object ) {
        super();
        this.m_pData = data;
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected virtual function onEnter() : void {
        super.onEnter();
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();

        this.extendData( m_pData );
    }

    override protected virtual function onExit() : void {
        super.onExit();
    }

}
}
