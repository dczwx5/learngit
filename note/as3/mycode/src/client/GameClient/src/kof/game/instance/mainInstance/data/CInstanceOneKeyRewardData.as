//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/11/3.
 */
package kof.game.instance.mainInstance.data {

import kof.data.CObjectData;
import kof.framework.CAppSystem;
import kof.game.common.CRewardUtil;
import kof.game.item.CItemData;
import kof.game.item.data.CRewardListData;

// 一键领取奖励
public class CInstanceOneKeyRewardData extends CObjectData {
    public function CInstanceOneKeyRewardData() {
    }

    public override function updateDataByData(data:Object) : void {
        resetChild();

        super.updateDataByData(data);
        var dataList:Array = data["dataList"];

        _itemList = new Array();
        if (dataList && dataList.length > 0) {
            var itemCount:int = dataList.length;
            var itemData:Object;
            var newItem:CInstanceOneKeyRewardItemData;
            for (var i:int = 0; i < itemCount; i++) {
                itemData = dataList[i];
                newItem = null;
                newItem = new CInstanceOneKeyRewardItemData();
                newItem.chapterID = itemData[_chapterID];
                newItem.subIndex = itemData[_rewardIndex];
                newItem.rewardList = itemData[_rewardList];
                _itemList[_itemList.length] = newItem;
            }
        }

        _itemList.sortOn([_chapterID, CInstanceOneKeyRewardItemData._subIndex], Array.NUMERIC);
    }

    public function get itemList() : Array {
        return _itemList;
    }

    public function getRewardListFull() : CRewardListData{
        if (!_itemList) return null;

        var totalRewardList:Array = new Array();
        var tempObject:Object = new Object();
        var item:CInstanceOneKeyRewardItemData;
        var subRewardList:Array;
        var itemData:Object;
        var num:int = 0;
        var ID:int = 0;
        var saveNum:int;
        for (var i:int = 0; i < _itemList.length; i++) {
            item = _itemList[i];
            subRewardList = item.rewardList;
            for each (itemData in subRewardList) {
                num = itemData[CItemData.NUM];
                ID = itemData[CItemData.ITEM_ID];
                if (false == tempObject.hasOwnProperty(ID.toString())) {
                    tempObject[ID] = 0;
                }
                saveNum = tempObject[ID];
                tempObject[ID] = saveNum + num;
            }
        }


        for (var key:* in tempObject) {
            totalRewardList[totalRewardList.length] = {num:tempObject[key], ID:key};
        }

        var ret:CRewardListData = CRewardUtil.createByList((_databaseSystem as CAppSystem).stage, totalRewardList);
        return ret;
    }

    public static const _chapterID:String = "chapterID";
    public static const _rewardIndex:String = "rewardIndex";
    public static const _rewardList:String = "rewardList";

    private var _itemList:Array;
}
}
