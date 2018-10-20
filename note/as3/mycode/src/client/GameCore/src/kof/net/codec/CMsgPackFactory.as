//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.net.codec {

import QFLib.Interface.IFactory;

import flash.utils.ByteArray;

import org.msgpack.MsgPack;
import org.msgpack.MsgPackFlags;

internal class CMsgPackFactory implements IFactory {

    static private var s_pInstance : CMsgPackFactory;

    public static function get instance() : CMsgPackFactory {
        if ( !s_pInstance )
            s_pInstance = new CMsgPackFactory();
        return s_pInstance;
    }

    /**
     * Creates an new CMsgPackFactory.
     */
    public function CMsgPackFactory() {
        super();
    }

    public function create() : * {
        var newMsgPack : MsgPack = new MsgPack();
        newMsgPack.factory.assign( CFixedRawWorker, ByteArray, String );
        newMsgPack.factory.assign( CFixedIntegerWorker, uint, int );
        return newMsgPack;
    }

    public function destroy( obj : Object ) : void {
        // ignore, GC auto.
    }

}

}