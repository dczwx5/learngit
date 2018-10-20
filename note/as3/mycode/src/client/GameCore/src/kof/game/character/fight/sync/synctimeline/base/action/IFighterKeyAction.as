//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/5/29.
//----------------------------------------------------------------------
package kof.game.character.fight.sync.synctimeline.base.action {

import QFLib.Interface.IDisposable;

import kof.message.CAbstractPackMessage;

public interface IFighterKeyAction{
    function replay() : void;
    function clear() : void;
    function get actionData() : CAbstractPackMessage;
    function set actionData( msg : CAbstractPackMessage) : void;
    function get type() : int;
    function get actionCategory() : int;
}
}
