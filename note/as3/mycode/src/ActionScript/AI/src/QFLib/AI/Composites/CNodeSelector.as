/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/5/7.
 * Time: 11:11
 */
package QFLib.AI.Composites {

    import QFLib.AI.BaseNode.CBaseNode;
    import QFLib.AI.BaseNode.CBaseNodeComposites;
    import QFLib.AI.CAIObject;
    import QFLib.AI.Enum.CNodeRunningStatusEnum;
    import QFLib.AI.events.CAIEvent;

    public class CNodeSelector extends CBaseNodeComposites {
        /*上一个选择的节点索引*/
        protected var m_lastSelectIndex : int = 0;
        protected var m_lastNodeState : int = -1;

        public function CNodeSelector( parentNode : CBaseNode, nodeName : String, nodeIndex : int ) {
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
                m_lastSelectIndex = 0;
                m_lastNodeState = CNodeRunningStatusEnum.FAIL;
            }
        }

        override protected function _doEvaluate( input : Object ) : Boolean {
            return true;
        }

        override protected function _doTransition( input : Object ) : void {
//		if(_checkIndex(m_lastSelectIndex))
//		{
//			var node:CBaseNode=m_childNodeVec[m_lastSelectIndex];
//			node.transition(input);
//		}
//		m_lastSelectIndex=m_childNodeCount;
        }

        override protected function _doTick( input : Object ) : int {
            var isFinish : int = CNodeRunningStatusEnum.SUCCESS;
            if ( !_checkIndex( m_lastSelectIndex ) ) {
                m_lastSelectIndex = 0;
            }
            for ( var i : int = m_lastSelectIndex; i < m_childNodeCount; i++ ) {
                var node : CBaseNode = m_childNodeVec[ i ];
                if ( m_lastNodeState == CNodeRunningStatusEnum.EXECUTING ) {
                    isFinish = node.tick( input );
                } else {
                    if ( node.evaluate( input ) ) {
                        isFinish = node.tick( input );
                    }
                    else {
                        continue;
                    }
                }
                if ( isFinish == CNodeRunningStatusEnum.SUCCESS ) {
                    m_lastSelectIndex++;
                    m_lastNodeState = CNodeRunningStatusEnum.SUCCESS;
                    return CNodeRunningStatusEnum.SUCCESS;
                }
                if ( isFinish == CNodeRunningStatusEnum.EXECUTING ) {
                    m_lastSelectIndex = i;
                    m_lastNodeState = CNodeRunningStatusEnum.EXECUTING;
                    return CNodeRunningStatusEnum.EXECUTING;
                }
            }
            m_lastNodeState = CNodeRunningStatusEnum.FAIL;
            return CNodeRunningStatusEnum.FAIL;
        }
    }
}
