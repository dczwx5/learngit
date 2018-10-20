/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Materials
{
    import QFLib.QEngine.Renderer.Material.IMaterial;
    import QFLib.QEngine.Renderer.Material.Passes.PColorSpriteTint;
    import QFLib.QEngine.Renderer.Material.Passes.PStride;
    import QFLib.QEngine.Renderer.Textures.Texture;

    public class MStride extends MaterialBase implements IMaterial
    {
        public function MStride()
        {
            super( 1 );
            _tint = false;

            _passStride = new PStride();
            _inactivePasses.add( PStride.sName, _passStride );
            _passes[ 0 ] = _passStride;
            _passStride.texture = texture;
            _orignalPass = _passStride;

            _passSpriteTint = new PColorSpriteTint();
            _inactivePasses.add( PColorSpriteTint.sName, _passSpriteTint );
        }
        private var _passStride : PStride = new PStride();
        private var _passSpriteTint : PColorSpriteTint;

        public override function set texture( value : Texture ) : void
        {
            super.texture = value;
            _passSpriteTint.texture = value;
            _passStride.texture = value;
        }

        private var _tint : Boolean;

        public function set tint( value : Boolean ) : void
        {
            _tint = value;
            if( _tint )
            {
                _passes[ 0 ] = _passSpriteTint;
                _orignalPass = _passSpriteTint;
            }
            else
            {
                _passes[ 0 ] = _passStride;
                _orignalPass = _passStride;
            }
        }

        public function set blendMode( value : String ) : void
        {
            _passSpriteTint.blendMode = value;
            _passStride.blendMode = value;
        }

        public function set tintColorAndAlpha( value : Vector.<Number> ) : void
        {
            if( _tint )
                _passSpriteTint.tintColor = value;
        }

        public override function dispose() : void
        {
            super.dispose();
        }

        public function equal( other : IMaterial ) : Boolean
        {
            var otherAlias : MStride = other as MStride;
            if( otherAlias == null )
            {
                return false;
            }

            if( !super.innerEqual( otherAlias ) )
            {
                return false;
            }

            return _tint == otherAlias._tint;
        }

        public function copySingleton() : IMaterial
        {
            return this;
        }
    }
}