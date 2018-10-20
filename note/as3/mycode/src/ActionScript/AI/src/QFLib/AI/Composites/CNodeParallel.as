//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/5/7.
 * Time: 11:24
 */
package QFLib.AI.Composites {

    import QFLib.AI.BaseNode.CBaseNode;
    import QFLib.AI.BaseNode.CBaseNodeComposites;
    import QFLib.AI.BaseNode.CBaseNodeCondition;
    import QFLib.AI.Enum.CNodeRunningStatusEnum;

    /**并行节点，是用for循环模拟的，依次执行子节点，
     * 每次进入都依次遍历所有子节点
     */
    public class CNodeParallel extends CBaseNodeComposites {
        public function CNodeParallel( parentNode : CBaseNode, nodeName : String ) {
            super( parentNode );
            setName( nodeName );
        }

        override protected function _doEvaluate( input : Object ) : Boolean {
            return true;
        }

        override protected function _doTransition( input : Object ) : void {
            for ( var j : int = 0; j < m_childNodeCount; j++ ) {
                var node : CBaseNode = m_childNodeVec[ j ];
                node.transition( input );
            }
        }

        override protected function _doTick( input : Object ) : int {
            var iCordFailNode : int = 0;
            var iCordExecuting : int = 0;
            var isFinish : int = CNodeRunningStatusEnum.SUCCESS;

            for ( var i : int = 0; i < m_childNodeCount; i++ ) {
                var node : CBaseNode = m_childNodeVec[ i ];
                if ( node.evaluate( input ) ) {
                    isFinish = node.tick( input );
                    if ( isFinish == CNodeRunningStatusEnum.EXECUTING ) {
                        iCordExecuting++;
                    }
                    if ( isFinish == CNodeRunningStatusEnum.FAIL ) {
                        iCordFailNode++;
                    }
                }
                else {
                    iCordFailNode++;
                }
            }
            if ( iCordExecuting > 0 ) {
                return CNodeRunningStatusEnum.EXECUTING;
            }
            if ( iCordFailNode > 0 ) {
                iCordFailNode = 0;
                return CNodeRunningStatusEnum.FAIL;
            }
            return CNodeRunningStatusEnum.SUCCESS;
        }
    }
}
