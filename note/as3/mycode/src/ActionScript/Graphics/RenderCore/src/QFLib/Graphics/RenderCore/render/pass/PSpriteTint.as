package QFLib.Graphics.RenderCore.render.pass
{
    import QFLib.Graphics.RenderCore.render.IPass;
    import QFLib.Graphics.RenderCore.render.shader.FBase;
    import QFLib.Graphics.RenderCore.render.shader.FColorTexture;
    import QFLib.Graphics.RenderCore.render.shader.VTintTC;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;

    public class PSpriteTint extends PassBase implements IPass
    {
        public static const sName : String = "PSpriteTint";

        public function PSpriteTint ( ...args )
        {
            super ();

            _passName = sName;
        }

        public override function get vertexShader () : String
        {
            return VTintTC.Name;
        }

        public override function get fragmentShader () : String
        {
            return FColorTexture.Name;
        }

        public function set maskingColor ( value : Vector.<Number> ) : void
        {
            registerVector ( "maskColor", value );
        }

        public function set tintColor ( value : Vector.<Number> ) : void
        {
            registerVector ( "color", value );
        }

        public override function clone () : IPass
        {
            var clonePass : PSpriteTint = new PSpriteTint ();
            clonePass.copy ( this );

            return clonePass;
        }
    }
}