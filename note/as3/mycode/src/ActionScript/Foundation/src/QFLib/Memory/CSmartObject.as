//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/2/17
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Memory
{
    import QFLib.Interface.IDisposable;

    import flash.utils.getQualifiedClassName;

    //
    //
    //
    public class CSmartObject implements IDisposable
    {
        public function CSmartObject()
        {
            if( CSmartObjectSystem.m_bEnableRecording )
            {
                if( CSmartObjectSystem.m_bEnableStackTrace )
                {
                    m_theStackTrace = new Error();
                    m_theStackTrace.name = "";
                }

                m_theSmartObjRecord = CSmartObjectSystem.add( this );
            }
        }

        public virtual function dispose() : void
        {
            if( m_theSmartObjRecord != null )
            {
                CSmartObjectSystem.remove( this );
                m_theSmartObjRecord = null;
            }
        }

        //
        //
        internal function _stackTrace() : String
        {
            if( m_theStackTrace != null ) return m_theStackTrace.getStackTrace();
            else return "";
        }

        internal function _clear() : void
        {
            m_theStackTrace = null;
            m_theSmartObjRecord = null;
        }

        //
        //
        internal var m_theStackTrace : Error = null;
        internal var m_theSmartObjRecord : CSmartObjectRecord = null;
    }
}
