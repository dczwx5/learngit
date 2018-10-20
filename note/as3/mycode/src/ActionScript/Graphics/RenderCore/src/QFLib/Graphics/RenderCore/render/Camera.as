package QFLib.Graphics.RenderCore.render
{
    import QFLib.Math.CVector2;

    import flash.geom.Matrix3D;
	import flash.geom.Point;

	public class Camera implements ICamera
	{
		private static var s_mxProjectionData : Vector.<Number> = new <Number>[ 1, 0, 0, 0,  0, 1, 0, 0,  0, 0, 1, 0,  -1, 1, 0, 1 ];

		public function Camera()
		{
			m_mxProjection	= new Matrix3D();
			m_mxProjection.copyRawDataFrom( s_mxProjectionData );
		}

        [Inline]
        public function get enabled() : Boolean
        {
            return m_bEnabled;
        }
        [Inline]
        public function set enabled( bEnabled : Boolean ) : void
        {
            m_bEnabled = bEnabled;
        }

		// ICamera
		public function get matrixProj() : Matrix3D
		{
            if ( m_CameraDirty )
            {
                m_fViewportX = m_Position.x - m_fWidth * 0.5;
                m_fViewportY = m_Position.y - m_fHeight * 0.5;

                computeOrthoProjectionMatrix();
                m_CameraDirty = false;
            }

			return m_mxProjection;
		}
		public function set matrixProj( matrix : Matrix3D ) : void
		{
			m_mxProjection.copyFrom( matrix );
		}

        [Inline]
		public function set cameraDirty ( value : Boolean ) : void
		{
			m_CameraDirty = value;
		}

		public function setPosition( x : Number, y : Number ) : void
		{
            //if( m_Position.x != x || m_Position.y != y )
            {
                m_Position.x = x;
                m_Position.y = y;

                m_CameraDirty = true;
            }
        }
		
		public function setOrthoSize( width : Number, height : Number ) : void
		{
            if( m_fHeight != height || m_fWidth != width)
            {
                m_fWidth = width;
                m_fHeight = height;

                m_CameraDirty = true;
            }
        }

		[Inline]
        public function get viewportWidth() : Number
		{
			return m_fWidth;
		}

        [Inline]
        public function get viewportHeight() : Number
		{
			return m_fHeight;
		}

        [Inline]
        public function get viewportX() : Number
		{
            if ( m_CameraDirty )
            {
                m_fViewportX = m_Position.x - m_fWidth * 0.5;
            }
			return m_fViewportX;
		}

        [Inline]
		public function get viewportY() : Number
		{
            if ( m_CameraDirty )
            {
                m_fViewportY = m_Position.y - m_fHeight * 0.5;
            }
			return m_fViewportY;
		}

        [Inline]
        public function get scale() : Number
		{
			return 1.0;
		}

		public function screenToWorld( x : Number, y : Number, worldPos : CVector2 ) : void
		{
            worldPos.x = x + viewportX;
            worldPos.y = y + viewportY;
		}

        [Inline]
        public function get cullingMask() : uint
		{
			return m_iCullingMask;
		}
        [Inline]
        public function set cullingMask( value : uint ) : void
		{
			m_iCullingMask = value;
		}

        [Inline]
        public function get depth() : int
		{
			return m_iDepth;
		}

        [Inline]
        public function set depth( value : int ) : void
		{
			m_iDepth = value;

			if (m_fnDepthChangeListener != null)
			{
				m_fnDepthChangeListener();
			}
		}

        [Inline]
        public function get clearMask() : int
        {
            return m_iClearMask;
        }
        [Inline]
        public function set clearMask( value : int ) : void
        {
            m_iClearMask = value;
        }

        internal function setDepthChangeListener( value : Function ) : void
		{
			m_fnDepthChangeListener = value;
		}

        private function computeOrthoProjectionMatrix () : void
        {
            s_mxProjectionData[0] = 2.0 / m_fWidth;
            s_mxProjectionData[5] = -2.0 / m_fHeight;
            s_mxProjectionData[12] = -(2 * m_Position.x) / m_fWidth;
            s_mxProjectionData[13] = (2 * m_Position.y) / m_fHeight;
            m_mxProjection.copyRawDataFrom(s_mxProjectionData);
        }

        //
        //
        private var m_mxProjection : Matrix3D;

        private var m_Position : CVector2 = CVector2.zero();

        private var m_fViewportX : Number = 0.0;
        private var m_fViewportY : Number = 0.0;
        private var m_fWidth : Number = 0.0;
        private var m_fHeight : Number = 0.0;

        private var m_iCullingMask : uint = 1;
        private var m_iClearMask : int = 0;

        private var m_iDepth : int = 0;
        private var m_fnDepthChangeListener : Function;

        private var m_CameraDirty : Boolean = true;
        private var m_bEnabled : Boolean = true;
	}
}