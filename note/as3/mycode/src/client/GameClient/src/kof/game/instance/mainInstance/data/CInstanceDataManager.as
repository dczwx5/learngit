//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/7.
 */
package kof.game.instance.mainInstance.data {

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.instance.enum.EInstanceType;
import kof.game.player.data.CPlayerData;
import kof.table.Instance;
import kof.table.InstanceChapter;
import kof.table.InstanceContent;

public class CInstanceDataManager {
    public function CInstanceDataManager(pDatabaseSystem:IDatabase, playerData:CPlayerData) {
        _instanceData = new CInstanceData(pDatabaseSystem);
        _playerData = playerData;
        _buildInitialData(pDatabaseSystem);
    }

    public final function get playerData() : CPlayerData {
        return _playerData;
    }
    public final function get instanceData() : CInstanceData {
        return _instanceData;
    }

    private function _buildInitialData(pDatabaseSystem:IDatabase) : void {
        var instanceInitialData:Object = {};
        var i:int = 0;

        // chapterList
        var chapterTableList:Array = pDatabaseSystem.getTable(KOFTableConstants.INSTANCE_CHAPTER).toArray();
        chapterTableList.sortOn("ID", Array.NUMERIC);
        var chapterObject:Object;
        var chapterTable:InstanceChapter;
        var chapterInfoList:Array = new Array(chapterTableList.length);
        var typeMap:Object = new Object();
        var isFristChapter:Boolean;
        for (i = 0; i < chapterTableList.length; i++) {
            chapterTable = chapterTableList[i];
            isFristChapter = false;
            if (false == typeMap.hasOwnProperty(chapterTable.Type.toString())) {
                isFristChapter = true;
                typeMap[chapterTable.Type] = 1;
            }
            chapterObject = CChapterData.createEmptyData(chapterTable.ID, chapterTable.Type, null, isFristChapter);
            chapterInfoList[i] = chapterObject;
        }

        // instanceList
        var instanceContentList:Array = pDatabaseSystem.getTable(KOFTableConstants.INSTANCE_CONTENT).toArray();
        instanceContentList.sortOn("ID", Array.NUMERIC);

        var content:Object;
       // var instanceRecord:Instance;
        var instanceContentTable:InstanceContent;
        var instanceMessageList:Array = new Array(instanceContentList.length);
        typeMap = new Object();
        var isFirstInstance:Boolean;
        for (i = 0; i < instanceContentList.length; i++) {
            isFirstInstance = false;
            instanceContentTable = instanceContentList[i] as InstanceContent;
            if (instanceContentTable.Chapter > 0 && false == typeMap.hasOwnProperty(instanceContentTable.Type.toString())) {
                isFirstInstance = true;
                typeMap[instanceContentTable.Type] = 1;
            }
            content = CChapterInstanceData.createEmptyData(instanceContentTable.Chapter, instanceContentTable.ID, instanceContentTable.Type, isFirstInstance);
            instanceMessageList[i] = content;
        }

        instanceInitialData[CInstanceData._instanceMessageList] = instanceMessageList;
        instanceInitialData[CInstanceData._chapterInfoList] = chapterInfoList;
        instanceData.initialData(instanceInitialData);
    }


    private var _instanceData:CInstanceData;
    private var _playerData:CPlayerData;

}
}
