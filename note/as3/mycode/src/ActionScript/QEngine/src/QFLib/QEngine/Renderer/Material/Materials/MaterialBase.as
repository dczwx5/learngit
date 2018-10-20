/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Materials
{
    import QFLib.Foundation.CMap;
    import QFLib.QEngine.Renderer.Material.IMaterial;
    import QFLib.QEngine.Renderer.Material.IPass;
    import QFLib.QEngine.Renderer.Textures.Texture;

    public class MaterialBase
    {
        public function MaterialBase( passCount : int )
        {
            _passes = new Vector.<IPass>( passCount );
            _inactivePasses = new CMap();
        }
        protected var _premultiplyAlpha : Boolean = false;

        protected var _passes : Vector.<IPass>;

        [inline]
        public function get passes() : Vector.<IPass>
        { return _passes; }

        protected var _texture : Texture = null;

        public function get texture() : Texture
        {
            return _texture;
        }

        //材质结构需要大改，材质有默认拥有的pass和后期被添加的pass，应有所区别

        public function set texture( value : Texture ) : void
        {
            _texture = value;
        }

        protected var _parentAlpha : Number = 1.0;

        public function get parentAlpha() : Number
        {
            return _parentAlpha;
        }

        public function set parentAlpha( value : Number ) : void
        {
            _parentAlpha = value;
        }

        protected var _selfAlpha : Number = 1.0;

        public function get selfAlpha() : Number
        {
            return _selfAlpha * _parentAlpha;
        }

        public function set selfAlpha( value : Number ) : void
        {
            _selfAlpha = value;
        }

        protected var _inactivePasses : CMap;

        [inline]
        public function get inactivePasses() : CMap
        { return _inactivePasses; }

        protected var _orignalPass : IPass = null;

        [inline]
        public function get orignalPass() : IPass
        { return _orignalPass; }

        [inline]
        public function get isTransparent() : Boolean
        { return false; }

        [inline]
        public function get isShadowCaster() : Boolean
        { return false; }

        [inline]
        public function get isShadowReceiver() : Boolean
        { return false; }

        public function get pma() : Boolean
        {
            return _premultiplyAlpha;
        }

        public function set pma( value : Boolean ) : void
        {
            _premultiplyAlpha = value;
        }

        public function get alpha() : Number
        {
            return _selfAlpha * _parentAlpha;
        }

        public function get useTexcoord() : Boolean
        {
            return texture != null;
        }

        public function get useColor() : Boolean
        {
            return true;
        }

        public function dispose() : void
        {
            _passes.fixed = false;
            _passes.length = 0;
            _passes.fixed = true;
            _passes = null;

            _orignalPass = null;

            for each ( var pass : IPass in _inactivePasses )
            {
                pass.dispose();
                pass = null;
            }
            _inactivePasses.clear();

            _texture = null;
        }

        public function clone() : IMaterial { return null; }

        public function setPass( passName : String, firstPass : Boolean ) : String
        {
            var original : String = _passes[ 0 ].name;
            if( original != passName )
            {
                var pass : IPass = _inactivePasses.find( passName );
                if( pass != null )
                {
                    if( firstPass ) _passes[ 0 ] = pass;
                    else
                    {
                        _passes.fixed = false;
                        _passes.length += 1;
                        _passes.fixed = true;

                        _passes[ _passes.length - 1 ] = pass;
                    }

                    pass.texture = _texture;
                }
            }

            return original;
        }

        public function addInactivePass( pass : IPass ) : void
        {
            var clonePass : IPass = _inactivePasses.find( pass.name );
            if( clonePass == null )
            {
                clonePass = pass.clone();
                _inactivePasses.add( clonePass.name, clonePass );
            }
        }

        public function addInactivePassByName( passName : String, className : Class ) : IPass
        {
            var pass : IPass = _inactivePasses.find( passName );
            if( pass == null )
            {
                pass = new className();
                _inactivePasses.add( passName, pass );
            }

            return pass;
        }

        public function cleanInactivePasses() : void
        {
        }

        public function setTintColorWithAlpha( red : Number, green : Number, blue : Number, alpha : Number ) : void {}

        protected function innerEqual( other : MaterialBase ) : Boolean
        {
            if( this.passes.length != other.passes.length
                    || this.pma != other.pma
                    || this.parentAlpha != other.parentAlpha
                    || this.selfAlpha != other.selfAlpha )
            {
                return false;
            }

            for( var i : int = 0, count : int = passes.length; i < count; i++ )
            {
                if( !passes[ i ].equal( other.passes[ i ] ) ) return false;
            }

            if( this.texture && other.texture )
            {
                if( this.texture.base != other.texture.base )
                    return false;
            }
            else if( this.texture || other.texture )
            {
                return false;
            }
            return true;
        }

        protected function innerCopyFrom( other : MaterialBase ) : void
        {
            _premultiplyAlpha = other._premultiplyAlpha;
            _parentAlpha = other._parentAlpha;
            _selfAlpha = other._selfAlpha;
            _texture = other._texture;

            for each ( var p : IPass in other._inactivePasses )
            {
                var pass : IPass = _inactivePasses.find( p.name );
                if( pass == null ) _inactivePasses.add( p.name, p.clone() );
            }

            var name : String = null;
            var otherPass : IPass = null;
            _passes.fixed = false;
            _passes.length = other.passes.length;
            _passes.fixed = true;
            for( var i : int = 0, count : int = other.passes.length; i < count; i++ )
            {
                otherPass = other.passes[ i ];
                name = otherPass.name;
                _passes[ i ] = _inactivePasses.find( name );
                _passes[ i ].copy( otherPass );

                texture = other.texture;
            }
        }
    }
}