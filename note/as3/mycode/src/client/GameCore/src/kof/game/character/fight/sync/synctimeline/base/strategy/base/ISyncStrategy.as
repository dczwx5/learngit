//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/5/31.
//----------------------------------------------------------------------
package kof.game.character.fight.sync.synctimeline.base.strategy.base {

import kof.game.character.fight.sync.synctimeline.base.CBaseFightTimeLineNode;
import kof.game.character.fight.sync.synctimeline.base.action.CBaseFighterKeyAction;

public interface ISyncStrategy {
    function takeAction() : void;
    function get action() : CBaseFighterKeyAction;
    function set action( data : CBaseFighterKeyAction ) : void;
    function set timelineNode(node : CBaseFightTimeLineNode) : void;
}
}
