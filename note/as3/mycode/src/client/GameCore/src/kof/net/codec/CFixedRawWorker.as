//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.net.codec {

import flash.utils.ByteArray;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;

import org.msgpack.Factory;
import org.msgpack.MsgPackFlags;
import org.msgpack.Worker;
import org.msgpack.incomplete;

use namespace incomplete;

public class CFixedRawWorker extends Worker {

    private var count : int;

    public static function checkType( byte : int ) : Boolean {
        return (byte & 0xe0) == 0xa0 || byte == 0xd9 || byte == 0xda || byte == 0xdb;
    }

    public function CFixedRawWorker( factory : Factory, byte : int = -1 ) {
        super( factory, byte );
        count = -1;
    }

    override public function assembly( data : *, destination : IDataOutput ) : void {
        var bytes : ByteArray;

        if ( data is ByteArray ) {
            bytes = data;
        }
        else {
            bytes = new ByteArray();
            bytes.writeUTFBytes( data.toString() );
        }

        if ( bytes.length < 32 ) {
            // fix raw
            destination.writeByte( 0xa0 | bytes.length );
        }
        else if (bytes.length < 256) {
            // raw 8
            destination.writeByte( 0xd9 );
            destination.writeByte( bytes.length );
        }
        else if ( bytes.length < 65536 ) {
            // raw 16
            destination.writeByte( 0xda );
            destination.writeShort( bytes.length );
        }
        else {
            // raw 32
            destination.writeByte( 0xdb );
            destination.writeInt( bytes.length );
        }

        destination.writeBytes( bytes );
    }

    override public function disassembly( source : IDataInput ) : * {
        if ( count == -1 ) {
            if ( (byte & 0xe0) == 0xa0 )
                count = byte & 0x1f;
            else if ( byte == 0xd9 && source.bytesAvailable >= 1)
                count = source.readUnsignedByte();
            else if ( byte == 0xda && source.bytesAvailable >= 2 )
                count = source.readUnsignedShort();
            else if ( byte == 0xdb && source.bytesAvailable >= 4 )
                count = source.readUnsignedInt();
        }

        if ( source.bytesAvailable >= count ) {
            var data : ByteArray = new ByteArray();

            // we need to check whether the byte array is empty to avoid EOFError
            // thanks to ccrossley
            if ( count > 0 )
                source.readBytes( data, 0, count );

            // using flags this worker may return RAW as String (not only as ByteArray like previous version)
            // thanks to sparkle
            return factory.checkFlag( MsgPackFlags.READ_RAW_AS_BYTE_ARRAY ) ? data : data.toString();
        }

        return incomplete;
    }

}
}
