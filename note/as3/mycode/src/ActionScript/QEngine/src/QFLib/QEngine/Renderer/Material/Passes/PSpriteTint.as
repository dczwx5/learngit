/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Passes
{
    import QFLib.QEngine.Renderer.Material.IPass;
    import QFLib.QEngine.Renderer.Material.Shaders.FBase;
    import QFLib.QEngine.Renderer.Material.Shaders.FColorTexture;
    import QFLib.QEngine.Renderer.Material.Shaders.VTintTC;
    import QFLib.QEngine.Renderer.Textures.Texture;

    public class PSpriteTint extends PassBase implements IPass
    {
        public static const sName : String = "PSpriteTint";

        public function PSpriteTint()
        {
            super();

            _passName = sName;
        }

        public override function get vertexShader() : String
        {
            return VTintTC.Name;
        }

        public override function get fragmentShader() : String
        {
            return FColorTexture.Name;
        }

        override public function set texture( value : Texture ) : void
        {
            if( value != null )
            {
                setTexture( FBase.mainTexture, value );
            }
        }

        public function set maskingColor( value : Vector.<Number> ) : void
        {
            registerVector( "maskColor", value );
        }

        public function set tintColor( value : Vector.<Number> ) : void
        {
            registerVector( "color", value );
        }

        public override function clone() : IPass
        {
            var clonePass : PSpriteTint = new PSpriteTint();
            clonePass.copy( this );

            return clonePass;
        }
    }
}