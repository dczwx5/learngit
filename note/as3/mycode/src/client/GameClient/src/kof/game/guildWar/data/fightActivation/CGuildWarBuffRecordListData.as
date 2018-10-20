//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/5/3.
 */
package kof.game.guildWar.data.fightActivation {

import kof.data.CObjectListData;

/**
 * 战斗鼓舞记录列表数据
 */
public class CGuildWarBuffRecordListData extends CObjectListData {
    public function CGuildWarBuffRecordListData()
    {
        super (CGuildWarBuffRecordData, null);
    }

    public function getRecordData(ranking:int) : CGuildWarBuffRecordData
    {
        var recordData:CGuildWarBuffRecordData = this.getByPrimary(ranking) as CGuildWarBuffRecordData;
        return recordData;
    }
}
}
