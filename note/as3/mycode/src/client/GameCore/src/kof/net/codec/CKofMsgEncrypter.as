//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.net.codec {

import QFLib.Interface.IDisposable;

import flash.utils.ByteArray;

import kof.net.ICodecKeyProvider;

/**
 * 封包加解密算法
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CKofMsgEncrypter implements IDisposable {

    private var m_pKeyProvider : ICodecKeyProvider;

    public function CKofMsgEncrypter( pKeyProvider : ICodecKeyProvider ) {
        super();

        m_pKeyProvider = pKeyProvider;
    }

    public function dispose() : void {
        if ( m_pKeyProvider ) {
            m_pKeyProvider.dispose();
        }
        m_pKeyProvider = null;
    }

    final internal function get privateKey() : ICodecKeyProvider {
        return m_pKeyProvider;
    }

    public function XORChunk( buf : ByteArray, nLength : uint ) : ByteArray {
        const keyBytes : ByteArray = this.m_pKeyProvider.bytes;

        var keyLen : uint = keyBytes.length;
        var pos : int = buf.position;

        for ( var i : int = 0, j : int = 0; i < nLength; ++i, j = (j + 1) % keyLen ) {
            keyBytes.position = j;
            var keyB : int = keyBytes.readByte();
            buf.position = pos + i;
            var bufB : int = buf.readByte();
            buf.position = pos + i;
            buf.writeByte( (bufB & 0xFF) ^ (keyB & 0xFF) );
        }

        buf.position = pos;
        return buf;
    }

    public function validateChecksum( buf : ByteArray, bufLen : uint, iCheckSum : int ) : Boolean {
        return checksum( buf, bufLen ) == iCheckSum;
    }

    public function checksum( buf : ByteArray, bufLen : uint ) : int {
        var oldPos : int = buf.position;
        var iVal : int = 0x77;
        for ( var i : int = 0; i < bufLen; ++i ) {
            iVal += buf.readUnsignedByte();
        }
        iVal = iVal & 0xFFFF;
        buf.position = oldPos;
        return iVal;
    }

}
}
