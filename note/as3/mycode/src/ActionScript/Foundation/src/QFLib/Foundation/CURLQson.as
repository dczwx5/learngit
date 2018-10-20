//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/2/1
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Foundation
{
    import QFLib.Foundation;
    import QFLib.Qson.CQson;

    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.utils.ByteArray;


    //
    //
    //
    public class CURLQson extends CURLJson
    {
        public static var enableQsonLoading : Boolean = true;

        public function CURLQson( sURL : String, sURLVersion : String = null, bLoadFileWithVersionOnly : Boolean = false, pStreamLoaderClass : Class = null )
        {
            super( sURL, sURLVersion, bLoadFileWithVersionOnly, pStreamLoaderClass );
        }
        public override function dispose() : void
        {
            super.dispose();
            m_theJson = null;
        }

        public override function startLoad( fnOnFinished : Function, fnOnProgress : Function = null,
                                                bSuppressLoadErrorMsg : Boolean = false, bUseStreamBufferMode : Boolean = false, bAutoCloseAfterLoadFinished : Boolean = true,
                                                iBeginLoadingIdx : int = 0, sAdditionalVersionTag : String = "" ) : void
        {
            if( enableQsonLoading == false )
            {
                for( var j : int = 0; j < m_vURLs.length; j++ )
                {
                    if( CPath.ext( m_vURLs[ j ] ).toLowerCase() == ".qson" )
                    {
                        m_vURLs[ j ] = CPath.driverDirName( m_vURLs[ j ] ) + ".json";
                    }
                }
            }
            super.startLoad( fnOnFinished, fnOnProgress, bSuppressLoadErrorMsg, bUseStreamBufferMode, bAutoCloseAfterLoadFinished, iBeginLoadingIdx );
        }
        //
        //
        protected override function _onCompleted( e : Event ) : void
        {
            try
            {
                var aBytes : ByteArray = readAllBytes();
                if( aBytes != null )
                {
                    Foundation.Perf.sectionBegin( "CQson.parse" );
                    m_theJson = CQson.parse( aBytes );
                    Foundation.Perf.sectionEnd( "CQson.parse" );
                }

                super._onCompleted( e );
            }
            catch( error : Error )
            {
                super._onError( new IOErrorEvent( "QSON parse fail", false, false, "QSON file format error: " + this.loadingURL, -1 ) );
            }
        }
    }

}