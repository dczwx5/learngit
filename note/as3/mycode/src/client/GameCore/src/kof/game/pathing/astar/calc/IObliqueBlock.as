//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/21.
 */
package kof.game.pathing.astar.calc {

import kof.game.pathing.astar.node.CNode;

public interface IObliqueBlock {
    function isBlock(stNode:CNode, targetNode:CNode) : Boolean ;
}
}
