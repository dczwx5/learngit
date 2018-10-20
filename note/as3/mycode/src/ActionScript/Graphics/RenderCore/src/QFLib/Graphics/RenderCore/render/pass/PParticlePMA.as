package QFLib.Graphics.RenderCore.render.pass
{
    import QFLib.Graphics.RenderCore.render.IPass;
    import QFLib.Graphics.RenderCore.render.shader.FColorAlphaPMA;

    public class PParticlePMA extends PParticle
    {
        public static const sName : String = "PParticlePMA";

        public function PParticlePMA ( ...args )
        {
            super ( args );

            _passName = "PParticlePMA";
        }

        public override function get fragmentShader () : String
        {
            return FColorAlphaPMA.Name;
        }

        public override function clone () : IPass
        {
            var clonePass : PParticlePMA = new PParticlePMA ();
            clonePass.copy ( this );

            return clonePass;
        }
    }
}