//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/11/14.
//----------------------------------------------------------------------
package kof.game.character.fight.sync {

/**
 * 需要同步的接口
 */
public interface INeedSync {
    /**
     * 接受网络的同步
     */
    function syncTo( ) : void;

    /**
     * 发送到网络同步
     */
    function syncFrom( ) : void;
}
}
