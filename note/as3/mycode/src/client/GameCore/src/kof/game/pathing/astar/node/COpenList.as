//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/21.
 */
package kof.game.pathing.astar.node {

public class COpenList extends CPoolArray {// CBaseNodeList {
    public function COpenList() {
        super (100);
    }

    // 永远把最新最小的f值在最后面
    public override function add(insertNode:CNode) : void {
        var len:int = length;
        if (len == 0) {
            super.add(insertNode);
            return ;
        }
        var node:CNode;
        for (var i:int = len-1; i >= 0; --i) {
            node = Get(i);
            if (insertNode.compareF(node) <= 0) {
                insert(i+1, insertNode);
//                splice(i+1, 0, insertNode);
                return;
            }
        }
        // 最大
//        splice(0, 0, insertNode);
        insert(0, insertNode);
    }


//    // 永远把最新最小的f值在最后面
//    public override function add(insertNode:CNode) : void {
//        var len:int = _list.length;
//        if (len == 0) {
//            _list.push(insertNode);
//            return ;
//        }
//        var node:CNode;
//        for (var i:int = len-1; i >= 0; --i) {
//            node = _list[i];
//            if (insertNode.compareF(node) <= 0) {
//                _list.splice(i+1, 0, insertNode);
//                return;
//            }
//        }
//        // 最大
//        _list.splice(0, 0, insertNode);
//    }
}
}
