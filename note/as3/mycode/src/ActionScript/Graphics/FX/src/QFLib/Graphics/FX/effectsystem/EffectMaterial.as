package QFLib.Graphics.FX.effectsystem
{

    import QFLib.Foundation.CPath;
    import QFLib.Graphics.RenderCore.render.IMaterial;
    import QFLib.Graphics.RenderCore.render.material.MParticle;
	import QFLib.Graphics.RenderCore.starling.textures.SubTexture;
	import QFLib.Graphics.RenderCore.starling.textures.Texture;
    import QFLib.Math.CMath;
	import QFLib.Utils.Quality;
	import QFLib.Utils.Quality;

	import flash.display3D.Context3DBlendFactor;
	import flash.geom.Rectangle;

	public class EffectMaterial
    {
        public static const NONE : int = 0;
        public static const ROT90 : int = 1;
        public static const ROT180 : int = 2;
        public static const ROT270 : int = 3;

        public var shader : String = "QFX/Additive";
        public var textureName : String;
        public var tintColor : Vector.<Number> = Vector.<Number> ( [ 0.5, 0.5, 0.5, 1.0 ] );
        public var isTiling : Boolean = false;
        public var tileLoop : int = 1;
        public var textureAnimation : Boolean = false;
        public var flipX : Boolean = false;
        public var flipY : Boolean = false;
        public var textureRegion : Rectangle;
        public var isRotate : Boolean = false;

        private var _uvList : Vector.<Number> = new Vector.<Number> ();
        private var _material : MParticle = new MParticle ();
        private var _orginalTintColor : Vector.<Number> = Vector.<Number> ( [ 0.5, 0.5, 0.5, 1.0 ] );
        private var _orignalMaskColor : Vector.<Number> = Vector.<Number> ( [ 0.0, 0.0, 0.0, 1.0 ] );
        private var _maskColor : Vector.<Number> = Vector.<Number> ( [ 0.0, 0.0, 0.0, 0.0 ] );
        private var _objectAlpha : Number = 1.0;
        private var _tintAlpha : Number = 1.0;

        private var _rCos : Number = 1;
        private var _rSin : Number = 0;
        private var _tileX : int = 1;
        private var _tileY : int = 1;
        private var _tileIndexInUVlist : int = 0;                   //index of first point of the tile that it is one of four point of tile
        private var _tileCount : int = 1;
        private var _rotation : int = NONE;
        private var _tileLoopCount : int = 1;
        private var _tileDirty : Boolean = true;
        private var _tintColorDirty : Boolean = false;

        public function dispose () : void
        {
            tintColor.fixed = false;
            tintColor.length = 0;
            tintColor = null;
            _orginalTintColor.fixed  = false;
            _orginalTintColor.length = 0;
            _orginalTintColor = null;

            _maskColor.fixed = false;
            _maskColor.length = 0;
            _maskColor = null;
            _orignalMaskColor.fixed = false;
            _orignalMaskColor.length = 0;
            _orignalMaskColor = null;

            _uvList.fixed = false;
            _uvList.length = 0;
            _uvList = null;

            textureRegion = null;

            _material.dispose ();
        }

        [Inline] final public function get tileX () : int { return _tileX; }

        public function set tileX ( value : int ) : void
        {
            if ( _tileX != value && value > 0 )
            {
                _tileX = value;
                _tileDirty = true;
            }
        }

        [Inline] final public function get tileY () : int { return _tileY; }

        public function set tileY ( value : int ) : void
        {
            if ( _tileY != value && value > 0 )
            {
                _tileY = value;
                _tileDirty = true;
            }
        }

        public function set tileID ( value : int ) : void
        {
            if ( value < 0 || value >= _tileX * _tileY ) _tileIndexInUVlist = 0;
            else _tileIndexInUVlist = value * 8;
        }

        [Inline] final public function get rotation () : int { return _rotation; }

        [Inline] final public function get texture () : Texture
        {
            return _material.mainTexture;
        }

        [Inline] public function set texture ( value : Texture ) : void
        {
            _material.mainTexture = value;
            _material.pma = value.premultipliedAlpha;

            if ( shader == "QFX/Blend" )
            {
                _material.srcOp = Context3DBlendFactor.SOURCE_ALPHA;
                _material.dstOp = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
            }
            else
            {
                _material.srcOp = Context3DBlendFactor.SOURCE_ALPHA;
                _material.dstOp = Context3DBlendFactor.ONE;
            }

            if(Quality.useFxAtlas)
            {
                updateTileTable();
            }
        }

        [Inline] final public function get concreteMaterial () : IMaterial { return _material;  }

        [Inline] final public function get uvList () : Vector.<Number> { return _uvList; }

        [Inline] final public function getUVOffsetByTileID ( tileID : int ) : int { return tileID * 8; }

        [Inline] final public function getUVOffsetByNormalLife ( normalLife : Number ) : int { return textureAnimation ? getTileIndex ( normalLife ) : _tileIndexInUVlist; }

        [Inline] final public function getUVOffsetByIndexInUVList () : int { return _tileIndexInUVlist; }

        public function setColor ( r : Number, g : Number, b : Number, alpha : Number, masking : Boolean ) : void
        {
            if ( masking )
            {
                _maskColor[ 0 ] = r;
                _maskColor[ 1 ] = g;
                _maskColor[ 2 ] = b;
                _maskColor[ 3 ] = alpha;
            }
            else
            {
                tintColor[ 0 ] = r;
                tintColor[ 1 ] = g;
                tintColor[ 2 ] = b;
                tintColor[ 3 ] = _tintAlpha = alpha;
            }

            _material.tintColor = tintColor;
            _material.maskColor = _maskColor;
            _tintColorDirty = true;
        }

        public function resetColor () : void
        {
            if ( !_tintColorDirty ) return;

            tintColor[ 0 ] = _orginalTintColor[ 0 ];
            tintColor[ 1 ] = _orginalTintColor[ 1 ];
            tintColor[ 2 ] = _orginalTintColor[ 2 ];
            _tintAlpha = tintColor[ 3 ] = _orginalTintColor[ 3 ];

            _maskColor[ 0 ] = _orignalMaskColor[ 0 ];
            _maskColor[ 1 ] = _orignalMaskColor[ 1 ];
            _maskColor[ 2 ] = _orignalMaskColor[ 2 ];
            _maskColor[ 3 ] = _orignalMaskColor[ 3 ];

            _material.tintColor = tintColor;
            _material.maskColor = _maskColor;
            _tintColorDirty = false;
        }

        public function set rotation ( value : int ) : void
        {
            if ( _rotation != value )
            {
                _rotation = value;
                _tileDirty = true;
                switch ( value )
                {
                    case NONE:
                        _rCos = 1;
                        _rSin = 0;
                        break;
                    case ROT90:
                        _rCos = 0;
                        _rSin = 1;
                        break;
                    case ROT180:
                        _rCos = -1;
                        _rSin = 0;
                        break;
                    case ROT270:
                        _rCos = 0;
                        _rSin = -1;
                        break;
                    default:
                        break;
                }
            }
        }

        public function getTileIndex ( normalLife : Number ) : int
        {
            var index : int = Math.floor ( normalLife * _tileLoopCount );
            return ( index % _tileCount ) * 8;
        }

        public function updateMaterial ( alpha : Number ) : void
        {
            updateTileTable ();

            if ( Math.abs ( alpha - _objectAlpha ) > CMath.EPSILON )
            {
                _objectAlpha = alpha;

                tintColor[ 3 ] = _objectAlpha * _tintAlpha;
                _material.tintColor = tintColor;
            }
        }

        public function loadFromObject ( data : Object ) : void
        {
            this.shader = data.shader;
            this.textureName = CPath.driverDirName ( data.texture );
            this.isTiling = data.isTiling;
            this.tileLoop = data.tileLoop <= 0 ? 1 : data.tileLoop;
            this.tileX = data.tileX;
            this.tileY = data.tileY;
            this.tileID = data.tileID;
            this.textureAnimation = data.textureAnimation;

            if ( data.hasOwnProperty ( "flipX" ) )
                this.flipX = data.flipX;

            if ( data.hasOwnProperty ( "flipY" ) )
                this.flipY = data.flipY;

            tintColor[ 0 ] = data.tintColor.r;
            tintColor[ 1 ] = data.tintColor.g;
            tintColor[ 2 ] = data.tintColor.b;
            tintColor[ 3 ] = _tintAlpha = data.tintColor.a;

            this.rotation = data.rotation;

            //blend mode
            if ( shader == "QFX/Blend" )
            {
                _material.srcOp = Context3DBlendFactor.SOURCE_ALPHA;
                _material.dstOp = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
            }
            else
            {
                _material.srcOp = Context3DBlendFactor.SOURCE_ALPHA;
                _material.dstOp = Context3DBlendFactor.ONE;
            }

            var masking : Boolean = false;
            if ( data.hasOwnProperty ( "colorMasking" ) )
            {
                masking = data.colorMasking;
                if ( !data.hasOwnProperty ( "maskColor" ) && masking )
                {
                    _maskColor[ 0 ] = tintColor[ 0 ];
                    _maskColor[ 1 ] = tintColor[ 1 ];
                    _maskColor[ 2 ] = tintColor[ 2 ];
                    _maskColor[ 3 ] = tintColor[ 3 ];
                }
            }

            var useOnlyMaskColor : Boolean = false;
            if ( data.hasOwnProperty ( "useOnlyMask" ) )
            {
                useOnlyMaskColor = data.useOnlyMask;
            }

            if ( data.hasOwnProperty ( "maskColor" ) )
            {
                _maskColor[ 0 ] = data.maskColor.r;
                _maskColor[ 1 ] = data.maskColor.g;
                _maskColor[ 2 ] = data.maskColor.b;
                _maskColor[ 3 ] = data.maskColor.a;
            }

            if ( useOnlyMaskColor )
            {
                tintColor[ 0 ] = tintColor[ 1 ] = tintColor[ 2 ] = 0.0;
                tintColor[ 3 ] = _maskColor[ 3 ];
            }

            if ( !masking )
                _maskColor[ 3 ] = 0.0;

            _orignalMaskColor[ 0 ] = _maskColor[ 0 ];
            _orignalMaskColor[ 1 ] = _maskColor[ 1 ];
            _orignalMaskColor[ 2 ] = _maskColor[ 2 ];
            _orignalMaskColor[ 3 ] = _maskColor[ 3 ];

            _orginalTintColor[ 0 ] = tintColor[ 0 ];
            _orginalTintColor[ 1 ] = tintColor[ 1 ];
            _orginalTintColor[ 2 ] = tintColor[ 2 ];
            _orginalTintColor[ 3 ] = tintColor[ 3 ];

            _material.tintColor = tintColor;
            _material.maskColor = _maskColor;

            _tileDirty = true;
        }

        private function updateTileTable () : void
        {
            if ( !_tileDirty || (Quality.useFxAtlas && !textureRegion) ) return;

            _tileCount = tileX * tileY;
            _tileLoopCount = _tileCount * tileLoop;

            _uvList.fixed = false;
            _uvList.length = _tileCount * 8;        //8 = 4 * 2, 4-->four vertex, 2-->(u, v)
            _uvList.fixed = true;

            var tileSizeX : Number = 1.0 / tileX;
            var tileSizeY : Number = 1.0 / tileY;

            var xl : Number = flipX ? 0.5 : -0.5;
            var xr : Number = flipX ? -0.5 : 0.5;
            var yt : Number = flipY ? -0.5 : 0.5;
            var yb : Number = flipY ? 0.5 : -0.5;

            var centerX : Number = 0.5;
            var centerY : Number = 0.5;

            var lbx : Number = centerX + _rCos * xl + _rSin * yb;
            var lby : Number = centerY + _rCos * yb - _rSin * xl;
            var ltx : Number = centerX + _rCos * xl + _rSin * yt;
            var lty : Number = centerY + _rCos * yt - _rSin * xl;
            var rbx : Number = centerX + _rCos * xr + _rSin * yb;
            var rby : Number = centerY + _rCos * yb - _rSin * xr;
            var rtx : Number = centerX + _rCos * xr + _rSin * yt;
            var rty : Number = centerY + _rCos * yt - _rSin * xr;

            var texture:Texture = _material.mainTexture;
            var subU:Number = Quality.useFxAtlas? textureRegion.x/texture.width:0;
            var subV:Number = Quality.useFxAtlas?textureRegion.y/texture.height:0;
            var endU:Number = Quality.useFxAtlas?textureRegion.right/texture.width:1;
            var endV:Number = Quality.useFxAtlas?textureRegion.bottom/texture.height:1;
            for ( var i : int = 0; i < _tileCount; ++i )
            {
                var col : int = i % tileX;
                var row : int = i / tileX;

                var left : Number = col * tileSizeX;
                var bottom : Number = row * tileSizeY;

                var index : int = i * 8;
                if(!isRotate)
                {
                    _uvList[ index ] = (endU-subU)*(left + lbx * tileSizeX)+subU;
                    _uvList[ index + 1 ] = (endV-subV)*(bottom + lby * tileSizeY)+subV;

                    _uvList[ index + 2 ] = (endU-subU)*(left + rbx * tileSizeX)+subU;
                    _uvList[ index + 3 ] = (endV-subV)*(bottom + rby * tileSizeY)+subV;

                    _uvList[ index + 4 ] = (endU-subU)*(left + rtx * tileSizeX)+subU;
                    _uvList[ index + 5 ] = (endV-subV)*(bottom + rty * tileSizeY)+subV;

                    _uvList[ index + 6 ] = (endU-subU)*(left + ltx * tileSizeX)+subU;
                    _uvList[ index + 7 ] = (endV-subV)*(bottom + lty * tileSizeY)+subV;
                }
                else
                {
                    _uvList[ index ] = (endU-subU)*(1-bottom - lby * tileSizeY)+subU;
                    _uvList[ index + 1 ] = (endV-subV)*(left + lbx * tileSizeX)+subV;

                    _uvList[ index + 2 ] = (endU-subU)*(1-bottom - rby * tileSizeY)+subU;
                    _uvList[ index + 3 ] = (endV-subV)*(left + rbx * tileSizeX)+subV;

                    _uvList[ index + 4 ] = (endU-subU)*(1-bottom - rty * tileSizeY)+subU;
                    _uvList[ index + 5 ] = (endV-subV)*(left + rtx * tileSizeX)+subV;

                    _uvList[ index + 6 ] = (endU-subU)*(1-bottom - lty * tileSizeY)+subU;
                    _uvList[ index + 7 ] = (endV-subV)*(left - ltx * tileSizeX)+subV;
                }
            }

            _tileDirty = false;
        }
    }
}