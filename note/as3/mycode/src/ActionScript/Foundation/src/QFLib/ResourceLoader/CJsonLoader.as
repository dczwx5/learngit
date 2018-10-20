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

    public class CJsonLoader extends CBaseLoader
    {
        public static const NAME : String = ".JSON";

        public function CJsonLoader( theBelongResourceLoadersRef : CResourceLoaders )
        {
            super( theBelongResourceLoadersRef );
        }

        public override function dispose() : void
        {
            super.dispose();
        }

        public override function createObject( bCleanUp : Boolean = true ) : Object
        {
            var theJson : Object = null;
            if(this.m_theBelongResourceLoadersRef.resourceCache.isExisted(this.loadingFilename, CJsonLoader.NAME))
            {
                theJson = this.m_theBelongResourceLoadersRef.resourceCache.find(this.loadingFilename, CJsonLoader.NAME ).theObject;
            }
            else
            {
                /*var sCheckSum : String = null;
                if( this.m_theBelongResourceLoadersRef.assetVersion != null )
                {
                    var sSubFilename : String = m_theURLFile.loadingURL.substr( this.m_theBelongResourceLoadersRef.assetVersion.assetPath.length );
                    sCheckSum = this.m_theBelongResourceLoadersRef.assetVersion.findChecksum( sSubFilename );
                }*/
                var s : String = m_theURLFile.readAllText();
                if( s != null )
                {
                    Foundation.Perf.sectionBegin("CJsonLoader.Json.parse");
                    theJson = JSON.parse(s);
                    Foundation.Perf.sectionEnd("CJsonLoader.Json.parse");
                }
                else
                {
                    Foundation.Log.logWarningMsg( "Loading a '0' byte json file: '" + this.loadingFilename + "'" );
                    theJson = new Object();
                }
            }

            return theJson;
        }
    }

}

