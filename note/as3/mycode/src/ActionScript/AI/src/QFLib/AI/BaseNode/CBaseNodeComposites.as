//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/5/30.
 * Time: 10:42
 */
package QFLib.AI.BaseNode {

import QFLib.AI.Enum.CNodeRunningStatusEnum;

public class CBaseNodeComposites extends CBaseNode {
        public function CBaseNodeComposites(parent:CBaseNode) {
            super(parent);
        }
        /**进入符合节点的固定条件*/
        override protected function _doEvaluate(input:Object):Boolean
        {
            return true;
        }
        /**节点更新方法，主要根据规则处理子节点*/
        override protected function _doTick(input:Object):int
        {
            return CNodeRunningStatusEnum.SUCCESS;
        }
    }
}
