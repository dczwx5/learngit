package QFLib.Graphics.FX.effectsystem
{
    import QFLib.Graphics.FX.effectsystem.keyFrame.ParticleKeyFrame;
    import QFLib.Graphics.FX.effectsystem.particleModifier.CParticleModifier;
    import QFLib.Math.CVector2;
    import QFLib.Utils.Random;

    public class ParticleBillboardEmitter extends ParticleBaseEmitter
    {
        public var isRotate : Boolean = false;
        public var randomInitRotation : Boolean = false;
        public var randomRotateVelocity : Boolean = false;

        private var _initialRotation : Number = 0.0;
        private var _initialRotationMin : Number = 0.0;
        private var _initialRotationRange : Number = 0.0;

        private var _rotateVelocity : Number = 0.0;
        private var _rotateVelocityMin : Number = 0.0;
        private var _rotateVelocityRange : Number = 0.0;

        public function ParticleBillboardEmitter ( pOnwer : ParticleInstance, keyFrame : ParticleKeyFrame, modifiers : Vector.<CParticleModifier> )
        {
            super ( pOnwer, keyFrame, modifiers );
        }

        [Inline]
        final public function set initialRotation ( value : Number ) : void
        {
            _initialRotation = value;
            if ( randomInitRotation )
            {
                _initialRotationRange = value - _initialRotationMin;
            }
        }

        [Inline]
        final public function set initialRotationMin ( value : Number ) : void
        {
            _initialRotationMin = value;
            if ( randomInitRotation )
            {
                _initialRotationRange = _initialRotation - value;
            }
        }

        [Inline]
        final public function set rotateVelocity ( value : Number ) : void
        {
            _rotateVelocity = value;
            if ( randomRotateVelocity )
            {
                _rotateVelocityRange = value - _rotateVelocityMin;
            }
        }

        [Inline]
        final public function set rotateVelocityMin ( value : Number ) : void
        {
            _rotateVelocityMin = value;
            if ( randomRotateVelocity )
            {
                _rotateVelocityRange = _rotateVelocity - value;
            }
        }

        override public function afterInitialParticle ( particle : Particle ) : void
        {
            if ( randomInitRotation )
            {
                particle.setInitialRotation( _initialRotationMin + _initialRotationRange * Random.seed01 );
            }
            else
            {
                particle.setInitialRotation( _initialRotation );
            }

            if ( isRotate )
            {
                if ( randomRotateVelocity )
                {
                    particle.rotateVelocity = _rotateVelocityMin + _rotateVelocityRange * Random.seed01;
                }
                else
                {
                    particle.rotateVelocity = _rotateVelocity;
                }
            }
        }

        override public function afterTickParticle ( particle : Particle, velocity : CVector2 ) : void
        {
            if ( isRotate )
            {
                var radian : Number = (particle.maxLife - particle.life) * particle.rotateVelocity + particle.initialRotation;
                particle.rotation.x = Math.cos ( radian );
                particle.rotation.y = Math.sin ( radian );
            }
        }

        override public function _loadFromJson ( data : Object ) : void
        {
            //unity和flash旋转的正向不同;
            isRotate = data.isRotate;

            initialRotation = -data.initialRotation;
            randomInitRotation = data.randomInitRotation;
            if ( randomInitRotation )
            {
                //和unity旋转方向不同，所以需要调换
                initialRotation = -data.initialRotationMin;
                initialRotationMin = -data.initialRotation;
            }

            if ( isRotate )
            {
                rotateVelocity = -data.rotateVelocity;
                randomRotateVelocity = data.randomRotateVelocity;
                if ( randomRotateVelocity )
                {
                    //和unity旋转方向不同，所以需要调换
                    rotateVelocity = -data.rotateVelocityMin;
                    rotateVelocityMin = -data.rotateVelocity;
                }
            }
        }
    }
}
