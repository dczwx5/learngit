/**
 * Created by david on 2016/11/30.
 */
package QFLib.Graphics.RenderCore.render.pass
{
    import QFLib.Graphics.RenderCore.render.IPass;
    import QFLib.Graphics.RenderCore.render.shader.FGaussianBlur;
    import QFLib.Graphics.RenderCore.render.shader.VGaussianBlur;

    import flash.display3D.Context3DBlendFactor;

    public class PGaussianBlur extends PassBase implements IPass
    {
        public static const sName : String = "PGaussianBlur";

        public function PGaussianBlur ( ...args )
        {
            super ();

            _passName = sName;
        }

        override public function dispose () : void
        {
            super.dispose ();
        }

        public override function get vertexShader () : String
        {
            return VGaussianBlur.Name;
        }

        public override function get fragmentShader () : String
        {
            return FGaussianBlur.Name;
        }

        public function set uvExpand ( value : Vector.<Number> ) : void
        {
            registerVector ( "uvExpand", value );
        }

        public function set weights ( value : Vector.<Number> ) : void
        {
            registerVector ( "weights", value );
        }

        public function set centerWeightAndOffsets ( value : Vector.<Number> ) : void
        {
            registerVector ( "centerWeightAndOffsets", value );
        }

        public function set glowColor ( value : Vector.<Number> ) : void
        {
            registerVector ( "glowColor", value );
        }

        public function set glowStrenthen ( value : Vector.<Number> ) : void
        {
            registerVector ( "glowStrenthen", value );
        }

        override public function equal ( other : IPass ) : Boolean
        {
            var otherAlias : PGaussianBlur = other as PGaussianBlur;
            return otherAlias != null && innerEqual ( otherAlias );
        }

        override public function clone () : IPass
        {
            var clonePass : PGaussianBlur = new PGaussianBlur ();
            clonePass.copy ( this );

            return clonePass;
        }
    }
}
