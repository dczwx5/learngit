//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.net.codec {

import flash.utils.ByteArray;

import io.asnetty.channel.IChannelHandlerContext;
import io.asnetty.handler.codec.MessageToMessageDecoder;

import kof.net.ICodecKeyProvider;

/**
 * KOF封包解密
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CKofMsgEncryptDecoder extends MessageToMessageDecoder {

    private var m_pEncrypter : CKofMsgEncrypter;

    /** Creates a new CKofMsgEncryptDecoder */
    public function CKofMsgEncryptDecoder( pKeyProvider : ICodecKeyProvider ) {
        super( ByteArray );

        m_pEncrypter = new CKofMsgEncrypter( pKeyProvider );
    }

    override protected function decode( ctx : IChannelHandlerContext, obj : *, out : Vector.<Object> ) : void {
        var bufIn : ByteArray = obj as ByteArray;
        if ( !bufIn.bytesAvailable ) {
            ctx.fireErrorCaught( new ArgumentError( "Zero bytes available in CKofMsgEncryptDecoder." ) );
            return;
        }

//        trace( "Decrypt with: ", m_pEncrypter.privateKey.key );
        bufIn = m_pEncrypter.XORChunk( bufIn, bufIn.bytesAvailable );

        var iCheckSum : int = bufIn.readUnsignedShort();
        var iMsgID : int = bufIn.readUnsignedShort();
        bufIn.position -= 2;
        if ( !m_pEncrypter.validateChecksum( bufIn, bufIn.bytesAvailable, iCheckSum ) ) {
            ctx.fireErrorCaught( new ArgumentError( "Checksum (" + iCheckSum + ") failed in CKofMsgEncryptDecoder for PackMessage 0x" + iMsgID.toString( 16 ) + "[" + iMsgID + "]." ) );
            return;
        }

        out.push( bufIn );
    }

}
}
