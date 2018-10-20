//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package preview.game.levelServer.protocol {

import kof.message.CAbstractPackMessage;

/**
 * perview使用
 */
[PACK_MSG(id="3333", desc="")]
public final class CEnterLevelResponse extends CAbstractPackMessage {

    [Inline] final public function get fileName() : String {
        return String(this.m_pData[ 0 ]);
    }

    [Inline] final public function set fileName( value : String ) : void {
        this.m_pData[ 0 ] = value;
    }

    public function CEnterLevelResponse() {
        super(3333, RESPONSE);

        this.m_pData = [];
    }


    override public function decode(data:Array):void {
        this.m_pData = data;
    }

    override public function encode(data:Array):Array {
        return this.m_pData;
    }

    private var m_pData : Array;

}
}
