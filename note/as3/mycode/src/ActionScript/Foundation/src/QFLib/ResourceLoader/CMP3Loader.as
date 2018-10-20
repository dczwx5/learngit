//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2017/4/13.
 */
package QFLib.ResourceLoader {

import QFLib.Foundation.CURLFile;
import QFLib.Foundation.CURLMP3;

public class CMP3Loader extends CBaseLoader {

    public static const NAME : String = ".MP3";

    public function CMP3Loader( theBelongResourceLoadersRef : CResourceLoaders ) {
        super( theBelongResourceLoadersRef );
    }

    override public function dispose() : void {
        super.dispose();

        /*if( m_theURLMP3 != null ){
            m_theURLMP3.dispose();
            m_theURLMP3 = null;
        }*/
    }

    override public virtual function createObject( bCleanUp : Boolean = true ) : Object
    {
        var theURLMP3 : CURLMP3 = m_theURLFile as CURLMP3;
        if( theURLMP3.soundMP3 != null )
        {
            return theURLMP3.soundMP3;
        }
        else return null;
    }

    override public virtual function start() : void
    {
        /*// try find it in cache
        var iFoundLoadingIndex : int = -1;
        if( iFoundLoadingIndex >= 0 )
        {
            _directFinished( iFoundLoadingIndex, true );
        }
        else
        {
            if( m_theURLMP3 == null ) m_theURLMP3 = new CURLMP3( m_vFilenames[ 0 ] );
            else
            {
                m_theURLMP3.urls.length = 1;
                m_theURLMP3.urls[ 0 ] = m_vFilenames[ 0 ];
            }

            for( var i : int = 1; i < m_vFilenames.length; i++ )
            {
                m_theURLMP3.urls.push(  m_vFilenames[ i ] );
            }

            if( m_theBelongResourceLoadersRef.assetVersion != null )
            {
                var vVersions : Vector.<String> = new Vector.<String>( m_vFilenames.length );
                for( var k : int = 0; k < m_vFilenames.length; k++ )
                {
                    vVersions[ k ] = m_theBelongResourceLoadersRef.assetVersion.mappingFileVersion( m_vFilenames[ k ] );
                }
                m_theURLMP3.urlVersions = vVersions;
            }
            else m_theURLMP3.urlVersions = null;

            m_theURLMP3.startLoad( _onLoadFinished, _loadOnProgress, m_bSuppressLoadErrorMsg, true, m_iBeginLoadingIdx );
        }*/

        m_bCheckCacheWhenStarted = false;
        super.start();
        if(this.arguments[0] is Function)
        {
            var theURLMP3 : CURLMP3 = m_theURLFile as CURLMP3;

            var startFunc:Function = this.arguments[0];
            startFunc( theURLMP3.soundMP3 );
        }
    }

    protected override function _createURLFile( sFilename : String ) : CURLFile
    {
        return new CURLMP3( sFilename, null, false, this.streamLoaderClass );
    }

    //private var m_theURLMP3:CURLMP3;
}

}
