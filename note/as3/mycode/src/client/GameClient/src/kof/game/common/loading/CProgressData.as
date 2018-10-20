//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/7.
 */
package kof.game.common.loading {

import kof.data.CObjectData;

public class CProgressData extends CObjectData {
    public function CProgressData() {
    }

    [Inline]
    public function get enemyProgress() : int { return _data["enemyProgress"]; }
}
}
