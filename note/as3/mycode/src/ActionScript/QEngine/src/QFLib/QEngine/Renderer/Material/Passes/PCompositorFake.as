/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by xandy on 2015/9/7.
 */
package QFLib.QEngine.Renderer.Material.Passes
{
    import QFLib.QEngine.Renderer.Material.IPass;
    import QFLib.QEngine.Renderer.Material.Shaders.FBase;
    import QFLib.QEngine.Renderer.Material.Shaders.FCompositorFake;
    import QFLib.QEngine.Renderer.Material.Shaders.VCompositor;
    import QFLib.QEngine.Renderer.Textures.Texture;

    public class PCompositorFake extends PassBase implements IPass
    {
        public static const sName : String = "PCompositorFake";

        protected static var GrayFactor : Vector.<Number> = new <Number>[ 0.3, 0.59, 0.11, 1.0 ];

        public function PCompositorFake()
        {
            super();

            _passName = sName;

            registerVector( FCompositorFake.GrayFactor, GrayFactor );
        }

        public override function get vertexShader() : String
        {
            return VCompositor.Name;
        }

        public override function get fragmentShader() : String
        {
            return FCompositorFake.Name;
        }

        override public function set texture( value : Texture ) : void
        {
            if( value != null )
            {
                setTexture( FBase.mainTexture, value );
            }
        }

        public override function clone() : IPass
        {
            var clonePass : PCompositorFake = new PCompositorFake();
            clonePass.copy( this );

            return clonePass;
        }
    }
}
