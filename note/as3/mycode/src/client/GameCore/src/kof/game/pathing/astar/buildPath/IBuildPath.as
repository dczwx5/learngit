//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/21.
 */
package kof.game.pathing.astar.buildPath {

import kof.game.pathing.astar.node.CNode;

public interface IBuildPath {
    function buildPath(startNode:CNode, endNode:CNode) : Array ; // CVector2 list
}
}
