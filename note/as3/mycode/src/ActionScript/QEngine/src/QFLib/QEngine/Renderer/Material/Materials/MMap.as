/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Materials
{
    import QFLib.QEngine.Renderer.Material.IMaterial;
    import QFLib.QEngine.Renderer.Material.IPass;
    import QFLib.QEngine.Renderer.Material.Passes.PSpriteTexture;
    import QFLib.QEngine.Renderer.Material.Passes.PSpriteTint;
    import QFLib.QEngine.Renderer.Textures.Texture;

    public class MMap extends MaterialBase implements IMaterial
    {
        public function MMap()
        {
            super( 1 );

            for( var i : int = 0; i < 4; ++i )
            {
                _tintColor[ i ] = 1.0;
                _maskColor[ i ] = 0.0;
            }
            _maskColor[ 3 ] = 1.0;

            _passTexture = new PSpriteTexture();
            _inactivePasses.add( PSpriteTexture.sName, _passTexture );
            _passes[ 0 ] = _passTexture;
            _orignalPass = _passTexture;

            _passTint = new PSpriteTint();
            _inactivePasses.add( PSpriteTint.sName, _passTint );
            _passTint.tintColor = _tintColor;
        }
        protected var _passTexture : PSpriteTexture;
        protected var _passTint : PSpriteTint;
        private var _tintColor : Vector.<Number> = new Vector.<Number>( 4 );
        private var _maskColor : Vector.<Number> = new Vector.<Number>( 4 );

        public override function set texture( value : Texture ) : void
        {
            super.texture = value;
            _passTexture.texture = value;
            _passTint.texture = value;
        }

        private var _tint : Boolean = false;

        public function get tint() : Boolean
        {
            return _tint;
        }

        public function set tint( value : Boolean ) : void
        {
            if( _tint != value )
            {
                _tint = value;
                var pass : IPass = tint ? _passTint : _passTexture;
                _passes[ 0 ] = pass;
                _orignalPass = pass;
            }
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
                _maskColor[ 3 ] = 1.0;
                _tintColor[ 0 ] = value[ 0 ];
                _tintColor[ 1 ] = value[ 1 ];
                _tintColor[ 2 ] = value[ 2 ];
                _tintColor[ 3 ] = value[ 3 ];
            }

            tint = true;
        }

        public override function dispose() : void
        {
            super.dispose();
        }

        public function equal( other : IMaterial ) : Boolean
        {
            var otherAlias : MMap = other as MMap;
            if( otherAlias == null )
            {
                return false;
            }

            if( !super.innerEqual( otherAlias ) )
            {
                return false;
            }

            if( _tint != otherAlias._tint )
            {
                return false;
            }

            if( _tint )
            {
                for( var i : int = 0; i < 4; ++i )
                {
                    if( _tintColor[ i ] != otherAlias._tintColor[ i ] )
                    {
                        return false;
                    }
                }
            }

            return true;
        }

        public function copySingleton() : IMaterial
        {
            return this;
        }
    }
}