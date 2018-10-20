/**
 * Created by Administrator on 2017/5/8.
 */
package QFLib.ResourceLoader {

import QFLib.Foundation;
import QFLib.Foundation.CPath;
import QFLib.Qson.CQson;

import flash.utils.ByteArray;

public class CPackedQsonLoader extends CPackedJsonLoader {

    public static const NAME : String = ".PQSON";
    public static var enablePackedQsonLoading : Boolean = true;

    public function CPackedQsonLoader( theBelongResourceLoadersRef : CResourceLoaders ) {
        super( theBelongResourceLoadersRef );
    }

    public override function dispose() : void {
        super.dispose();
    }

    public override function start() : void {
        if ( enablePackedQsonLoading == false ) {
            for ( var j : int = 0; j < m_vFilenames.length; j++ ) {
                if ( CPath.ext( m_vFilenames[ j ] ).toLowerCase() == ".qson" ) {
                    m_vFilenames[ j ] = CPath.driverDirName( m_vFilenames[ j ] ) + ".json";
                }
            }
        }
        super.start();
    }

    public override function createObject( bCleanUp : Boolean = true ) : Object {
        if ( CPath.ext( m_theURLFile.loadingURL ).toLowerCase() == ".qson" ) {
            var aBytes : ByteArray = m_theURLFile.readAllBytes();
            if ( aBytes != null ) {
                Foundation.Perf.sectionBegin( "CQsonLoader.CQson.parse" );
                var theJson : Object = CQson.parse( aBytes );
                Foundation.Perf.sectionEnd( "CQsonLoader.CQson.parse" );
                if ( theJson == null ) {
                    Foundation.Log.logErrorMsg( "Error loading qson: " + this.loadingFilename );
                    return null;
                }
                for (var jsonKey:String in theJson) {
                    var sFullFilename:String = CPath.driverDir(this.filename) + jsonKey + ".json";
                    var cacheValue:CResource = new CResource(sFullFilename, CJsonLoader.NAME, theJson[jsonKey]);
                    if (this.m_theBelongResourceLoadersRef.resourceCache.isExisted(sFullFilename, CJsonLoader.NAME) == false) {
                        this.m_theBelongResourceLoadersRef.resourceCache.add(sFullFilename, CJsonLoader.NAME, cacheValue, false);
                    }
                }
                return theJson;
            }
            else return null;
        }
        else return super.createObject( bCleanUp );
    }
}
}
