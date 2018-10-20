/**
 * Created by auto
 */
package core.pathing.astar.calc {
import core.pathing.astar.node.CNode;

public interface IObliqueBlock {
    function isBlock(stNode:CNode, targetNode:CNode) : Boolean ;
}
}
