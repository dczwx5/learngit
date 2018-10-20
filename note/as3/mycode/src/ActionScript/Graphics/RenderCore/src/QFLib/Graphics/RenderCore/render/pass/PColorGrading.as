package QFLib.Graphics.RenderCore.render.pass
{
    import QFLib.Graphics.RenderCore.render.IPass;
    import QFLib.Graphics.RenderCore.render.shader.FColorGrading;
    import QFLib.Graphics.RenderCore.render.shader.VTC;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;

    public class PColorGrading extends PassBase implements IPass
    {
        public static const sName : String = "PColorGrading";

        static private const grid : Vector.<Number> = new <Number>[ 1.0 / 16.0, 16.0, 255.0, 0.099 ];

        public function PColorGrading ( ...args )
        {
            super ();

            _passName = sName;

            registerVector ( "grid", grid );
        }

        public override function get vertexShader () : String
        {
            return VTC.Name;
        }

        public override function get fragmentShader () : String
        {
            return FColorGrading.Name;
        }

        public function get colorGrading () : Texture
        {
            return getTexture ( "colorGrading" );
        }

        public function set colorGrading ( value : Texture ) : void
        {
            if ( value != null )
            {
                setTexture ( "colorGrading", value );
            }
        }

        public override function equal ( other : IPass ) : Boolean
        {
            var otherAlias : PColorGrading = other as PColorGrading;
            if ( otherAlias != null && innerEqual ( otherAlias ) )
            {
                return colorGrading == otherAlias.colorGrading;
            }

            return false;
        }

        public override function clone () : IPass
        {
            var clonePass : PColorGrading = new PColorGrading ();
            clonePass.copy ( this );

            return clonePass;
        }
    }
}
