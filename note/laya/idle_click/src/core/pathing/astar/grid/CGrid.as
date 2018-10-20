/**
 * Created by auto
 */
package core.pathing.astar.grid {

import core.pathing.astar.node.CNode;


// 优化 将格子缓存起来
public class CGrid {
    public function CGrid() {
    }

    public function clear() : void {
        _gridMap = null;
    }
    // rowCount V   y
    // colCount ->  x
    public function setData(data:Object, xCount:int) : void {
        _xCount = xCount;
        var len:int = data.length;
        _gridMap = new Vector.<CNode>(len); // 优化
        var node:CNode;
        var gridX:int;
        var gridY:int;
        for (var i:int = 0; i < len; ++i) {
            gridX = i % xCount;
            gridY = i / xCount;
            node = new CNode(gridX, gridY);
            node.isBlock = data[i];
            _gridMap[i] = node;
        }
    }

    public function clearOpenAndCloseListMark():void{
        var len:int = _gridMap.length;
        var node:CNode;
        for(var i:int=0; i<len; i++)
        {
            node = _gridMap[i];
            node.inCloseList = false;
            node.inOpenList = false;
        }
    }

    
    public function isBlock(gridx:int, gridy:int) : Boolean {
        return getNode.isBlock(gridx, gridy);
    }
    
    public function getNode(gridx:int, gridy:int) : CNode {
        var index:int = gridy * _xCount + gridx;
        if (index >= _gridMap.length || index < 0) return null;
        return _gridMap[index] as CNode;
    }

    private var _gridMap:Vector.<CNode>;
    private var _xCount:int;
}
}
