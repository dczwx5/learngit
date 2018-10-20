//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/3/12
//----------------------------------------------------------------------------------------------------------------------

/*
*/

package QFLib.Graphics.RenderCore
{
    import QFLib.Graphics.RenderCore.starling.textures.TextureAtlas;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;
    import QFLib.ResourceLoader.CResourceLoaders;
    import QFLib.ResourceLoader.ELoadingPriority;

    public class CTextureAtlasLoader extends CTextureLoader
    {
        public static const NAME : String = ".ATLAS";

        public function CTextureAtlasLoader( theBelongResourceLoadersRef : CResourceLoaders )
        {
            super( theBelongResourceLoadersRef );
        }

        public override function dispose() : void
        {
            super.dispose();
        }

        public override function createObject( bCleanUp : Boolean = true ) : Object
        {
            var tex : Texture = super.createObject( bCleanUp ) as Texture;
            if( tex != null )
            {
                var xml : XML = m_aArguments[ 1 ] as XML;
                var sAtlasFile : String = m_aArguments[ 2 ] as String;
                var textureAtlas : TextureAtlas = new TextureAtlas( tex, xml, sAtlasFile, this.loadingFilename );
                return textureAtlas;
            }
            else return null;
        }

    }

}

