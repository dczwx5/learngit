//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package QFLib.ResourceLoader {

import QFLib.Foundation.CURLFile;
import QFLib.Foundation.CURLSwf;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public class CSwfLoader extends CBaseLoader {

    public static const NAME : String = ".SWF";

    public function CSwfLoader( theBelongResourceLoaderRef : CResourceLoaders ) {
        super( theBelongResourceLoaderRef );
    }

    override public function dispose() : void {
        super.dispose();

        /*if ( m_theSwfURL ) {
            m_theSwfURL.dispose();
            m_theSwfURL = null;
        }*/
    }

    override public virtual function createObject( bCleanUp : Boolean = true ) : Object
    {
        var theSwfURL : CURLSwf = m_theURLFile as CURLSwf;
        if ( theSwfURL && theSwfURL.loader ) {
            return theSwfURL.loader.content;
        }
        return null;
    }

    override public virtual function start() : void {
        /*// try find it in cache
        var iFoundLoadingIndex : int = -1;
        if( iFoundLoadingIndex >= 0 )
        {
            _directFinished( iFoundLoadingIndex, true );
        }
        else
        {
            if( m_theSwfURL == null ) m_theSwfURL = new CURLSwf( m_vFilenames[ 0 ] );
            else
            {
                m_theSwfURL.urls.length = 1;
                m_theSwfURL.urls[ 0 ] = m_vFilenames[ 0 ];
            }

            m_theSwfURL.allowCodeImport = true;

            for( var i : int = 1; i < m_vFilenames.length; i++ )
            {
                m_theSwfURL.urls.push(  m_vFilenames[ i ] );
            }

            if( m_theBelongResourceLoadersRef.assetVersion != null )
            {
                var vVersions : Vector.<String> = new Vector.<String>( m_vFilenames.length );
                for( var k : int = 0; k < m_vFilenames.length; k++ )
                {
                    vVersions[ k ] = m_theBelongResourceLoadersRef.assetVersion.mappingFileVersion( m_vFilenames[ k ] );
                }
                m_theSwfURL.urlVersions = vVersions;
            }
            else m_theSwfURL.urlVersions = null;

            m_theSwfURL.startLoad( _onLoadFinished, _loadOnProgress, m_bSuppressLoadErrorMsg, true, m_iBeginLoadingIdx );
        }*/

        m_bCheckCacheWhenStarted = false;
        super.start();
    }

    protected override function _createURLFile( sFilename : String ) : CURLFile
    {
        var theSwfURL : CURLSwf = new CURLSwf( sFilename, null, false, this.streamLoaderClass );
        theSwfURL.allowCodeImport = true;
        return theSwfURL;
    }

    //private var m_theSwfURL : CURLSwf;

}
}
