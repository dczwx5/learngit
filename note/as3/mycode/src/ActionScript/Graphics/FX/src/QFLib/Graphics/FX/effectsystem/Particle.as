package QFLib.Graphics.FX.effectsystem
{
    import QFLib.Math.CVector2;

    public final class Particle
    {
        public var color : uint = 0xFFFFFFFF;
        public var size : CVector2 = CVector2.one();
        public var origin : CVector2 = CVector2.zero();
        public var position : CVector2 = CVector2.zero();
        public var velocity : CVector2 = CVector2.zero();
        public var velocityNormal : Number = 0.0;
        public var velocityTangent : Number = 0.0;
        public var acceleration : CVector2 = CVector2.zero();
        public var accelerationNormal : Number = 0.0;
        public var accelerationTangent : Number = 0.0;
        public var sizeScaler : Number = 1.0;
        public var rotateVelocity : Number = 0.0;

        public var maxLife : Number = 1.0;
        public var life : Number = 1.0;
        public var normalLife : Number = 0.0;
        public var initialRotation : Number = 0.0;
        public var rotation : CVector2 = new CVector2 ( 1.0, 0.0 );

        [Inline]
        final public function setMaxLife ( value : Number ) : void
        {
            maxLife = value;
            normalLife = 1.0 - life / value;
        }

        [Inline]
        final public function setLife ( value : Number ) : void
        {
            life = value<0? 0:value;
            normalLife = 1.0 - value / maxLife;
        }

        public function setInitialRotation ( value : Number ) : void
        {
            initialRotation = value;
            rotation.x = Math.cos ( value );
            rotation.y = Math.sin ( value );
        }
    }
}