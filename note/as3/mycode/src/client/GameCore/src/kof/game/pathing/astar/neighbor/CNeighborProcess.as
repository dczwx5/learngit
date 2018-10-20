//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/20.
 */
package kof.game.pathing.astar.neighbor {

import kof.game.pathing.astar.IAStar;
import kof.game.pathing.astar.calc.IObliqueBlock;
import kof.game.pathing.astar.node.CNode;
import kof.game.pathing.astar.node.INodeList;

public class CNeighborProcess implements INeighborProcess{

    public function CNeighborProcess(astar:IAStar, obliqueBlockCalc:IObliqueBlock) {
        _aStar = astar;
        _obliqueBlockCalc = obliqueBlockCalc;
    }

    /**
     * @return node new, need to putin openlist
     */
    public function process(node:CNode, endNode:CNode, neighborList:Array, openList:INodeList) : int {
        var neighborCount:int = neighborList.length;
        var neighborData:CNeighborData;
        var neighborNode:CNode;
        var curGridX:int;
        var curGridY:int;
        var isInClose:Boolean;
        var isInOpen:Boolean;
        var isWalkable:Boolean;
        // loop neighborList, for 保证 方向顺序, foreach 有随机性
        var num:int = 0;//统计遍历的节点
        var i:int = 0;
        for (; i < neighborCount; ++i) {
            neighborData = neighborList[i];
            curGridX = node.gridX + neighborData.x;
            curGridY = node.gridY + neighborData.y;
            neighborNode = _aStar.getNode(curGridX, curGridY);

            if (neighborNode == null) continue;

            // walkable
            isWalkable = _isWalkable(node, neighborNode);
            if (!isWalkable) continue;

            isInClose = neighborNode.inCloseList;//_aStar.isInClose(neighborNode);
            if (isInClose) continue;

            //
            isInOpen = neighborNode.inOpenList;//_aStar.isInOpen(neighborNode);

            var g:int = node.g + neighborData.cost;
            if (isInOpen) {
                if (g < neighborNode.g) {
//                    neighborNode.setData(g, h, f, node);
                    neighborNode.g = g;
                    neighborNode.f = neighborNode.g + neighborNode.h;
                }
            } else {
                var h:int = _aStar.calcH(neighborNode, endNode);//新增open表节点计算一次h
                var f:int = g + h;
                neighborNode.setData(g, h, f, node);

                openList.add(neighborNode);
                neighborNode.inOpenList = true;
                num++;
//                nodeAddToOpenList.push(neighborNode);
            }
        }
        return num;
    }

    private function _isWalkable(stNode:CNode, targetNode:CNode) : Boolean {
        if (targetNode == null) return false;
        if (stNode == targetNode) return false;

        if (targetNode.isBlock) {
            return false;
        }
        // 斜角阻挡
        if (_obliqueBlockCalc && _obliqueBlockCalc.isBlock(stNode, targetNode)) {
            return false;
        }

        return true;
    }

    private var _aStar:IAStar;
    // _obliqueBlockCalc不为空, 下面三种情况都不能走到对象
    // X E  |  X E  |  O E      -> B is startNode -> E is TargetNode
    // B X  |  B O  |  B X      -> O is unBlock -> X is Block
    private var _obliqueBlockCalc:IObliqueBlock;
}
}
