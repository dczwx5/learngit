//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2016/10/13.
 */
package kof.game.common.view.component {

public interface IUICompeontBase {
    function dispose() : void;
    function refresh() : void;
    function clear() : void;
    function set compoentMap(v:IUICompeontBase) : void;
}
}
