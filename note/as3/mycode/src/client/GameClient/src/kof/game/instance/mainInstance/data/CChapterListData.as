//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/1.
 */
package kof.game.instance.mainInstance.data {

import kof.data.CObjectListData;
import kof.data.IObjectData;
import kof.framework.CAppSystem;
import kof.game.common.CRewardUtil;
import kof.game.instance.enum.EInstanceType;

public class CChapterListData extends CObjectListData {
    public function CChapterListData() {
        super (CChapterData, CChapterData._chapterID);
    }
    // 非同步server数据, 由配置表数据创建
    public function initialData(datas:Object) : void {
        super.updateDataByData(datas);
    }

    public override function updateDataByData(list:Object) : void {
        super.updateDataByData(list);

        for each (var objData:Object in list) {
            this.getByID(objData[CChapterData._chapterID]).isServerData = true;
        }
    }
    public function updateChapterReward(chapter:int, rewardIndex:int) : void {
        var chapterData:CChapterData = this.getByID(chapter);
        if (chapterData) {
            chapterData.updateReward(rewardIndex);
        }
    }
    public function getFirstChapter(instanceType:int) : CChapterData {
        var list:Array = this.list;
        for (var i : int = 0; i < list.length; i++) {
            var data:CChapterData = list[i] as CChapterData;
            if (data.isFirstChapter && instanceType == data.instanceType) {
                return data;
            }
        }
        return null;
    }
    public function getOpenList(instanceType:int) : Array {
        var ret:Array = new Array();
        var list:Array = getChapterListByType(instanceType);
        var chapter:CChapterData;
        var instance:CInstanceData = _rootData as CInstanceData;
        for (var i:int = 0; i < list.length; i++) {
            chapter = (list[i]);
            if (instance.isChapterOpen(instanceType, chapter.chapterID)) {
                ret.push(chapter);
            }
        }
        return ret;
    }
    public function getChapterIndex(instanceType:int, chapterID:int) : int {
        var openList:Array = getOpenList(instanceType);
        for (var i:int = 0; i < openList.length; i++) {
            var chapter:CChapterData = openList[i] as CChapterData;
            if (chapter && chapter.chapterID == chapterID) {
                return i;
            }
        }
        return 0;
    }
    public function getOpenNameList(instanceType:int) : Array {
        var ret:Array = new Array();
        var list:Array = getChapterListByType(instanceType);
        var chapter:CChapterData;
        var instance:CInstanceData = _rootData as CInstanceData;
        for (var i:int = 0; i < list.length; i++) {
            chapter = (list[i]);
            if (instance.isChapterOpen(instanceType, chapter.chapterID)) {
                ret.push(chapter.name);
            }
        }
        return ret;
    }
    public function getChapterOpenListLess6(instanceType:int) : Array {
        var ret:Array = new Array();
        var list:Array = getChapterListByType(instanceType);
        var chapter:CChapterData;
        var instance:CInstanceData = _rootData as CInstanceData;
        for (var i:int = 0; i < list.length; i++) {
            chapter = (list[i]);
            if (instance.isChapterOpen(instanceType, chapter.chapterID) || i < 6) {
                ret.push(chapter);
            }
        }
        return ret;
    }
    public function getByID(ID:int) : CChapterData {
        return super.getByPrimary(ID) as CChapterData;
    }
    public function getChapterListByType(instanceType:int) : Array {
        return getListByKey(CChapterData._instanceType, instanceType);
    }

    public function getScenarioOneKeyRewardDataList() : Array {
        var list:Array = childList;
        var ret:Array;
        var chapterRewardData:CInstanceOneKeyRewardItemData;
        for each (var data:IObjectData in list) {
            if (data[CChapterData._instanceType] == EInstanceType.TYPE_MAIN) {
                var chapterData:CChapterData = (data as CChapterData);
                var hasReward:Boolean = isChapterHasReward(chapterData);
                if (hasReward) {
                    if (!ret) {
                        ret = new Array();
                    }
                    var isReward1:Boolean = chapterData.isRewarded(1) == false && chapterData.isCanGetReward(0);
                    var isReward2:Boolean = chapterData.isRewarded(2) == false && chapterData.isCanGetReward(1);
                    var isReward3:Boolean = chapterData.isRewarded(3) == false && chapterData.isCanGetReward(2);
                    if (isReward1) {
                        chapterRewardData = new CInstanceOneKeyRewardItemData();
                        chapterRewardData.chapterID = chapterData.chapterID;
                        chapterRewardData.subIndex = 1;
                        chapterRewardData.rewardList = CRewardUtil.createByDropPackageID((_databaseSystem as CAppSystem).stage, chapterData.reward[0]).list;
                        ret[ret.length] = chapterRewardData;
                    }
                    if (isReward2) {
                        chapterRewardData = new CInstanceOneKeyRewardItemData();
                        chapterRewardData.chapterID = chapterData.chapterID;
                        chapterRewardData.subIndex = 2;
                        chapterRewardData.rewardList = CRewardUtil.createByDropPackageID((_databaseSystem as CAppSystem).stage, chapterData.reward[1]).list;
                        ret[ret.length] = chapterRewardData;
                    }
                    if (isReward3) {
                        chapterRewardData = new CInstanceOneKeyRewardItemData();
                        chapterRewardData.chapterID = chapterData.chapterID;
                        chapterRewardData.subIndex = 3;
                        chapterRewardData.rewardList = CRewardUtil.createByDropPackageID((_databaseSystem as CAppSystem).stage, chapterData.reward[2]).list;
                        ret[ret.length] = chapterRewardData;
                    }
                }
            }
        }
        return ret;
    }

    public function isScenarioHasReward() : Boolean {
        var list:Array = childList;
        for each (var data:IObjectData in list) {
            if (data[CChapterData._instanceType] == EInstanceType.TYPE_MAIN) {
                var chapterData:CChapterData = (data as CChapterData);
                var hasReward:Boolean = isChapterHasReward(chapterData);
                if (hasReward) {
                    return true;
                }
            }
        }
        return false;
    }
    public function isChapterHasReward(chapterData:CChapterData) : Boolean {
        var isReward1:Boolean = chapterData.isRewarded(1) == false && chapterData.isCanGetReward(0);
        var isReward2:Boolean = chapterData.isRewarded(2) == false && chapterData.isCanGetReward(1);
        var isReward3:Boolean = chapterData.isRewarded(3) == false && chapterData.isCanGetReward(2);
        if (isReward1 || isReward2 || isReward3) {
            return true;
        }
        return false;
    }
    public function isEliteHasReward() : Boolean {
        var list:Array = childList;
        for each (var data:IObjectData in list) {
            if (data[CChapterData._instanceType] == EInstanceType.TYPE_ELITE) {
                var chapterData:CChapterData = (data as CChapterData);
                var hasReward:Boolean = isChapterHasReward(chapterData);
                if (hasReward) {
                    return true;
                }
            }
        }
        return false;
    }
}
}
