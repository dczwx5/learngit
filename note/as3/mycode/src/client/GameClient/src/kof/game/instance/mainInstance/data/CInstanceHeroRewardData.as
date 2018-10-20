//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/2.
 */
package kof.game.instance.mainInstance.data {

import kof.data.CObjectData;

// 格斗家奖励 surrender
public class CInstanceHeroRewardData extends CObjectData {
    public function CInstanceHeroRewardData() {
    }

    public function get heroID() : int { return _data["heroID"]; }
    public function get addExp() : int { return _data["addExp"]; }
}
}
