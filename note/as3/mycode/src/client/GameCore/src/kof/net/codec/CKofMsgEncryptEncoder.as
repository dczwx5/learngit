//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.net.codec {

import QFLib.Foundation;

import flash.utils.ByteArray;

import io.asnetty.channel.IChannelHandlerContext;
import io.asnetty.handler.codec.MessageToByteEncoder;

import kof.net.ICodecKeyProvider;

/**
 * 封包加密
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CKofMsgEncryptEncoder extends MessageToByteEncoder {

    private var m_pEncrypter : CKofMsgEncrypter;
    private var m_iWriteSeq : int;

    /** Creates a new CKofMsgEncryptEncoder */
    public function CKofMsgEncryptEncoder( pKeyProvider : ICodecKeyProvider ) {
        super( ByteArray );

        m_pEncrypter = new CKofMsgEncrypter( pKeyProvider );

        m_iWriteSeq = 0;
    }

    override protected function encode( ctx : IChannelHandlerContext, msg : *, buf : ByteArray ) : void {
        var bufIn : ByteArray = msg as ByteArray;

        if ( m_iWriteSeq >= int.MAX_VALUE )
            m_iWriteSeq = 0;
        m_iWriteSeq++;

        var iInitPos : int = buf.position;
        var iMark : int = buf.position;

        var iMSGID : int = bufIn.readShort();
        bufIn.position = 0;

        buf.position = iInitPos;
        buf.writeShort( 0 );
        buf.writeInt( m_iWriteSeq );
        buf.writeBytes( bufIn );

        // calc checksum
        buf.position = iMark + 2;
        var iCheckSum : int = m_pEncrypter.checksum( buf, buf.bytesAvailable );
        buf.position = iMark;
        buf.writeShort( iCheckSum );

        buf.position = iMark;
        buf = m_pEncrypter.XORChunk( buf, buf.bytesAvailable );

        buf.position = iInitPos;

//        CONFIG::debug {
//            Foundation.Log.logMsg( "MSGWrite: SeqID " + m_iWriteSeq + ", CheckSum: " + iCheckSum + ", MSGID: " + iMSGID );
//        }
    }

}
}
