//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/24.
 */
package kof.game.player.data {

import QFLib.Utils.ArrayUtil;
import kof.data.CObjectListData;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.game.character.property.CBasePropertyData;
import kof.game.player.data.property.CGlobalProperty;
import kof.table.PlayerGlobal;

public class CPlayerHeroListData extends CObjectListData {
    public function CPlayerHeroListData() {
        super (CPlayerHeroData, CPlayerHeroData._prototypeID);
        _unHireList = new Array();
        _pHeroListSortUtil = new CPlayerHeroListSortUtil(this);
    }

    public function addHeroData(data:Object) : CPlayerHeroData {
        var heroData:CPlayerHeroData;
        var idxInUnHireList:int = ArrayUtil.findItemByProp(_unHireList, CPlayerHeroData._prototypeID, data[CPlayerHeroData._prototypeID]);
        if (idxInUnHireList != -1) {
            heroData = _unHireList[idxInUnHireList];
            heroData = super.addByCreatedData(heroData, data) as CPlayerHeroData;
            _unHireList.splice(idxInUnHireList, 1);
        } else {
            heroData = super.adddData(data) as CPlayerHeroData;
        }
        return heroData;
    }
    public function updateHeroData(data:Object) : CPlayerHeroData {
        var heroData:CPlayerHeroData = updateItemData(data) as CPlayerHeroData;
        return heroData;
    }

    // 重新计算所有格斗家属性
    public function reclacProperty(globalProperty:CGlobalProperty, globalPercentProperty:CBasePropertyData) : void {
        for each (var heroData:CPlayerHeroData in list) {
            heroData.recalcProperty(globalProperty, globalPercentProperty);
        }
    }

    // =====================interface
    // 根据碎片ID, 返回相应格斗家召唤所需要的碎片数量
    public function getTotalPieceCountByItemID(id:int) : int {
        var table:IDataTable = _databaseSystem.getTable(KOFTableConstants.PLAYER_BASIC);
        var result:Array = table.findByProperty("heropieceid", id);
        if (result && result.length > 0) {
            var heroID:int = result[0] as int;
            var heroData:CPlayerHeroData = getHero(heroID);
            return heroData.hireNeedPieceCount;
        }
        return -1;
    }

    public function hasHero(heroID:int) : Boolean {
        var heroData:CPlayerHeroData = this.getByPrimary(heroID) as CPlayerHeroData;
        return heroData != null;
    }

    // 如果数据不存在, 则创建一个新数据, 并存于_unHireList
    public function getHero(heroID:int) : CPlayerHeroData {
        var heroData:CPlayerHeroData = this.getByPrimary(heroID) as CPlayerHeroData;
        if (heroData) return heroData;

        var idxInUnHireList:int = ArrayUtil.findItemByProp(_unHireList, CPlayerHeroData._prototypeID, heroID);
        if (idxInUnHireList != -1) {
            heroData = _unHireList[idxInUnHireList];
            return heroData;
        }
        heroData = _createObject(_itemClass) as CPlayerHeroData;
        heroData.updateDataByData({prototypeID:heroID});
        _unHireList.push(heroData);
        return heroData;
    }


    // 用完请dispose
    public function createHero(heroID:int) : CPlayerHeroData {
        var heroData:CPlayerHeroData = _createObject(_itemClass) as CPlayerHeroData;
        heroData.updateDataByData({prototypeID:heroID});
        return heroData;
    }

    // 已召唤格斗家列表默认排序
    public function sort() : void {
        list.sort(_pHeroListSortUtil.compareByScenario);
    }

    public function getCommentList(emType:int) : Array {
        return _pHeroListSortUtil.getCommentList(emType);
    }
    public function getSortList(emType:int) : Array {
        return _pHeroListSortUtil.getSortList(emType);
    }
    public function compare(v1:CPlayerHeroData, v2:CPlayerHeroData) : Number {
        return _pHeroListSortUtil.compare(v1, v2);
    }

    public function get globalRecord() : PlayerGlobal {
        if (null == _globalRecord) {
            _globalRecord = _databaseSystem.getTable(KOFTableConstants.PLAYER_GLOBAL).first();
        }
        return _globalRecord;
    }
    private var _unHireList:Array;
    private var _globalRecord:PlayerGlobal;
    private var _pHeroListSortUtil:CPlayerHeroListSortUtil;

}
}
