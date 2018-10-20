/**
 * Created by Administrator on 2017/5/6.
 */
package QFLib.ResourceLoader {
import QFLib.Foundation.CPath;

public class CPackedJsonLoader extends CJsonLoader {

    public static const NAME:String = ".PJSON";

    public function CPackedJsonLoader(theBelongResourceLoadersRef:CResourceLoaders) {
        super(theBelongResourceLoadersRef);
    }

    public override function dispose():void {
        super.dispose();
    }

    public override function createObject(bCleanUp:Boolean = true):Object {
        var theJson:Object = super.createObject(bCleanUp);
        if (theJson != null) {
            for (var jsonKey:String in theJson) {
                var sFullFilename:String = CPath.driverDir(this.loadingFilename) + jsonKey + ".json";
                var cacheValue:CResource = new CResource(sFullFilename, CJsonLoader.NAME, theJson[jsonKey]);
                if (this.m_theBelongResourceLoadersRef.resourceCache.isExisted(sFullFilename, CJsonLoader.NAME) == false) {
                    this.m_theBelongResourceLoadersRef.resourceCache.add(sFullFilename, CJsonLoader.NAME, cacheValue, false);
                }
            }

            return theJson;
        }

        return null;
    }
}
}
