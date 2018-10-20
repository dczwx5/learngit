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

    public class CXmlLoader extends CBaseLoader
    {
        public static const NAME : String = ".XML";

        public function CXmlLoader( theBelongResourceLoadersRef : CResourceLoaders )
        {
            super( theBelongResourceLoadersRef );
        }

        public override function dispose() : void
        {
            super.dispose();
        }

        public override function createObject( bCleanUp : Boolean = true ) : Object
        {
            var s : String = m_theURLFile.readAllText();
            if( s ) return XML( s );
            else return null;
        }
    }

}

