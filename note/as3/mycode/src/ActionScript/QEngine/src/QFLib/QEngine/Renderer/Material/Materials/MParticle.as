/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Materials
{
    import QFLib.QEngine.Renderer.Material.IMaterial;
    import QFLib.QEngine.Renderer.Material.Passes.PParticle;
    import QFLib.QEngine.Renderer.Material.Passes.PParticlePMA;
    import QFLib.QEngine.Renderer.Textures.Texture;

    public class MParticle extends MaterialBase implements IMaterial
    {
        public static var _singleton : MParticle = new MParticle();

        public function MParticle()
        {
            super( 1 );

            for( var i : int = 0; i < 4; ++i )
            {
                _tintColor[ i ] = 0.5;
                _brightness[ i ] = 2.0;
                _maskColor[ i ] = 0.0;
            }
            _tintColor[ 3 ] = 1.0;
            _maskColor[ 3 ] = 1.0;

            _passNormal = new PParticle();
            _inactivePasses.add( PParticle.sName, _passNormal );
            _passNormal.tintColor = _tintColor;
            _passNormal.maskColor = _maskColor;
            _passes[ 0 ] = _passNormal;
            _orignalPass = _passNormal;

            _passPMA = new PParticlePMA();
            _inactivePasses.add( PParticlePMA.sName, _passPMA );
            _passPMA.tintColor = _tintColor;
            _passPMA.maskColor = _maskColor;

            _passNormal.brightness = _brightness;
            _passPMA.brightness = _brightness;
        }
        private var _tintColor : Vector.<Number> = new Vector.<Number>( 4 );
        private var _maskColor : Vector.<Number> = new Vector.<Number>( 4 );
        private var _brightness : Vector.<Number> = new Vector.<Number>( 4 );
        private var _passNormal : PParticle;
        private var _passPMA : PParticlePMA;

        public override function set pma( value : Boolean ) : void
        {
            if( super.pma != value )
            {
                if( value )
                {
                    _passes[ 0 ] = _passPMA;
                    _orignalPass = _passPMA;
                }
                else
                {
                    _passes[ 0 ] = _passNormal;
                    _orignalPass = _passPMA;
                }

                super.pma = value;
            }
        }

        public override function set texture( value : Texture ) : void
        {
            super.texture = value;
            _passNormal.texture = value;
            _passPMA.texture = value;
        }

        private var _masking : Boolean = false;

        public function set masking( value : Boolean ) : void
        {
            _masking = value;
            if( !_masking )
            {
                _maskColor[ 0 ] = _maskColor[ 1 ] = _maskColor[ 2 ] = 0.0;
                _maskColor[ 3 ] = 1.0;
            }
        }

        public function set tintColorAndAlpha( value : Vector.<Number> ) : void
        {
            if( _masking )
            {
                _maskColor[ 0 ] = value[ 0 ] * value[ 3 ];
                _maskColor[ 1 ] = value[ 1 ] * value[ 3 ];
                _maskColor[ 2 ] = value[ 2 ] * value[ 3 ];
                _maskColor[ 3 ] = 1.0 - value[ 3 ];
                _tintColor[ 0 ] = _tintColor[ 1 ] = _tintColor[ 2 ] = _tintColor[ 3 ] = 0.5;
            }
            else
            {
                _maskColor[ 0 ] = _maskColor[ 1 ] = _maskColor[ 2 ] = 0.0;
                _maskColor[ 3 ] = 1.0;
                _tintColor[ 0 ] = value[ 0 ];
                _tintColor[ 1 ] = value[ 1 ];
                _tintColor[ 2 ] = value[ 2 ];
                _tintColor[ 3 ] = value[ 3 ];
            }
        }

        public function set srcOp( value : String ) : void
        {
            if( pma )
                _passPMA.srcOp = value;
            else
                _passNormal.srcOp = value;
        }

        public function set dstOp( value : String ) : void
        {
            if( pma )
                _passPMA.dstOp = value;
            else
                _passNormal.dstOp = value;
        }

        public override function dispose() : void
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

            super.dispose();
        }

        public function equal( other : IMaterial ) : Boolean
        {
            var otherAlias : MParticle = other as MParticle;
            if( otherAlias == null )
                return false;

            if( !super.innerEqual( otherAlias ) )
                return false;

            for( var i : int = 0; i < 4; ++i )
            {
                if( _tintColor[ i ] != otherAlias._tintColor[ i ] )
                    return false;
                if( _maskColor[ i ] != otherAlias._maskColor[ i ] )
                    return false;
                if( _brightness[ i ] != otherAlias._brightness[ i ] )
                    return false;
            }

            return true;
        }

        public function copy( other : MParticle ) : void
        {
            super.innerCopyFrom( other );

            pma = other.pma;

            for( var i : int = 0; i < 4; i++ )
            {
                _tintColor[ i ] = other._tintColor[ i ];
                _maskColor[ i ] = other._maskColor[ i ];
                _brightness[ i ] = other._brightness[ i ];
            }

            _passes[ 0 ].texture = other._texture;
        }

        public function copySingleton() : IMaterial
        {
            _singleton.copy( this );
            return _singleton;
        }
    }
}