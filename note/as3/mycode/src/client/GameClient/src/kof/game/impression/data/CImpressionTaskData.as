//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/6/2.
 */
package kof.game.impression.data {

public class CImpressionTaskData {

    private var _data:Object;

    public function CImpressionTaskData( data:Object):void
    {
        _data = data;
    }

    public function get id() : int
    {
        return _data.id;
    }

    public function get state() : int
    {
        return _data.state;
    }

    public function get conditionValue() : int
    {
        return _data.conditionValue;
    }

    public function get time() : Number
    {
        return _data.time;
    }

    public function get done() : int
    {
        return _data.done;
    }

}
}
