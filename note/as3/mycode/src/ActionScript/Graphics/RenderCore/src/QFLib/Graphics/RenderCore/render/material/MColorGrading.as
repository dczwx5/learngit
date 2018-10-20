package QFLib.Graphics.RenderCore.render.material
{
    import QFLib.Graphics.RenderCore.render.IMaterial;
    import QFLib.Graphics.RenderCore.render.pass.PColorGrading;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;

    public class MColorGrading extends MaterialBase implements IMaterial
    {
        private var _passColorGrading : PColorGrading;

        public function MColorGrading ()
        {
            super ( 1 );

            _passColorGrading = new PColorGrading ();
            _passColorGrading.enable = true;
            _passes[ 0 ] = _passColorGrading;
        }

        public function equal ( other : IMaterial ) : Boolean
        {
            if ( other == null ) return false;
            var otherAlias : MColorGrading = other as MColorGrading;
            if ( otherAlias == null ) return false;

            return super.innerEqual ( otherAlias );
        }

        override public function reset () : void
        {
            setPassEnable ( _passColorGrading.name, true, true );
        }

        override public function set mainTexture ( value : Texture ) : void
        {
            super.mainTexture = value;
            _passes[ 0 ].mainTexture = value;
        }

        public function set colorGrading ( value : Texture ) : void
        {
            _passColorGrading.colorGrading = value;
        }

        public function get colorGrading () : Texture
        {
            return _passColorGrading.colorGrading;
        }
    }
}
