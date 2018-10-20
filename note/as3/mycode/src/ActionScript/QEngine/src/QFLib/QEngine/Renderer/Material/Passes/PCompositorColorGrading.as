/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Passes
{
    import QFLib.QEngine.Renderer.Material.IPass;
    import QFLib.QEngine.Renderer.Material.Shaders.FBase;
    import QFLib.QEngine.Renderer.Material.Shaders.FColorGrading;
    import QFLib.QEngine.Renderer.Material.Shaders.VCompositor;
    import QFLib.QEngine.Renderer.Textures.Texture;

    public class PCompositorColorGrading extends PassBase implements IPass
    {
        public static const sName : String = "PCompositorColorGrading";

        static private const grid : Vector.<Number> = new <Number>[ 1.0 / 16.0, 16.0, 255.0, 0.099 ];

        public function PCompositorColorGrading()
        {
            super();

            _passName = sName;

            registerVector( "grid", grid );
        }

        public override function get vertexShader() : String
        {
            return VCompositor.Name;
        }

        public override function get fragmentShader() : String
        {
            return FColorGrading.Name;
        }

        override public function set texture( value : Texture ) : void
        {
            if( value != null )
            {
                setTexture( FBase.mainTexture, value );
            }
        }

        public function get colorGrading() : Texture
        {
            return getTexture( "colorGrading" );
        }

        public function set colorGrading( value : Texture ) : void
        {
            if( value != null )
            {
                setTexture( "colorGrading", value );
            }
        }

        public override function equal( other : IPass ) : Boolean
        {
            var otherAlias : PCompositorColorGrading = other as PCompositorColorGrading;
            if( otherAlias != null && innerEqual( otherAlias ) )
            {
                return colorGrading == otherAlias.colorGrading;
            }

            return false;
        }

        public override function clone() : IPass
        {
            var clonePass : PCompositorColorGrading = new PCompositorColorGrading();
            clonePass.copy( this );

            return clonePass;
        }
    }
}
