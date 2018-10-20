//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/20.
 */
package kof.game.pathing.astar {

import flash.utils.getTimer;

import kof.game.pathing.astar.buildPath.IBuildPath;
import kof.game.pathing.astar.grid.CGrid;
import kof.game.pathing.astar.neighbor.INeighborProcess;
import kof.game.pathing.astar.node.INodeList;
import kof.game.pathing.astar.tile.ITile;
import kof.game.pathing.astar.node.CNode;

public class CAStar implements IAStar {
    // 需要判断终点能不能走
    public function CAStar() {
        _calcH = new CCalcH();
        _grid = new CGrid();
    }

    public function initialByGridData(blockGrids:Object, xCount:int) : void {
        _grid.setData(blockGrids, xCount)
    }

    // find path都是不包括起点, 包括终点
    public function findReversePath(stGridX:int, stGridY:int, endGridX:int, endGridY:int) : Array {
        buildPath = _buildReversePath;
        return _findPathB(endGridX, endGridY, stGridX, stGridY); // 起点和终点反过来
    }
    public function findPath(stGridX:int, stGridY:int, endGridX:int, endGridY:int) : Array {
        buildPath = _buildOrderPath;
        return _findPathB(stGridX, stGridY, endGridX, endGridY);
    }
    private function _findPathB(stGridX:int, stGridY:int, endGridX:int, endGridY:int) : Array {
        if (stGridX == endGridX && stGridY == endGridY) {
            return null;
        }

        var path:Array;
        _openList.clear();
//        _closeList.clear();
        _grid.clearOpenAndCloseListMark();

        var stNode:CNode = _grid.getNode(stGridX, stGridY);
        var endNode:CNode = _grid.getNode(endGridX, endGridY);
        if (stNode == null || endNode == null) return null;

        _numVisitedNodes = 0;//统计遍历的节点数量
        path = _search(stNode, endNode);
        return path;
    }
    private function _search(stNode:CNode, endNode:CNode) : Array {

        var path:Array;
        var node:CNode = stNode;

        var neighborList:Array = _tileUtil.neighborList;
//        var newOpenNode:CNode;

        while (endNode != node) {
            _numVisitedNodes += _neighborProcess.process(node, endNode, neighborList, _openList);
//            if (newOpenNodeList && newOpenNodeList.length > 0) {
//                for (var i:int = 0; i < newOpenNodeList.length; i++) {
//                    newOpenNode = newOpenNodeList[i];
//                    _openList.add(newOpenNode);
//                    newOpenNode.inOpenList = true;
//                    num++;
//                }
//            }

            // none node or path block
            if (_openList.length == 0) {
                return null;
            }

//            _closeList.add(node);
            node.inCloseList = true;
            node = _openList.pop();
            node.inOpenList = false;
        }

        path = _buildPath.buildPath(stNode, endNode);
        return path;
    }

    [Inline]
    public function isInClose(node:CNode) : Boolean {
        return node.inCloseList;//_closeList.isExist(node);
    }
    [Inline]
    public function isInOpen(node:CNode) : Boolean {
        return node.inOpenList;//_openList.isExist(node);
    }
    [Inline]
    public function calcH(node:CNode, endNode:CNode) : int {
        return _calcH.calcH(node, endNode);
    }
    [Inline]
    public function set tileUtil(v:ITile) : void { _tileUtil = v; }
    [Inline]
    public function set openList(v:INodeList) : void { _openList = v; }
    [Inline]
    public function set closeList(v:INodeList) : void { /*_closeList = v;*/ }
    [Inline]
    public function set buildPath(v:IBuildPath) : void { _buildPath = v; }
    [Inline]
    public function set buildOrderPath(v:IBuildPath) : void { _buildOrderPath = v; }
    [Inline]
    public function set buildReversePath(v:IBuildPath) : void { _buildReversePath = v; }
    [Inline]
    public function set neighborProcess(v:INeighborProcess) : void { _neighborProcess = v; }
    [Inline]
    public function getNode(gridX:int, gridY:int) : CNode { return _grid.getNode(gridX, gridY); }

    protected var _tileUtil:ITile;
    protected var _calcH:CCalcH;
    protected var _openList:INodeList;
//    protected var _closeList:INodeList;
    protected var _buildPath:IBuildPath;

    protected var _buildOrderPath:IBuildPath;
    protected var _buildReversePath:IBuildPath;
    protected var _neighborProcess:INeighborProcess;

    private var _numVisitedNodes:int = 0;

    protected var _grid:CGrid;
    /**
     * 地表信息
     * CSceneSystem.scenegraph.terrainData
     */
}
}
