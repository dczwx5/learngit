//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/21.
 */
package kof.game.guildWar.data {

import kof.data.CObjectData;
import kof.framework.IDatabase;
import kof.game.guildWar.data.fightActivation.CGuildWarBuffData;
import kof.game.guildWar.data.fightActivation.CGuildWarBuffResponseData;
import kof.game.guildWar.data.fightReport.CGuildWarFightReportData;
import kof.game.guildWar.data.giftBag.CGiftBagRecordListData;
import kof.game.guildWar.data.giftBag.CGuildWarGiftBagData;

public class CGuildWarData extends CObjectData {

    public var myProgress:int;
    public var enemyProgress:int;
    public var obtainSpaceIds:Array;// 占领的空间站id

    public function CGuildWarData(database:IDatabase)
    {
        setToRootData(database);
        this.addChild(CGuildWarBaseData);
        this.addChild(CGuildWarStationListData);
        this.addChild(CGuildWarMatchData);
        this.addChild(CGuildWarResultData);
        this.addChild(CStationClubRankData);
        this.addChild(CStationRoleRankData);
        this.addChild(CTotalScoreRankListData);
        this.addChild(CStationTotalScoreRankListData);
        this.addChild(CGuildWarFightReportData);
        this.addChild(CGuildWarBuffData);
        this.addChild(CGuildWarBuffResponseData);
        this.addChild(CGuildWarGiftBagData);
        this.addChild(CGiftBagRecordListData);
    }

    // 基本信息
    public function get baseData():CGuildWarBaseData
    {
        return getChild(0) as CGuildWarBaseData;
    }

    // 主界面空间站信息数据
    public function get stationListData() : CGuildWarStationListData
    {
        return getChild(1) as CGuildWarStationListData;
    }

    // 匹配数据
    public function get matchData() : CGuildWarMatchData
    {
        return getChild(2) as CGuildWarMatchData;
    }

    // 结算数据
    public function get resultData() : CGuildWarResultData
    {
        return getChild(3) as CGuildWarResultData;
    }

    // 公会战某个空间站俱乐部排行数据
    public function get stationClubRankData() : CStationClubRankData
    {
        return getChild(4) as CStationClubRankData;
    }

    // 公会战某个空间站个人排行数据
    public function get stationRoleRankData() : CStationRoleRankData
    {
        return getChild(5) as CStationRoleRankData;
    }

    // 公会战总能源排行数据
    public function get totalScoreRankListData() : CTotalScoreRankListData
    {
        return getChild(6) as CTotalScoreRankListData;
    }

    // 公会战所有空间站能源排行数据
    public function get stationTotalScoreRankListData() : CStationTotalScoreRankListData
    {
        return getChild(7) as CStationTotalScoreRankListData;
    }

    // 公会战战报数据
    public function get fightReportData() : CGuildWarFightReportData
    {
        return getChild(8) as CGuildWarFightReportData;
    }

    // 战斗激活数据
    public function get buffData() : CGuildWarBuffData
    {
        return getChild(9) as CGuildWarBuffData;
    }

    // 战斗鼓舞反馈数据
    public function get buffResponseData() : CGuildWarBuffResponseData
    {
        return getChild(10) as CGuildWarBuffResponseData;
    }

    // 礼包数据
    public function get giftBagData() : CGuildWarGiftBagData
    {
        return getChild(11) as CGuildWarGiftBagData;
    }

    // 礼包记录数据
    public function get giftBagRecordData() : CGiftBagRecordListData
    {
        return getChild(12) as CGiftBagRecordListData;
    }
}
}
