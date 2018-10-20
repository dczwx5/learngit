//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/2/1
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Foundation
{
    import flash.events.Event;
    import flash.events.IOErrorEvent;
import flash.system.System;


//
    //
    //
    public class CURLXml extends CURLFile
    {
        public function CURLXml( sURL : String, sURLVersion : String = null, bLoadFileWithVersionOnly : Boolean = false, pStreamLoaderClass : Class = null )
        {
            super( sURL, sURLVersion, bLoadFileWithVersionOnly, pStreamLoaderClass );
        }
        public override function dispose() : void
        {
            super.dispose();

            if (m_theXml) {
                System.disposeXML( XML(m_theXml) );
            }

            m_theXml = null;
        }

        public override function close( bFullCleanUp : Boolean = false ) : void
        {
            super.close( bFullCleanUp );
            m_theXml = null;
        }

        public function get xmlObject() : Object
        {
            return m_theXml;
        }

        //
        //
        protected override function _onCompleted( e : Event ) : void
        {
            try
            {
                var s : String = readAllText();
                if( s ) m_theXml = XML( s );
                super._onCompleted( e );
            }
            catch( error : Error )
            {
                super._onError( new IOErrorEvent( "XML parse fail", false, false, "XML file format error: " + loadingURL, -1 ) );
            }
        }

        //
        //
        private var m_theXml : Object = null;
    }

}