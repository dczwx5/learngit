/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Materials
{
    import QFLib.QEngine.Renderer.Material.IMaterial;
    import QFLib.QEngine.Renderer.Material.Passes.PWater;
    import QFLib.QEngine.Renderer.Textures.Texture;

    public class MWater extends MaterialBase implements IMaterial
    {
        public function MWater()
        {
            super( 1 );

            _passWater = new PWater();
            _inactivePasses.add( PWater.sName, _passWater );
            _passes[ 0 ] = _passWater;
            _orignalPass = _passWater;

            _passWater.reflectScaler = _reflectScaler;
            _passWater.waveScaler = _waveScaler;
            _passWater.reflectParam = _reflectParam;
            _passWater.waveParam = _waveParam;
            _passWater.turbParam = _turbParam;
            _passWater.waveColor = _waveColor;
        }
        private var _reflectScaler : Vector.<Number> = new Vector.<Number>( 4 );
        private var _waveScaler : Vector.<Number> = new Vector.<Number>( 4 );
        private var _reflectParam : Vector.<Number> = new Vector.<Number>( 4 );
        private var _waveParam : Vector.<Number> = new Vector.<Number>( 4 );
        private var _turbParam : Vector.<Number> = new Vector.<Number>( 4 );
        private var _passWater : PWater;

        private var _reflectTexture : Texture = null;

        public function get reflectTexture() : Texture
        {
            return _reflectTexture;
        }

        public function set reflectTexture( value : Texture ) : void
        {
            _reflectTexture = value;
            _passWater.reflectTexture = value;
        }

        private var _waveTexture : Texture = null;

        public function get waveTexture() : Texture
        {
            return _waveTexture;
        }

        public function set waveTexture( value : Texture ) : void
        {
            if( value )
            {
                value.repeat = true;
            }

            _waveTexture = value;
            _passWater.waveTexture = value;
        }

        private var _waveColor : Vector.<Number> = new Vector.<Number>( 4 );

        public function set waveColor( value : Vector.<Number> ) : void
        {
            for( var i : int = 0; i < 4; ++i ) _waveColor[ i ] = value[ i ];
        }

        public function set reflectTextureScaler( pair : Object ) : void
        {
            _reflectScaler[ 0 ] = pair.x;
            _reflectScaler[ 1 ] = pair.y;
            _reflectScaler[ 2 ] = 0.5 - 0.5 * pair.x;
            _reflectScaler[ 3 ] = 0.5 - 0.5 * pair.y;
        }

        public function set waveTextureScaler( pair : Object ) : void
        {
            _waveScaler[ 0 ] = pair.x * 5.0;
            _waveScaler[ 1 ] = pair.y * 2.0;
        }

        public function set reflectTurbOffset( pair : Object ) : void
        {
            _turbParam[ 0 ] = pair.x;
            _turbParam[ 1 ] = pair.y;
        }

        public function set reflectTurbScale( pair : Object ) : void
        {
            _waveParam[ 2 ] = pair.x;
            _waveParam[ 3 ] = pair.y;
        }

        public function set reflectTurbTimeScale( value : Number ) : void
        {
            _reflectParam[ 3 ] = value;
        }

        public function set waveOffset( value : Number ) : void
        {
            _waveParam[ 0 ] = value;
        }

        public function set waveTime( value : Number ) : void
        {
            _waveParam[ 1 ] = value;
        }

        public function set reflectTime( value : Number ) : void
        {
            _reflectParam[ 0 ] = value;
        }

        public function set reflectScale( value : Number ) : void
        {
            _reflectParam[ 1 ] = value;
        }

        public function set reflectSwing( value : Number ) : void
        {
            _reflectParam[ 2 ] = value;
        }

        public function set globalOffsetX( value : Number ) : void
        {
            _waveScaler[ 2 ] = value;
        }

        public function set globalOffsetY( value : Number ) : void
        {
            _waveScaler[ 3 ] = value;
        }

        public override function dispose() : void
        {
            super.dispose();
        }

        public function equal( other : IMaterial ) : Boolean
        {
            var otherAlias : MWater = other as MWater;
            if( otherAlias == null )
            {
                return false;
            }

            if( !super.innerEqual( otherAlias ) )
            {
                return false;
            }

            for( var i : int = 0; i < 4; ++i )
            {
                if( _reflectScaler[ i ] != otherAlias._reflectScaler[ i ] )
                {
                    return false;
                }

                if( _waveScaler[ i ] != otherAlias._waveScaler[ i ] )
                {
                    return false;
                }

                if( _reflectParam[ i ] != otherAlias._reflectParam[ i ] )
                {
                    return false;
                }

                if( _waveParam[ i ] != otherAlias._waveParam[ i ] )
                {
                    return false;
                }

                if( _turbParam[ i ] != otherAlias._turbParam[ i ] )
                {
                    return false;
                }

                if( _waveColor[ i ] != otherAlias._waveColor[ i ] )
                {
                    return false;
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