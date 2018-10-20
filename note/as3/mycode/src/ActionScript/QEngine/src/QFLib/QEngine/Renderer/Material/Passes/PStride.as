/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Passes
{
    import QFLib.QEngine.Renderer.Material.IPass;
    import QFLib.QEngine.Renderer.Material.Shaders.FBase;
    import QFLib.QEngine.Renderer.Material.Shaders.FColorTexture;
    import QFLib.QEngine.Renderer.Material.Shaders.VColorTC;
    import QFLib.QEngine.Renderer.Textures.Texture;

    public class PStride extends PassBase implements IPass
    {
        public static const sName : String = "PStride";

        public function PStride()
        {
            super();

            _passName = sName;
        }

        public override function get vertexShader() : String
        {
            return VColorTC.Name;
        }

        public override function get fragmentShader() : String
        {
            return FColorTexture.Name;
        }

        override public function set texture( value : Texture ) : void
        {
            if( value )
            {
                super.setTexture( FBase.mainTexture, value );
            }
        }

        public override function clone() : IPass
        {
            var clonePass : PStride = new PStride();
            clonePass.copy( this );

            return clonePass;
        }
    }
}