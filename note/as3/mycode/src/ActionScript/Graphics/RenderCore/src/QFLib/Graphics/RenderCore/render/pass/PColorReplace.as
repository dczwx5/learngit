/**
 * Created by xandy on 2015/9/11.
 */
package QFLib.Graphics.RenderCore.render.pass
{
    import QFLib.Graphics.RenderCore.render.IPass;
    import QFLib.Graphics.RenderCore.render.shader.FColorMatrix;
    import QFLib.Graphics.RenderCore.render.shader.VTC;

    import flash.display3D.Context3DBlendFactor;

    public class PColorReplace extends PassBase implements IPass
    {
        public static const sName : String = "PReplace";

        static private var sAlphaBias : Vector.<Number> = new <Number>[ 1.0, 0, 0, 0.01 ];

        public function PColorReplace ( ...args )
        {
            super ();

            _passName = sName;

            registerVector ( FColorMatrix.AlphaBias, sAlphaBias );
            _blendMode = "custom";
        }

        public override function get vertexShader () : String
        {
            return VTC.Name;
        }

        public override function get fragmentShader () : String
        {
            return FColorMatrix.Name;
        }

        [Inline]
        public override function get srcOp () : String
        { return Context3DBlendFactor.ONE; }

        [Inline]
        public override function get dstOp () : String
        { return Context3DBlendFactor.ZERO; }

        public function set colorMatrix ( value : Vector.<Number> ) : void
        {
            registerVector ( FColorMatrix.ColorMatrix, value );
        }

        public function set colorOffsets ( value : Vector.<Number> ) : void
        {
            registerVector( FColorMatrix.ColorOffsets, value );
        }

        public override function clone () : IPass
        {
            var clonePass : PColorReplace = new PColorReplace ();
            clonePass.copy ( this );

            return clonePass;
        }
    }
}
