package QFLib.Graphics.RenderCore.render.material
{
    import QFLib.Graphics.RenderCore.render.IMaterial;
    import QFLib.Graphics.RenderCore.render.pass.PParticle;
    import QFLib.Graphics.RenderCore.render.pass.PParticlePMA;

import flash.display3D.Context3DBlendFactor;

    public class MParticle extends MaterialBase implements IMaterial
    {
        private var _tintColor : Vector.<Number> = Vector.<Number> ( [ 0.5, 0.5, 0.5, 1.0 ] );
        private var _maskColor : Vector.<Number> = Vector.<Number> ( [ 0.0, 0.0, 0.0, 1.0 ] );
        private var _brightness : Vector.<Number> = Vector.<Number> ( [ 2.0, 2.0, 2.0, 1.0 ] );

        private var _passNormal : PParticle;
        private var _passPMA : PParticlePMA;

        private var _srcOP : String;
        private var _dstOP : String;

        public function MParticle ()
        {
            super ( 2 );
        }

        public override function dispose () : void
        {
            _tintColor.fixed = false;
            _tintColor.length = 0;
            _tintColor = null;

            _maskColor.fixed = false;
            _maskColor.length = 0;
            _maskColor = null;

            _brightness.fixed = false;
            _brightness.length = 0;
            _brightness = null;

            super.dispose ();
        }

        override public function reset () : void
        {
            setAllPassEnable ( false );
            if ( _premultiplyAlpha && _passPMA )
                _passPMA.enable = true;
            else if ( _passNormal )
                _passNormal.enable = true;
        }


        public function set tintColor ( value : Vector.<Number> ) : void
        {
            _tintColor[ 0 ] = value[ 0 ];
            _tintColor[ 1 ] = value[ 1 ];
            _tintColor[ 2 ] = value[ 2 ];
            _tintColor[ 3 ] = value[ 3 ];
        }

        public function set maskColor ( value : Vector.<Number> ) : void
        {
            _maskColor[ 0 ] = value[ 0 ] * value[ 3 ];
            _maskColor[ 1 ] = value[ 1 ] * value[ 3 ];
            _maskColor[ 2 ] = value[ 2 ] * value[ 3 ];
            _maskColor[ 3 ] = 1.0 - value[ 3 ];
        }

        [Inline] public function set srcOp ( value : String ) : void { _srcOP = value; }
        [Inline] public function set dstOp ( value : String ) : void { _dstOP = value; }

        override public function update () : void
        {
            if ( this.pma )
            {
                createPMAPass ();
                _passPMA.enable = true;
                _passPMA.srcOp = _srcOP;
                _passPMA.dstOp = _dstOP;
                if ( _passNormal ) _passNormal.enable = false;
            }
            else
            {
                createNormalPass ();
                _passNormal.enable = true;
                _passNormal.srcOp = _srcOP;
                _passNormal.dstOp = _dstOP;
                if ( _passPMA ) _passPMA.enable = false;
            }

            if ( _passPMA ) _passPMA.mainTexture = this.mainTexture;
            if ( _passNormal ) _passNormal.mainTexture = this.mainTexture;
        }

        public function equal ( other : IMaterial ) : Boolean
        {
            if ( other == null ) return false;
            var otherAlias : MParticle = other as MParticle;
            if ( otherAlias == null )
                return false;

            if ( !super.innerEqual ( otherAlias ) )
                return false;

            if ( _srcOP != otherAlias._srcOP || _dstOP != otherAlias._dstOP )
                return false;

            for ( var i : int = 0; i < 4; ++i )
            {
                if ( _tintColor[ i ] != otherAlias._tintColor[ i ] )
                    return false;
                if ( _maskColor[ i ] != otherAlias._maskColor[ i ] )
                    return false;
                if ( _brightness[ i ] != otherAlias._brightness[ i ] )
                    return false;
            }

            return true;
        }

        private function createNormalPass () : void
        {
            if ( _passNormal != null ) return;
            _passNormal = new PParticle ();
            _passNormal.tintColor = _tintColor;
            _passNormal.maskColor = _maskColor;
            _passes[ 0 ] = _passNormal;
            _passNormal.brightness = _brightness;
        }

        private function createPMAPass () : void
        {
            if ( _passPMA != null ) return;
            _passPMA = new PParticlePMA ();
            _passPMA.tintColor = _tintColor;
            _passPMA.maskColor = _maskColor;
            _passes[ 1 ] = _passPMA;
            _passPMA.brightness = _brightness;
        }
    }
}