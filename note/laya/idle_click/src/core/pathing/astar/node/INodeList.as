/**
 * Created by auto
 */
package core.pathing.astar.node {

public interface INodeList {
    function clear() : void;
    function get length() : int;
    function pop() : CNode;
    // function getNode(gridX:int, gridY:int) : CNode;
    function add(insertNode:CNode) : void;
    function isExist(findNode:CNode) : Boolean ;

}
}
