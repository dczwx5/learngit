//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/5/27.
//----------------------------------------------------------------------
package kof.game.character.fight.sync.synctimeline.base {

public interface IFightTimeLine {
    function createNodeByData( data : CFightSyncNodeData ) : CBaseFightTimeLineNode;
    function deleteNodeByData( data : CFightSyncNodeData ) : Boolean;
    function findNodeByData( data : CFightSyncNodeData ) : CBaseFightTimeLineNode;
    function insertNodeByData( data : CFightSyncNodeData ) : CBaseFightTimeLineNode;
    function get nodeCount() : int;
    function traverse() : void;
}
}
