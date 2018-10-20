/**
 * Created by auto
 */
package core.pathing.astar.neighbor {
import core.pathing.astar.node.CNode;
import core.pathing.astar.node.INodeList;

public interface INeighborProcess {
    function process(node:CNode, endNode:CNode, neighborList:Array, openList:INodeList) : int;

}
}
