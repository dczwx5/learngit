//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/21.
 */
package kof.game.pathing.astar {

import kof.game.pathing.astar.buildPath.IBuildPath;
import kof.game.pathing.astar.neighbor.INeighborProcess;
import kof.game.pathing.astar.node.CNode;
import kof.game.pathing.astar.node.INodeList;
import kof.game.pathing.astar.tile.ITile;

public interface IAStar {
    function initialByGridData(blockGrids:Object, xCount:int) : void ;

    function findPath(stGridX:int, stGridY:int, endGridX:int, endGridY:int) : Array;
    function findReversePath(stGridX:int, stGridY:int, endGridX:int, endGridY:int) : Array;
    // function isWalkable(gridX:int, gridY:int) : Boolean;
    function isInClose(node:CNode) : Boolean;
    function isInOpen(node:CNode) : Boolean;
    function calcH(node:CNode, endNode:CNode) : int;

    function set tileUtil(v:ITile) : void;
    function set openList(v:INodeList) : void;
    function set closeList(v:INodeList) : void;
    function set buildPath(v:IBuildPath) : void;
    function set neighborProcess(v:INeighborProcess) : void;
    function getNode(gridX:int, gridY:int) : CNode ;

}
}
