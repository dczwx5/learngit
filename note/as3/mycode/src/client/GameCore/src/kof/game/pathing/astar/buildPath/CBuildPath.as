//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/21.
 */
package kof.game.pathing.astar.buildPath {

import QFLib.Math.CVector2;
import kof.game.pathing.astar.node.CNode;

public class CBuildPath implements IBuildPath {
    public function buildPath(startNode:CNode, endNode:CNode) : Array {
        var path:Array = new Array();
        var node:CNode = endNode;
        var pixelPos:CVector2;
        while (node != startNode) {
            pixelPos = new CVector2(node.gridX, node.gridY);
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
