/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Passes
{
    import QFLib.QEngine.Renderer.Device.RenderDevice;
    import QFLib.QEngine.Renderer.Material.BlendMode;
    import QFLib.QEngine.Renderer.Material.IFragmentShader;
    import QFLib.QEngine.Renderer.Material.IPass;
    import QFLib.QEngine.Renderer.Material.IVertexShader;
    import QFLib.QEngine.Renderer.Material.Shaders.ShaderLib;
    import QFLib.QEngine.Renderer.Textures.Texture;

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
        protected var _premultiplyAlpha : Boolean = false;
        protected var _texDirty : Boolean = true;
        protected var _passName : String = null;

        protected var _renderTarget : Texture = null;

        public function get renderTarget() : Texture
        {
            return _renderTarget;
        }

        public function set renderTarget( value : Texture ) : void
        {
            _renderTarget = value;
        }

        protected var _blendMode : String = BlendMode.NORMAL;

        public function get blendMode() : String
        {
            return _blendMode;
        }

        public function set blendMode( value : String ) : void
        {
            _blendMode = value;
        }

        protected var _texFlagList : Vector.<String> = new Vector.<String>();

        public function get texFlagList() : Vector.<String>
        {
            if( _texDirty )
            {
                updateInfo();
                _texDirty = false;
            }

            return _texFlagList;
        }

        protected var _shaderName : Number;

        public function get shaderName() : Number
        {
            if( _texDirty )
            {
                updateInfo();
                _texDirty = false;
            }

            return _shaderName;
        }

        public function get name() : String
        {
            return _passName;
        }

        public function get vertexShader() : String
        {
            return null;
        }

        public function get fragmentShader() : String
        {
            return null;
        }

        public function get pma() : Boolean
        {
            return _premultiplyAlpha;
        }

        public function set pma( value : Boolean ) : void
        {
            _premultiplyAlpha = value;
        }

        public function get srcOp() : String
        {
            return Context3DBlendFactor.SOURCE_ALPHA;
        }

        public function get dstOp() : String
        {
            return Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
        }

        public function get usingRTT() : Boolean
        {
            return _renderTarget != null;
        }

        public function set texture( value : Texture ) : void
        {
        }

        public function dispose() : void
        {
            _renderTarget = null;
            _textures = null;
            _vectors = null;
            _matrixs = null;
            _blendMode = null;

            if( _texFlagList )
            {
                _texFlagList.length = 0;
                _texFlagList = null;
            }
        }

        public function equal( other : IPass ) : Boolean
        {
            var otherAlias : PassBase = other as PassBase;
            if( otherAlias != null ) return innerEqual( otherAlias );
            else return false;
        }

        public function copy( other : IPass ) : void
        {
            var otherAlias : PassBase = other as PassBase;
            if( otherAlias != null ) innerCopyFrom( otherAlias );
        }

        public function getVector( name : String ) : Vector.<Number>
        {
            if( name in _vectors )
                return _vectors[ name ];
            return null;
        }

        public function getMatrix( name : String ) : Matrix3D
        {
            if( name in _matrixs )
                return _matrixs[ name ];
            return null;
        }

        public function getTexture( name : String ) : Texture
        {
            if( name in _textures )
                return _textures[ name ];
            return null;
        }

        public function setVector( name : String, value : Vector.<Number> ) : Boolean
        {
            var v : Vector.<Number>;
            var reset : Boolean;
            if( name in _vectors )
            {
                v = _vectors[ name ];
                reset = true;
            }
            else
            {
                v = createVector( name );
                reset = false;
            }

            if( value )
            {
                for( var i : int = 0; i < 4; ++i )
                {
                    v[ i ] = value[ i ];
                }
            }
            return reset;
        }

        public function setMatrix( name : String, value : Matrix3D ) : Boolean
        {
            var m : Matrix3D;
            var reset : Boolean;
            if( name in _matrixs )
            {
                m = _matrixs[ name ];
                reset = true;
            }
            else
            {
                m = createMatrix( name );
                reset = false;
            }
            if( value )
                m.copyFrom( value );
            return reset;
        }

        [inline]
        public function setTexture( name : String, texture : Texture ) : void
        {
            if( !_textures.hasOwnProperty( name ) || _textures[ name ] != texture )
            {
                _textures[ name ] = texture;
                _texDirty = true;
            }
        }

        public function registerVector( name : String, param : Vector.<Number> ) : void
        {
            _vectors[ name ] = param;
        }

        public function registerMatrix( name : String, param : Matrix3D ) : void
        {
            _matrixs[ name ] = param;
        }

        public function createVector( name : String, size : int = 4 ) : Vector.<Number>
        {
            _vectors[ name ] = new Vector.<Number>( size );
            return _vectors[ name ];
        }

        public function createMatrix( name : String ) : Matrix3D
        {
            var matrix : Matrix3D = new Matrix3D();
            matrix.identity();
            _matrixs[ name ] = matrix;
            return matrix;
        }

        public function clone() : IPass
        {
            return null;
        }

        protected function innerEqual( other : PassBase ) : Boolean
        {
            return ( _blendMode == other._blendMode
            && _premultiplyAlpha == other._premultiplyAlpha
            && vertexShader == other.vertexShader
            && fragmentShader == other.fragmentShader );
        }

        protected function innerCopyFrom( other : PassBase ) : void
        {
            this._blendMode = other._blendMode;
            this._premultiplyAlpha = other._premultiplyAlpha;
        }

        private function updateInfo() : void
        {
            //设置shader和参数
            var vertShader : IVertexShader = ShaderLib.getVertex( this.vertexShader );
            var fragShader : IFragmentShader = ShaderLib.getFragment( this.fragmentShader );

            if( vertShaderArr.indexOf( vertShader.name ) == -1 )
            {
                vertShaderArr.push( vertShader.name );
            }
            var v : int = vertShaderArr.indexOf( vertShader.name );

            if( fragShaderArr.indexOf( fragShader.name ) == -1 )
            {
                fragShaderArr.push( fragShader.name );
            }
            var f : int = fragShaderArr.indexOf( fragShader.name );
            var num : int = 10;
            _shaderName = v + f * num;

            var numTexture : int = fragShader.textureLayout.length;
            _texFlagList.length = numTexture;

            var i : int = 0;
            var texture : Texture;
            var texFlagListName : String;
            var s : int;
            for( ; i < numTexture; ++i )
            {
                texture = getTexture( fragShader.textureLayout[ i ].name );
                if( texture == null )
                {
                    throw new Error( "fragment shader : ["
                            + fragShader.name
                            + "] from material cannot read texture:["
                            + fragShader.textureLayout[ i ].name
                            + "]"
                    );
                    continue;
                }
                _texFlagList[ i ] = RenderDevice.getTextureLookupFlags(
                        texture.format,
                        texture.mipMapping,
                        texture.repeat
                );

                texFlagListName = RenderDevice.getTextureLookupFlags(
                        texture.format,
                        texture.mipMapping,
                        texture.repeat
                );
                _texFlagList[ i ] = texFlagListName;
                if( texFlagListArr.indexOf( texFlagListName ) == -1 )
                {
                    texFlagListArr.push( texFlagListName );
                }
                s = texFlagListArr.indexOf( texFlagListName );
                num *= 10;
                _shaderName += s * num;
            }
        }
    }
}