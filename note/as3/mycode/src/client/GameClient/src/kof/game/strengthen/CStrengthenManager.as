//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/28.
 */
package kof.game.strengthen {

import kof.framework.CAbstractHandler;
import QFLib.Interface.IUpdatable;

import kof.framework.CAppSystem;
import kof.framework.IDatabase;
import kof.game.strengthen.data.CStrengthenData;
import kof.game.strengthen.data.CStrengthenItemData;
import kof.table.StrengthItem;

public class CStrengthenManager extends CAbstractHandler implements IUpdatable {
    public function CStrengthenManager() {
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
        _data = initialStrengthenDataByConfig(system);

        return ret;
    }
    public static function initialStrengthenDataByConfig(system:CAppSystem) : CStrengthenData {
        var strengthenData:CStrengthenData = new CStrengthenData(system.stage.getSystem(IDatabase) as IDatabase);
        var dataList:Array = new Array();
        var pItemList:Array = strengthenData.itemTable.toArray();
        var pItemRecord:StrengthItem;
        for (var i:int = 0; i < pItemList.length; i++) {
            pItemRecord = pItemList[i] as StrengthItem;

            var dataObject:Object = CStrengthenItemData.buildData(pItemRecord.ID);
            dataList[dataList.length] = dataObject;
        }

        strengthenData.updateDataByData(dataList);

        return strengthenData;
    }

    [Inline]
    public function get data() : CStrengthenData {
        return _data;
    }
    [Inline]
    private function get _system() : CStrengthenSystem {
        return system as CStrengthenSystem;
    }
    private var _data:CStrengthenData;
}
}
