/**
 * Created by Cliff on 2017/5/8.
 */
package QFLib.Graphics.RenderCore.render.pass
{
    import QFLib.Graphics.RenderCore.render.IPass;
    import QFLib.Graphics.RenderCore.render.shader.FUVAnimation;
    import QFLib.Graphics.RenderCore.render.shader.VTintColorTC;

    public class PUVAnimation extends PassBase implements IPass
    {
        public static const sName : String = "PUVAnimation";

        public function PUVAnimation ()
        {
            _passName = sName;
        }

        public override function get vertexShader () : String
        {
            return VTintColorTC.Name;
        }

        public override function get fragmentShader () : String
        {
            return FUVAnimation.Name;
        }

        public function set maskColor ( value : Vector.<Number> ) : void
        {
            registerVector ( "maskColor", value );
        }

        public function set tintColor ( value : Vector.<Number> ) : void
        {
            registerVector ( "color", value );
        }

        public function setUVParams ( offsetUV : Vector.<Number> ) : void
        {
            registerVector ( "offsetUV", offsetUV );
        }

        public function setTilingParams ( tilingParams : Vector.<Number> ) : void
        {
            registerVector ( "tilingParams", tilingParams );
        }

        public function setMarginParams ( marginParams : Vector.<Number> ) : void
        {
            registerVector ( "marginParams", marginParams );
        }
    }
}
