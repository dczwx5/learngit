//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/12/22
//----------------------------------------------------------------------------------------------------------------------

/*
*/

package QFLib.ResourceLoader
{

import QFLib.Foundation;
import QFLib.Foundation.CPath;
    import QFLib.Qson.CQsonStream;

    import flash.utils.ByteArray;

    public class CQsonStreamLoader extends CJsonLoader
    {
        public static const NAME : String = ".QSONSTREAM";

        public function CQsonStreamLoader( theBelongResourceLoadersRef : CResourceLoaders )
        {
            super( theBelongResourceLoadersRef );
        }

        public override function dispose() : void
        {
            super.dispose();
        }

        public override function createObject( bCleanUp : Boolean = true ) : Object
        {
            if( CPath.ext( m_theURLFile.loadingURL ).toLowerCase() == ".qson" )
            {
                var aBytes : ByteArray = m_theURLFile.readAllBytes();
                return new CQsonStream( aBytes );
            }
            else return super.createObject( bCleanUp );
        }
    }

}

