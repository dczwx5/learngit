/**
 * Created by xandy on 2015/9/11.
 */
package QFLib.Graphics.RenderCore.render.material
{
    import QFLib.Graphics.RenderCore.render.IMaterial;
    import QFLib.Graphics.RenderCore.render.pass.PColorReplace;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;
    import QFLib.Graphics.RenderCore.starling.utils.Util;

    import flash.display3D.Context3DBlendFactor;

    public class MColorReplace extends MaterialBase implements IMaterial
    {
        protected var _passColorReplace : PColorReplace;
        private var _colorMatrix : Vector.<Number> = new Vector.<Number> ( 16 );
        private var _colorOffsets : Vector.<Number> = new Vector.<Number>( 4 );

        public function MColorReplace ()
        {
            super ( 1 );

            _passColorReplace = new PColorReplace ();
            _passColorReplace.colorMatrix = _colorMatrix;
            _passColorReplace.colorOffsets  = _colorOffsets;
            _passColorReplace.enable = true;
            _passes[ 0 ] = _passColorReplace;
        }

        public override function dispose () : void
        {
            super.dispose ();
        }

        [Inline] override public function set pma ( value : Boolean ) : void
        {
            super.pma = value;
            _passColorReplace.pma = value;
        }

        public function equal ( other : IMaterial ) : Boolean
        {
            if ( other == null ) return false;
            var otherAlias : MColorReplace = other as MColorReplace;
            if ( otherAlias == null )
            {
                return false;
            }

            if ( !super.innerEqual ( otherAlias ) )
            {
                return false;
            }

            return Util.comapreNumberList ( _colorMatrix, otherAlias._colorMatrix );
        }

        override public function reset () : void
        {
            setPassEnable ( _passColorReplace.name, true, true );
        }

        public function set colorMatrix ( value : Vector.<Number> ) : void
        {
            var count : int = value.length;
            for ( var i : int = 0; i < count; ++i )
            {
                _colorMatrix[ i ] = value[ i ];
            }
        }

        public function set colorOffsets ( value : Vector.<Number> ) : void
        {
            for ( var i : int = 0; i < 4; i++ )
            {
                _colorOffsets[ i ] = value[ i ];
            }
        }

        override public function set mainTexture ( value : Texture ) : void
        {
            super.mainTexture = value;
            _passes[ 0 ].mainTexture = value;
        }
    }
}