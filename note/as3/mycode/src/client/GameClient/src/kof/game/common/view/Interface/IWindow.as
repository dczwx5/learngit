//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/26.
 */
package kof.game.common.view.Interface {

public interface IWindow {
    function create() : void;
    function show() : void;
    function hide() : void;
    function getChild(type:int) : IWindow;
}
}
