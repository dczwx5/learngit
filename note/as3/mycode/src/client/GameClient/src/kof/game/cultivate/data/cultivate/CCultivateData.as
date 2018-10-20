//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/11.
 */
package kof.game.cultivate.data.cultivate {

import kof.data.CObjectData;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.message.ClimbTower.ClimbTowerChallengeResultResponse;
import kof.message.ClimbTower.ClimbTowerOpenBoxResponse;
import kof.table.TowerConstant;
import kof.table.TowerRandBuffCost;

// 修行之路
public class CCultivateData extends CObjectData {
    public function CCultivateData() {
        this.addChild(CCultivateLevelListData);
        this.addChild(CCultivateHeroListData);
        this.addChild(CCultivateOtherData);
        this.addChild(CCultivateResultData);
    }

    public override function clearData() : void {
        super.clearData();
        levelList.clearAll();
        otherData.clearData();
        heroList.clearAll();
    }
    public override function updateDataByData(data:Object) : void {
        var towerDatas:Array = data["towerDatas"];
        var heroStates:Array = data["heroStates"];
        if (towerDatas) {
            levelList.updateDataByData(towerDatas);
        }
        if (heroStates) {
            heroList.updateDataByData(heroStates);
        }
        if (data.hasOwnProperty("otherInfo") && data["otherInfo"] != null) {
            otherData.updateDataByData(data["otherInfo"]);
        }

    }

    public function updateResultData(data:ClimbTowerChallengeResultResponse) : void {
        resultData.updateDataByData({index:data.index, win:data.win, rewardList:data.rewardList})
    }
    public function updateRewardBoxData(data:ClimbTowerOpenBoxResponse) : void {
        otherData.rewardBoxRewardList = data.rewardList;
    }
    public function get levelList() : CCultivateLevelListData { return this.getChild(0) as CCultivateLevelListData; }
    public function get heroList() : CCultivateHeroListData { return this.getChild(1) as CCultivateHeroListData; }
    public function get otherData() : CCultivateOtherData { return this.getChild(2) as CCultivateOtherData; }
    public function get resultData() : CCultivateResultData { return this.getChild(3) as CCultivateResultData; }

    public function getRandBuffCosttRecord(randBuffCount:int) : TowerRandBuffCost {
        var findCount:int = randBuffCount + 1;
        var randBuffCostTable:IDataTable = _databaseSystem.getTable(KOFTableConstants.CULITIVATE_RAND_BUFF_COST);
        var record:TowerRandBuffCost = randBuffCostTable.findByPrimaryKey(findCount);
        return record;
    }
    public function getMaxRandBuffCost() : int {
        if (-1 == _maxRandBuffCost) {
            var randBuffCostTable:IDataTable = _databaseSystem.getTable(KOFTableConstants.CULITIVATE_RAND_BUFF_COST);
            var list:Vector.<Object> = randBuffCostTable.toVector();
            var maxValue:int = -1;
            for each (var record:TowerRandBuffCost in list) {
                if (record.randBuffCost > maxValue) {
                    maxValue = record.randBuffCost;
                }
            }
            _maxRandBuffCost = maxValue;
        }

        return _maxRandBuffCost;
    }

    private var _maxRandBuffCost:int = -1;

    public var buffSelectIndex:int;

}
}
