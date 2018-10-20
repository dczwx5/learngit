//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/14.
 */
package kof.game.story {

import kof.framework.CAbstractHandler;
import QFLib.Interface.IUpdatable;
import kof.framework.IDatabase;
import kof.game.story.data.CStoryData;
import kof.game.story.data.CStoryGateData;
import kof.table.HeroStoryBase;

public class CStoryManager extends CAbstractHandler implements IUpdatable {
    public function CStoryManager() {
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
        _data = new CStoryData(system.stage.getSystem(IDatabase) as IDatabase);

        var buyCountTotal:int = _data.BUY_FIGHT_COUNT_DAILY;

        var dataList:Array = new Array();
        var pHeroList:Array = _data.heroTable.toArray();
        var pHeroRecord:HeroStoryBase;
        for (var i:int = 0; i < pHeroList.length; i++) {
            pHeroRecord = pHeroList[i];
            if (pHeroRecord.challenge > 0) {
                var heroID:int = pHeroRecord.ID;
                var pGateList:Array = pHeroRecord.GateIDs;
                for (var gateIndex:int = 0; gateIndex < pGateList.length; gateIndex++) {
                    var gateDataObject:Object = new Object();
                    gateDataObject[CStoryGateData._heroID] = heroID;
                    gateDataObject[CStoryGateData._gateIndex] = gateIndex + 1;
                    gateDataObject[CStoryGateData._challengeNum] = 0;
                    gateDataObject[CStoryGateData._resetNum] = buyCountTotal;
                    var gateID:int = pGateList[gateIndex];
                    gateDataObject[CStoryGateData._gateID] = gateID;

                    dataList[dataList.length] = gateDataObject;
                }
            }
        }

        _data.updateDataByData(dataList);

        return ret;
    }

    [Inline]
    public function get data() : CStoryData {
        return _data;
    }
    [Inline]
    private function get _system() : CStorySystem {
        return system as CStorySystem;
    }
    private var _data:CStoryData;
}
}
