/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by xandy on 2015/9/11.
 */
package QFLib.QEngine.Renderer.Material.Materials
{
    import QFLib.QEngine.Renderer.Material.IMaterial;
    import QFLib.QEngine.Renderer.Material.Passes.PCompositorColorReplace;
    import QFLib.QEngine.Renderer.Textures.Texture;
    import QFLib.QEngine.Renderer.Utils.Util;

    public class MCompositorColorReplace extends MaterialBase implements IMaterial
    {
        public function MCompositorColorReplace()
        {
            super( 1 );

            _passColorReplace = new PCompositorColorReplace();
            _inactivePasses.add( PCompositorColorReplace.sName, _passColorReplace );
            _passColorReplace.colorMatrix = _colorMatrix;
            _passes[ 0 ] = _passColorReplace;
        }
        protected var _passColorReplace : PCompositorColorReplace;

        override public function set texture( value : Texture ) : void
        {
            super.texture = value;
            _passes[ 0 ].texture = value;
        }

        private var _colorMatrix : Vector.<Number> = new Vector.<Number>( 20 );

        public function set colorMatrix( value : Vector.<Number> ) : void
        {
            var count : int = value.length;
            for( var i : int = 0; i < count; ++i )
            {
                _colorMatrix[ i ] = value[ i ];
            }
        }

        public override function dispose() : void
        {
            super.dispose();
        }

        public function equal( other : IMaterial ) : Boolean
        {
            var otherAlias : MCompositorColorReplace = other as MCompositorColorReplace;
            if( otherAlias == null )
            {
                return false;
            }

            if( !super.innerEqual( otherAlias ) )
            {
                return false;
            }

            return Util.comapreNumberList( _colorMatrix, otherAlias._colorMatrix );
        }

        public function copySingleton() : IMaterial
        {
            return this;
        }

    }
}
