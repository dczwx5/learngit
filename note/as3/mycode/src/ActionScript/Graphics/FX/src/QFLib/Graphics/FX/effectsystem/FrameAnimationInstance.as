package QFLib.Graphics.FX.effectsystem
{
    import QFLib.Graphics.RenderCore.starling.core.Starling;
    import QFLib.Graphics.RenderCore.starling.utils.VertexData;
    import QFLib.Math.CVector2;

    public class FrameAnimationInstance extends BaseEffectInstance
    {
        private var _start : int = 0;
        private var _end : int = 0;
        private var _loopTimes : int = 1;
        private var _currentLoopTimes : int = 0;
        private var _interval : Number = 0.1;
        private var _velocityW : Number = 0.0;
        private var _startRotation : Number = 0.0;
        private var _maxLife : Number;
        private var _rotationX : Number = 0.0;

        public function FrameAnimationInstance ()
        {
            _maxLife = (_end - _start + 1) * _interval;
            _currentLife = 0.0;

            _material.tileX = _material.tileY = 1;
            _material.isTiling = true;

            _rotationX = _startRotation;

            //vertices
            _vertices = new VertexData ( 4 );
        }

        public override function dispose () : void { super.dispose (); }

        public override function get isDead () : Boolean
        {
            if ( _loop && _currentLoopTimes <= 0 )
                _currentLoopTimes = _loopTimes;

            return _currentLoopTimes <= 0;
        }

        protected override function _loadFromObject ( data : Object ) : void
        {
            if ( checkObject ( data, "start" ) )
            {
                _start = data.start;
            }

            if ( checkObject ( data, "end" ) )
            {
                _end = data.end;
            }

            if ( checkObject ( data, "loopTimes" ) )
            {
                _loopTimes = data.loopTimes;
            }

            if ( checkObject ( data, "interval" ) )
            {
                _interval = data.interval;
            }

            if ( checkObject ( data, "velocityW" ) )
            {
                _velocityW = data.velocityW;
            }

            //radian
            if ( checkObject ( data, "startRotation" ) )
            {
                _startRotation = -data.startRotation;
            }

            _currentLoopTimes = _loopTimes;
            _maxLife = (_end - _start + 1) * _interval;
            _currentLife = 0.0;
            _rotationX = _startRotation;
        }

        protected override function _updateMesh () : void
        {
            if ( !Starling.current.contextValid ) return;

            var tileID : int = currentTiling;

            var life : Number = lifeNormalized;
            var size : CVector2 = _keyFrame.getSize ( life );
            var cosR : Number = Math.cos ( _rotationX );
            var sinR : Number = Math.sin ( _rotationX );

            var axisR : CVector2 = sVector2DHelper0;
            var axisQ : CVector2 = sVector2DHelper1;

            axisR.x = cosR;
            axisR.y = sinR;
            axisQ.x = -sinR;
            axisQ.y = cosR;

            var axisRXmulSizeX : Number = axisR.x * size.x;
            var axisQXmulSizeY : Number = axisQ.x * size.y;

            var axisRYmulSizeX : Number = axisR.y * size.x;
            var axisQYmulSizeY : Number = axisQ.y * size.y;

            //update vertex position
            var xPos : Number = -axisRXmulSizeX - axisQXmulSizeY;
            var yPos : Number = -axisRYmulSizeX - axisQYmulSizeY;
            _vertices.setPosition ( 0, xPos, yPos );

            xPos = axisRXmulSizeX - axisQXmulSizeY;
            yPos = axisRYmulSizeX - axisQYmulSizeY;
            _vertices.setPosition ( 1, xPos, yPos );

            xPos = axisRXmulSizeX + axisQXmulSizeY;
            yPos = axisRYmulSizeX + axisQYmulSizeY;
            _vertices.setPosition ( 2, xPos, yPos );

            xPos = -axisRXmulSizeX + axisQXmulSizeY;
            yPos = -axisRYmulSizeX + axisQYmulSizeY;
            _vertices.setPosition ( 3, xPos, yPos );

            //update vertex color
            var color : uint = _keyFrame.getColor ( life );
            var alpha : Number = ( color & 0xff ) / 255.0;

            color = ( color >> 8 ) & 0x00FFFFFF;
            _vertices.setColorAndAlpha ( 0, color, alpha );
            _vertices.setColorAndAlpha ( 1, color, alpha );
            _vertices.setColorAndAlpha ( 2, color, alpha );
            _vertices.setColorAndAlpha ( 3, color, alpha );

            //update vertex uv
            var offset : int = _material.getUVOffsetByTileID ( tileID );
            var uvList : Vector.<Number> = _material.uvList;
            _vertices.setTexCoords ( 0, uvList[ offset ], uvList[ offset + 1 ] );
            _vertices.setTexCoords ( 1, uvList[ offset + 2 ], uvList[ offset + 3 ] );
            _vertices.setTexCoords ( 2, uvList[ offset + 4 ], uvList[ offset + 5 ] );
            _vertices.setTexCoords ( 3, uvList[ offset + 6 ], uvList[ offset + 7 ] );
        }

        protected override function _update ( deltaTime : Number ) : void
        {
            super._update( deltaTime );
            _currentLife += deltaTime;

            _rotationX += _velocityW;
            if ( _currentLife > _maxLife )
            {
                if ( _currentLoopTimes > 0 )
                {
                    _currentLife -= _maxLife;
                    _currentLoopTimes--;
                }
            }
        }

        protected override function _reset () : void
        {
            super._reset ();

            _currentLoopTimes = _loopTimes;
            _currentLife = 0;
            _maxLife = (_end - _start + 1) * _interval;
            _rotationX = _startRotation;
        }

        [Inline]
        private function get currentTiling () : int
        {
            return _start + Math.floor ( lifeNormalized * (_end - _start + 1) );
        }

        [Inline]
        private function get lifeNormalized () : Number
        {
            var normalizedLife : Number = _currentLife / _maxLife;
            normalizedLife = normalizedLife - Math.floor ( normalizedLife );

            return normalizedLife;
        }
    }
}