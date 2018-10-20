//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2017/7/11.
 */
package kof.game.pathing.astar.node {

public class CMinHeapOpenList implements INodeList {

    /**元素个数，0表示空*/
    private var _numData:int;

    /**数据节点记录*/
    private var _myData:Vector.<CNode>;

    public function CMinHeapOpenList()
    {
        _numData = 0;
        _myData = new Vector.<CNode>();
    }

    public function add(insertNode:CNode) : void
    {
        _myData[_numData] = insertNode;
        upHandle(_numData);
        _numData++;
    }

    public function pop() : CNode
    {
        if(_numData <= 0) return null;

        var node:CNode = _myData[0];
        _myData[0] = _myData[_numData-1];
        _numData--;
        downHandle(0);
        return node;
    }

    public function isExist(findNode:CNode) : Boolean
    {
        for(var i:int=0; i<_numData; i++)
        {
            if(_myData[i] == findNode)
            {
                return true;
            }
        }
        return false;
    }

    public function get length() : int
    {
        return _numData;
    }

    public function clear() : void
    {
        _numData = 0;
        _myData.length = 0;
    }

    private function upHandle(local:int):void
    {
        var tempNode:CNode;
        var i:int = (local-1) / 2;//父节点
        while(i>=0 && _myData[local].f < _myData[i].f)
        {
            tempNode = _myData[local];
            _myData[local] = _myData[i];
            _myData[i] = tempNode;
            local = i;
            i = (local-1) / 2;
        }
    }

    private function downHandle( local : int ) : void
    {
        var tempNode:CNode;
        var i:int = local*2 + 1;//左孩子
        while(i<_numData)
        {
            if(i+1 < _numData && _myData[i].f > _myData[i+1].f)
            {
                i++;
            }
            if(_myData[local].f<_myData[i].f)
            {
                break;
            }
            else
            {
                tempNode = _myData[local];
                _myData[local] = _myData[i];
                _myData[i] = tempNode;
                local = i;
                i = local*2 + 1;
            }
        }
    }

}
}
