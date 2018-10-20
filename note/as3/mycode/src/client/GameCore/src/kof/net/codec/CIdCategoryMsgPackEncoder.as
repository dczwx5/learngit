//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.net.codec {

import flash.utils.ByteArray;
import flash.utils.ByteArray;
import flash.utils.Endian;

import io.asnetty.channel.IChannelHandlerContext;
import io.asnetty.handler.codec.MessageToMessageEncoder;

import kof.message.CAbstractPackMessage;
import kof.message.kof_message;
import kof.util.CAssertUtils;

import org.msgpack.MsgPack;

use namespace kof_message;

/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CIdCategoryMsgPackEncoder extends MessageToMessageEncoder {

    /** @private */
    private var m_theEncodeMsgPack : MsgPack;

    /** @private */
    private var m_theOutBuffer : ByteArray;

    /**
     * Creates a new CIdCategoryMsgPackEncoder
     */
    public function CIdCategoryMsgPackEncoder( bBufferCreation : Boolean = false ) {
        super( CAbstractPackMessage );
        m_theEncodeMsgPack = CMsgPackFactory.instance.create();

        if ( !bBufferCreation )
            m_theOutBuffer = new ByteArray();
    }

    /**
     * @inheritDoc
     */
    override protected function encode( ctx : IChannelHandlerContext, obj : *, out : Vector.<Object> ) : void {
        var msg : CAbstractPackMessage = obj as CAbstractPackMessage;
        var buf : ByteArray;
        if ( m_theOutBuffer )
            buf = m_theOutBuffer;
        else
            buf = new ByteArray();
        buf.length = 0;
        buf.writeShort( msg.kof_message::token );

        var encoded : Array = msg.encode( null );
        CAssertUtils.assertNotNull( encoded );

        m_theEncodeMsgPack.write( encoded, buf );
        buf.position = 0;

        out.push( buf ); // push in outList.
    }

}
}
