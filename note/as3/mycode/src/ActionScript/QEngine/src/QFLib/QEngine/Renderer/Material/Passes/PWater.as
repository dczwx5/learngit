/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Passes
{
    import QFLib.QEngine.Renderer.Material.IPass;
    import QFLib.QEngine.Renderer.Material.Shaders.FWater;
    import QFLib.QEngine.Renderer.Material.Shaders.VWater;
    import QFLib.QEngine.Renderer.Textures.Texture;

    import flash.display3D.Context3DBlendFactor;

    public class PWater extends PassBase implements IPass
    {
        public static const sName : String = "PWater";

        public function PWater()
        {
            super();

            _passName = sName;

            blendMode = "custom";
        }

        public override function get vertexShader() : String
        {
            return VWater.Name;
        }

        public override function get fragmentShader() : String
        {
            return FWater.Name;
        }

        public override function get srcOp() : String
        {
            return Context3DBlendFactor.ONE;
        }

        public override function get dstOp() : String
        {
            return Context3DBlendFactor.ZERO;
        }

        public function set reflectTexture( value : Texture ) : void
        {
            if( value )
            {
                super.setTexture( "reflectTex", value );
            }
        }

        public function set waveTexture( value : Texture ) : void
        {
            if( value )
            {
                super.setTexture( "waveTex", value );
            }
        }

        public function set reflectScaler( value : Vector.<Number> ) : void
        {
            registerVector( "reflectScaler", value );
        }

        public function set waveScaler( value : Vector.<Number> ) : void
        {
            registerVector( "waveScaler", value );
        }

        public function set waveParam( value : Vector.<Number> ) : void
        {
            registerVector( "waveParam", value );
        }

        public function set reflectParam( value : Vector.<Number> ) : void
        {
            registerVector( "reflectParam", value );
        }

        public function set turbParam( value : Vector.<Number> ) : void
        {
            registerVector( "turbParam", value );
        }

        public function set waveColor( value : Vector.<Number> ) : void
        {
            registerVector( "waveColor", value );
        }

        public override function clone() : IPass
        {
            var clonePass : PWater = new PWater();
            clonePass.copy( this );

            return clonePass;
        }
    }
}