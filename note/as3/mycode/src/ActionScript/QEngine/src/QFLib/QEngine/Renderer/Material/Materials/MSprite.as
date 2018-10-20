/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Materials
{
    import QFLib.QEngine.Renderer.Material.IMaterial;
    import QFLib.QEngine.Renderer.Material.IPass;
    import QFLib.QEngine.Renderer.Material.Passes.PColorSpriteTint;
    import QFLib.QEngine.Renderer.Material.Passes.PSpriteSimple;
    import QFLib.QEngine.Renderer.Textures.Texture;

    public class MSprite extends MaterialBase implements IMaterial
    {
        public function MSprite()
        {
            super( 1 );

            for( var i : int = 0; i < 4; ++i )
            {
                _tintColor[ i ] = 1.0;
                _maskColor[ i ] = 0.0;
            }
            _maskColor[ 3 ] = 1.0;

            var passTint : PColorSpriteTint = new PColorSpriteTint();
            _inactivePasses.add( PColorSpriteTint.sName, passTint );
            passTint.tintColor = _tintColor;
            passTint.maskColor = _maskColor;

            var passSimple : PSpriteSimple = new PSpriteSimple();
            _inactivePasses.add( PSpriteSimple.sName, passSimple );
            passSimple.tintColor = _tintColor;
            passSimple.maskColor = _maskColor;

            _passes[ 0 ] = passSimple;
            _orignalPass = passSimple;
        }
        protected var _tintColor : Vector.<Number> = new Vector.<Number>( 4 );
        protected var _maskColor : Vector.<Number> = new Vector.<Number>( 4 );

        public override function set texture( value : Texture ) : void
        {
            if( _texture != value )
            {
                _texture = value;

                updatePass();
            }
        }

        public override function set pma( value : Boolean ) : void
        {
            _passes[ 0 ].pma = value;

            _premultiplyAlpha = value;
        }

        protected var _masking : Boolean = false;

        public function set masking( value : Boolean ) : void
        {
            _masking = value;
            if( !_masking )
            {
                _maskColor[ 0 ] = _maskColor[ 1 ] = _maskColor[ 2 ] = 0.0;
                _maskColor[ 3 ] = 1.0;
            }
        }

        public function set blendMode( value : String ) : void
        {
            _passes[ 0 ].blendMode = value;
        }

        public function set tintColorAndAlpha( value : Vector.<Number> ) : void
        {
            if( _masking )
            {
                _maskColor[ 0 ] = value[ 0 ] * value[ 3 ];
                _maskColor[ 1 ] = value[ 1 ] * value[ 3 ];
                _maskColor[ 2 ] = value[ 2 ] * value[ 3 ];
                _maskColor[ 3 ] = 1.0 - value[ 3 ];

                _tintColor[ 0 ] = _tintColor[ 1 ] = _tintColor[ 2 ] = _tintColor[ 3 ] = 1.0;
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

        public function get hasTexture() : Boolean
        {
            return _texture != null;
        }

        public override function dispose() : void
        {
            if( _tintColor )
            {
                _tintColor.length = 0;
                _tintColor = null;
            }

            if( _maskColor )
            {
                _maskColor.length = 0;
                _maskColor = null;
            }

            super.dispose();
        }

        override public function clone() : IMaterial
        {
            var newMat : MSprite = new MSprite();
            newMat.copy( this );
            return newMat;
        }

        public function equal( other : IMaterial ) : Boolean
        {
            var otherAlias : MSprite = other as MSprite;
            if( otherAlias == null )
            {
                return false;
            }

            if( !super.innerEqual( otherAlias ) )
                return false;

            if( _passes[ 0 ].blendMode != otherAlias._passes[ 0 ].blendMode )
            {
                return false;
            }

            if( hasTexture )
            {
                for( var i : int = 0; i < 4; ++i )
                {
                    if( _tintColor[ i ] != otherAlias._tintColor[ i ] )
                    {
                        return false;
                    }
                    if( _maskColor[ i ] != otherAlias._maskColor[ i ] )
                    {
                        return false;
                    }
                }
            }
            return true;
        }

        public function copy( other : MSprite ) : void
        {
            super.innerCopyFrom( other );

            blendMode = other.passes[ 0 ].blendMode;
            pma = other.passes[ 0 ].pma;

            var len : int = _tintColor.length;
            for( var i : int = 0; i < len; ++i )
            {
                _tintColor[ i ] = other._tintColor[ i ];
                _maskColor[ i ] = other._maskColor[ i ];
            }

            _passes[ 0 ].texture = _texture;
        }

        public function copySingleton() : IMaterial
        {
            return this;
        }

        protected function updatePass() : void
        {
            if( !hasTexture )
            {
                var pass : IPass = _inactivePasses.find( PSpriteSimple.sName );
                _passes[ 0 ] = pass;
                _orignalPass = pass;
            }
            else
            {
                pass = _inactivePasses.find( PColorSpriteTint.sName );
                _passes[ 0 ] = pass;
                _passes[ 0 ].texture = _texture;
                _passes[ 0 ].pma = _texture.premultipliedAlpha;
                _orignalPass = pass;
            }
        }
    }
}