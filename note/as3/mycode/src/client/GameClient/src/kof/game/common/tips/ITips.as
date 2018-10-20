//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/12/12.
 */
package kof.game.common.tips {

import morn.core.components.Component;

public interface ITips {
    function addTips(item:Component, args:Array = null) : void;
}
}
