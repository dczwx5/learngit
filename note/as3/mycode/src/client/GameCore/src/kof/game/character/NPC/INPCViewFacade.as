//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/1/20.
 */
package kof.game.character.NPC {

import QFLib.Math.CVector3;

public interface INPCViewFacade {
    function showNPCView(data:Object,position:CVector3,callbackFun:Function):void;
    function closeNPCView():void;
    function isOpen():Boolean;
}
}
