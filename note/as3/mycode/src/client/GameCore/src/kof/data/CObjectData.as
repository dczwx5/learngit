//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/1.
 */
package kof.data {

import QFLib.Foundation.CMap;

import kof.framework.IDatabase;

public class CObjectData implements IObjectData {
    public function CObjectData() {
        _data = new CMap();
        _childMap = new Array();
    }

    public function dispose() : void {
        _databaseSystem = null;
        _rootData = null;
    }

    public function updateDataByData(data:Object) : void {
        if (!data) return ;
        for (var key:String in data) {
            _data[key] = data[key];
        }
    }

    // ===============backup data
    public function backup() : void {
        _backupData = null;
        if (_backupDataClass != null) {
            _backupData = new _backupDataClass();
        } else {
            _backupData = new CObjectData();
        }
        _backupData._data = new CMap();
        for (var key:String in _data) {
            if (_data[key] is Array == false) {
                _backupData._data[key] = _data[key];
            }
        }
    }
    public function get backupData() : CObjectData {
        return this._backupData;
    }
    public function set backupDataClass(v:Class) : void {
        _backupDataClass = v;
    }

    // ====================child
    // child 浅复制
    public function get cloneChildList() : Array {
        var ret:Array = new Array(_childMap.length);
        for (var i:int = 0; i < _childMap.length; i++) {
            ret[i] = _childMap[i];
        }
        return ret;
    }
    public function get childList() : Array {
        return _childMap;
    }
    public function addChild(childClass:Class) : IObjectData {
        var objectData:IObjectData = _createObject(childClass);
        _childMap.push(objectData);
        return objectData;
    }
    public function addChildByCreatedData(child:IObjectData) : IObjectData {
        child.rootData = _rootData;
        child.databaseSystem = _databaseSystem;
        _childMap.push(child);
        return child;
    }
    protected function _createObject(childClass:Class) : IObjectData {
        var objectData:IObjectData = new childClass();
        objectData.rootData = _rootData;
        objectData.databaseSystem = _databaseSystem;
        return objectData;
    }
    public function removeChildByIndex(index:int) : void {
        if (_childMap == null || index == -1 || index >= _childMap.length) return ;
        _childMap.splice(index, 1);
    }
    public function popChild() : IObjectData {
        if (_childMap.length > 0) {
            return _childMap.pop();
        }
        return null;
    }

    public function shiftChild() : IObjectData {
        if (_childMap.length > 0) {
            return _childMap.shift();
        }
        return null;
    }
    public function getChild(index:int) : IObjectData {
        if (_childMap == null) return null;
        if (index >= _childMap.length) return null;
        return _childMap[index];
    }
    public function loopChild(func:Function) : void {
        if (func == null) return ;
        for each (var data:IObjectData in _childMap) {
            func(data);
        }
    }
    public function resetChild() : void {
        _childMap = new Array();
    }
    public function clearAll() : void {
        clearData();
        resetChild();
    }

    public function setToRootData(system:IDatabase) : void {
        rootData = this;
        databaseSystem = system;
    }
    public function get data() : CMap { return _data; }
    public function get rootData() : IObjectData{
        return _rootData;
    }
    public function set rootData(dataObject:IObjectData) : void {
        _rootData = dataObject;
        for each (var data:IObjectData in _childMap) {
            data.rootData = data;
        }
    }
    public function set databaseSystem(database:IDatabase) : void {
        _databaseSystem = database;
        for each (var data:IObjectData in _childMap) {
            data.databaseSystem = database;
        }
    }
    public function get databaseSystem() : IDatabase {
        return _databaseSystem;
    }
    public function clearData() : void {
        for (var key:String in _data) {
            delete _data[key];
        }
    }

    private var _needSync:Boolean;
    public function sync() : void {
        _needSync = false;
    }
    public function resetSync() : void {
        _needSync = true;
    }
    public function get needSync() : Boolean {
        return _needSync; // getTimer() - _lastSyncTime > 600000; // 10分钟
    }

    protected var _data:CMap; //
    private var _childMap:Array; // objectData list
    protected var _databaseSystem:IDatabase;
    protected var _rootData:IObjectData; // 根数据

    private var _backupData:CObjectData; //备份数据.只保存一些基础, 简单的数据
    private var _backupDataClass:Class; // 备份数据类, extends CObjectData

    // 是否从服务器同步过数据, false : 说明本关由客户端创建，未完成, true : 由服务器同步过, 是已完成的数据
    // 未通关的副本。服务器不会同步下来
    public var isServerData:Boolean = false;


    public function get extendsData() : Object {
        return _extendsData;
    }
    public function set extendsData(value : Object) : void {
        _extendsData = value;
    }

    private var _extendsData:Object;
}
}
