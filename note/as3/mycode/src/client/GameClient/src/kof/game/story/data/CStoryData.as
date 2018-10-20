//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/14.
 */
package kof.game.story.data {

import kof.data.CObjectData;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.message.HeroStory.HeroStoryChallengeResultResponse;
import kof.table.HeroStoryConstant;
import kof.table.HeroStoryConsume;

public class CStoryData extends CObjectData {
    public function CStoryData( database:IDatabase) {
        setToRootData(database);

        this.addChild(CStoryResultData);
        this.addChild(CStoryGateListData);

    }
    // ===========================data
    public function initialData(data:Object) : void {
        isServerData = true;
        updateDataByData(data);
    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);
        gateListData.updateDataByData(data);
    }

    // ===========================reportData
    public function updateResultData(data:HeroStoryChallengeResultResponse) : void {
        resultData.isServerData = true;
        resultData.clearAll();

        var dataObject:Object = new Object();
        dataObject[CStoryResultData._heroID] = data.heroID;
        dataObject[CStoryResultData._gateIndex] = data.gateIndex;
        dataObject[CStoryResultData._win] = data.win;
        dataObject[CStoryResultData._rewardList] = data.rewardList;
        resultData.updateDataByData(dataObject);
    }

    // ============================================================================================================================
    public function hasHero(heroID:int) : Boolean {
        return gateListData.hasHero(heroID);
    }
//    [Inline]
//    public function get startTime() : Number { return _data["startTime"]; } //活动开始时间

    [Inline]
    public function get resultData() : CStoryResultData {
        return getChild(0) as CStoryResultData;
    }
    [Inline]
    public function get gateListData() : CStoryGateListData {
        return getChild(1) as CStoryGateListData;
    }

    public function get heroTable() : IDataTable {
        if (!_heroTable) {
            _heroTable = _databaseSystem.getTable(KOFTableConstants.STORY_HERO);
        }
        return _heroTable;
    }
    public function get gateTable() : IDataTable {
        if (!_gateTable) {
            _gateTable = _databaseSystem.getTable(KOFTableConstants.STORY_GATE);
        }
        return _gateTable;
    }
    public function get contantRecord() : HeroStoryConstant {
        if (!_contantRecord) {
            var pDataTable:IDataTable = _databaseSystem.getTable(KOFTableConstants.STORY_CONSTANT);
            var datalist:Array = pDataTable.toArray();
            _contantRecord = datalist[0] as HeroStoryConstant;
        }
        return _contantRecord;
    }
    public function get consumeTable() : IDataTable {
        if (!_consumeTable) {
            _consumeTable = _databaseSystem.getTable(KOFTableConstants.STORY_CONSUME);
        }
        return _consumeTable;
    }
    public function getFightGateConsume(qualityBase:int, gateIndex:int) : int {
        var fightConsumeRecord:HeroStoryConsume = consumeTable.findByPrimaryKey(qualityBase);
        var fightConsume:int = 0;
        if (fightConsumeRecord) {
            fightConsume = fightConsumeRecord.Consumes[gateIndex-1];
        }
        return fightConsume;
    }

    // ==========================

    public function get FREE_FIGHT_COUNT_DAILY() : int {
        var freeFightCount:int = contantRecord.DailyChallengeTimes;
        return freeFightCount;
    }
    public function get BUY_FIGHT_COUNT_DAILY() : int {
        var buyCount:int = BUY_COUNT_CONSUME_LIST.length;
        return buyCount;
    }
    public function get CURRENCY_TYPE() : int {
        var type:int = contantRecord.ResetChallengeCurrency;
        return type;
    }
    public function get ITEM_ID() : int {
        var itemID:int = contantRecord.ConsumeItemID;
        return itemID;
    }
    public function get BUY_COUNT_CONSUME_LIST() : Array {
        if (!_buyCountConsumeList) {
            var strConsume:String = contantRecord.ResetChallengeConsume;
            var consumeList:Array = strConsume.split(",");
            _buyCountConsumeList = consumeList;
        }
        return _buyCountConsumeList;
    }
    // boughtCount 已购买次数
    public function getBuyCountConsume(boughtCount:int) : int {
        if (_buyCountConsumeList.length > boughtCount) {
            return _buyCountConsumeList[boughtCount];
        }
        return -1;
    }
    public function isCanBuy(boughtCount:int) : Boolean {
        return _buyCountConsumeList.length > boughtCount;
    }

    private var _buyCountConsumeList:Array;

    private var _heroTable:IDataTable;
    private var _gateTable:IDataTable;
    private var _contantRecord:HeroStoryConstant;
    private var _consumeTable:IDataTable;

    public var lastFightGateIsFirstPass:Boolean; // 当前打的副本是否为首通
}
}
