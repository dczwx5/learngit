package QFLib.Graphics.RenderCore.render.pass
{
    import QFLib.Graphics.RenderCore.render.IPass;
    import QFLib.Graphics.RenderCore.render.shader.FBase;
    import QFLib.Graphics.RenderCore.render.shader.FColorTexture;
    import QFLib.Graphics.RenderCore.render.shader.VTintColorTC;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;

    public class PColorSpriteTint extends PassBase implements IPass
    {
        public static const sName : String = "PColorSpriteTint";

        static private const _bias : Vector.<Number> = Vector.<Number> ( [ 0.01, 0, 0, 0 ] );

        public function PColorSpriteTint ( ...args )
        {
            super ();

            _passName = sName;
            registerVector ( "_bias", _bias );
        }

        public override function set blendMode ( value : String ) : void
        {
            _blendMode = value;
        }

        public override function get vertexShader () : String
        {
            return VTintColorTC.Name;
        }

        public override function get fragmentShader () : String
        {
            return FColorTexture.Name;
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
            var clonePass : PColorSpriteTint = new PColorSpriteTint ();
            clonePass.copy ( this );

            return clonePass;
        }
    }
}
