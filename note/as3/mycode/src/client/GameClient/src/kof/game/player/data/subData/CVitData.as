//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/6.
 */
package kof.game.player.data.subData {

import kof.data.CObjectData;

public class CVitData extends CObjectData {
    public function CVitData() {
    }

    public function get physicalStrength() : Number {
        return _rootData.data[ _physicalStrength ];
    }
    public function get buyPhysicalStrengthCount() : Number {
        return _rootData.data[ _buyPhysicalStrengthCount ];
    }
    public function get remainTimeGetNextVit() : Number {
        return _rootData.data[ _remainTimeGetNextVit ];
    }
    //optional bool notRemindFlag = 17; // 用蓝钻购买体力不再提醒标志
    public function get notRemindFlag() : Number {
        return _rootData.data[ _notRemindFlag ];
    }

    public static const _notRemindFlag : String = "notRemindFlag";
    public static const _physicalStrength : String = "physicalStrength";
    public static const _buyPhysicalStrengthCount : String = "buyPhysicalStrengthCount";
    public static const _remainTimeGetNextVit : String = "remainTimeGetNextVit";

}
}
