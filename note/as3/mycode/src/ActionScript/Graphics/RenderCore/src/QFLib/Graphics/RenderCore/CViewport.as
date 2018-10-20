package QFLib.Graphics.RenderCore
{
    import QFLib.Math.CAABBox2;
    import QFLib.Math.CVector2;

    public class CViewport
	{
        // min / max range from: 0.0 to 1.0
		public function CViewport( fMinX : Number, fMinY : Number, fMaxX : Number, fMaxY : Number )
		{
            set( fMinX, fMinY, fMaxX, fMaxY );
		}
        public function dispose() : void
        {
            m_theAABB = null;
        }

        public function set( fMinX : Number, fMinY : Number, fMaxX : Number, fMaxY : Number ) : void
        {
            m_theAABB.setValue( fMinX, fMinY, fMaxX, fMaxY );
        }
        public function setCenter( vCenter : CVector2 ) : void
        {
            m_theAABB.setCenter( vCenter );
        }
        public function setExt( vExt : CVector2 ) : void
        {
            m_theAABB.setExt( vExt );
        }
        public function setCenterExt( vCenter : CVector2, vExt : CVector2 ) : void
        {
            m_theAABB.setCenterExt( vCenter, vExt );
        }
        public function setCenterExtValue( fCenterX : Number, fCenterY : Number, fExtX : Number, fExtY : Number ) : void
        {
            m_theAABB.setCenterExtValue( fCenterX, fCenterY, fExtX, fExtY );
        }

        public function get center() : CVector2
        {
            return m_theAABB.center;
        }
        public function get ext() : CVector2
        {
            return m_theAABB.ext;
        }
        public function get min() : CVector2
        {
            return m_theAABB.min;
        }
        public function get max() : CVector2
        {
            return m_theAABB.max;
        }

        public function get x() : Number
        {
            return m_theAABB.min.x;
        }
        public function get y() : Number
        {
            return m_theAABB.min.y;
        }
        public function get width() : Number
        {
            return m_theAABB.max.x - m_theAABB.min.x;
        }
        public function get height() : Number
        {
            return m_theAABB.max.y - m_theAABB.min.y;
        }


        //
        //
        private var m_theAABB : CAABBox2 = new CAABBox2( CVector2.ZERO );
    }
}