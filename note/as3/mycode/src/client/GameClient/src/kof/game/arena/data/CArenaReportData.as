//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/24.
 */
package kof.game.arena.data {

import kof.data.CObjectData;

/**
 * 竞技场战报数据
 */
public class CArenaReportData extends CObjectData {

    public function CArenaReportData()
    {
        super();
    }

    public static function createObjectData(roleId:int, roleSName:String, rank:int, combat:int, worshipNum:int) : Object
    {
        return {roleId:roleId, roleSName:roleSName, rank:rank, combat:combat, worshipNum:worshipNum};
    }
}
}
