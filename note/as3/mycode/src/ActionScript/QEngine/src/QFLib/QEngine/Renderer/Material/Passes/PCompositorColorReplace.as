/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by xandy on 2015/9/11.
 */
package QFLib.QEngine.Renderer.Material.Passes
{
    import QFLib.QEngine.Renderer.Material.IPass;
    import QFLib.QEngine.Renderer.Material.Shaders.FBase;
    import QFLib.QEngine.Renderer.Material.Shaders.FFilterColor;
    import QFLib.QEngine.Renderer.Material.Shaders.VCompositor;
    import QFLib.QEngine.Renderer.Textures.Texture;

    public class PCompositorColorReplace extends PassBase implements IPass
    {
        public static const sName : String = "PCompositorColorReplace";

        static private var sMinColor : Vector.<Number> = new <Number>[ 0, 0, 0, 0.0001 ];

        public function PCompositorColorReplace()
        {
            super();

            _passName = sName;

            registerVector( FFilterColor.MinColor, sMinColor );
        }

        public override function get vertexShader() : String
        {
            return VCompositor.Name;
        }

        public override function get fragmentShader() : String
        {
            return FFilterColor.Name;
        }

        override public function set texture( value : Texture ) : void
        {
            if( value != null )
            {
                setTexture( FBase.mainTexture, value );
            }
        }

        public function set colorMatrix( value : Vector.<Number> ) : void
        {
            registerVector( FFilterColor.ColorMatrix, value );
        }

        public override function clone() : IPass
        {
            var clonePass : PCompositorColorReplace = new PCompositorColorReplace();
            clonePass.copy( this );

            return clonePass;
        }
    }
}
