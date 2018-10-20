//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/23.
 */
package kof.game.peakGame.data {

import kof.data.CObjectData;
import kof.table.PeakReward;

public class CPeakGameRewardTaskData extends CObjectData {
    public function CPeakGameRewardTaskData() {
        _state = UNOK;
    }

    public function get target() : int {
        return record.param[0] as int;
    }
    public function get min() : int {
        return record.param[0] as int;
    }
    public function get max() : int {
        return record.param[1] as int;
    }

    public function get record() : PeakReward { return _record; }
    public function set record(value : PeakReward) : void { _record = value; }
    private var _record:PeakReward;

    public function get isUnReady() : Boolean { return _state == UNOK; }
    public function get isCanReward() : Boolean { return _state == OK; }
    public function get isReward() : Boolean { return _state == REWARDED; }

    public function setUnReady() : void { _state = UNOK; }
    public function setCanReward() : void { _state = OK; }
    public function setReward() : void { _state = REWARDED; }

    private var _state:int; // -1 : 未达成, 0 : 达成, 1 : 已领取

    public static const UNOK:int = -1;
    public static const OK:int = 0;
    public static const REWARDED:int = 1;

    public function get value() : int {
        return _value;
    }
    public function set value(value : int) : void {
        _value = value;
    }

    private var _value:int;

}
}
