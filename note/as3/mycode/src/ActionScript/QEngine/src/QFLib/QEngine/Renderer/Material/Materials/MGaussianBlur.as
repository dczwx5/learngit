/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2016/11/30.
 */

package QFLib.QEngine.Renderer.Material.Materials
{
    import QFLib.QEngine.Renderer.Material.IMaterial;
    import QFLib.QEngine.Renderer.Material.Passes.PGaussianBlur;
    import QFLib.QEngine.Renderer.Textures.Texture;

    public class MGaussianBlur extends MaterialBase implements IMaterial
    {
        public function MGaussianBlur()
        {
            super( 1 );

            _inactivePasses.add( PGaussianBlur.sName, _passGaussianBlur );
            _passGaussianBlur.uvExpand = _uvExpand;
            _passGaussianBlur.weights = _weights;
            _passGaussianBlur.centerWeightAndOffsets = _centerWeightExAndOffsets;
            _passes[ 0 ] = _passGaussianBlur;
        }
        private var _passGaussianBlur : PGaussianBlur = new PGaussianBlur();
        private var _centerWeightExAndOffsets : Vector.<Number> = new Vector.<Number>( 4 );

        override public function set texture( value : Texture ) : void
        {
            super.texture = value;
            _passes[ 0 ].texture = value;
        }

        private var _uvExpand : Vector.<Number> = new Vector.<Number>( 4 );

        public function set uvExpand( value : Vector.<Number> ) : void
        {
            for( var i : int = 0; i < 4; i++ )
            {
                _uvExpand[ i ] = value[ i ];
            }
        }

        private var _weights : Vector.<Number> = new Vector.<Number>( 4 );

        public function set weights( value : Vector.<Number> ) : void
        {
            for( var i : int = 0; i < 4; i++ )
            {
                _weights[ i ] = value[ i ];
            }
        }

        public function set centerWeightAndOffsets( value : Vector.<Number> ) : void
        {
            for( var i : int = 0; i < 4; i++ )
            {
                _centerWeightExAndOffsets[ i ] = value[ i ];
            }
        }

        override public function dispose() : void
        {
            super.dispose();
        }

        public function equal( other : IMaterial ) : Boolean
        {
            var otherAlias : MGaussianBlur = other as MGaussianBlur;
            if( otherAlias == null ) return false;

            return super.innerEqual( otherAlias );
        }

        public function copySingleton() : IMaterial
        {
            return this;
        }
    }
}
