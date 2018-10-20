/**
 * Created by auto
 */
package core.pathing.astar.node {

public class CBaseNodeList implements INodeList {
    public function CBaseNodeList() {
        _list = [];
    }
    public function clear() : void {
        if (_list.length > 0) _list = [];
    }
    public function get length() : int {
        return _list.length;
    }
    public function pop() : CNode {
        return _list.pop();
    }
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
