//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/5/7.
 * Time: 10:47
 */
package QFLib.AI.Composites {

    import QFLib.AI.BaseNode.CBaseNode;
    import QFLib.AI.BaseNode.CBaseNodeComposites;
    import QFLib.AI.BaseNode.CBaseNodeCondition;
    import QFLib.AI.Enum.CNodeRunningStatusEnum;

    /*优先选择节点*/
    public class CNodePrioritySelector extends CBaseNodeComposites {
        /*当前选择的节点索引*/
        protected var m_currentSelectIndex : int;
        /*上一个选择的节点索引*/
        protected var m_lastSelectIndex : int;

        public function CNodePrioritySelector( parentNode : CBaseNode, nodeName : String ) {
            super( parentNode )
            setName( nodeName );
        }

        override protected function _doEvaluate( input : Object ) : Boolean {
            return true;
        }

        override protected function _doTransition( input : Object ) : void {
            if ( _checkIndex( m_lastSelectIndex ) ) {
                var node : CBaseNode = m_childNodeVec[ m_lastSelectIndex ];
                node.transition( input );
            }
            m_lastSelectIndex = m_childNodeCount;
        }

        override protected function _doTick( input : Object ) : int {
            var isFinish : int = CNodeRunningStatusEnum.FAIL;
            var node : CBaseNode = null;
            if ( !_checkIndex( m_lastSelectIndex ) ) {
                m_lastSelectIndex = 0;
            }
            var len : int = m_childNodeCount;
            for ( var i : int = 0; i < len; i++ ) {
                var node : CBaseNode = m_childNodeVec[ i ];
                m_currentSelectIndex = i;
                if ( m_lastSelectIndex != m_currentSelectIndex ) {
                    if ( node.evaluate( input ) ) {
                        isFinish = node.tick( input );
                        if ( isFinish == CNodeRunningStatusEnum.SUCCESS ) {
                            if ( _checkIndex( m_lastSelectIndex ) && m_currentSelectIndex < m_lastSelectIndex ) {
                                node = m_childNodeVec[ m_lastSelectIndex ];
                                node.transition( input );
                            }
                            m_lastSelectIndex = m_currentSelectIndex;
                            return CNodeRunningStatusEnum.SUCCESS;
                        }
                        else if ( isFinish == CNodeRunningStatusEnum.EXECUTING ) {
                            if ( _checkIndex( m_lastSelectIndex ) && m_currentSelectIndex < m_lastSelectIndex ) {
                                node = m_childNodeVec[ m_lastSelectIndex ];
                                node.transition( input );
                            }
                            m_lastSelectIndex = m_currentSelectIndex;
                            return CNodeRunningStatusEnum.EXECUTING;
                        } else {
                            continue;
                        }
                    }
                    else {
                        continue;
                    }
                } else {
                    isFinish = node.tick( input );
                    if ( isFinish == CNodeRunningStatusEnum.SUCCESS ) {
                        return CNodeRunningStatusEnum.SUCCESS;
                    }
                    else if ( isFinish == CNodeRunningStatusEnum.EXECUTING ) {
                        return CNodeRunningStatusEnum.EXECUTING;
                    } else {
                        continue;
                    }
                }
            }
            m_lastSelectIndex = len - 1;
            return isFinish;
        }
    }
}
