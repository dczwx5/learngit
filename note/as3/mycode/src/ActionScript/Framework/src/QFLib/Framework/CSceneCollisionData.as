//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by Dan Lin on 2016/6/27.
//----------------------------------------------------------------------

package QFLib.Framework
{
    import QFLib.Math.CAABBox2;
    import QFLib.Math.CVector2;

    public class CSceneCollisionData
	{
		public function CSceneCollisionData()
		{
		}

		public function dispose() : void
		{
		}

        public function get movableBoxID() : int
        {
            return m_iMovableBoxID;
        }

        // set / get movable constrain box
        public function setMovableBoxCenterExtValue( fCenterX: Number, fCenterY: Number, fExtX: Number, fExtY: Number, bLockMovableConstrainBoxImmediately : Boolean = false ) : void
        {
            if( m_theMovableBox == null ) m_theMovableBox = new CAABBox2( CVector2.ZERO );
            else
            {
                // check if the same size of movable box
                if( m_theMovableBox.center.equalsValueWithinError( fCenterX, fCenterY ) && m_theMovableBox.ext.equalsValueWithinError( fExtX, fExtY ) ) return ;
            }

            m_theMovableBox.setCenterExtValue( fCenterX, fCenterY, fExtX, fExtY );

            m_bLockMovableBoxImmediately = bLockMovableConstrainBoxImmediately;

            m_iMovableBoxID = ++m_iMovableBoxIDCounter;
        }
        public function set movableBox( theAABB : CAABBox2 ) : void
        {
            if( m_theMovableBox != null && theAABB != null )
            {
                // check if the same size of movable box
                if( m_theMovableBox.equalsWithinError( theAABB ) ) return ;
            }

            m_theMovableBox = theAABB;

            if( m_theMovableBox != null )
            {
                m_iMovableBoxID = ++m_iMovableBoxIDCounter;
            }
            else m_iMovableBoxID = 0;
        }
        public function get movableBox() : CAABBox2
        {
            return m_theMovableBox;
        }

        public function setMovableBoxLockMode( bLockImmediate : Boolean ) : void
        {
            m_bLockMovableBoxImmediately = bLockImmediate;
        }
        public function get movableBoxLockImmediately() : Boolean
        {
            return m_bLockMovableBoxImmediately;
        }

        public function isInMovableBox( fPosX : Number, fPosY : Number, fPosZ : Number ) : Boolean
        {
            if( m_theMovableBox == null ) return true;

            fPosZ *= CObject.TAN_THETA_OF_CAMERA; // to convert 3D position to 2D screen space
            var x : Number = fPosX;
            var y : Number = -fPosY + fPosZ;

            if( m_theMovableBox.isCollidedVertexValue( x, y ) ) return true;
            else return false;
        }

        //
		//
        private var m_theMovableBox : CAABBox2 = null;
        private var m_bLockMovableBoxImmediately : Boolean = true;
        private var m_iMovableBoxID : int = 0;
        private var m_iMovableBoxIDCounter : int = 0;
    }
}
