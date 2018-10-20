//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/5/29.
 */
package kof.game.pathing.astar.node {

import kof.util.CAssertUtils;

public class CPoolArray implements INodeList {

    public function CPoolArray(capacity:int) {
        _array = new Array(capacity);
        _length = capacity;
    }

    [Inline]
    public function get list() : Array {
        return _array;
    }
    [Inline]
    public function get last() : CNode {
        return _array[_length-1];
    }
    [Inline]
    public function Get(index:int) : CNode {
        return _array[index];
    }
    [Inline]
    public function Set(index:int, value:CNode) : void {
        _array[index] = value;
    }
    [Inline]
    public function add(insertNode:CNode) : void {
        _array[_length] = insertNode;
        ++_length;
    }
    [Inline]
    public function pop() : CNode {
        if (_length <= 0) return null;
        var ret:CNode = _array[_length-1];
        --_length;
        return ret;
    }

    [Inline]
    public function get length() : int {
        return _length;
    }
    [Inline]
    public function set length(v:int) : void {
        _length = v;
        if (_length > _array.length) {
            _array[_length-1] = null;
        }
    }

    public function insert(index:int, value:CNode) : void {
        CAssertUtils.assertFalse(index > _length); // 不允许插入到后面, 数组错误操作
        if (index == _length) {
            _array[_length] = value;
            ++_length;
            return ;
        }
        _array[_length] = null;
        ++_length;

        var moveNode:CNode;
        for (var i:int = _length-2; i >= index; --i) {
            moveNode = _array[i];
            Set(i+1, moveNode);
        }
        Set(index, value);
    }

    // 不应该使用splice插入, 会使数组越来越大，原来这个数组就是处理长度使用的
//
    // 只可插入一个元素
//    [Inline]
//    public function splice(index:int, deleteCount:int, insertNode:CNode) : * {
//        if (insertNode == null) {
//            _length -= deleteCount;
//            return _array.splice(index, deleteCount);
//        } else {
//            _length += (1 - deleteCount);
//            return _array.splice(index, deleteCount, insertNode);
//        }
//        return null;
//    }
//
//    // 尽量不要调用这个函数, 会产生数组碎片
//    [Inline]
//    public function spliceList(index:int, deleteCount:int, ...insertList) : * {
//        if (insertList == null) {
//            _length -= deleteCount;
//            return _array.splice(index, deleteCount);
//        } else {
//            _length += (insertList.length - deleteCount);
//            var args:Array = [index, deleteCount].concat(insertList);
//            return _array.splice.apply(null, args);
//        }
//        return null;
//    }

    public function isExist(findNode:CNode) : Boolean {
        for (var i:int = 0; i < _length; ++i) {
            if (findNode == _array[i]) {
                return true;
            }
        }
        return false;
    }
    [Inline]
    public function clear() : void {
        _length = 0;
    }


    protected var _array:Array;
    private var _length:int;
}
}
