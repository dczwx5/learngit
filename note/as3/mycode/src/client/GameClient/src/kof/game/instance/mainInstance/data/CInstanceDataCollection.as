//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/4.
 */
package kof.game.instance.mainInstance.data {

// 界面需要数据, 非源数据
public class CInstanceDataCollection {
    public function CInstanceDataCollection() {
    }

//    public var dataTableManager:CInstanceDataTableCollection;

//    public var instanceData:CInstanceData;
    public var instanceDataManager:CInstanceDataManager;

    public var curChapterData:CChapterData;
    public function set curInstanceData(v:CChapterInstanceData) : void {
        _curInstanceData = v;
//        _isFirstTimes = !_curInstanceData.isServerData;
    }
    final public function get curInstanceData() : CChapterInstanceData { return _curInstanceData; }
    private var _curInstanceData:CChapterInstanceData; // 当前操作的副本

    public var instanceType:int; // EInstanceType

    private var _isFirstTimes:Boolean; // 是否首次
    public function get isFirstTimes() : Boolean {
        return _isFirstTimes;
    }
}
}
