package QFLib.Graphics.FX.effectsystem
{
    import QFLib.Graphics.RenderCore.starling.utils.VertexData;
    import QFLib.Math.CVector2;

    public class HaloInstance extends BaseEffectInstance
    {
        public var loopLife : Number = 1.0;
        public var rotateVelocity : Number = 1.0;
        public var initialRotation : Number = 0.0;

        private var _currentRotation : Number = 0.0;

        public function HaloInstance ()
        {
            //vertices
            _vertices = new VertexData ( 4 );
        }

        public override function get isDead () : Boolean
        {
            if ( _loop && _currentLife > life )
            {
                _reset ();
            }

            return _currentLife > life;
        }

        public function get currentRotation () : Number
        {
            return _currentRotation;
        }

        public function get normalLife () : Number
        {
            var l : Number = _currentLife / loopLife;
            return l - Math.floor ( l );
        }

        protected override function _loadFromObject ( data : Object ) : void
        {
            if ( checkObject ( data, "loopLife" ) )
                loopLife = data.loopLife;

            //unity和flash旋转正向不同
            if ( checkObject ( data, "rotateVelocity" ) )
                rotateVelocity = -data.rotateVelocity;

            if ( checkObject ( data, "initialRotation" ) )
                initialRotation = -data.initialRotation;

            _reset ();
        }

        protected override function _updateMesh () : void
        {
            var size : CVector2 = _keyFrame.getSize ( normalLife );
            var cosR : Number = Math.cos ( _currentRotation );
            var sinR : Number = Math.sin ( _currentRotation );

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
            var color : uint = _keyFrame.getColor ( normalLife );
            var alpha : Number = ( color & 0xff ) / 255.0;
            color = ( color >> 8 ) & 0x00FFFFFF;
            _vertices.setColorAndAlpha ( 0, color, alpha );
            _vertices.setColorAndAlpha ( 1, color, alpha );
            _vertices.setColorAndAlpha ( 2, color, alpha );
            _vertices.setColorAndAlpha ( 3, color, alpha );

            //update vertex uv
            var offset : int = _material.getUVOffsetByNormalLife ( normalLife );
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
            _currentRotation += deltaTime * rotateVelocity;
        }

        protected override function _reset () : void
        {
            super._reset ();
            _currentLife = 0.0;
            _currentRotation = initialRotation;
        }
    }
}