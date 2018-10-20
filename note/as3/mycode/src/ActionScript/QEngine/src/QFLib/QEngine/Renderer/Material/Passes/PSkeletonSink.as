/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Passes
{
    import QFLib.QEngine.Renderer.Material.BlendMode;
    import QFLib.QEngine.Renderer.Material.IPass;
    import QFLib.QEngine.Renderer.Material.Shaders.FBase;
    import QFLib.QEngine.Renderer.Material.Shaders.FLightTexture;
    import QFLib.QEngine.Renderer.Material.Shaders.VSkeletonSink;
    import QFLib.QEngine.Renderer.Textures.Texture;

    import flash.display3D.Context3DBlendFactor;

    public class PSkeletonSink extends PassBase implements IPass
    {
        public static const sName : String = "PSkeletonSink";

        static private const _bias : Vector.<Number> = Vector.<Number>( [ 0.01, 0, 0, 0 ] );

        public function PSkeletonSink()
        {
            super();

            _passName = sName;

            registerVector( "bias", _bias );
        }
        private var _isBlendNormal : Boolean = false;

        public override function get vertexShader() : String
        {
            return VSkeletonSink.Name;
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
                pma = value.premultipliedAlpha;
            }
        }

        override public function set blendMode( value : String ) : void
        {
            _isBlendNormal = ( value == BlendMode.NORMAL );
            _blendMode = value;
        }

        override public function get srcOp() : String
        {
            _bias[ 1 ] = _premultiplyAlpha ? 1.0 : 0.0;
            return Context3DBlendFactor.ONE;
        }

        override public function get dstOp() : String
        {
            _bias[ 1 ] = _premultiplyAlpha ? 1.0 : 0.0;
            return Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;//( !_isBlendNormal ) ? Context3DBlendFactor.ONE : Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
        }

        public function set sinkParam( value : Vector.<Number> ) : void
        {
            registerVector( "sinkParam", value );
        }

        public function set lightColor( value : Vector.<Number> ) : void
        {
            registerVector( "lightColor", value );
        }

        public function set maskColor( value : Vector.<Number> ) : void
        {
            registerVector( "maskColor", value );
        }

        public function set tintColor( value : Vector.<Number> ) : void
        {
            registerVector( "tintColor", value );
        }

        public function set lightContrast( value : Vector.<Number> ) : void
        {
            registerVector( "lightContrast", value );
        }

        public override function clone() : IPass
        {
            var clonePass : PSkeletonSink = new PSkeletonSink();
            clonePass.copy( this );

            return clonePass;
        }
    }
}