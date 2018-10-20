package QFLib.Graphics.RenderCore.render.pass
{
    import QFLib.Graphics.RenderCore.render.IFragmentShader;
    import QFLib.Graphics.RenderCore.render.IPass;
    import QFLib.Graphics.RenderCore.render.IVertexShader;
    import QFLib.Graphics.RenderCore.render.shader.FBase;
    import QFLib.Graphics.RenderCore.render.shader.ShaderLib;
    import QFLib.Graphics.RenderCore.starling.core.RenderSupport;
    import QFLib.Graphics.RenderCore.starling.display.BlendMode;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;

    import flash.display3D.Context3DBlendFactor;
    import flash.geom.Matrix3D;

    public class PassBase
    {
        private static var vertShaderArr : Array = [];
        private static var fragShaderArr : Array = [];
        private static var texFlagListArr : Array = [];

        protected var _textures : Object = new Object;
        protected var _vectors : Object = new Object;
        protected var _matrixs : Object = new Object;
        protected var _texFlagList : Vector.<String> = new Vector.<String> ();
        protected var _passName : String = null;
        protected var _blendMode : String = BlendMode.NORMAL;
        protected var _shaderName : Number;
        protected var _texDirty : Boolean = true;
        protected var _premultiplyAlpha : Boolean = false;

        protected var _renderTarget : Texture = null;

        public function PassBase ()
        {}

        public function dispose () : void
        {
            _renderTarget = null;
            _textures = null;
            _vectors = null;
            _matrixs = null;
            _blendMode = null;
            _passName = null;

            if ( _texFlagList )
            {
                _texFlagList.length = 0;
                _texFlagList = null;
            }
        }

        [Inline]
        public function get renderTarget () : Texture
        { return _renderTarget; }

        [Inline]
        public function set renderTarget ( value : Texture ) : void
        { _renderTarget = value; }

        public function get texFlagList () : Vector.<String>
        {
            if ( _texDirty )
            {
                updateInfo ();
                _texDirty = false;
            }

            return _texFlagList;
        }

        [Inline]
        public function get blendMode () : String
        { return _blendMode; }

        [Inline]
        public function set blendMode ( value : String ) : void
        { _blendMode = value; }

        public function get shaderName () : Number
        {
            if ( _texDirty )
            {
                updateInfo ();
                _texDirty = false;
            }

            return _shaderName;
        }

        protected var _enable : Boolean = false;

        [Inline]
        public function get enable () : Boolean
        { return _enable; }

        [Inline]
        public function set enable ( value : Boolean ) : void
        { _enable = value; }

        [Inline]
        public function get name () : String
        { return _passName; }

        [Inline]
        public function get vertexShader () : String
        { return null; }

        [Inline]
        public function get fragmentShader () : String
        { return null; }

        [Inline]
        public function get pma () : Boolean
        { return _premultiplyAlpha; }

        [Inline]
        public function set pma ( value : Boolean ) : void
        { _premultiplyAlpha = value; }

        [Inline]
        public function get srcOp () : String
        { return Context3DBlendFactor.SOURCE_ALPHA; }

        [Inline]
        public function get dstOp () : String
        { return Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA; }

        [Inline]
        public function get usingRTT () : Boolean
        { return _renderTarget != null; }

        [Inline]
        public function get isClearRT () : Boolean
        { return true; }

        [Inline]
        public function set mainTexture ( value : Texture ) : void
        {
            if ( value != null )
            {
                setTexture ( FBase.mainTexture, value );
            }
        }

        public function equal ( other : IPass ) : Boolean
        {
            var otherAlias : PassBase = other as PassBase;
            if ( otherAlias != null ) return innerEqual ( otherAlias );
            else return false;
        }

        public function copy ( other : IPass ) : void
        {
            var otherAlias : PassBase = other as PassBase;
            if ( otherAlias != null ) innerCopyFrom ( otherAlias );
        }

        public function clone () : IPass { return null; }

        [Inline]
        public function getVector ( name : String ) : Vector.<Number>
        {
            if ( name in _vectors )
                return _vectors[ name ];
            return null;
        }

        [Inline]
        public function getMatrix ( name : String ) : Matrix3D
        {
            if ( name in _matrixs )
                return _matrixs[ name ];
            return null;
        }

        [Inline]
        public function getTexture ( name : String ) : Texture
        {
            if ( name in _textures )
                return _textures[ name ];
            return null;
        }

        [Inline]
        public function setVector ( name : String, value : Vector.<Number> ) : Boolean
        {
            var v : Vector.<Number>;
            var reset : Boolean;
            if ( name in _vectors )
            {
                v = _vectors[ name ];
                reset = true;
            }
            else
            {
                v = createVector ( name );
                reset = false;
            }

            if ( value )
            {
                for ( var i : int = 0; i < 4; ++i )
                {
                    v[ i ] = value[ i ];
                }
            }
            return reset;
        }

        public function setMatrix ( name : String, value : Matrix3D ) : Boolean
        {
            var m : Matrix3D;
            var reset : Boolean;
            if ( name in _matrixs )
            {
                m = _matrixs[ name ];
                reset = true;
            }
            else
            {
                m = createMatrix ( name );
                reset = false;
            }
            if ( value )
                m.copyFrom ( value );
            return reset;
        }

        [Inline]
        public function setTexture ( name : String, texture : Texture ) : void
        {
            if ( !_textures.hasOwnProperty ( name ) || _textures[ name ] != texture )
            {
                _textures[ name ] = texture;
                _texDirty = true;
            }
        }

        [Inline]
        public function registerVector ( name : String, param : Vector.<Number> ) : void
        { _vectors[ name ] = param; }

        [Inline]
        public function registerMatrix ( name : String, param : Matrix3D ) : void
        { _matrixs[ name ] = param; }

        [Inline]
        public function createVector ( name : String, size : int = 4 ) : Vector.<Number>
        {
            _vectors[ name ] = new Vector.<Number> ( size );
            return _vectors[ name ];
        }

        [Inline]
        public function createMatrix ( name : String ) : Matrix3D
        {
            var matrix : Matrix3D = new Matrix3D ();
            matrix.identity ();
            _matrixs[ name ] = matrix;
            return matrix;
        }

        protected function innerEqual ( other : PassBase ) : Boolean
        {
            return ( _blendMode == other._blendMode
            && _premultiplyAlpha == other._premultiplyAlpha
            && vertexShader == other.vertexShader
            && fragmentShader == other.fragmentShader
            && _enable == other._enable );
        }

        protected function innerCopyFrom ( other : PassBase ) : void
        {
            this._enable = other._enable;
            this._blendMode = other._blendMode;
            this._premultiplyAlpha = other._premultiplyAlpha;
        }

        private function updateInfo () : void
        {
            //设置shader和参数
            var vertShader : IVertexShader = ShaderLib.getVertex ( this.vertexShader );
            var fragShader : IFragmentShader = ShaderLib.getFragment ( this.fragmentShader );

            if ( vertShaderArr.indexOf ( vertShader.name ) == -1 )
            {
                vertShaderArr.push ( vertShader.name );
            }
            var v : int = vertShaderArr.indexOf ( vertShader.name );

            if ( fragShaderArr.indexOf ( fragShader.name ) == -1 )
            {
                fragShaderArr.push ( fragShader.name );
            }
            var f : int = fragShaderArr.indexOf ( fragShader.name );
            var num : int = 10;
            _shaderName = v + f * num;

            var numTexture : int = fragShader.textureLayout.length;
            _texFlagList.length = numTexture;

            var i : int = 0;
            var texture : Texture;
            var texFlagListName : String;
            var s : int;
            for ( ; i < numTexture; ++i )
            {
                texture = getTexture ( fragShader.textureLayout[ i ].name );
                if ( texture == null )
                {
                    throw new Error ( "fragment shader : ["
                            + fragShader.name
                            + "] from material cannot read texture:["
                            + fragShader.textureLayout[ i ].name
                            + "]"
                    );
                    continue;
                }
                _texFlagList[ i ] = RenderSupport.getTextureLookupFlags (
                        texture.format,
                        texture.mipMapping,
                        texture.repeat
                );

                texFlagListName = RenderSupport.getTextureLookupFlags (
                        texture.format,
                        texture.mipMapping,
                        texture.repeat
                );
                _texFlagList[ i ] = texFlagListName;
                if ( texFlagListArr.indexOf ( texFlagListName ) == -1 )
                {
                    texFlagListArr.push ( texFlagListName );
                }
                s = texFlagListArr.indexOf ( texFlagListName );
                num *= 10;
                _shaderName += s * num;
            }
        }
    }
}