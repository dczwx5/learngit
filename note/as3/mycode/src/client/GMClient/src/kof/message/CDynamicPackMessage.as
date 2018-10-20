//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.message {

import flash.errors.IllegalOperationError;

/**
 * 用于动态封装
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CDynamicPackMessage extends CAbstractPackMessage {

    private var m_pData : Array;

    public function CDynamicPackMessage() {
        super();

        m_pData = [];
    }

    public function getToken() : uint {
        return kof_message::token;
    }

    public function setToken( value : uint ) : void {
        kof_message::token = value;
    }

    public function getData() : Array {
        return m_pData;
    }

    public function setData( value : Array ) : void {
        m_pData = value;
    }

    override public function decode( data : Array ) : void {
        throw new IllegalOperationError( "Not supported by CDynamicPackMessage." );
    }

    override public function encode( data : Array ) : Array {
        return m_pData;
    }

}
}
