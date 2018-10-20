//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/21.
 */
package kof.game.taskcallup.data {

import QFLib.Foundation.CMap;

import kof.data.CObjectData;
import kof.table.TaskCallUp;

public class CCallUpAcceptedData extends CObjectData  {
    public function CCallUpAcceptedData() {
        super();
        _data = new CMap();
    }

    public function get taskId() : int { return _data[_taskId]; }
    public function get endTime() : Number { return _data[_endTime]; }
    public function set endTime( value : Number ) : void { _data[_endTime] = value; }
    public function get heros() : Array { return _data[_heros]; }
    public var taskCallUp : TaskCallUp;

    public static function createObjectData( taskId:int,endTime:Number,heros:Array) : Object {
        return {taskId:taskId,endTime:endTime,heros:heros}
    }

    public static const _taskId:String = "taskId";
    public static const _endTime:String = "endTime";
    public static const _heros:String = "heros";
}
}
