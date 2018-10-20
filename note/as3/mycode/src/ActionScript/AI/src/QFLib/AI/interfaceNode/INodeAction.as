//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/5/30.
 * Time: 10:29
 */
package QFLib.AI.interfaceNode {

    public interface INodeAction {
        function _doEnter(input:Object):void;
        function _doExecute(input:Object):int;
        function _doExit(input:Object):void;
    }
}
