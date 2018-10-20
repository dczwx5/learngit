package QFLib.Graphics.RenderCore.render.pass
{
    import QFLib.Graphics.RenderCore.render.IPass;
    import QFLib.Graphics.RenderCore.render.shader.FBase;
    import QFLib.Graphics.RenderCore.render.shader.FColorMatrix;
    import QFLib.Graphics.RenderCore.render.shader.VTintColorTC;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;

    public class PColorMatrix extends PassBase implements IPass
    {
        public static const sName : String = "PColorMatrix";

        static private var _minColor : Vector.<Number> = new <Number>[ 0, 0, 0, 0.0001 ];

        public function PColorMatrix (  ...args )
        {
            super ();

            _passName = sName;

            registerVector ( "minColor", _minColor );
        }

        public override function get vertexShader () : String
        {
            return VTintColorTC.Name;
        }

        public override function get fragmentShader () : String
        {
            return FColorMatrix.Name;
        }

        public function set maskColor ( value : Vector.<Number> ) : void
        {
            registerVector ( "maskColor", value );
        }

        public function set tintColor ( value : Vector.<Number> ) : void
        {
            registerVector ( "color", value );
        }

        public function set colorMatrix ( value : Vector.<Number> ) : void
        {
            registerVector ( FColorMatrix.ColorMatrix, value );
        }

        public override function clone () : IPass
        {
            var clonePass : PColorMatrix = new PColorMatrix ();
            clonePass.copy ( this );

            return clonePass;
        }
    }
}