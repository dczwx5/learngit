//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/15.
 */
package kof.data {

public class CObjectListData extends CObjectData {
    public function CObjectListData(ItemClass:Class, primaryKey:String, key2:String = null) {
        super();
        _itemClass = ItemClass;
        _primaryKey = primaryKey;
        _key2 = key2;
    }

    // update and add
    public override function updateDataByData(datas:Object) : void {
        var objectData:IObjectData;

        if (datas is Array) {
            var list:Array = datas as Array;
//            for each (var data:Object in list) { for each有随机性
            for (var i:int = 0; i < list.length; i++) {
                var data:Object = list[i];

                objectData = _getItemCommon(data);

                if (objectData) {
                    objectData.updateDataByData(data);
                } else {
                    objectData = this.addChild(_itemClass);
                    objectData.updateDataByData(data);
                }
            }
        } else {
            var singleData:Object = datas;
            objectData = _getItemCommon(singleData);

            if (objectData) {
                objectData.updateDataByData(singleData);
            } else {
                objectData = this.addChild(_itemClass);
                objectData.updateDataByData(singleData);
            }
        }

    }

    //add
    public function addDataByData(datas:Object) : void {
        var objectData:IObjectData;

        if (datas is Array) {
            var list:Array = datas as Array;
            for (var i:int = 0; i < list.length; i++) {
                var data:Object = list[i];
                objectData = this.addChild(_itemClass);
                objectData.updateDataByData(data);
            }
        }
    }

    // =====================单个item操作===========================
    // item是已经new出来的对象, 和addChild不一样, addChild是指定类, 而且不会updateData
    public function addByCreatedData(object:IObjectData, data:Object) : IObjectData {
        var oldData:IObjectData = _getItemCommon(data);
        if (oldData) {
            return oldData;
        }

        this.addChildByCreatedData(object);
        object.updateDataByData(data);
        return object;
    }
    // add and update, or update
    public function adddData(data:Object) : IObjectData {
        var oldData:IObjectData = _getItemCommon(data);
        if (oldData) {
            oldData.updateDataByData(data);
            return oldData;
        }
        var emData:IObjectData = this.addChild(_itemClass);
        emData.updateDataByData(data);
        return emData;
    }

    public function updateItemData(data:Object) : IObjectData {
        var oldData:IObjectData = _getItemCommon(data);
        if (!oldData) return oldData;

        oldData.updateDataByData(data);
        return oldData;
    }


    // =================================================双key========================================================================
    public function getByPrimary(value:*, value2:* = null) : IObjectData {
        return getByKey(_primaryKey, value, _key2, value2)
    }
    public function getIndexByPrimary(value:*, value2:* = null) : int {
        return getIndexByKey(_primaryKey, value, _key2, value2);
    }
    public function removeByPrimary(value:*, value2:* = null) : void {
        removeByKey(_primaryKey, value, _key2, value2);
    }
    public function removeByKey(key:String, value:*, key2:String = null, value2:* = null) : void {
        if (!key) return ;
        var index:int = getIndexByKey(key, value, key2, value2);
        removeChildByIndex(index);
    }
    public function getByKey(key:String, value:*, key2:String = null, value2:* = null) : IObjectData {
        if (!key) return null;

        var list:Array = childList;
        for each (var data:IObjectData in list) {
            if (data[key] == value) {
                if (key2) {
                    if (data[key2] == value2) {
                        return data;
                    }
                } else {
                    return data;
                }
            }
        }
        return null;
    }
    public function getIndexByKey(key:String, value:*, key2:String, value2:*) : int {
        if (!key) return -1;

        var list:Array = childList;
        var object:Object;
        for (var i:int = 0; i < list.length; i++) {
            object = list[i];
            if (object[key] == value) {
                if (key2) {
                    if (object[key2] == value2) {
                        return i;
                    }
                } else {
                    return i;
                }
            }
        }
        return -1;
    }
    // =====================get, remove, index===========================
    public function getListByKey(key:String, value:*) : Array {
        if (!key) return null;

        var list:Array = childList;
        var ret:Array = new Array();
        for each (var data:IObjectData in list) {
            if (data[key] == value) {
                ret.push(data);
            }
        }
        return ret;
    }

    private function _getItemCommon(data:Object) : IObjectData {
        var objectData:IObjectData;
        if (_primaryKey && _primaryKey.length > 0) {
            if (_key2 && _key2.length > 0) {
                objectData = getByPrimary(data[_primaryKey], data[_key2]);
            } else {
                objectData = getByPrimary(data[_primaryKey]);
            }
        }
        return objectData;
    }

    public function get list() : Array {
        return super.childList;
    }
    public function hasData() : Boolean {
        return list && list.length > 0;
    }
    protected var _itemClass:Class;
    private var _primaryKey:String; // 主键, 在列表中惟一
    private var _key2:String; // 补充, 有些一个字段无法定位
}
}
