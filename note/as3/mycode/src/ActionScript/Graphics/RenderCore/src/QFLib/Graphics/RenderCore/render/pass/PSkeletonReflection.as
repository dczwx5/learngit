package QFLib.Graphics.RenderCore.render.pass
{
    import QFLib.Graphics.RenderCore.render.IPass;
    import QFLib.Graphics.RenderCore.render.shader.FBase;
    import QFLib.Graphics.RenderCore.render.shader.FLightTexture;
    import QFLib.Graphics.RenderCore.render.shader.VSkeletonReflection;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;

    import flash.display3D.Context3DBlendFactor;

    public class PSkeletonReflection extends PassBase implements IPass
    {
        public static const sName : String = "PSkeletonReflection";

        static private const alphaColor : Vector.<Number> = new <Number>[ 1.0, 1.0, 1.0, 0.5 ];

        public function PSkeletonReflection ( ...args )
        {
            super ();

            _passName = sName;

            registerVector ( "alphaScaler", alphaColor );
        }

        public override function get vertexShader () : String
        {
            return VSkeletonReflection.Name;
        }

        public override function get fragmentShader () : String
        {
            return FLightTexture.Name
        }

        public override function get blendMode () : String
        {
            return "custom";
        }

        public override function get srcOp () : String
        {
            return Context3DBlendFactor.SOURCE_ALPHA;
        }

        public override function get dstOp () : String
        {
            return Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
        }

        public function set sinkParam ( value : Vector.<Number> ) : void
        {
            registerVector ( "sinkParam", value );
        }

        public function set modelParam ( value : Vector.<Number> ) : void
        {
            registerVector ( "modelParam", value );
        }

        public function set tintColor ( value : Vector.<Number> ) : void
        {
            registerVector ( "tintColor", value );
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
            var clonePass : PSkeletonReflection = new PSkeletonReflection ();
            clonePass.copy ( this );

            return clonePass;
        }
    }
}