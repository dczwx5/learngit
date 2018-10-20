//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Burgess on 2017/4/19.
 */
package QFLib.ResourceLoader {
import QFLib.Foundation;
import QFLib.Foundation.CPath;
import flash.utils.ByteArray;

public class CQbinLoader extends CQsonLoader
{
    public static const NAME : String = ".QBIN";
    public static var enableQbinLoading : Boolean = true;

    public function CQbinLoader(theBelongResourceLoadersRef : CResourceLoaders )
    {
        super( theBelongResourceLoadersRef );
    }

    public override function dispose() : void
    {
        super.dispose();
    }
    public override function start() : void
    {
        if( enableQbinLoading == false )
        {
            for( var j : int = 0; j < m_vFilenames.length; j++ )
            {
                if( CPath.ext( m_vFilenames[ j ] ).toLowerCase() == ".qbin" )
                {
                    m_vFilenames[ j ] = CPath.driverDirName( m_vFilenames[ j ] ) + ".qson";
                }
            }
        }
        super.start();
    }
    public override function createObject( bCleanUp : Boolean = true ) : Object
    {
        if( CPath.ext( m_theURLFile.loadingURL ).toLowerCase() == ".qbin" )
        {
            var aBytes : ByteArray;
            Foundation.Perf.sectionBegin("CQbinLoader.Qbin.parse");
            aBytes = m_theURLFile.readAllBytes();
            Foundation.Perf.sectionEnd("CQbinLoader.Qbin.parse");
            
            if( aBytes != null )
            {
                return aBytes;
            }
            else return null;
        }
        else return super.createObject( bCleanUp );
    }
}
}
