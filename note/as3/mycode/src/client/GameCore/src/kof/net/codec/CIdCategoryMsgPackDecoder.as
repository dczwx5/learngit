//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.net.codec {

import flash.errors.IllegalOperationError;
import flash.utils.ByteArray;

import io.asnetty.channel.IChannelHandlerContext;
import io.asnetty.handler.codec.MessageToMessageDecoder;

import kof.message.CAbstractPackMessage;
import kof.message.kof_message;
import kof.util.CAssertUtils;

import org.msgpack.MsgPack;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public class CIdCategoryMsgPackDecoder extends MessageToMessageDecoder {

    /** @private */
    private var m_fnMsgProvider : Function;
    /** @private */
    private var m_theDecodeMsgPack : MsgPack;

    /**
     * Creates a new CIdCategoryMsgPackDecoder.
     */
    public function CIdCategoryMsgPackDecoder( msgProvider : Function ) {
        super( ByteArray );
        this.m_fnMsgProvider = msgProvider;
        if ( null == this.m_fnMsgProvider )
            throw new ArgumentError( "Must provides a PackMessage provider." );

        m_theDecodeMsgPack = CMsgPackFactory.instance.create();
    }

    /**
     * @inheritDoc
     */
    override protected function decode( ctx : IChannelHandlerContext, obj : *, out : Vector.<Object> ) : void {
        var bufIn : ByteArray = obj as ByteArray;
        if ( !bufIn.bytesAvailable ) {
            ctx.fireErrorCaught( new ArgumentError( "Zero bytes available in CIdCategoryMsgPackDecoder." ) );
        }

//        var flag:uint = bufIn.readUnsignedShort();
//        var id:uint = flag & 0x0FFF;
//        var category:uint = flag >>> 12;

        var id : uint = bufIn.readUnsignedShort();

        var msg : CAbstractPackMessage = null;
        var msgError : String = null;

        try {
            msg = m_fnMsgProvider( id, 0 );
        } catch (e : Error) {
            msgError = "Cannot find the PackMessage 0x" + id.toString( 16 ) + "[" + id + "]\n\t%%%" + e.message + "%%%";
        }

        if ( !msg ) {
            ctx.fireErrorCaught( new IllegalOperationError( msgError ) );
            return;
        }

        msg.kof_message::token = id;
        const decoded : Object = m_theDecodeMsgPack.read( bufIn );

        CAssertUtils.assertTrue( decoded is Array );

        try {
            msg.decode( decoded as Array );
        } catch ( e : Error ) {
            ctx.fireErrorCaught( e );
        }

        out.push( msg );
    }

}
}
