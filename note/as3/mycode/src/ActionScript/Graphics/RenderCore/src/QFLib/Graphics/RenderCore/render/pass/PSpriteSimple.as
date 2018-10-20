package QFLib.Graphics.RenderCore.render.pass
{
    import QFLib.Graphics.RenderCore.render.IPass;
    import QFLib.Graphics.RenderCore.render.shader.FColor;
    import QFLib.Graphics.RenderCore.render.shader.VTintColor;

    public class PSpriteSimple extends PassBase implements IPass
    {
        public static const sName : String = "PSpriteSimple";

        public function PSpriteSimple ( ...args )
        {
            super ();

            _passName = sName;
        }

        public override function get vertexShader () : String
        {
            return VTintColor.Name;
        }

        public override function get fragmentShader () : String
        {
            return FColor.Name;
        }

        public function set maskColor ( value : Vector.<Number> ) : void
        {
            registerVector ( "maskColor", value );
        }

        public function set tintColor ( value : Vector.<Number> ) : void
        {
            registerVector ( "color", value );
        }

        public override function clone () : IPass
        {
            var clonePass : PSpriteSimple = new PSpriteSimple ();
            clonePass.copy ( this );

            return clonePass;
        }
    }
}