/**
 * Created by Administrator on 2017/4/19.
 */
package QFLib.Qson {
import QFLib.Interface.IDisposable;
import flash.utils.ByteArray;
import flash.system.ApplicationDomain;
import avm2.intrinsics.memory.*;

public class CStream implements IDisposable
{
    public function CStream( stream : ByteArray )
    {
        _setStream( stream );
    }
    public function dispose() : void
    {
        m_iCurrentStreamIndex = 0;
        m_aStream = null;
    }


    private function _setStream( stream : ByteArray ) : void
    {
        if( stream.length < 1024 ) stream.length = 1024; // make sure the stream is readable by the ApplicationDomain.currentDomain.domainMemory ( >= 1024 )
        ApplicationDomain.currentDomain.domainMemory = stream;
        m_aStream = stream;

        if( stream == null ) m_iCurrentStreamIndex = 0;
        else m_iCurrentStreamIndex = stream.position;
    }

    public function setSelfStream() : void
    {
        ApplicationDomain.currentDomain.domainMemory = m_aStream;
    }
    [Inline]
    final public function readString() : String
    {
        var iCount : int =  li16( m_iCurrentStreamIndex );
        m_iCurrentStreamIndex += 2;
        if( iCount > 0 )
        {
            m_aStream.position = m_iCurrentStreamIndex;
            var s :String = m_aStream.readUTFBytes( iCount );
            m_iCurrentStreamIndex = m_aStream.position;
            return s;
        }
        else return "";
        //var iCount : int = m_aStream.readUnsignedShort();
        //if( iCount > 0 ) return m_aStream.readUTFBytes( iCount );
        //else return "";
    }
    [Inline]
    final public function readShortString() : String
    {
        var iCount : int =  li8( m_iCurrentStreamIndex );
        m_iCurrentStreamIndex += 1;
        if( iCount > 0 )
        {
            m_aStream.position = m_iCurrentStreamIndex;
            var s :String = m_aStream.readUTFBytes( iCount );
            m_iCurrentStreamIndex = m_aStream.position;
            return s;
        }
        else return "";
        //var iCount : int = m_aStream.readUnsignedShort();
        //if( iCount > 0 ) return m_aStream.readUTFBytes( iCount );
        //else return "";
    }
    [Inline]
    final public function readInt() : int
    {
        var iValue : int = li32( m_iCurrentStreamIndex );
        m_iCurrentStreamIndex += 4;
        return iValue;
        //var iValue : int = m_aStream.readInt();
        //return iValue;
    }
    [Inline]
    final public function readUnsignedShort() : uint
    {
        var iValue : uint = li16( m_iCurrentStreamIndex );
        m_iCurrentStreamIndex += 2;
        return iValue;
        //var iValue : uint = m_aStream.readUnsignedShort();
        //return iValue;
    }
    [Inline]
    final public function readByte() : int
    {
        var iValue : int = li8( m_iCurrentStreamIndex );
        m_iCurrentStreamIndex += 1;
        return iValue;
        //var iValue : int = m_aStream.readByte();
        //return iValue;
    }
    [Inline]
    final public function readBoolean() : Boolean
    {
        var bValue : Boolean = li8( m_iCurrentStreamIndex );
        m_iCurrentStreamIndex += 1;
        return bValue;
        //var bValue : Boolean = m_aStream.readBoolean();
        //return bValue;
    }
    [Inline]
    final public function readFloat() : Number
    {
        var fValue : Number = lf32( m_iCurrentStreamIndex );
        m_iCurrentStreamIndex += 4;
        return fValue;
        //var fValue : Number = m_aStream.readFloat();
        //return fValue;
    }

    protected var m_iCurrentStreamIndex : int;
    protected var m_aStream : ByteArray;
}
}
