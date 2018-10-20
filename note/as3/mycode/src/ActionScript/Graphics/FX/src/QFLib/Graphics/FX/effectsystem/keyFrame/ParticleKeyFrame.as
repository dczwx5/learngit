/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2016/10/19.
 */
package QFLib.Graphics.FX.effectsystem.keyFrame
{
    import QFLib.Math.CVector2;

    public class ParticleKeyFrame extends KeyFrame
    {
        private var _velocityKeys : Vector.<Vector2DKey>;
        private var _accelerationKeys : Vector.<Vector2DKey>;

        public function ParticleKeyFrame ()
        {
            _velocityKeys = new Vector.<Vector2DKey> ();
            _accelerationKeys = new Vector.<Vector2DKey> ();
        }

        public override function clear () : void
        {
            _velocityKeys.fixed = false;
            _velocityKeys.length = 0;
            _velocityKeys.fixed = true;
            _velocityKeys = null;

            _accelerationKeys.fixed = false;
            _accelerationKeys.length = 0;
            _accelerationKeys.fixed = true;
            _accelerationKeys = null;

            super.clear ();
        }

        public function addVelocityKey ( time : Number, velocity : CVector2 ) : void
        {
            Vector2DKey.addVector2DKey ( _velocityKeys, time, velocity );
        }

        public function addAccelerationKey ( time : Number, accerleration : CVector2 ) : void
        {
            Vector2DKey.addVector2DKey ( _accelerationKeys, time, accerleration );
        }

        public function getVelocity ( time : Number ) : CVector2
        {
            return Vector2DKey.getVector2D ( _velocityKeys, time );
        }

        public function getAcceleration ( time : Number ) : CVector2
        {
            return Vector2DKey.getVector2D ( _accelerationKeys, time );
        }

        public override function loadFromObject ( data : Object ) : void
        {
            super.loadFromObject ( data );
            if ( data.hasOwnProperty ( "velocityKeys" ) )
            {
                Vector2DKey.keysLoadFromJson(data.velocityKeys, _velocityKeys);
            }
            if ( data.hasOwnProperty ( "accelerationKeys" ) )
            {
                Vector2DKey.keysLoadFromJson(data.accelerationKeys, _accelerationKeys);
            }
        }
    }
}
