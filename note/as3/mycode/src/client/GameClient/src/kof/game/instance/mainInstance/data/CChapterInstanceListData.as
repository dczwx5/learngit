//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/1.
 */
package kof.game.instance.mainInstance.data {

import kof.data.CObjectListData;
import kof.data.IObjectData;
import kof.game.instance.enum.EInstanceType;


public class CChapterInstanceListData extends CObjectListData {
    public function CChapterInstanceListData() {
        super (CChapterInstanceData, CChapterInstanceData.INSTANCE_ID);
    }
    // 非同步server数据, 由配置创建
    public function initialData(datas:Object) : void {
        super.updateDataByData(datas);
    }
    public override function updateDataByData(list:Object) : void {
        // 解决高星被低星级覆盖的问题
        var lastStar:int = 0;
        var pInstanceData:CChapterInstanceData;
        var tempList:Array = list as Array;
        if (tempList && tempList.length == 1) {
            // 打副本时，只有一个数据, 初始化时是整个列表
            var pInstanceObjectData:Object = tempList[0];
            pInstanceData = this.getByID(pInstanceObjectData[CChapterInstanceData.INSTANCE_ID]);
            if (pInstanceData) {
                lastStar = pInstanceData.star;
            }
        }

        super.updateDataByData(list);
        for each (var objData:Object in list) {
            var pItem:CChapterInstanceData = this.getByID(objData[CChapterInstanceData.INSTANCE_ID]);
            pItem.isServerData = true;
        }

        if (lastStar > 0) {
            // 判断是否需要回滚星级
            pInstanceData = this.getByID(objData[CChapterInstanceData.INSTANCE_ID]);
            if (pInstanceData.star < lastStar) {
                pInstanceData.star = lastStar;
            }
        }
    }

    public function getFirstInstance(instanceType:int) : CChapterInstanceData {
        var list:Array = this.childList;
        for (var i : int = 0; i < list.length; i++) {
            var data:CChapterInstanceData = list[i] as CChapterInstanceData;
            if (data.chapterID > 0 && data.isFirstInstance && instanceType == data.instanceType) {
                return data;
            }
        }
        return null;
    }
    // ret : CChapterInstanceData Array
    public function getByChapterID(instanceType:int, chapterID:int) : Array {
        var list:Array = childList;
        var ret:Array = new Array();
        for each (var data:CChapterInstanceData in list) {
            if (data.chapterID == chapterID && data.instanceType == instanceType) {
                ret.push(data);
            }
        }
        return ret;
    }
    public function isChapterInstanceAllFinish(instanceType:int, chapterID:int) : Boolean {
        var list:Array = getByChapterID(instanceType, chapterID);
        for each (var instance:CChapterInstanceData in list) {
            if (instance.isServerData == false) return false;
        }
        return true;
    }
    public function getFirstPassMovieInstanceByChapterID(instanceType:int, chapterID:int) : CChapterInstanceData {
        var instanceList:Array = getByChapterID(instanceType, chapterID);
        if (instanceList && instanceList.length > 0) {
            for each (var chapterInstanceData:CChapterInstanceData in instanceList) {
                if (chapterInstanceData.firstPassMovieUrl && chapterInstanceData.firstPassMovieUrl.length > 0) {
                    return chapterInstanceData;
                }
            }
        }
        return null;
    }
    public function getByID(instanceID:int) : CChapterInstanceData {
        return super.getByPrimary(instanceID) as CChapterInstanceData;
    }

    // 消耗大
    public function isEliteHasExternsReward() : Boolean {
        var list:Array = this.childList;
        for (var i : int = 0; i < list.length; i++) {
            var data:CChapterInstanceData = list[i] as CChapterInstanceData;
            if (EInstanceType.TYPE_ELITE == data.instanceType) {
                if (data.isServerData && data.rewardExtends > 0 && data.isDrawReard == false) {
                    // 通关, 且未领, 且是有宝箱的
                    return true;
                }
            }
        }
        return false;
    }
}
}
