//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/5/6.
 * Time: 12:24
 */
package QFLib.AI.BaseNode {

    import QFLib.AI.CAIObject;
    import QFLib.AI.Enum.CActionNodeStatusEnum;
    import QFLib.AI.Enum.CNodeRunningStatusEnum;
    import QFLib.AI.interfaceNode.INodeAction;

    public class CBaseNodeAction extends CBaseNode implements INodeAction {
        /*节点当前运行状态*/
        protected var m_currentStatus : int = CActionNodeStatusEnum.READY;
        /*是否需要退出*/
        protected var m_needExit : Boolean = false;

        public function CBaseNodeAction( parentNode : CBaseNode, data : CAIObject = null, nodeName : String = null ) {
            super( parentNode );
        }

        public function _doEnter( input : Object ) : void {
        }

        public function _doExecute( input : Object ) : int {
            return CNodeRunningStatusEnum.SUCCESS;
        }

        public function _doExit( input : Object ) : void {
        }

        override protected function _doTransition( input : Object ) : void {
            if ( m_needExit ) {
                _doExit( input );
            }
            setActiveNode( null );
            m_currentStatus = CActionNodeStatusEnum.READY;
            m_needExit = false;
        }

        override protected function _doTick( input : Object ) : int {
            var isSuccess : int = CNodeRunningStatusEnum.SUCCESS;
            if ( m_currentStatus == CActionNodeStatusEnum.READY ) {
                _doEnter( input );
                m_needExit = true;
                m_currentStatus = CActionNodeStatusEnum.RUNNING;
                setActiveNode( this );
            }
            if ( m_currentStatus == CActionNodeStatusEnum.RUNNING ) {
                isSuccess = _doExecute( input );
                setActiveNode( this );
                if ( isSuccess == CNodeRunningStatusEnum.SUCCESS || isSuccess == CNodeRunningStatusEnum.FAIL ) {
                    m_currentStatus = CActionNodeStatusEnum.FINISH;
                }
            }
            if ( m_currentStatus == CActionNodeStatusEnum.FINISH ) {
                if ( m_needExit ) {
                    _doExit( input );
                }
                m_currentStatus = CActionNodeStatusEnum.READY;
                m_needExit = false;
                setActiveNode( null );
                return isSuccess;
            }
            return isSuccess;
        }
    }
}
