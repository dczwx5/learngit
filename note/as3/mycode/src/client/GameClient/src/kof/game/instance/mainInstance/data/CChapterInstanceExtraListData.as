//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/12/1.
 */
package kof.game.instance.mainInstance.data {

import kof.data.CObjectListData;
import kof.game.instance.enum.EInstanceType;


public class CChapterInstanceExtraListData extends CObjectListData {
    public function CChapterInstanceExtraListData() {
        super (CChapterInstanceData, CChapterInstanceData.INSTANCE_ID);
    }
    // 非同步server数据, 由配置创建
    public function initialData(datas:Object) : void {
        super.updateDataByData(datas);
    }
    public override function updateDataByData(list:Object) : void {
        super.updateDataByData(list);
        for each (var objData:Object in list) {
            this.getByID(objData[CChapterInstanceData.INSTANCE_ID]).isServerData = true;
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
    public function getByChapterID(chapterID:int) : Array {
        return super.getListByKey(CChapterInstanceData.CHAPTER_ID, chapterID);
    }
    public function isChapterInstanceAllFinish(chapterID:int) : Boolean {
        var list:Array = getByChapterID(chapterID);
        for each (var instance:CChapterInstanceData in list) {
            if (instance.isServerData == false) return false;
        }
        return true;
    }
    public function getByID(instanceID:int) : CChapterInstanceData {
        return super.getByPrimary(instanceID) as CChapterInstanceData;
    }
}
}
