//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/19.
 */
package kof.game.title {

import kof.framework.CAbstractHandler;
import QFLib.Interface.IUpdatable;

import kof.framework.CAppSystem;
import kof.framework.IDatabase;
import kof.game.title.data.CTitleData;
import kof.game.title.data.CTitleItemData;
import kof.table.TitleConfig;

public class CTitleManager extends CAbstractHandler implements IUpdatable {
    public function CTitleManager() {
        clear();
    }

    public function update( delta : Number ) : void {
    }

    public override function dispose():void {
        super.dispose();
        clear();
    }

    public function clear() : void {

    }

    override protected function onSetup():Boolean {
        var ret:Boolean =  super.onSetup();
        _data = initialTitleDataByConfig(system);

        return ret;
    }
    public static function initialTitleDataByConfig(system:CAppSystem) : CTitleData {
        var titleData:CTitleData = new CTitleData(system.stage.getSystem(IDatabase) as IDatabase);
        var dataList:Array = new Array();
        var pItemList:Array = titleData.itemTable.toArray();
        var pItemRecord:TitleConfig;
        for (var i:int = 0; i < pItemList.length; i++) {
            pItemRecord = pItemList[i];

            var dataObject:Object = new Object();
            dataObject[CTitleItemData._configId] = pItemRecord.ID;
            dataObject[CTitleItemData._isComplete] = false;
            dataObject[CTitleItemData._invalidTick] = 0;
            dataList[dataList.length] = dataObject;
        }

        var allDataObject:Object = new Object();
        allDataObject[CTitleData._curTitle] = 0;
        allDataObject[CTitleData._titleInfos] = dataList;
        titleData.updateDataByData(allDataObject);

        return titleData;
    }

    [Inline]
    public function get data() : CTitleData {
        return _data;
    }
    [Inline]
    private function get _system() : CTitleSystem {
        return system as CTitleSystem;
    }
    private var _data:CTitleData;
}
}
