/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Passes
{
    import QFLib.QEngine.Renderer.Material.IPass;
    import QFLib.QEngine.Renderer.Material.Shaders.FColorAlphaPMA;

    public class PParticlePMA extends PParticle
    {
        public static const sName : String = "PParticlePMA";

        public function PParticlePMA()
        {
            super();

            _passName = "PParticlePMA";
        }

        public override function get fragmentShader() : String
        {
            return FColorAlphaPMA.Name;
        }

        public override function clone() : IPass
        {
            var clonePass : PParticlePMA = new PParticlePMA();
            clonePass.copy( this );

            return clonePass;
        }
    }
}