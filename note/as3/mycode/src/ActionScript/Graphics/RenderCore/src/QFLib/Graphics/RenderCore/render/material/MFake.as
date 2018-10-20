/**
 * Created by xandy on 2015/9/7.
 */
package QFLib.Graphics.RenderCore.render.material
{
    import QFLib.Graphics.RenderCore.render.IMaterial;
    import QFLib.Graphics.RenderCore.render.pass.PFake;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;

    public class MFake extends MaterialBase implements IMaterial
    {
        protected var _passFake : PFake;

        public function MFake ()
        {
            super ( 1 );

            _passFake = new PFake ();
            _passFake.enable = true;
            _passes[ 0 ] = _passFake;
        }

        public function equal ( other : IMaterial ) : Boolean
        {
            if ( other == null ) return false;
            var otherAlias : MFake = other as MFake;
            if ( otherAlias == null ) return false;

            return super.innerEqual ( otherAlias );
        }

        override public function reset () : void
        {
            setPassEnable ( _passFake.name, true, true );
        }

        override public function set mainTexture ( value : Texture ) : void
        {
            super.mainTexture = value;
            _passes[ 0 ].mainTexture = value;
        }
    }
}
