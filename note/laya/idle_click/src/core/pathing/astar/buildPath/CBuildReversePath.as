/**
 * Created by auto
 */
package core.pathing.astar.buildPath {

import core.pathing.astar.node.CNode;
import laya.maths.Point;

public class CBuildReversePath implements IBuildPath {
    public function buildPath(startNode:CNode, endNode:CNode) : Array {
        var path:Array = new Array();
        var node:CNode = endNode;
        var pixelPos:Point;

        // 去掉终点
        if (node) {
            node = node.pParent;
        }
        while (node != startNode) {
            pixelPos = new Point(node.gridX, node.gridY);
            path[path.length] = pixelPos;
            // path.push(pixelPos);
            node = node.pParent;
        }

        // 插入起来
        pixelPos = new Point(startNode.gridX, startNode.gridY);
        path[path.length] = pixelPos;
        return path;
    }
}
}
