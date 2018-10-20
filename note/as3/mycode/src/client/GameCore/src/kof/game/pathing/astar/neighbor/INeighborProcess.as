//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/21.
 */
package kof.game.pathing.astar.neighbor {

import kof.game.pathing.astar.node.CNode;
import kof.game.pathing.astar.node.INodeList;

public interface INeighborProcess {
    function process(node:CNode, endNode:CNode, neighborList:Array, openList:INodeList) : int;

}
}
