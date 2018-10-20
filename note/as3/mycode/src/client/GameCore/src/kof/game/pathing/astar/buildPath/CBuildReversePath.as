//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/21.
 */
package kof.game.pathing.astar.buildPath {

import QFLib.Math.CVector2;
import kof.game.pathing.astar.node.CNode;

public class CBuildReversePath implements IBuildPath {
    public function buildPath(startNode:CNode, endNode:CNode) : Array {
        var path:Array = new Array();
        var node:CNode = endNode;
        var pixelPos:CVector2;

        // 去掉终点
        if (node) {
            node = node.pParent;
        }
        while (node != startNode) {
            pixelPos = new CVector2(node.gridX, node.gridY);
            path[path.length] = pixelPos;
            // path.push(pixelPos);
            node = node.pParent;
        }

        // 插入起来
        pixelPos = new CVector2(startNode.gridX, startNode.gridY);
        path[path.length] = pixelPos;
        return path;
    }
}
}
