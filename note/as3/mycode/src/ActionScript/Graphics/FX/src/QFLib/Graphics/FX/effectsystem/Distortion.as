//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by david on 2017/5/25.
 */
package QFLib.Graphics.FX.effectsystem
{
    import QFLib.Graphics.FX.IFXModify;
    import QFLib.Graphics.RenderCore.starling.filters.DistortionEffect;
    import QFLib.Graphics.RenderCore.starling.filters.FilterEffect;

    public class Distortion extends BaseModifier
    {
        public function Distortion ()
        {
            super ();
        }

        override public function dispose () : void
        {
            super.dispose ();

            if ( _direction != null )
            {
                _direction.length = 0;
                _direction = null;
            }

            if( _range != null )
            {
                _range.length = 0;
                _range = null;
            }

            _distortionEffect = null;
        }

        override protected function _loadFromObject ( url : String, data : Object ) : void
        {
            if ( checkObject ( data, "distortion" ) )
            {
                var node : Object = data[ "distortion" ];

                if ( checkObject ( node, "size" ) )
                    _distortionSize = node.size;

                if ( checkObject ( node, "velocity" ) )
                    _velocity = node.velocity;

                if ( checkObject ( node, "amplitude" ) )
                    _amplitude = node.amplitude;

                if ( checkObject ( node, "direction" ) )
                    parseParamFromVector( _direction, node.direction );

                if ( checkObject ( node, "range" ) )
                {
                    parseParamFromVector ( _range, node.range );
                    _range[ 2 ] = 1.0 - _range[ 2 ];
                    _range[ 3 ] = 1.0 - _range[ 3 ];
                }

                var frequence : Number = 3.0;
                if ( checkObject ( node, "frequence" ) )
                {
                    frequence = node.frequence;
                }

                _passVal[ 0 ] = _distortionSize;
                var rangeY : Number = Math.abs ( _range[ 3 ] - _range[ 2 ] );
                var cycleSize : Number = 0.9 * rangeY / frequence;
                _passVal[ 1 ] = cycleSize - _distortionSize;
                _passVal[ 2 ] = _amplitude / rangeY;
                _passVal[ 3 ] = cycleSize;

                _currentPos[ 1 ] = _range[ 2 ] - 0.9 * rangeY;
            }
        }

        override public function attachToTarget ( target : IFXModify ) : void
        {
            super.attachToTarget ( target );
            setDistortion ();
        }

        override protected virtual function _reset () : void
        {
            _currentLife = 0.0;
            if ( _distortionEffect != null )
                setDistortion ( false );
            _distortionEffect = null;
        }

        override public function get isDead () : Boolean
        {
            if ( _loop && _currentLife > _life )
            {
                _reset ();
            }

            return _currentLife > _life;
        }

        override public function update ( deltaTime : Number ) : void
        {
            _currentLife += deltaTime;
            if ( _distortionEffect == null )
                setDistortion ( true );

            if ( _distortionEffect == null ) return;

            var currentEnd : Number = _currentPos[ 1 ];

            var rangeY : Number = Math.abs( _range[ 3 ] - _range[ 2 ] );
            var stepS : Number = _velocity * deltaTime;

            currentEnd -= stepS;
            var tempVal : Number = currentEnd - _range[ 3 ];
            if ( tempVal < 0.0 )
            {
                currentEnd = _range[ 2 ] - Math.abs ( tempVal );
            }

            var currentStart : Number = currentEnd + 0.9 * rangeY;
            if ( currentStart > _range[ 2 ] )
            {
                currentStart = currentEnd - 0.1 * rangeY;
            }

            _currentPos[ 0 ] = currentStart;
            _currentPos[ 1 ] = currentEnd;
            _currentPos[ 2 ] = currentStart;
            _currentPos[ 3 ] = currentEnd;
            if ( currentStart < currentEnd )
            {
                _currentPos[ 0 ] = _range[ 2 ];
                _currentPos[ 3 ] = _range[ 3 ];
            }

            _distortionEffect.currentPos = _currentPos;
        }

        private function parseParamFromVector ( vec : Vector.<Number>, data : Object ) : void
        {
            vec[ 0 ] = data.x;
            vec[ 1 ] = data.y;
            vec[ 2 ] = data.z;
            vec[ 3 ] = data.w;
        }

        private function setDistortion ( bEnable : Boolean = true ) : void
        {
            if ( _theTarget != null && _theTarget.theObject != null )
            {
                var effects : Vector.<FilterEffect> = _theTarget.theObject.setFilter ( _theTarget.renderableObject, DistortionEffect.Name, bEnable );
                if ( effects == null ) return;

                _distortionEffect = effects[ 0 ] as DistortionEffect;
                _distortionEffect.direction = _direction;
                _distortionEffect.range = _range;
                _distortionEffect.distortionSize = _passVal;
                _distortionEffect.currentPos = _currentPos;
            }
        }

        private var _currentPos : Vector.<Number> = Vector.<Number> ( [ 0.0, 1.0, 0.0, 1.0 ] );

        private var _direction : Vector.<Number> = Vector.<Number> ( [ 0.0, 1.0, 0.0, 0.0 ] );
        private var _range : Vector.<Number> = Vector.<Number> ( [ 0.0, 1.0, 0.0, 1.0 ] );
        private var _passVal : Vector.<Number> = Vector.<Number> ( [ 0.0, 1.0, 0.0, 0.0 ] );
        private var _velocity : Number = 0.1;
        private var _amplitude : Number = 0.05;
        private var _distortionSize : Number = 0.05;

        private var _currentLife : Number = 0.0;

        private var _distortionEffect : DistortionEffect = null;
    }
}
