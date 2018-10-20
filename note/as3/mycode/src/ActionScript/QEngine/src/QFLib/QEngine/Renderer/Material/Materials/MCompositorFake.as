/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by xandy on 2015/9/7.
 */
package QFLib.QEngine.Renderer.Material.Materials
{
    import QFLib.QEngine.Renderer.Material.IMaterial;
    import QFLib.QEngine.Renderer.Material.Passes.PCompositorFake;
    import QFLib.QEngine.Renderer.Textures.Texture;

    public class MCompositorFake extends MaterialBase implements IMaterial
    {
        public function MCompositorFake()
        {
            super( 1 );

            _passFake = new PCompositorFake();
            _inactivePasses.add( PCompositorFake.sName, _passFake );
            _passes[ 0 ] = _passFake;
        }
        protected var _passFake : PCompositorFake;

        override public function set texture( value : Texture ) : void
        {
            super.texture = value;
            _passes[ 0 ].texture = value;
        }

        public function equal( other : IMaterial ) : Boolean
        {
            var otherAlias : MCompositorFake = other as MCompositorFake;
            if( otherAlias == null )
            {
                return false;
            }

            return super.innerEqual( otherAlias );
        }

        public function copySingleton() : IMaterial
        {
            return this;
        }
    }
}
