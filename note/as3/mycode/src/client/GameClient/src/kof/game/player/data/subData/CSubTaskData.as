//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/6.
 */
package kof.game.player.data.subData {

import kof.data.CObjectData;

public class CSubTaskData extends CObjectData {
    public function CSubTaskData() {
    }

    public function get dailyQuestActiveValue() : int {
        return _rootData.data[ _dailyQuestActiveValue ];
    }
    public function set dailyQuestActiveValue( value : int ) : void {
        _rootData.data[ _dailyQuestActiveValue ] = value;
    }
    public function get dailyQuestActiveRewards() : Array {
        return _rootData.data[ _dailyQuestActiveRewards ];
    }
    public function set dailyQuestActiveRewards( value : Array) : void {
        _rootData.data[ _dailyQuestActiveRewards ] = value;
    }

    public static const _dailyQuestActiveValue : String = "dailyQuestActiveValue";
    public static const _dailyQuestActiveRewards : String = "dailyQuestActiveRewards";
}
}
