/**
 * Created by auto
 */
package core.pathing.astar.node {
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
    
    public function get length() : int {
        throw new Error("need not to call get length");
        return -1; // 不需要length
    }
    
    public function pop() : CNode {
        throw new Error("need not to call pop");
        return null; // 不需要pop
    }
    
    public function add(node:CNode) : void {
        _list[node] = true;
    }
    
    public function isExist(findNode:CNode) : Boolean {
        return findNode in _list;
    }

    protected var _list:Dictionary;
}
}
