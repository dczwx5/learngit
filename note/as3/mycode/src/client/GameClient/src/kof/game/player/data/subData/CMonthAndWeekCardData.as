//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/6.
 */
package kof.game.player.data.subData {

import kof.data.CObjectData;

public class CMonthAndWeekCardData extends CObjectData {
    public function CMonthAndWeekCardData() {
    }

    public function get goldCardState() : int {
        return _rootData.data[ _goldCardState ];
    }

    public function get silverCardState() : int {
        return _rootData.data[ _silverCardState ];
    }

    public static const _goldCardState : String = "goldCardState";
    public static const _silverCardState : String = "silverCardState";
}
}
