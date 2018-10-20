//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/6.
 */
package kof.game.player.data.subData {

import kof.data.CObjectData;

public class CSubSkillData extends CObjectData {
    public function CSubSkillData() {
    }


    public function get buySkillPointCount() : int {
        return _rootData.data[ _buySkillPointCount ];
    }

    public function get skillPoint() : int {
        return _rootData.data[ _skillPoint ];
    }
    public function get remainTimeGetNexSkillPoint() : Number {
        return _rootData.data[ _remainTimeGetNexSkillPoint ];
    }

    public static const _buySkillPointCount : String = "buySkillPointCount";
    public static const _skillPoint : String = "skillPoint";
    public static const _remainTimeGetNexSkillPoint : String = "remainTimeGetNexSkillPoint";

}
}
