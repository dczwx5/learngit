//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/21.
 */
package kof.game.pathing.astar.node {

public interface INodeList {
    function clear() : void;
    function get length() : int;
    function pop() : CNode;
    // function getNode(gridX:int, gridY:int) : CNode;
    function add(insertNode:CNode) : void;
    function isExist(findNode:CNode) : Boolean ;

}
}
