/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2016/12/12.
 */
package QFLib.QEngine.Renderer.Material.Passes
{
    import QFLib.QEngine.Renderer.Material.IPass;
    import QFLib.QEngine.Renderer.Material.Shaders.FBase;
    import QFLib.QEngine.Renderer.Material.Shaders.FSmooth;
    import QFLib.QEngine.Renderer.Material.Shaders.VSmooth;
    import QFLib.QEngine.Renderer.Textures.Texture;

    public class PSmooth extends PassBase implements IPass
    {
        public static const sName : String = "p.smooth";

        public function PSmooth()
        {
            super();

            _passName = sName;

            _blendMode = "custom";
        }

        public override function get vertexShader() : String
        {
            return VSmooth.Name;
        }

        public override function get fragmentShader() : String
        {
            return FSmooth.Name;
        }

        public override function set texture( value : Texture ) : void
        {
            if( value != null )
            {
                setTexture( FBase.mainTexture, value );
            }
        }

        public function set uvOffsets( value : Vector.<Number> ) : void
        {
            registerVector( "uvOffsets", value );
        }

        public override function dispose() : void
        {
            super.dispose();
        }
    }
}
