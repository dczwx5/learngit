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
    import QFLib.Qson.CQson;

    import flash.utils.ByteArray;

    public class CQsonLoader extends CJsonLoader
    {
        public static const NAME : String = ".QSON";
        public static var enableQsonLoading : Boolean = true;

        public function CQsonLoader( theBelongResourceLoadersRef : CResourceLoaders )
        {
            super( theBelongResourceLoadersRef );
        }

        public override function dispose() : void
        {
            super.dispose();
        }

        public override function start() : void
        {
            if( enableQsonLoading == false )
            {
                for( var j : int = 0; j < m_vFilenames.length; j++ )
                {
                    if( CPath.ext( m_vFilenames[ j ] ).toLowerCase() == ".qson" )
                    {
                        m_vFilenames[ j ] = CPath.driverDirName( m_vFilenames[ j ] ) + ".json";
                    }
                }
            }
            super.start();
        }

        public override function createObject( bCleanUp : Boolean = true ) : Object
        {
            if( CPath.ext( m_theURLFile.loadingURL ).toLowerCase() == ".qson" )
            {
                var aBytes : ByteArray = m_theURLFile.readAllBytes();
                if( aBytes != null )
                {
                    Foundation.Perf.sectionBegin( "CQsonLoader.CQson.parse" );
                    var theJson : Object = CQson.parse( aBytes );
                    Foundation.Perf.sectionEnd( "CQsonLoader.CQson.parse" );
                    if( theJson == null ) Foundation.Log.logErrorMsg( "Error loading qson: " + this.loadingFilename );

                    return theJson;
                }
                else
                {
                    Foundation.Log.logWarningMsg( "Loading a '0' byte qson file: '" + this.loadingFilename + "'" );
                    return new Object();
                }
            }
            else return super.createObject( bCleanUp );
        }
    }

}

