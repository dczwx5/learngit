//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/21.
 */
package kof.game.pathing.astar.calc {

import kof.game.pathing.astar.IAStar;
import kof.game.pathing.astar.node.CNode;

public class CObliqueBlockCalc implements IObliqueBlock {
    public function CObliqueBlockCalc(astar:IAStar) {
        _astar = astar;
    }
    public function isBlock(stNode:CNode, targetNode:CNode) : Boolean {
        var isOblique:Boolean = (stNode.gridX != targetNode.gridX && stNode.gridY != targetNode.gridY);
        if (isOblique) {
            // X E  |  X E  |  O E      -> B is startNode -> E is TargetNode
            // B X  |  B O  |  B X      -> O is unBlock -> X is Block
            // 斜角两个阻挡点

            var checkGridX1:int = stNode.gridX;
            var checkGridY1:int = targetNode.gridY;
            var node:CNode = _astar.getNode(checkGridX1, checkGridY1);
            if (node != null && node.isBlock) {
                return true;
            }
            var checkGridX2:int = targetNode.gridX;
            var checkGridY2:int = stNode.gridY;
            node = _astar.getNode(checkGridX2, checkGridY2);

            if (node != null && node.isBlock) {
                return true;
            }
        }
        return false;
    }

    private var _astar:IAStar;
}
}
