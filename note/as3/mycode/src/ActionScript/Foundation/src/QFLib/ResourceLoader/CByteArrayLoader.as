//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
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

    import flash.utils.ByteArray;

    public class CByteArrayLoader extends CBaseLoader
    {
        public static const NAME : String = ".BYTES";

        public function CByteArrayLoader( theBelongResourceLoadersRef : CResourceLoaders )
        {
            super( theBelongResourceLoadersRef );
        }

        public override function dispose() : void
        {
            super.dispose();
        }

        public override function createObject( bCleanUp : Boolean = true ) : Object
        {
            var theByteArray : Object = null;
            if( this.m_theBelongResourceLoadersRef.resourceCache.isExisted( this.loadingFilename, CByteArrayLoader.NAME ) )
            {
                theByteArray = this.m_theBelongResourceLoadersRef.resourceCache.find( this.loadingFilename, CByteArrayLoader.NAME ).theObject;
            }
            else
            {
                theByteArray = m_theURLFile.readAllBytes();
                if( theByteArray == null )
                {
                    Foundation.Log.logWarningMsg( "Loading a '0' byte from file: '" + this.loadingFilename + "'" );
                    theByteArray = new ByteArray();
                }
            }

            return theByteArray;
        }
    }

}

