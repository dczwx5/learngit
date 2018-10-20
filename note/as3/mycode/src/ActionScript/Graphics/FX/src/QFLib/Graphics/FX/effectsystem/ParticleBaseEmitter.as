package QFLib.Graphics.FX.effectsystem
{
    import QFLib.Graphics.FX.effectsystem.keyFrame.ParticleKeyFrame;
    import QFLib.Graphics.FX.effectsystem.particleModifier.CParticleModifier;
    import QFLib.Math.CVector2;
    import QFLib.Utils.Random;

    import flash.geom.Matrix;
    import flash.geom.Point;

    public class ParticleBaseEmitter
    {
        protected static const PI2 : Number = Math.PI * 2;
        protected static var sPointHelper0 : Point = new Point ();
        protected static var sPositionHelper : CVector2 = new CVector2 ();
        protected static var sVelocityHelper : CVector2 = new CVector2 ();
        protected static var sNormalHelper : CVector2 = new CVector2 ();

        public var maxEmit : int = 0;
        public var emitLimit : int = 0;
        public var emittType : int = EffectSystem.RING;
        public var emittRange : CVector2 = new CVector2 ( 0, PI2 );
        public var emittScaler : CVector2 = CVector2.one ();

        public var randomParticleLife : Boolean = false;
        public var randomParticleSize : Boolean = false;
        public var randomVelocity : Boolean = false;
        public var randomVelocityNormal : Boolean = false;
        public var randomVelocityTangent : Boolean = false;
        public var randomAcceleration : Boolean = false;
        public var randomAccelerationNormal : Boolean = false;
        public var randomAccelerationTangent : Boolean = false;
        public var isWorld : Boolean = false;

        private var _isExpire : Boolean = false;
        private var _emittedCount : int = 0;
        private var _emitRate : Number = 1;
        private var _emitExpire : Number = 0.0;
        private var _emitInterval : Number;
        private var _worldScaler : CVector2 = CVector2.one ();
        private var _worldRotationC : Number = 1.0;
        private var _worldRotationS : Number = 0.0;

        private var _particleLife : Number = 1.0;
        private var _particleLifeMin : Number = 1.0;
        private var _particleLifeRange : Number = 0.0;

        private var _velocity : CVector2 = CVector2.zero ();
        private var _velocityMin : CVector2 = CVector2.zero ();
        private var _velocityRange : CVector2 = CVector2.zero ();

        private var _velocityNormal : Number = 0.0;
        private var _velocityNormalMin : Number = 0.0;
        private var _velocityNormalRange : Number = 0.0;

        private var _velocityTangent : Number = 0.0;
        private var _velocityTangentMin : Number = 0.0;
        private var _velocityTangentRange : Number = 0.0;

        private var _acceleration : CVector2 = CVector2.zero ();
        private var _accelerationMin : CVector2 = CVector2.zero ();
        private var _accelerationRange : CVector2 = CVector2.zero ();

        private var _accelerationNormal : Number = 0.0;
        private var _accelerationNormalMin : Number = 0.0;
        private var _accelerationNormalRange : Number = 0.0;

        private var _accelerationTangent : Number = 0.0;
        private var _accelerationTangentMin : Number = 0.0;
        private var _accelerationTangentRange : Number = 0.0;

        private var _randomSizeMax : Number = 1.0;
        private var _randomSizeMin : Number = 0.0;
        private var _randomSizeRange : Number = 1.0;

        private var _pKeyFrame : ParticleKeyFrame;
        private var _pOwner : ParticleInstance;

        private var _particles : Vector.<Particle>;
        private var _particlePool : ParticlePool;
        private var _modifiers : Vector.<CParticleModifier>;
        private var _validParticleCount : int = 0;

        public function ParticleBaseEmitter ( pOwner : ParticleInstance, keyFrame : ParticleKeyFrame, modifiers : Vector.<CParticleModifier> )
        {
            this._pKeyFrame = keyFrame;
            _pOwner = pOwner;

            emitRate = _emitRate;
            _emitExpire = _emitInterval - 0.001;
//			_emitExpire = _emitInterval;
            _particlePool = ParticlePool.getInstance ();
            _particles = new Vector.<Particle> ();
            _particles.fixed = true;

            _modifiers = modifiers;
        }

        public function dispose () : void
        {
            _particles.fixed = false;
            _particles.length = 0;
            _particles = null;

            _validParticleCount = 0;
        }

        [Inline]
        final public function set worldRotation ( value : Number ) : void
        {
            _worldRotationC = Math.cos( value );
            _worldRotationS = Math.sin( value );
        }

        [Inline]
        final public function get isExpire () : Boolean
        {
            return _isExpire || (maxEmit > 0 && maxEmit <= _emittedCount);
        }

        [Inline]
        final public function set isExpire ( value : Boolean ) : void
        { _isExpire = value; }

        [Inline]
        final public function set emitRate ( value : Number ) : void
        {
            _emitRate = value;
            _emitInterval = 1.0 / value;
            _emitExpire = _emitInterval - 0.001;
            //_emitExpire = _emitInterval;
        }

        [Inline]
        final public function set particleLife ( value : Number ) : void
        {
            _particleLife = value;
            if ( randomParticleLife )
                _particleLifeRange = value - _particleLifeMin;
        }

        [Inline]
        final public function set particleLifeMin ( value : Number ) : void
        {
            _particleLifeMin = value;
            if ( randomParticleLife )
                _particleLifeRange = _particleLife - value;
        }

        [Inline]
        final public function set velocity ( value : CVector2 ) : void
        {
            _velocity.x = value.x;
            _velocity.y = value.y;
            if ( randomVelocity )
            {
                _velocityRange.x = value.x - _velocityMin.x;
                _velocityRange.y = value.y - _velocityMin.y;
            }
        }

        [Inline]
        final public function set velocityMin ( value : CVector2 ) : void
        {
            _velocityMin.x = value.x;
            _velocityMin.y = value.y;
            if ( randomVelocity )
            {
                _velocityRange.x = _velocity.x - value.x;
                _velocityRange.y = _velocity.y - value.y;
            }
        }


        [Inline]
        final public function set velocityNormal ( value : Number ) : void
        {
            _velocityNormal = value;
            if ( randomVelocityNormal )
            {
                _velocityNormalRange = value - _velocityNormalMin;
            }
        }

        [Inline]
        final public function set velocityNormalMin ( value : Number ) : void
        {
            _velocityNormalMin = value;
            if ( randomVelocityNormal )
            {
                _velocityNormalRange = _velocityNormal - value;
            }
        }

        [Inline]
        final public function set velocityTangent ( value : Number ) : void
        {
            _velocityTangent = value;
            if ( randomVelocityTangent )
            {
                _velocityTangentRange = value - _velocityTangentMin;
            }
        }

        [Inline]
        final public function set velocityTangentMin ( value : Number ) : void
        {
            _velocityTangentMin = value;
            if ( randomVelocityTangent )
            {
                _velocityTangentRange = _velocityTangent - value;
            }
        }

        [Inline]
        final public function set acceleration ( value : CVector2 ) : void
        {
            _acceleration.x = value.x;
            _acceleration.y = value.y;
            if ( randomAcceleration )
            {
                _accelerationRange.x = value.x - _accelerationMin.x;
                _accelerationRange.y = value.y - _accelerationMin.y;
            }
        }

        [Inline]
        final public function set accelerationMin ( value : CVector2 ) : void
        {
            _accelerationMin.x = value.x;
            _accelerationMin.y = value.y;
            if ( randomAcceleration )
            {
                _accelerationRange.x = _acceleration.x - value.x;
                _accelerationRange.y = _acceleration.y - value.y;
            }
        }

        [Inline]
        final public function set accelerationNormal ( value : Number ) : void
        {
            _accelerationNormal = value;
            if ( randomAccelerationNormal )
            {
                _accelerationNormalRange = value - _accelerationNormalMin;
            }
        }

        [Inline]
        final public function set accelerationNormalMin ( value : Number ) : void
        {
            _accelerationNormalMin = value;
            if ( randomAccelerationNormal )
            {
                _accelerationNormalRange = _accelerationNormal - value;
            }
        }

        [Inline]
        final public function set accelerationTangent ( value : Number ) : void
        {
            _accelerationTangent = value;
            if ( randomAccelerationTangent )
            {
                _accelerationTangentRange = value - _accelerationTangentMin;
            }
        }

        [Inline]
        final public function set accelerationTangentMin ( value : Number ) : void
        {
            _accelerationTangentMin = value;
            if ( randomAccelerationTangent )
            {
                _accelerationTangentRange = _accelerationTangent - value;
            }
        }

        [Inline]
        final public function set randomSizeMax ( value : Number ) : void
        {
            _randomSizeMax = value;
            if ( randomParticleSize )
            {
                _randomSizeRange = value - _randomSizeMin;
            }
        }

        [Inline]
        final public function set randomSizeMin ( value : Number ) : void
        {
            _randomSizeMin = value;
            if ( randomParticleSize )
            {
                _randomSizeRange = _randomSizeMax - value;
            }
        }

        [Inline]
        final public function setWorldScale ( scaleX : Number, scaleY : Number ) : void
        {
            _worldScaler.setValueXY ( scaleX, scaleY );
        }

        [Inline]
        final public function get particles () : Vector.<Particle>
        { return _particles; }

        [Inline]
        final public function get validParticleCount () : int
        {
            return _validParticleCount;
        }

        [Inline]
        final public function get isDead () : Boolean
        { return isExpire && _validParticleCount == 0; }

        public function reset () : void
        {
            isExpire = false;
            _emitExpire = _emitInterval - 0.001;
            //_emitExpire   = _emitInterval;
            _emittedCount = 0;

            _validParticleCount = 0;
        }

        public function tick ( deltaTime : Number ) : void
        {
            //destroy
            for ( var i : int = 0, n : int = _validParticleCount; i < n; )
            {
                var particle : Particle = _particles[ i ];
                tickParticle ( deltaTime, particle );
                if ( particle.life <= 0 )
                {
                    _particlePool.push ( particle );
                    _particles[ i ] = _particles[ n - 1 ];
                    n--;
                }
                else
                {
                    i++;
                }
            }

            _validParticleCount = n;

            if ( !isExpire )
            {
                //generate
                _emitExpire += deltaTime;
                var generateLimited : int;
                if ( emitLimit == 0 )
                    generateLimited = 4096 - _validParticleCount;
                else
                    generateLimited = emitLimit - _validParticleCount;

                var generateCount : int = 0;
                if ( _emitExpire > _emitInterval && generateLimited > 0 )
                {
                    generateCount = _emitExpire / _emitInterval;
                    if ( generateCount > generateLimited )
                    {
                        generateCount = generateLimited;
                        _emitExpire -= ( _emitInterval * generateCount );
                    }
                    else
                        _emitExpire %= _emitInterval;
                }

                if ( generateCount > 0 )
                {
                    generateParticle ( generateCount );
                }
            }
        }

        private function generateParticle ( count : int ) : void
        {
            var particle : Particle;
            _emittedCount += count;
            var i : int = _validParticleCount;
            var n : int = i + count;
            _validParticleCount = n;

            var parVecLength : int = _particles.length;
            if ( parVecLength < n )
            {
                _particles.fixed = false;
                _particles.length = n * 1.5;
                _particles.fixed = true;
            }

            if ( isWorld )
            {
                for ( ; i < n; ++i )
                {
                    particle = _particlePool.pop ();
                    initParticleWorld ( particle );
                    _particles[ i ] = particle;

                    //XXX:粒子修改器功能，该功能打算废弃地
                    //_modifyParticleAfterEmittion ( particle );
                }
            }
            else
            {
                for ( ; i < n; ++i )
                {
                    particle = _particlePool.pop ();
                    initParticle ( particle );
                    _particles[ i ] = particle;

                    //XXX:粒子修改器功能，该功能打算废弃地
                    //_modifyParticleAfterEmittion ( particle );
                }
            }
        }

        private function initParticleCommon ( particle : Particle ) : void
        {
            if ( randomParticleLife )
            {
                var life : Number = _particleLifeMin + _particleLifeRange * Random.seed01;
                particle.setMaxLife( life );
                particle.setLife( life );
            }
            else
            {
                particle.setMaxLife( _particleLife );
                particle.setLife( _particleLife );
            }

            particle.color = _pKeyFrame.getColor ( 0.0 );
            particle.size.set ( _pKeyFrame.getSize ( 0.0 ) );

            if ( isWorld )
            {
                particle.size.x *= _worldScaler.x;
                particle.size.y *= _worldScaler.y;
            }

            if ( randomParticleSize )
            {
                particle.sizeScaler = _randomSizeMin + _randomSizeRange * Random.seed01;
                particle.size.x *= particle.sizeScaler;
                particle.size.y *= particle.sizeScaler;
            }

            if ( randomVelocity )
            {
                particle.velocity.x = _velocityMin.x + _velocityRange.x * Random.seed01;
                particle.velocity.y = _velocityMin.y + _velocityRange.y * Random.seed01;
            }
            else
            {
                particle.velocity.x = _velocity.x;
                particle.velocity.y = _velocity.y;
            }

            if ( randomVelocityNormal )
            {
                particle.velocityNormal = _velocityNormalMin + _velocityNormalRange * Random.seed01;
            }
            else
            {
                particle.velocityNormal = _velocityNormal;
            }

            if ( randomVelocityTangent )
            {
                particle.velocityTangent = _velocityTangentMin + _velocityTangentRange * Random.seed01;
            }
            else
            {
                particle.velocityTangent = _velocityTangent;
            }

            if ( randomAcceleration )
            {
                particle.acceleration.x = _acceleration.x * Random.seed01;
                particle.acceleration.y = _acceleration.y * Random.seed01;
            }
            else
            {
                particle.acceleration.x = _acceleration.x;
                particle.acceleration.y = _acceleration.y;
            }

            if ( randomAccelerationNormal )
            {
                particle.accelerationNormal = _accelerationNormalMin + _accelerationNormalRange * Random.seed01;
            }
            else
            {
                particle.accelerationNormal = _accelerationNormal;
            }

            if ( randomAccelerationTangent )
            {
                particle.accelerationTangent = _accelerationTangentMin + _accelerationTangentRange * Random.seed01;
            }
            else
            {
                particle.accelerationTangent = _accelerationTangent;
            }

            afterInitialParticle ( particle );
        }

        private function initParticle ( particle : Particle ) : void
        {
            initParticleCommon ( particle );
            var v2 : CVector2 = EmitGenerator.genPosition ( emittType, emittRange, emittScaler, sPositionHelper );
            particle.position.set ( v2 );
        }

        private function initParticleWorld ( particle : Particle ) : void
        {
            initParticleCommon ( particle );

            var localPosition : CVector2 = EmitGenerator.genPosition ( emittType, emittRange, emittScaler, sPositionHelper );
            var worldTransform : Matrix = _pOwner.worldTransform;
            sPointHelper0.setTo( localPosition.x, localPosition.y );

            var point : Point = worldTransform.transformPoint ( sPointHelper0 );
            particle.origin.setValueXY ( worldTransform.tx, worldTransform.ty );
            particle.position.setValueXY ( point.x, point.y );
        }

        protected function tickParticle ( dt : Number, particle : Particle ) : void
        {
            particle.setLife ( particle.life - dt );

            //XXX:粒子修改器功能，该功能打算废弃地
            //_modifyParticleBeforeUpdate ( particle, dt );

            particle.color = _pKeyFrame.getColor ( particle.normalLife );
            var size : CVector2 = _pKeyFrame.getSize ( particle.normalLife );
            particle.size.x = size.x;
            particle.size.y = size.y;

            if ( isWorld )
            {
                particle.size.x *= _worldScaler.x;
                particle.size.y *= _worldScaler.y;
            }

            if ( randomParticleSize )
            {
                particle.size.x *= particle.sizeScaler;
                particle.size.y *= particle.sizeScaler;
            }

            //加速度时间轴数值影响
            var scaler : CVector2 = _pKeyFrame.getAcceleration ( particle.normalLife );
            particle.velocity.x += particle.acceleration.x * scaler.x * dt;
            particle.velocity.y += particle.acceleration.y * scaler.y * dt;

            particle.velocityNormal += particle.accelerationNormal * dt;
            particle.velocityTangent += particle.accelerationTangent * dt;

            sVelocityHelper.x = particle.velocity.x;
            sVelocityHelper.y = particle.velocity.y;

            sNormalHelper.x = particle.position.x - particle.origin.x;
            sNormalHelper.y = particle.position.y - particle.origin.y;
            sNormalHelper.normalize ();

            sVelocityHelper.x += particle.velocityNormal * sNormalHelper.x;
            sVelocityHelper.y += particle.velocityNormal * sNormalHelper.y;

            sVelocityHelper.x -= particle.velocityTangent * sNormalHelper.y;
            sVelocityHelper.y += particle.velocityTangent * sNormalHelper.x;

            if ( isWorld && _worldRotationC != 1.0 )
            {
                var vx : Number = sVelocityHelper.x * _worldRotationC - sVelocityHelper.y * _worldRotationS;
                var vy : Number = sVelocityHelper.y * _worldRotationC + sVelocityHelper.x * _worldRotationS;
                sVelocityHelper.x = vx; sVelocityHelper.y = vy;
            }

            //速度时间轴数值影响
            scaler = _pKeyFrame.getVelocity ( particle.normalLife );

            particle.position.x += sVelocityHelper.x * scaler.x * dt;
            particle.position.y += sVelocityHelper.y * scaler.y * dt;

            afterTickParticle ( particle, sVelocityHelper );

            //XXX:粒子修改器功能，该功能打算废弃地
            //_modifyParticleAfterUpdate ( particle, dt );
        }

        public function loadFromObject ( data : Object ) : void
        {
            maxEmit = data.maxEmit;

            particleLife = data.particleLife;
            randomParticleLife = data.randomParticleLife;
            if ( randomParticleLife )
            {
                particleLifeMin = data.particleLifeMin;
            }

            emitLimit = data.emitLimit;
            emitRate = data.emitRate;
            emittType = data.emitType;
            emittRange.x = data.emitRange.x;
            emittRange.y = -data.emitRange.y;
            emittScaler.x = data.emitScaler.x;
            emittScaler.y = data.emitScaler.y;

            velocity = new CVector2 ( data.velocity.x, data.velocity.y );
            randomVelocity = data.randomVelocity;
            if ( randomVelocity )
            {
                velocityMin = new CVector2 ( data.velocityMin.x, data.velocityMin.y );
            }

            velocityNormal = data.velocityNormal;
            randomVelocityNormal = data.randomVelocityNormal;
            if ( randomVelocityNormal )
            {
                velocityNormalMin = data.velocityNormalMin;
            }

            velocityTangent = data.velocityTangent;
            randomVelocityTangent = data.randomVelocityTangent;
            if ( randomVelocityTangent )
            {
                velocityTangentMin = data.velocityTangentMin;
            }

            acceleration = new CVector2 ( data.acceleration.x, data.acceleration.y );
            randomAcceleration = data.randomAcceleration;
            if ( randomAcceleration )
            {
                accelerationMin = new CVector2 ( data.accelerationMin.x, data.accelerationMin.y );
            }

            accelerationNormal = data.accelerationNormal;
            randomAccelerationNormal = data.randomAccelerationNormal;
            if ( randomAccelerationNormal )
            {
                accelerationNormalMin = data.accelerationNormalMin;
            }

            accelerationTangent = data.accelerationTangent;
            randomAccelerationTangent = data.randomAccelerationTangent;
            if ( randomAccelerationTangent )
            {
                accelerationTangentMin = data.accelerationTangentMin;
            }

            randomParticleSize = data.randomSize;
            if ( randomParticleSize )
            {
                randomSizeMax = data.randomSizeMax;
                randomSizeMin = data.randomSizeMin;
            }

            isWorld = data.world;
            _loadFromJson ( data );
        }

        public virtual function afterInitialParticle ( particle : Particle ) : void
        {}

        public virtual function afterTickParticle ( particle : Particle, velocity : CVector2 ) : void
        {}

        public virtual function _loadFromJson ( data : Object ) : void {}

        private function _modifyParticleAfterEmittion ( particle : Particle ) : void
        {
            var modifiers : Vector.<CParticleModifier> = _modifiers;
            for ( var i : int = 0, l : int = modifiers.length; i < l; ++i )
            {
                modifiers[ i ].processAfterEmition ( particle );
            }
        }

        private function _modifyParticleBeforeUpdate ( particle : Particle, deltaTime : Number ) : void
        {
            var modifiers : Vector.<CParticleModifier> = _modifiers;
            for ( var i : int = 0, l : int = modifiers.length; i < l; ++i )
            {
                modifiers[ i ].processBeforeUpdate ( particle, deltaTime );
            }
        }

        private function _modifyParticleAfterUpdate ( particle : Particle, deltaTime : Number ) : void
        {
            var modifiers : Vector.<CParticleModifier> = _modifiers;
            for ( var i : int = 0, l : int = modifiers.length; i < l; ++i )
            {
                modifiers[ i ].processAfterUpdate ( particle, deltaTime );
            }
        }
    }
}