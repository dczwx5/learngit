//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/1/16.
 */
package kof.game.task.data {

import QFLib.Foundation.CMap;

import kof.data.CObjectData;
import kof.table.PlotTask;
import kof.table.Task;

public class CTaskData extends CObjectData {

    public var task:Task;
    public var plotTask:PlotTask;

    public function CTaskData() {
        super();
        _data = new CMap();
    }

    public function get taskID() : int { return _data[_taskID]; }
    public function get type() : int { return _data[_type]; }
    public function get state() : int { return _data[_state]; }
    public function get condition() : int { return _data[_condition]; }
    public function get conditionParam() : Array { return _data[_conditionParam]; }

    public static function createObjectData(taskID:int, type:int, state:int, condition:int, conditionParam:Array) : Object {
        return {taskID:taskID, type:type, state:state, condition:condition, conditionParam:conditionParam}
    }

    public static const _taskID:String = "taskID";
    public static const _type:String = "type";
    public static const _state:String = "state"; //已接取，还不能进行 2; //已接取，可进行  3;//已完成
    public static const _condition:String = "condition";
    public static const _conditionParam:String = "conditionParam";

    public static const _modifyType:String = "modifyType";//1:增加 2：删除 3：更新
}
}
