package QFLib.Graphics.RenderCore.render.material
{
    import QFLib.Graphics.RenderCore.render.IMaterial;
    import QFLib.Graphics.RenderCore.render.pass.PColorSpriteTint;
    import QFLib.Graphics.RenderCore.render.pass.PSpriteSimple;
    import QFLib.Graphics.RenderCore.render.pass.PUVAnimation;

    public class MSprite extends MaterialBase implements IMaterial
    {
        protected var _tintColor : Vector.<Number> = new Vector.<Number> ( 4 );
        protected  var _maskColor : Vector.<Number> = new Vector.<Number> ( 4 );

        //uv动画参数
        protected  var _offsetUV : Vector.<Number> = Vector.<Number> ( [ 0.0, 0.0, 0.0, 1.0 ] );//后两位为常量
        protected  var _marginParams : Vector.<Number> = Vector.<Number> ( [ 0, 1, 0, 1 ] );
        protected  var _tilingParams : Vector.<Number> = Vector.<Number> ( [1, 1, 0.0, 0.0]);

        protected  var _blendMode : String = "normal";
        protected  var _uvAnimationEnable : Boolean = false;

        public function MSprite ( passCount : int = 3 )
        {
            super ( passCount );

            for ( var i : int = 0; i < 4; ++i )
            {
                _tintColor[ i ] = 1.0;
                _maskColor[ i ] = 0.0;
            }
            _maskColor[ 3 ] = 1.0;
        }

        public override function dispose () : void
        {
            if ( _tintColor )
            {
                _tintColor.length = 0;
                _tintColor = null;
            }

            if ( _maskColor )
            {
                _maskColor.length = 0;
                _maskColor = null;
            }

            super.dispose ();
        }

        override public function reset () : void
        {
            updatePass ();
        }

        [Inline] public function set blendMode ( value : String ) : void { _blendMode = value; }

        public function set tintColor ( value : Vector.<Number> ) : void
        {
            var multipler : Number = _premultiplyAlpha ? value[ 3 ] : 1.0;
            _tintColor[ 0 ] = value[ 0 ] * multipler;
            _tintColor[ 1 ] = value[ 1 ] * multipler;
            _tintColor[ 2 ] = value[ 2 ] * multipler;
            _tintColor[ 3 ] = value[ 3 ];
        }

        public function set maskColor ( value : Vector.<Number> ) : void
        {
            _maskColor[ 0 ] = value[ 0 ] * value[ 3 ];
            _maskColor[ 1 ] = value[ 1 ] * value[ 3 ];
            _maskColor[ 2 ] = value[ 2 ] * value[ 3 ];
            _maskColor[ 3 ] = 1.0 - value[ 3 ];
        }

        public function get hasTexture () : Boolean { return _mainTexture != null; }

        public function set uvAnimationEnable( enable:Boolean):void
        {
            if(_uvAnimationEnable != enable)
            {
                _uvAnimationEnable = enable;
                updatePass();
            }
        }

        public function updateOffsetUV ( offsetU : Number = 0.0, offsetV : Number = 0.0 ) : void
        {
            _offsetUV[ 0 ] = offsetU;
            _offsetUV[ 1 ] = offsetV;
        }

        public function updateTiling ( tilingX : int = 0, tilingY : int = 0, offsetX : Number = 0.0, offsetY : Number = 0.0 ) : void
        {
            _tilingParams[ 0 ] = tilingX;
            _tilingParams[ 1 ] = tilingY;
            _tilingParams[ 2 ] = offsetX;
            _tilingParams[ 3 ] = offsetY;
        }

        public function updateMargin ( marginX : Number = 0.01, marginY : Number = 0.01 ) : void
        {
            _marginParams[ 0 ] = marginX * _tilingParams[ 0 ];
            _marginParams[ 1 ] = _tilingParams[ 0 ] - _marginParams[ 0 ];
            _marginParams[ 2 ] = marginY * _tilingParams[ 1 ];
            _marginParams[ 3 ] = _tilingParams[ 1 ] - _marginParams[ 2 ];
        }

        override public function update () : void { updatePass (); }

        public function equal ( other : IMaterial ) : Boolean
        {
            if ( other == null ) return false;
            var otherAlias : MSprite = other as MSprite;
            if ( otherAlias == null )
            {
                return false;
            }

            if ( !super.innerEqual ( otherAlias ) )
                return false;

            if ( _blendMode != otherAlias._blendMode )
                return false;

            if ( hasTexture )
            {
                for ( var i : int = 0; i < 4; ++i )
                {
                    if ( _tintColor[ i ] != otherAlias._tintColor[ i ] )
                    {
                        return false;
                    }
                    if ( _maskColor[ i ] != otherAlias._maskColor[ i ] )
                    {
                        return false;
                    }
                }
            }

            if ( _uvAnimationEnable )
            {
                for ( i = 0; i < 4; ++i )
                {
                    if ( _offsetUV[ i ] != otherAlias._offsetUV[ i ] ) return false;
                    if ( _marginParams[ i ] != otherAlias._marginParams[ i ]) return false;
                    if ( _tilingParams[ i ] != otherAlias._tilingParams[ i ] ) return false;
                }
            }
            return true;
        }

        protected function updatePass () : void
        {
            setAllPassEnable ( false );
            if ( _mainTexture == null )
            {
                if ( _passes[ 1 ] == null )
                {
                    var passSimple : PSpriteSimple = new PSpriteSimple ();
                    passSimple.tintColor = _tintColor;
                    passSimple.maskColor = _maskColor;
                    _passes[ 1 ] = passSimple;
                }
                if ( _blendMode != null ) _passes[ 1 ].blendMode = _blendMode;
                _passes[ 1 ].pma = this.pma;
                _passes[ 1 ].enable = true;
            }
            else if ( _uvAnimationEnable )
            {
                var passUVAnimation : PUVAnimation = _passes[ 2 ] as PUVAnimation;
                if ( passUVAnimation == null )
                {
                    passUVAnimation = new PUVAnimation();
                    passUVAnimation.tintColor = _tintColor;
                    passUVAnimation.maskColor = _maskColor;
                    _passes[ 2 ] = passUVAnimation;
                }
                _passes[ 2 ].mainTexture = this.mainTexture;
                if ( _blendMode != null ) _passes[ 2 ].blendMode = _blendMode;
                _passes[ 2 ].pma = this.pma;
                passUVAnimation.setUVParams ( _offsetUV );
                passUVAnimation.setTilingParams ( _tilingParams );
                passUVAnimation.setMarginParams ( _marginParams );
                _passes[ 2 ].enable = true;
            }
            else
            {
                if ( _passes[ 0 ] == null )
                {
                    var passTint : PColorSpriteTint = new PColorSpriteTint ();
                    passTint.tintColor = _tintColor;
                    passTint.maskColor = _maskColor;
                    _passes[ 0 ] = passTint;
                }
                _passes[ 0 ].mainTexture = this.mainTexture;
                if ( _blendMode != null ) _passes[ 0 ].blendMode = _blendMode;
                _passes[ 0 ].pma = this.pma;
                _passes[ 0 ].enable = true;
            }
        }
    }
}