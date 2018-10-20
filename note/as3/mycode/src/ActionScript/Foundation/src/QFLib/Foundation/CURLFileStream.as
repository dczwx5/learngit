package QFLib.Foundation {

import flash.errors.IOError;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.HTTPStatusEvent;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLRequest;
import flash.net.URLStream;
import flash.utils.ByteArray;
import flash.utils.IDataInput;

/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CURLFileStream extends EventDispatcher implements IURLFileStream {

    public function CURLFileStream( delegater : Class = null ) {
        if ( null == delegater ) {
            delegater = URLStream;
        }

        this.m_pDelegaterClass = delegater;
        this.m_pDelegater = new this.m_pDelegaterClass();

        this.m_pDataInput = this.m_pDelegater as IDataInput;
    }

    public function dispose() : void {
        this.close();

        free( this.m_pDelegater );

        this.m_pDelegaterClass = null;
        this.m_pDataInput = null;
    }

    [Inline] final public function get target() : Object {
        return m_pDelegater;
    }

    [Inline] final public function get connected() : Boolean {
        return m_bConnected;
    }

    [Inline] final public function close() : void {
        if ( m_pDelegater ) {
            m_pDelegater.removeEventListener( Event.OPEN, _eventProxyHandler );
            m_pDelegater.removeEventListener( Event.COMPLETE, _eventProxyHandler );
            m_pDelegater.removeEventListener( ProgressEvent.PROGRESS, _eventProxyHandler );
            m_pDelegater.removeEventListener( IOErrorEvent.IO_ERROR, _eventProxyHandler );
            m_pDelegater.removeEventListener( HTTPStatusEvent.HTTP_STATUS, _eventProxyHandler );
            m_pDelegater.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, _eventProxyHandler );
        }

        if ( m_bConnected ) {
            m_bConnected = false;
            if ( m_pDelegater ) {
                try {
                    m_pDelegater[ 'close' ]();
                } catch ( e : IOError ) {}
            }
        }
    }

    [Inline] final public function load( request : URLRequest ) : void {
        if ( !m_pDelegater )
            return;

        m_pDelegater['load'](request);

        m_pDelegater.addEventListener( Event.OPEN, _eventProxyHandler, false, 0, true );
        m_pDelegater.addEventListener( Event.COMPLETE, _eventProxyHandler, false, 0, true );
        m_pDelegater.addEventListener( ProgressEvent.PROGRESS, _eventProxyHandler, false, 0, true );
        m_pDelegater.addEventListener( IOErrorEvent.IO_ERROR, _eventProxyHandler, false, 0, true );
        m_pDelegater.addEventListener( HTTPStatusEvent.HTTP_STATUS, _eventProxyHandler, false, 0, true );
        m_pDelegater.addEventListener( SecurityErrorEvent.SECURITY_ERROR, _eventProxyHandler, false, 0, true );
    }

    private function _eventProxyHandler( event : Event ) : void {
        if ( event.type == Event.OPEN ) {
            this.m_bConnected = true;
        }

        IEventDispatcher(this).dispatchEvent( event );
    }

    [Inline] final public function readBytes( bytes : ByteArray, offset : uint = 0, length : uint = 0 ) : void {
        if ( m_pDataInput )
            m_pDataInput.readBytes( bytes, offset, length );
    }

    [Inline] final public function readBoolean() : Boolean {
        return m_pDataInput ? m_pDataInput.readBoolean() : false;
    }

    [Inline] final public function readByte() : int {
        return m_pDataInput ? m_pDataInput.readByte() : 0;
    }

    [Inline] final public function readUnsignedByte() : uint {
        return m_pDataInput ? m_pDataInput.readUnsignedByte() : 0;
    }

    [Inline] final public function readShort() : int {
        return m_pDataInput ? m_pDataInput.readShort() : 0;
    }

    [Inline] final public function readUnsignedShort() : uint {
        return m_pDataInput ? m_pDataInput.readUnsignedShort() : 0;
    }

    [Inline] final public function readInt() : int {
        return m_pDataInput ? m_pDataInput.readInt() : 0;
    }

    [Inline] final public function readUnsignedInt() : uint {
        return m_pDataInput ? m_pDataInput.readUnsignedInt() : 0;
    }

    [Inline] final public function readFloat() : Number {
        return m_pDataInput ? m_pDataInput.readFloat() : 0.0;
    }

    [Inline] final public function readDouble() : Number {
        return m_pDataInput ? m_pDataInput.readDouble() : 0.0;
    }

    [Inline] final public function readMultiByte( length : uint, charSet : String ) : String {
        return m_pDataInput ? m_pDataInput.readMultiByte( length, charSet ) : null;
    }

    [Inline] final public function readUTF() : String {
        return m_pDataInput ? m_pDataInput.readUTF() : null;
    }

    [Inline] final public function readUTFBytes( length : uint ) : String {
        return m_pDataInput ? m_pDataInput.readUTFBytes( length ) : null;
    }

    [Inline] final public function get bytesAvailable() : uint {
        return m_pDataInput ? m_pDataInput.bytesAvailable : 0;
    }

    [Inline] final public function readObject() : * {
        return m_pDataInput ? m_pDataInput.readObject() : null;
    }

    [Inline] final public function get objectEncoding() : uint {
        return m_pDataInput ? m_pDataInput.objectEncoding : 0;
    }

    [Inline] final public function set objectEncoding( version : uint ) : void {
        if ( m_pDataInput )
            m_pDataInput.objectEncoding = version;
    }

    [Inline] final public function get endian() : String {
        return m_pDataInput ? m_pDataInput.endian : null;
    }

    [Inline] final public function set endian( type : String ) : void {
        if ( m_pDataInput )
            m_pDataInput.endian = type;
    }

    [Inline] final public function get position() : uint {
        if ( m_pDelegater && 'position' in m_pDelegater ) {
            return uint( m_pDelegater[ 'position' ] );
        }
        return 0;
    }

    [Inline] final public function set position( value : uint ) : void {
        if ( m_pDelegater && 'position' in m_pDelegater )
            m_pDelegater[ 'position' ] = value;
    }

    private var m_pDelegaterClass : Class;
    private var m_pDelegater : IEventDispatcher;
    private var m_pDataInput : IDataInput;
    private var m_bConnected : Boolean;

}
}
// vi:ft=as3 tw=120 ts=4 sw=4 expandtab
