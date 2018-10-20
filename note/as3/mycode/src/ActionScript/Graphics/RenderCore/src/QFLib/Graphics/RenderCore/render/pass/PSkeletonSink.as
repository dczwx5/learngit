package QFLib.Graphics.RenderCore.render.pass
{
    import QFLib.Graphics.RenderCore.render.IPass;
    import QFLib.Graphics.RenderCore.render.shader.FBase;
    import QFLib.Graphics.RenderCore.render.shader.FLightTexture;
    import QFLib.Graphics.RenderCore.render.shader.VSkeletonSink;
    import QFLib.Graphics.RenderCore.starling.display.BlendMode;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;

    import flash.display3D.Context3DBlendFactor;

    public class PSkeletonSink extends PassBase implements IPass
    {
        public static const sName : String = "PSkeletonSink";

        private static const _bias : Vector.<Number> = Vector.<Number> ( [ 0.01, 0.0, 0, 0 ] );

        public function PSkeletonSink ( ...args )
        {
            super ();

            _passName = sName;

            registerVector ( "bias", _bias );
        }
        private var _isBlendNormal : Boolean = false;

        public override function get vertexShader () : String
        {
            return VSkeletonSink.Name;
        }

        public override function get fragmentShader () : String
        {
            return FLightTexture.Name;
        }

        override public function set blendMode ( value : String ) : void
        {
            _isBlendNormal = ( value == BlendMode.NORMAL );
            _blendMode = "custom";
        }

        override public function get srcOp () : String
        {
            _bias[ 1 ] = _premultiplyAlpha ? 0.0 : 1.0;
            return Context3DBlendFactor.ONE;
        }

        override public function get dstOp () : String
        {
            _bias[ 1 ] = _premultiplyAlpha ? 0.0 : 1.0;
            //return Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
            return ( !_isBlendNormal ) ? Context3DBlendFactor.ONE : Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
        }

        public function set sinkParam ( value : Vector.<Number> ) : void
        {
            registerVector ( "sinkParam", value );
        }

        public function set lightColor ( value : Vector.<Number> ) : void
        {
            registerVector ( "lightColor", value );
        }

        public function set maskColor ( value : Vector.<Number> ) : void
        {
            registerVector ( "maskColor", value );
        }

        public function set tintColor ( value : Vector.<Number> ) : void
        {
            registerVector ( "tintColor", value );
        }

        public function set lightContrast ( value : Vector.<Number> ) : void
        {
            registerVector ( "lightContrast", value );
        }

        public override function equal ( other : IPass ) : Boolean
        {
            var otherAlias : PSkeletonSink = other as PSkeletonSink;
            if ( otherAlias == null ) return false;

            return super.innerEqual ( otherAlias ) && _isBlendNormal == otherAlias._isBlendNormal;
        }

        public override function copy ( other : IPass ) : void
        {
            var otherAlias : PSkeletonSink = other as PSkeletonSink;
            if ( otherAlias == null ) return;

            super.innerCopyFrom ( otherAlias );

            this._isBlendNormal = otherAlias._isBlendNormal;
        }

        public override function clone () : IPass
        {
            var clonePass : PSkeletonSink = new PSkeletonSink ();
            clonePass.copy ( this );

            return clonePass;
        }
    }
}