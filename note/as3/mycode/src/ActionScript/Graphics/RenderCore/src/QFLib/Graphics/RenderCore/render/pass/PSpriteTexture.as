package QFLib.Graphics.RenderCore.render.pass
{
    import QFLib.Graphics.RenderCore.render.IPass;
    import QFLib.Graphics.RenderCore.render.shader.FTexture;
    import QFLib.Graphics.RenderCore.render.shader.VTC;

    public class PSpriteTexture extends PassBase implements IPass
    {
        public static const sName : String = "PSpriteTexture";

        public function PSpriteTexture ( ...args )
        {
            super ();

            _passName = sName;
        }

        public override function get vertexShader () : String
        {
            return VTC.Name;
        }

        public override function get fragmentShader () : String
        {
            return FTexture.Name;
        }

        public override function clone () : IPass
        {
            var clonePass : PSpriteTexture = new PSpriteTexture ();
            clonePass.copy ( this );

            return clonePass;
        }
    }
}