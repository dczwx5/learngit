/**
 * Created by auto
 */
package core.pathing.astar.buildPath {

import core.pathing.astar.node.CNode;

public interface IBuildPath {
    function buildPath(startNode:CNode, endNode:CNode) : Array ; // CVector2 list
}
}
