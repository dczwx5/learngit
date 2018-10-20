//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/28.
 */
package kof.game.strengthen.data {

import kof.data.CObjectData;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.table.StrengthBattleValueCalc;
import kof.table.StrengthConst;
import kof.table.StrengthLevelBattleValue;
import kof.table.StrengthTargetBattleValue;

public class CStrengthenData extends CObjectData {
    public function CStrengthenData( database : IDatabase ) {
        setToRootData( database );

        this.addChild(CStrengthenItemListData);
    }

    // ===========================data
    public override function updateDataByData(data:Object) : void {
        isServerData = true;
        itemListData.updateDataByData(data);
    }

    [Inline]
    public function get itemListData() : CStrengthenItemListData {
        return getChild(0) as CStrengthenItemListData;
    }

    public function get itemTable() : IDataTable {
        if (_itemTable == null) {
            _itemTable = _databaseSystem.getTable(KOFTableConstants.STRENGTHEN_ITEM);
        }
        return _itemTable;
    }
    public function get typeTable() : IDataTable {
        if (_typeTable == null) {
            _typeTable = _databaseSystem.getTable(KOFTableConstants.STRENGTHEN_TYPE);
        }
        return _typeTable;
    }
    public function get battleValueTargetTable() : IDataTable {
        if (_battleValueTargetTable == null) {
            _battleValueTargetTable = _databaseSystem.getTable(KOFTableConstants.STRENGTHEN_BATTLE_VALUE_TARGET);
        }
        return _battleValueTargetTable;
    }
    public function get levelBattleValueTable() : IDataTable {
        if (_levelBattleValueTable == null) {
            _levelBattleValueTable = _databaseSystem.getTable(KOFTableConstants.STRENGTHEN_LEVEL_BATTLE_VALUE);
        }
        return _levelBattleValueTable;
    }
    public function get battleValueCalcTable() : IDataTable {
        if (_battleValueCalcTable == null) {
            _battleValueCalcTable = _databaseSystem.getTable(KOFTableConstants.STRENGTHEN_BATTLE_VALUE_CALC);
        }
        return _battleValueCalcTable;
    }

    public function get constRecord() : StrengthConst {
        if (!_constRecord) {
            _constRecord = _databaseSystem.getTable(KOFTableConstants.STRENGTHEN_CONSTANTS ).toArray()[0];
        }
        return _constRecord;
    }

    // 获得玩家当前等级，对应的战力要求
    public function getLevelBattleValueRecord(teamLevel:int) : StrengthLevelBattleValue {
        var list:Array = levelBattleValueTable.toArray();
        list.sortOn("ID", Array.NUMERIC);
        for (var i:int = list.length-1; i >= 0; --i) {
            var record:StrengthLevelBattleValue = list[i];
            if (teamLevel >= record.ID) {
                return record;
            }
        }
        return list[0];
    }
    // 根据当前战力的比例。获得打分index->CBAS
    public function getIndexByBattleValuePercent(rate:int) : int {
        var ret:int = 0;
        for (var i:int = constRecord.BattleValueLevelPercent.length - 1; i >= 0 ; i--) {
            if (rate > constRecord.BattleValueLevelPercent[i]) {
                ret = i+1;
                break;
            } else if (rate == constRecord.BattleValueLevelPercent[i]) {
                ret = i;
                break;
            }
        }
        ret = Math.min(ret, constRecord.BattleValueLevelPercent.length - 1);
        return ret;
    }

    // 根据item的战力比例, 获得打分index-> 不及格/及格...
    public function getItemLevel(rate:int) : int {
        var index:int = 0;
        for (var i:int = constRecord.ItemLevelPercent.length - 1; i >= 0; i--) {
            if (rate > constRecord.ItemLevelPercent[i]) {
                index = i+1;
                break;
            } else if (rate == constRecord.ItemLevelPercent[i]) {
                index = i;
                break;
            }
        }
        index = Math.min(index, constRecord.ItemLevelPercent.length - 1);
        return index;
    }
    // 获得玩家当前等级，对应item的战力要求
    // type : 战力提升类型
    public function getItemTargetBattleValueRecord(type:int, teamLevel:int) : StrengthTargetBattleValue {
        var list:Vector.<Object> = battleValueTargetTable.toVector();
        var tempList:Array = new Array();
        var record:StrengthTargetBattleValue;
        for (var i:int = 0; i < list.length; i++) {
            record = list[i] as StrengthTargetBattleValue;
            if (record.type == type) {
                tempList[tempList.length] = record;
            }
        }

        for (i = tempList.length-1; i >= 0; --i) {
            record = tempList[i];
            if (record.type == type && teamLevel >= record.level) {
                return record;
            }
        }

        return tempList[0];
    }
    // 计算战力
    // type : 战力提升类型
    // value : 用于计算上的值, 比如1001, value是格斗家等级
    public function calcBattleValueScore(type:int, value:int) : int {
        var pRecord:StrengthBattleValueCalc = battleValueCalcTable.findByPrimaryKey(type);
        var preLevel:int = 0;
        var totalScore:int = 0;
        for (var i:int = 0; i < pRecord.level.length; i++) {
            var level:int = pRecord.level[i];
            var score:int = pRecord.score[i];
            var tempScore:int = 0;
            var subLevel:int = level - preLevel;
            var subValue:int = value - level; // subValue > 0 说明value超过了value段
            if (subValue > 0) {
                tempScore = subLevel * score;
            } else {
                tempScore = (value - preLevel) * score;
            }
            totalScore += tempScore;
            if (subValue <= 0) {
                break;
            }
            preLevel = level;
        }
        return totalScore;
    }

    private var _battleValueTargetTable:IDataTable; // 每个item的战力表
    private var _itemTable:IDataTable;
    private var _constRecord:StrengthConst;
    private var _typeTable:IDataTable;
    private var _levelBattleValueTable:IDataTable; // 玩家等级对应的战力 - 总的
    private var _battleValueCalcTable:IDataTable;


}
}
