//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by data on 2016/11/1.
 */
package kof.game.instance.mainInstance.data {

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.data.CObjectData;
import kof.table.InstanceChapter;
import kof.table.InstanceTxt;

public class CChapterData extends CObjectData {
    public function CChapterData() {
    }

    public static function createEmptyData(chapterID:int, instanceType:int, rewardIndexList:Array, isFirstChapter:Boolean) : Object {
        return {chapterID:chapterID, rewardIndex:rewardIndexList, instanceType:instanceType, isFirstChapter:isFirstChapter};
    }
    public function get chapterID() : int { return _data[_chapterID]; }
    public function get rewardIndexList() : Array { return _data[_rewardIndex]; } // int list
    public function get instanceType() : int { return _data[_instanceType]; }
    public function get isFirstChapter() : int { return _data[_isFirstChapter]; }

    public function updateReward(index:int) : void {
        if (rewardIndexList == null) {
            _data[_rewardIndex] = new Array();
        }
        if (rewardIndexList.indexOf(index) == -1) {
            rewardIndexList.push(index);
        }
    }

    public function isRewarded(index:int) : Boolean {
        if (rewardIndexList == null) return false;
        return rewardIndexList.indexOf(index) != -1;
    }

    // chapter表数据
    public function get name() : String {
        var nameID:int = chapterRecord.Name;
        return (textTable.findByPrimaryKey(nameID) as InstanceTxt).Name;
    }
    public function get nameIcon() : int {
        return chapterRecord.NameIcon;
    }
    public function get bgIcon() : String {
        return chapterRecord.BgIcon;
    }
    public function get openLevel() : int {
        return chapterRecord.OpenLevel;
    }
    public function get starList() : Array {
        return chapterRecord.star;
    }
    public function get reward() : Array {
        return chapterRecord.reward;
    }
    // 后面需要改过来
//    public function get instanceType() : int {
//        return chapterRecord.Type;
//    }
    public function get isOpen() : Boolean {
        return (_rootData as CInstanceData).isChapterOpen(instanceType, chapterID);
    }
    public function get isCompleted() : Boolean {
        return (_rootData as CInstanceData).isChapterCompleted(instanceType, chapterID);
    }
    // 章节已经有多少星
    public function get curStar() : int {
        return (_rootData as CInstanceData).getChapterStar(instanceType, chapterID);
    }
    // 单个目标需要几星
    public function getStarByIndex(index:int) : int {
//        var count:int = 0;
//        for (var i:int = 0; i < starList.length && index >= i; i++) {
//            var value:int = starList[i];
//            count += value;
//        }
//        return count;
        return starList[index];
    }
    // 总星数
    public function get totalStar() : int {
//        var count:int = 0;
//        for each (var value:int in starList) {
//            count += value;
//        }
//        return count;
        return 15;
    }
    public function isCanGetReward(starIndex:int) :Boolean {
        if (chapterID > 0 && starIndex >= 0) {
            var starCount:int = curStar;
            var openCount:int = starList[starIndex];
            if (starCount >= openCount) {
                return true;
            }
        }
        return false;
    }
    public static const _chapterID:String = "chapterID";
    public static const _rewardIndex:String = "rewardIndex";
    public static const _instanceType:String = "instanceType";
    public static const _isFirstChapter:String = "isFirstChapter";


    public function get chapterRecord() : InstanceChapter {
        if (null == _chapterRecord) _chapterRecord = _databaseSystem.getTable(KOFTableConstants.INSTANCE_CHAPTER).findByPrimaryKey(chapterID);
        return _chapterRecord;
    }
    public function get textTable() : IDataTable {
        if (null == _txtTable) _txtTable = _databaseSystem.getTable(KOFTableConstants.INSTANCE_TXT);
        return _txtTable;
    }

    private var _chapterRecord:InstanceChapter;
    private var _txtTable:IDataTable;
}
}
