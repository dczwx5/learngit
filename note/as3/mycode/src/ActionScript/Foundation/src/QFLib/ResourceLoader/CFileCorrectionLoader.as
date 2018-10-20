//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/3/12
//----------------------------------------------------------------------------------------------------------------------

/*
*/

package QFLib.ResourceLoader
{
    import QFLib.Foundation;
    import QFLib.Foundation.CPath;
import QFLib.Foundation.CSHA1;
import QFLib.Foundation.CURLFile;

import flash.utils.ByteArray;

    public class CFileCorrectionLoader extends CBaseLoader
    {
        public static const NAME : String = ".FILE_CORRECTION";

        public function CFileCorrectionLoader( theBelongResourceLoadersRef : CResourceLoaders )
        {
            super( theBelongResourceLoadersRef );
        }

        public override function dispose() : void
        {
            super.dispose();
        }

        protected override function _onLoadFinished( file : CURLFile, idError : int ) : void
        {
            //Foundation.Log.logErrorMsg( "CBaseLoader._onLoadFinished: " + file.loadingURL );
            m_iLoadingIndex = file.loadingIndex;

            var bCallLoadFinished : Boolean = true;
            if( idError == 0 )
            {
                if( this.m_theBelongResourceLoadersRef.assetVersion != null )
                {
                    var sSubFilename : String = file.loadingURL.substr( this.m_theBelongResourceLoadersRef.assetVersion.assetPath.length );
                    var iFileSize : uint = this.m_theBelongResourceLoadersRef.assetVersion.findSize( sSubFilename );
                    if( iFileSize == file.numLoadedBytes )
                    {
                        if( file.streamBuffer != null )
                        {
                            var sChecksum : String = this.m_theBelongResourceLoadersRef.assetVersion.findChecksum( sSubFilename );

                            var sHashedChecksum : String = CSHA1.hashBytes( file.streamBuffer );
                            if( sChecksum != sHashedChecksum ) idError = 12039; // checksum failed
                        }
                    }
                    else
                    {
                        // file size not match
                        idError = 12038;
                    }
                }
            }

            if( bCallLoadFinished ) _loadFinished( file, idError );
        }
    }

}

