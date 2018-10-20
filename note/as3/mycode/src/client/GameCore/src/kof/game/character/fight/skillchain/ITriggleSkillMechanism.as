//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/7/15.
//----------------------------------------------------------------------
package kof.game.character.fight.skillchain {


/**
 * 触发机制是自动还是需要手动的
 */
public interface ITriggleSkillMechanism {
     function dispose() : void;
     function isEvaluate() : Boolean;
     function onTransfer() : void;
     function reset() : void;
     function exitMechanism() : void;
     function get modeType() : int;
}
}
