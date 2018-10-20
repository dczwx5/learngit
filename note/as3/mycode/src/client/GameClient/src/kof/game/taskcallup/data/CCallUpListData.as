//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/6/19.
 */
package kof.game.taskcallup.data {

import QFLib.Foundation.CMap;

import kof.data.CObjectData;
import kof.table.TaskCallUp;

public class CCallUpListData extends CObjectData {
    public function CCallUpListData() {
        super();
        _data = new CMap();
    }
    public function get taskId() : int { return _data[_taskId]; }
    public function get accepted() : Boolean { return _data[_accepted]; }
    public function set accepted( value : Boolean ) : void { _data[_accepted] = value; }
    public var taskCallUp : TaskCallUp;

    public static function createObjectData( taskId:int,accepted:Boolean) : Object {
        return {taskId:taskId,accepted:accepted}
    }

    public static const _taskId:String = "taskId";
    public static const _accepted:String = "accepted";
}
}
