/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Materials
{
    import QFLib.QEngine.Renderer.Material.IMaterial;
    import QFLib.QEngine.Renderer.Material.Passes.PCompositorColorGrading;
    import QFLib.QEngine.Renderer.Textures.Texture;

    public class MCompositorColorGrading extends MaterialBase implements IMaterial
    {
        public function MCompositorColorGrading()
        {
            super( 1 );

            _passColorGrading = new PCompositorColorGrading();
            _inactivePasses.add( PCompositorColorGrading.sName, _passColorGrading );
            _passes[ 0 ] = _passColorGrading;
        }
        private var _passColorGrading : PCompositorColorGrading;

        override public function set texture( value : Texture ) : void
        {
            super.texture = value;
            _passes[ 0 ].texture = value;
        }

        public function get colorGrading() : Texture
        {
            return _passColorGrading.colorGrading;
        }

        public function set colorGrading( value : Texture ) : void
        {
            _passColorGrading.colorGrading = value;
        }

        public function equal( other : IMaterial ) : Boolean
        {
            var otherAlias : MCompositorColorGrading = other as MCompositorColorGrading;
            if( otherAlias == null ) return false;

            return super.innerEqual( otherAlias );
        }

        public function copySingleton() : IMaterial
        {
            return this;
        }
    }
}
