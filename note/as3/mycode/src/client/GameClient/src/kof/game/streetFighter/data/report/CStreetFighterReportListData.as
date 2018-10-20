//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/21.
 */
package kof.game.streetFighter.data.report {
import kof.data.CObjectListData;

//战报数据
public class CStreetFighterReportListData extends CObjectListData {
    public function CStreetFighterReportListData() {
        super (CStreetFighterReportItemData, CStreetFighterReportItemData._time);

        _fightDataObject = new Object();
    }

    public override function updateDataByData(datas:Object) : void {
        super.updateDataByData(datas[_FIGHT_REPORT_DATA]); //战报数据
        _fightDataObject = datas[_FIGHT_DATA];//战况数据
    }

    public function getReport(time:int) : CStreetFighterReportItemData {
        return super.getByPrimary(time) as CStreetFighterReportItemData;
    }

    [Inline]
    public function get fightCount() : int { return _fightDataObject["fightCount"]; } //参加次数
    [Inline]
    public function get winCount() : int { return _fightDataObject["winCount"]; } //胜利次数
    [Inline]
    public function get drawCount() : int { return _fightDataObject["drawCount"]; } //平局次数
    [Inline]
    public function get loseCount() : int { return _fightDataObject["loseCount"]; } //失败次数
    [Inline]
    public function get historyHighAlwaysWin() : int { return _fightDataObject["historyHighAlwaysWin"]; } //最大连胜

    private var _fightDataObject:Object; // 战况数据

    public static const _FIGHT_REPORT_DATA:String = "fightReportDatas";//战报数据
    public static const _FIGHT_DATA:String = "fightData"; // 战况数据

}
}
