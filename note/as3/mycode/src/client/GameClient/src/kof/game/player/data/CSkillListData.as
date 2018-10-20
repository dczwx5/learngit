//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/28.
 */
package kof.game.player.data {

import kof.data.CObjectListData;
public class CSkillListData extends CObjectListData {
    public function CSkillListData() {
        super(CSkillData, CSkillData._skillPosition);
    }

    public function getByID(pos:int) : CSkillData {
        return getByPrimary(pos) as CSkillData;
    }

    [Inline]
    public function get ID() : int { return _ID; }
    public function set ID(value:int) : void { _ID = value; } // 格斗家ID

    private var _ID:int;
}
}
