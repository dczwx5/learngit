//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * 头顶冒泡
 * Created by user on 2016/12/9.
 */
package kof.game.bubbles {

import kof.game.core.CGameObject;

public interface IBubblesFacade {

    /**
     * 显示冒泡对话
     * @param actor　说话对象
     * @param value　说话内容
     * @return
     */
    function bubblesTalk(actor:CGameObject, value:String, time:int, position:int = 0, x:int = 0, y:int = 0,  callBack:Function = null, type:int = 0):void;

    /**
     * 隐藏冒泡对话
     * @param actor　说话对象
     * @return
     */
    function hideTalk(Actor:CGameObject):void;

    function stopBubblesTalk():void;

    function startBubblesTalk():void;
}
}
