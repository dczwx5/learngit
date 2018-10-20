/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Passes
{
    import QFLib.QEngine.Renderer.Material.IPass;
    import QFLib.QEngine.Renderer.Material.Shaders.FBase;
    import QFLib.QEngine.Renderer.Material.Shaders.FTexture;
    import QFLib.QEngine.Renderer.Material.Shaders.VTC;
    import QFLib.QEngine.Renderer.Textures.Texture;

    public class PSpriteTexture extends PassBase implements IPass
    {
        public static const sName : String = "PSpriteTexture";

        public function PSpriteTexture()
        {
            super();

            _passName = sName;
        }

        public override function get vertexShader() : String
        {
            return VTC.Name;
        }

        public override function get fragmentShader() : String
        {
            return FTexture.Name;
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
            var clonePass : PSpriteTexture = new PSpriteTexture();
            clonePass.copy( this );

            return clonePass;
        }
    }
}