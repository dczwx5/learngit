/**
 * Created by david on 2016/8/3.
 */
package QFLib.Framework.CharacterExtData
{
    import QFLib.ResourceLoader.CJsonLoader;
    import QFLib.ResourceLoader.CResourceLoaders;
    import QFLib.ResourceLoader.ELoadingPriority;

    public class CCharacterFXDataLoader extends CJsonLoader
    {
        public static const NAME : String = ".CHARAFX";

        public function CCharacterFXDataLoader( theBelongResourceLoadersRef : CResourceLoaders )
        {
            super( theBelongResourceLoadersRef );
        }

        public override function dispose() : void
        {
            super.dispose();
        }

        public override function createObject( bCleanUp : Boolean = true ) : Object
        {
            var obj : Object = super.createObject( bCleanUp );
            if( obj != null )
            {
                var theCharaFXData : CCharacterFXData = new CCharacterFXData();
                theCharaFXData.fileName = this.filename;
                theCharaFXData.loadFromData(obj);

                return theCharaFXData;
            }

            return null;
        }
    }
}
