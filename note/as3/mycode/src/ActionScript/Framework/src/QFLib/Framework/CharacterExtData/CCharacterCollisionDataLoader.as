//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package QFLib.Framework.CharacterExtData
{

import QFLib.Framework.CharacterExtData.CCharacterCollisionAssemblyData;
import QFLib.ResourceLoader.CJsonLoader;
    import QFLib.ResourceLoader.CResourceLoaders;
    import QFLib.ResourceLoader.ELoadingPriority;

    public class CCharacterCollisionDataLoader extends CJsonLoader
    {
        public static const NAME : String = ".COL";

        public function CCharacterCollisionDataLoader( theBelongResourceLoadersRef : CResourceLoaders )
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
//                var theCollisonData : CCharacterCollisionData = new CCharacterCollisionData();
                var theCollisonData : CCharacterCollisionAssemblyData = new CCharacterCollisionAssemblyData();
//                if( obj.hasOwnProperty( "collision" ) ) theCollisonData.loadData( obj.collision );
//                else
                    theCollisonData.loadData( obj );

                return theCollisonData;
            }
            else return null;
        }
    }

}

