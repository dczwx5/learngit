package QFLib.Graphics.RenderCore.render.pass
{
    import QFLib.Graphics.RenderCore.render.IPass;
    import QFLib.Graphics.RenderCore.render.shader.FBase;
    import QFLib.Graphics.RenderCore.render.shader.FLightTexture;
    import QFLib.Graphics.RenderCore.render.shader.VLightTC;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;

    public class PSpriteLight extends PassBase implements IPass
    {
        public static const sName : String = "PSpriteLight";

        public function PSpriteLight ( ...args )
        {
            super ();

            _passName = sName;
        }

        public override function get vertexShader () : String
        {
            return VLightTC.Name;
        }

        public override function get fragmentShader () : String
        {
            return FLightTexture.Name;
        }

        public function set lightColor ( value : Vector.<Number> ) : void
        {
            registerVector ( "lightColor", value );
        }

        public function set lightContrast ( value : Vector.<Number> ) : void
        {
            registerVector ( "lightContrast", value );
        }

        public override function clone () : IPass
        {
            var clonePass : PSpriteLight = new PSpriteLight ();
            clonePass.copy ( this );

            return clonePass;
        }
    }
}