package QFLib.Graphics.RenderCore.render.pass
{
    import QFLib.Graphics.RenderCore.render.IPass;
    import QFLib.Graphics.RenderCore.render.shader.FBase;
    import QFLib.Graphics.RenderCore.render.shader.FColorAlpha;
    import QFLib.Graphics.RenderCore.render.shader.VTintColorTC;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;

    import flash.display3D.Context3DBlendFactor;

    public class PParticle extends PassBase implements IPass
    {
        public static const sName : String = "PParticle";

        static private const _bias : Vector.<Number> = Vector.<Number> ( [ 0.001, 0, 0, 0 ] );

        public function PParticle ( ...args )
        {
            super ();

            _passName = sName;

            registerVector ( "bias", _bias );
            blendMode = "custom";
        }

        private var _srcOp : String = Context3DBlendFactor.SOURCE_ALPHA;

        [Inline]
        public override function get srcOp () : String
        { return _srcOp; }

        [Inline]
        public function set srcOp ( value : String ) : void
        { _srcOp = value; }

        private var _dstOp : String = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;

        [Inline]
        public override function get dstOp () : String
        { return _dstOp; }

        [Inline]
        public function set dstOp ( value : String ) : void
        { _dstOp = value; }

        public override function get vertexShader () : String { return VTintColorTC.Name; }

        public override function get fragmentShader () : String { return FColorAlpha.Name; }

        public function set maskColor ( value : Vector.<Number> ) : void
        {
            registerVector ( "maskColor", value );
        }

        public function set tintColor ( value : Vector.<Number> ) : void
        {
            registerVector ( "color", value );
        }

        public function set brightness ( value : Vector.<Number> ) : void
        {
            registerVector ( "brightness", value );
        }

        public override function dispose () : void
        {
            _srcOp = null;
            _dstOp = null;

            super.dispose ();
        }

        public override function copy ( other : IPass ) : void
        {
            var otherAlias : PParticle = other as PParticle;
            if ( !( otherAlias as PParticle ) ) return;

            super.copy ( otherAlias );

            this._srcOp = otherAlias._srcOp;
            this._dstOp = otherAlias._dstOp;

            this.mainTexture = otherAlias.getTexture ( FBase.mainTexture );
        }

        public override function clone () : IPass
        {
            var clonePass : PParticle = new PParticle ();
            clonePass.copy ( this );

            return clonePass;
        }
    }
}