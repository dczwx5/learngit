//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/28.
 */
package kof.game.player.data {

import kof.data.CObjectListData;

public class CSkillSlotListData extends CObjectListData {
    public function CSkillSlotListData() {
        super(CSkillSlotData, CSkillSlotData._position);
    }

    // pos : 1开始
    public function getByPosition(pos:int) : CSkillSlotData {
        return getByPrimary(pos) as CSkillSlotData;
    }
}
}
