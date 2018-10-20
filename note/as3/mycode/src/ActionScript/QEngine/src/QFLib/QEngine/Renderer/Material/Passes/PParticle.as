/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Passes
{
    import QFLib.QEngine.Renderer.Material.IPass;
    import QFLib.QEngine.Renderer.Material.Shaders.FBase;
    import QFLib.QEngine.Renderer.Material.Shaders.FColorAlpha;
    import QFLib.QEngine.Renderer.Material.Shaders.VTintColorTC;
    import QFLib.QEngine.Renderer.Textures.Texture;

    import flash.display3D.Context3DBlendFactor;

    public class PParticle extends PassBase implements IPass
    {
        public static const sName : String = "PParticle";

        static private const _bias : Vector.<Number> = Vector.<Number>( [ 0.001, 0, 0, 0 ] );

        public function PParticle()
        {
            super();

            _passName = sName;

            registerVector( "bias", _bias );

            blendMode = "custom";
        }

        private var _srcOp : String = Context3DBlendFactor.SOURCE_ALPHA;

        [inline]
        public override function get srcOp() : String
        {
            return _srcOp;
        }

        [inline]
        public function set srcOp( value : String ) : void
        {
            _srcOp = value;
        }

        private var _dstOp : String = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;

        [inline]
        public override function get dstOp() : String
        {
            return _dstOp;
        }

        [inline]
        public function set dstOp( value : String ) : void
        {
            _dstOp = value;
        }

        public override function get vertexShader() : String
        {
            return VTintColorTC.Name;
        }

        public override function get fragmentShader() : String
        {
            return FColorAlpha.Name;
        }

        public override function set texture( value : Texture ) : void
        {
            if( value != null )
                setTexture( FBase.mainTexture, value );
        }

        public function set maskColor( value : Vector.<Number> ) : void
        {
            registerVector( "maskColor", value );
        }

        public function set tintColor( value : Vector.<Number> ) : void
        {
            registerVector( "color", value );
        }

        public function set brightness( value : Vector.<Number> ) : void
        {
            registerVector( "brightness", value );
        }

        public override function dispose() : void
        {
            _srcOp = null;
            _dstOp = null;

            super.dispose();
        }

        public override function copy( other : IPass ) : void
        {
            var otherAlias : PParticle = other as PParticle;
            if( !( otherAlias as PParticle ) ) return;

            super.copy( otherAlias );

            this._srcOp = otherAlias._srcOp;
            this._dstOp = otherAlias._dstOp;

            this.texture = otherAlias.getTexture( FBase.mainTexture );
        }

        public override function clone() : IPass
        {
            var clonePass : PParticle = new PParticle();
            clonePass.copy( this );

            return clonePass;
        }
    }
}