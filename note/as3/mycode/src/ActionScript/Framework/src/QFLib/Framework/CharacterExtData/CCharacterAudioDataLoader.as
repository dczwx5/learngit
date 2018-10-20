//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package QFLib.Framework.CharacterExtData
{
    import QFLib.ResourceLoader.CJsonLoader;
    import QFLib.ResourceLoader.CResourceLoaders;
    import QFLib.ResourceLoader.ELoadingPriority;

    public class CCharacterAudioDataLoader extends CJsonLoader
    {
        public static const NAME : String = ".ADO";

        public function CCharacterAudioDataLoader( theBelongResourceLoadersRef : CResourceLoaders )
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
                var theAudioData : CCharacterAudioData = new CCharacterAudioData(); // <-- change to audio data format in the future
                theAudioData.loadData( obj );
                return theAudioData;
            }
            else return null;
        }
    }

}

