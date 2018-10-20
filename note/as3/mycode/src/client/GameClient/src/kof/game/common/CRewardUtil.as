//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/16.
 */
package kof.game.common {

import kof.data.CDataTable;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAppStage;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.table.DropPackage;

public class CRewardUtil {
    public static function createByDropPackageID(stage:CAppStage, packageID:int,times:int = 1) : CRewardListData {
        if (packageID <= 0) return null;

        var result:CRewardListData = new CRewardListData();
        result.setToRootData(stage.getSystem(CDatabaseSystem) as CDatabaseSystem);
        var dataList:Array = new Array();
        var pDatabaseSystem:CDatabaseSystem = stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
        var packageTable:CDataTable = pDatabaseSystem.getTable(KOFTableConstants.DROP_PACKAGE) as CDataTable;
        var packageData:DropPackage = packageTable.findByPrimaryKey(packageID) as DropPackage;
        for (var i:int = 0; i < 20; i++) {
            var sourceID:int = packageData["resourceID" + (i+1)];
            if (sourceID > 0) {
                var wardType:int = CRewardData.getTypeByID(sourceID);
                var count:int = packageData["countMin" + (i+1)] * times; // 先用min
                var wardData:Object = CRewardData.buildData(wardType, sourceID, count);
                dataList.push(wardData);
            }
        }

        result.updateDataByData(dataList);

        return result;
    }
    public static function createByList(stage:CAppStage, datas:Array) : CRewardListData {
        if (datas == null || datas.length == 0) return null;

        var result:CRewardListData = new CRewardListData();
        result.setToRootData(stage.getSystem(CDatabaseSystem) as CDatabaseSystem);

        var dataList:Array = new Array();
        for (var i:int = 0; i < datas.length; i++) {
            var item:Object = datas[i];
            var sourceID:int = item["ID"];
            var num:int = item.hasOwnProperty("num") ? item["num"] : 0;
            var wardType:int = CRewardData.getTypeByID(sourceID);
            var wardData:Object = CRewardData.buildData(wardType, sourceID, num);
            dataList.push(wardData);
        }

        result.updateDataByData(dataList);

        return result;
    }

    public static function createByList2(stage:CAppStage, datas:Array) : CRewardListData {
        if (datas == null || datas.length == 0) return null;

        var result:CRewardListData = new CRewardListData();
        result.setToRootData(stage.getSystem(CDatabaseSystem) as CDatabaseSystem);

        var dataList:Array = new Array();
        for (var i:int = 0; i < datas.length; i++) {
            var item:Object = datas[i];
            var sourceID:int = item["ID"];
            var num:int = item.hasOwnProperty("num") ? item["num"] : 0;
            var wardType:int = CRewardData.getTypeByID(sourceID);
            var wardData:Object = CRewardData.buildData(wardType, sourceID, num);
            dataList.push(wardData);
        }

        result.addDataByData(dataList);

        return result;
    }

    /**
     * 整合掉落包
     * @param stage
     * @param packageID  掉落包集合
     * @param times      重复次数
     * @return
     */
    public static function createByDropPackageIDArray(stage:CAppStage, packageIDArray:Array,timeArray:Array) : CRewardListData {
        if (packageIDArray.length <= 0 && packageIDArray.length != timeArray.length) return null;

        var result:CRewardListData = new CRewardListData();
        result.setToRootData(stage.getSystem(CDatabaseSystem) as CDatabaseSystem);
        var dataList:Array = new Array();
        var pDatabaseSystem:CDatabaseSystem = stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
        var packageTable:CDataTable = pDatabaseSystem.getTable(KOFTableConstants.DROP_PACKAGE) as CDataTable;
        var packageID : int;
        var itemIDTemp : Array = [];
        var wardType:int;
        var count:int;
        var wardData:Object;
        var packageData:DropPackage;
        for(var j : int = 0; j < packageIDArray.length; j++)
        {
            packageID = packageIDArray[j];
            if(packageID <= 0) continue;
            packageData = packageTable.findByPrimaryKey(packageID) as DropPackage;
            for (var i:int = 0; i < 20; i++)
            {
                var sourceID:int = packageData["resourceID" + (i+1)];
                if (sourceID > 0) {
                    if(itemIDTemp.indexOf(sourceID) == -1)//创建新data
                    {
                        wardType = CRewardData.getTypeByID(sourceID);
                        count = packageData["countMin" + (i+1)] * timeArray[j]; // 先用min
                        wardData = CRewardData.buildData(wardType, sourceID, count);
                        dataList.push(wardData);
                        itemIDTemp.push(sourceID);//记录已有ID
                    }
                    else//已有data，合并数量
                    {
                        for each(var obj :Object in dataList)
                        {
                            if(obj.ID == sourceID)
                            {
                                wardType = CRewardData.getTypeByID(sourceID);
                                count = packageData["countMin" + (i+1)] * timeArray[j] + obj.num;//数量叠加
                                wardData = CRewardData.buildData(wardType, sourceID, count);
                                dataList.push(wardData);
                                break;
                            }
                        }
                    }
                }
            }
        }

        result.updateDataByData(dataList);

        return result;
    }
}
}
