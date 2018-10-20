/**
 * Created by xandy on 2015/9/7.
 */
package QFLib.Graphics.RenderCore.render.pass
{
    import QFLib.Graphics.RenderCore.render.IPass;
    import QFLib.Graphics.RenderCore.render.shader.FFake;
    import QFLib.Graphics.RenderCore.render.shader.VTC;

    public class PFake extends PassBase implements IPass
    {
        public static const sName : String = "PFake";

        protected static var GrayFactor : Vector.<Number> = new <Number>[ 0.3, 0.59, 0.11, 1.0 ];

        public function PFake ( ...args )
        {
            super ();

            _passName = sName;

            registerVector ( FFake.GrayFactor, GrayFactor );
        }

        public override function get vertexShader () : String
        {
            return VTC.Name;
        }

        public override function get fragmentShader () : String
        {
            return FFake.Name;
        }

        public override function clone () : IPass
        {
            var clonePass : PFake = new PFake ();
            clonePass.copy ( this );

            return clonePass;
        }
    }
}
