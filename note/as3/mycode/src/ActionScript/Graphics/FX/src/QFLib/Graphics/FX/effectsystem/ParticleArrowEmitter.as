package QFLib.Graphics.FX.effectsystem
{
    import QFLib.Graphics.FX.effectsystem.keyFrame.ParticleKeyFrame;
    import QFLib.Graphics.FX.effectsystem.particleModifier.CParticleModifier;
    import QFLib.Math.CVector2;

    public class ParticleArrowEmitter extends ParticleBaseEmitter
    {
        public function ParticleArrowEmitter ( pOnwer : ParticleInstance, keyFrame : ParticleKeyFrame, modifiers : Vector.<CParticleModifier> )
        {
            super ( pOnwer, keyFrame, modifiers );
        }

        override public function afterInitialParticle ( particle : Particle ) : void
        {
            tickParticle ( 0.01, particle );
        }

        override public function afterTickParticle ( particle : Particle, velocity : CVector2 ) : void
        {
            velocity.normalize ();

            if ( velocity.equals ( CVector2.ZERO ) )
            {
                var temp : CVector2 = particle.origin.sub( particle.position );
                temp.normalize();
                velocity = temp;
            }

            particle.rotation.x = -velocity.y;
            particle.rotation.y = -velocity.x;
        }
    }
}
