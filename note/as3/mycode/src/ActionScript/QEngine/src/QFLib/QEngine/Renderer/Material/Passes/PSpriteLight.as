/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Passes
{
    import QFLib.QEngine.Renderer.Material.IPass;
    import QFLib.QEngine.Renderer.Material.Shaders.FBase;
    import QFLib.QEngine.Renderer.Material.Shaders.FLightTexture;
    import QFLib.QEngine.Renderer.Material.Shaders.VLightTC;
    import QFLib.QEngine.Renderer.Textures.Texture;

    public class PSpriteLight extends PassBase implements IPass
    {
        public static const sName : String = "PSpriteLight";

        public function PSpriteLight()
        {
            super();

            _passName = sName;
        }

        public override function get vertexShader() : String
        {
            return VLightTC.Name;
        }

        public override function get fragmentShader() : String
        {
            return FLightTexture.Name;
        }

        override public function set texture( value : Texture ) : void
        {
            if( value != null )
            {
                setTexture( FBase.mainTexture, value );
            }
        }

        public function set lightColor( value : Vector.<Number> ) : void
        {
            registerVector( "lightColor", value );
        }

        public function set lightContrast( value : Vector.<Number> ) : void
        {
            registerVector( "lightContrast", value );
        }

        public override function clone() : IPass
        {
            var clonePass : PSpriteLight = new PSpriteLight();
            clonePass.copy( this );

            return clonePass;
        }
    }
}