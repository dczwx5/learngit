//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/20.
 */
package kof.game.pathing.astar {

import kof.game.pathing.astar.node.CNode;

public class CCalcH {
    public function CCalcH() {
        _calcFunc = _manhattan;
    }

    [Inline]
    public function calcH(node:CNode, endNode:CNode) : int {
        return _calcFunc(node, endNode);
    }
    [Inline]
    private function _manhattan(node:CNode, endNode:CNode) : int {
        return Math.abs(node.gridX - endNode.gridX) * CNode.H_VALUE + Math.abs(node.gridY - endNode.gridY) * CNode.H_VALUE;
    }

    private function _euclidian(node:CNode, endNode:CNode) : Number {
        var dx:Number = node.gridX - endNode.gridX;
        var dy:Number = node.gridY - endNode.gridY;
        return Math.sqrt(dx * dx + dy * dy) * CNode.H_VALUE;
    }

    private function _diagonal(node:CNode, endNode:CNode):Number {
        var dx:Number = Math.abs(node.gridX - endNode.gridX);
        var dy:Number = Math.abs(node.gridY - endNode.gridY);
        var diag:Number = Math.min(dx, dy);
        var straight:Number = dx + dy;
        return CNode.G_OBLIQUE_VALUE * diag + CNode.H_VALUE * (straight - 2 * diag);
    }

    private var _calcFunc:Function;
}
}
