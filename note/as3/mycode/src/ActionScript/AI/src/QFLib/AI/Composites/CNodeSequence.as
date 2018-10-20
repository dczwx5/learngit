/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/5/7.
 * Time: 11:13
 */
package QFLib.AI.Composites {

    import QFLib.AI.BaseNode.CBaseNode;
    import QFLib.AI.BaseNode.CBaseNodeComposites;
    import QFLib.AI.CAIObject;
    import QFLib.AI.Enum.CNodeRunningStatusEnum;
    import QFLib.AI.events.CAIEvent;

    public class CNodeSequence extends CBaseNodeComposites {
        /*当前节点索引*/
        private var m_currentNodeIndex : int = 0;
        //上一次子节点执行状态
        private var m_lastChildNodeState : int = -1;

        public function CNodeSequence( parentNode : CBaseNode, nodeName : String, nodeIndex : int ) {
            super( parentNode );
            if ( nodeIndex > -1 ) {
                setTemplateIndex( nodeIndex );
                setName( nodeIndex + "_" + nodeName );
            }
            else {
                setName( nodeName );
            }
        }

        override public function set aiObj( value : CAIObject ) : void {
            _aiObj = value;
            _aiObj.addEventListener( CAIEvent.OVERRIDE_ACTION, _resetExcuteNode );
        }

        private function _resetExcuteNode( e : CAIEvent ) : void {
            var index : String = getName().split( "_" )[ 0 ];
            if ( e.data.tempIndex != index ) {
                m_currentNodeIndex = 0;
                m_lastChildNodeState = CNodeRunningStatusEnum.FAIL;
            }
        }

        override protected function _doEvaluate( input : Object ) : Boolean {
            return true;
        }

        override protected function _doTransition( input : Object ) : void {
            m_currentNodeIndex = 0;
        }

        override protected function _doTick( input : Object ) : int {
            var isFinish : int = CNodeRunningStatusEnum.SUCCESS;
            if ( !_checkIndex( m_currentNodeIndex ) ) {
                m_currentNodeIndex = 0;
            }
            for ( var i : int = m_currentNodeIndex; i < m_childNodeCount; i++ ) {
                var node : CBaseNode = m_childNodeVec[ i ];
                if ( m_lastChildNodeState == CNodeRunningStatusEnum.EXECUTING ) {
                    isFinish = node.tick( input );
                } else {
                    if ( node.evaluate( input ) ) {
                        isFinish = node.tick( input );
                    }
                    else {
                        m_currentNodeIndex = 0;
                        m_lastChildNodeState = CNodeRunningStatusEnum.FAIL;
                        return CNodeRunningStatusEnum.FAIL;
                    }
                }
                if ( isFinish != CNodeRunningStatusEnum.SUCCESS ) {
                    break;
                }
                if ( isFinish == CNodeRunningStatusEnum.SUCCESS ) {
                    m_lastChildNodeState = CNodeRunningStatusEnum.SUCCESS;
                }
            }
            m_currentNodeIndex = i;
            if ( isFinish == CNodeRunningStatusEnum.FAIL ) {
                m_currentNodeIndex = 0;
                m_lastChildNodeState = isFinish;
                return CNodeRunningStatusEnum.FAIL;
            }
            if ( isFinish == CNodeRunningStatusEnum.EXECUTING ) {
                m_lastChildNodeState = isFinish;
                return CNodeRunningStatusEnum.EXECUTING;
            }
            m_lastChildNodeState = isFinish;
            return isFinish;
        }
    }
}
