/**
 * Created by auto
 */
package core.pathing.astar.buildPath {

import core.pathing.astar.node.CNode;
import laya.maths.Point;

public class CBuildPath implements IBuildPath {
    public function buildPath(startNode:CNode, endNode:CNode) : Array {
        var path:Array = new Array();
        var node:CNode = endNode;
        var pixelPos:Point;
        while (node != startNode) {
            pixelPos = new Point(node.gridX, node.gridY);
            path.push(pixelPos);
            node = node.pParent;
        }

        // start 不放进path
//        pixelPos = new CVector2(node.gridX, node.gridY);
//        path.push(pixelPos);
        // 反转 路径从0开始
        path.reverse();
        return path;
    }
}
}
