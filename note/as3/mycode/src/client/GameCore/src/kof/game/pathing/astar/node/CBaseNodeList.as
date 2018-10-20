//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/21.
 */
package kof.game.pathing.astar.node {

public class CBaseNodeList implements INodeList {
    public function CBaseNodeList() {
        _list = [];
    }
    [Inline]
    public function clear() : void {
        if (_list.length > 0) _list = [];
    }
    [Inline]
    public function get length() : int {
        return _list.length;
    }
    [Inline]
    public function pop() : CNode {
        return _list.pop();
    }
    [Inline]
    public function add(node:CNode) : void {
        _list.push(node);
    }
//    public function getNode(gridX:int, gridY:int) : CNode {
//        for each (var node:CNode in _list) {
//            if (node.gridX == gridX && node.gridY == gridY) {
//                return node;
//            }
//        }
//        return null;
//    }

    public function isExist(findNode:CNode) : Boolean {
        for each (var node:CNode in _list) {
            // if (node.gridX == gridX && node.gridY == gridY) {
            if (node == findNode) {
                return true;
            }
        }
        return false;
    }

    protected var _list:Array;
}
}
