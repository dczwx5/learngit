//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package QFLib.ResourceLoader.Worker {

import QFLib.Foundation;
import QFLib.Foundation.CSHA1;
import QFLib.Worker.CWorker;

    import flash.display.Sprite;
import flash.utils.ByteArray;

public class CResourceWorker extends Sprite
    {
        public function CResourceWorker()
        {
            super();

            m_theWorker.registerMessageHandler( CFileCheckRequestEvent, _onFileCheckRequestEvent );
        }

        //
        protected function _onFileCheckRequestEvent( event : CFileCheckRequestEvent ) : void
        {
            var iResult : int = 0;
            var sChecksum : String = event.checksum;
            if( sChecksum != null && sChecksum.length != 0 ) // do checksum
            {
                var aBytes : ByteArray = event.getByteArray( 0 );
                if( aBytes == null ) iResult = 12040; // byte array null
                else
                {
                    aBytes.position = 0;
                    var sHashedChecksum : String = CSHA1.hashBytes( aBytes );
                    if( sChecksum != sHashedChecksum ) iResult = 12039; // checksum failed
                }
            }

            var theEvent : CFileCheckResponseEvent = new CFileCheckResponseEvent();
            theEvent.set( event.loaderID, event.filename, iResult );
            m_theWorker.send( theEvent );
        }


        //
        //
        private var m_theWorker : CWorker = new CWorker( "FoundationResourceWorker" );
    }
}
