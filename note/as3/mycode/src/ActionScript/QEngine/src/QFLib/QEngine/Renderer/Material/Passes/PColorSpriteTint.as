/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Passes
{
    import QFLib.QEngine.Renderer.Material.IPass;
    import QFLib.QEngine.Renderer.Material.Shaders.FBase;
    import QFLib.QEngine.Renderer.Material.Shaders.FColorTexture;
    import QFLib.QEngine.Renderer.Material.Shaders.VTintColorTC;
    import QFLib.QEngine.Renderer.Textures.Texture;

    public class PColorSpriteTint extends PassBase implements IPass
    {
        public static const sName : String = "PColorSpriteTint";

        static private const _bias : Vector.<Number> = Vector.<Number>( [ 0.01, 0, 0, 0 ] );

        public function PColorSpriteTint()
        {
            super();

            _passName = sName;

            registerVector( "_bias", _bias );
        }

        public override function set blendMode( value : String ) : void
        {
            _blendMode = value;
        }

        public override function get vertexShader() : String
        {
            return VTintColorTC.Name;
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

        public function set maskColor( value : Vector.<Number> ) : void
        {
            registerVector( "maskColor", value );
        }

        public function set tintColor( value : Vector.<Number> ) : void
        {
            registerVector( "color", value );
        }

        public override function clone() : IPass
        {
            var clonePass : PColorSpriteTint = new PColorSpriteTint();
            clonePass.copy( this );

            return clonePass;
        }
    }
}
