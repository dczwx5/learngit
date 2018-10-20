//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by tDAN 2016/5/20
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Graphics.Scene
{
    import QFLib.Math.CVector2;

    public class CCameraAnchor
    {
        public function CCameraAnchor( vCenter : CVector2, vExt : CVector2, vOuterExt : CVector2 )
        {
            m_theCenter = vCenter;
            m_theExt = vExt;
            m_theOuterExt = vOuterExt;
        }

        //
        //
        public var m_theCenter : CVector2;
        public var m_theExt : CVector2;
        public var m_theOuterExt : CVector2;

    }
}