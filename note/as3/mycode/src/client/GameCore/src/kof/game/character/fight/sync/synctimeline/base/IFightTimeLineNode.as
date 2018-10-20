//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/5/23.
//----------------------------------------------------------------------
package kof.game.character.fight.sync.synctimeline.base {

public interface IFightTimeLineNode {
    function get nextLocalNode() : CBaseFightTimeLineNode;
    function get nextGlobalNode() : CBaseFightTimeLineNode;
    function get nodeFightData() : CFightSyncNodeData;
    function  get prev() : CBaseFightTimeLineNode;
    function  get next() : CBaseFightTimeLineNode;
}
}
