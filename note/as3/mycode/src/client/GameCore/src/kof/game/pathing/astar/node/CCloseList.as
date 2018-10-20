//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/21.
 * modify by auto on 2017/5.12
 */
package kof.game.pathing.astar.node {

import flash.utils.Dictionary;

public class CCloseList implements INodeList {
    public function CCloseList() {
        _list = new Dictionary();
    }

    public function clear() : void {
        for (var key:* in _list) {
            delete _list[key];
        }
    }
    [Inline]
    public function get length() : int {
        throw new Error("need not to call get length");
        return -1; // 不需要length
    }
    [Inline]
    public function pop() : CNode {
        throw new Error("need not to call pop");
        return null; // 不需要pop
    }
    [Inline]
    public function add(node:CNode) : void {
        _list[node] = true;
    }
    [Inline]
    public function isExist(findNode:CNode) : Boolean {
        return findNode in _list;
    }

    protected var _list:Dictionary;
}
}
