/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/3/12
//----------------------------------------------------------------------------------------------------------------------

/*
 */

package QFLib.QEngine.Loader
{
    import QFLib.QEngine.Renderer.Textures.Texture;
    import QFLib.QEngine.Renderer.Textures.TextureAtlas;
    import QFLib.ResourceLoader.CResourceLoaders;

    public class TextureAtlasLoader extends TextureLoader
    {
        public static const NAME : String = ".ATLAS";

        public function TextureAtlasLoader( theBelongResourceLoaderRef : CResourceLoaders )
        {
            super( theBelongResourceLoaderRef );
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

