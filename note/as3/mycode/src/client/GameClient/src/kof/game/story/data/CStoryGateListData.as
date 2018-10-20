//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/14.
 */
package kof.game.story.data {

import kof.data.CObjectListData
import kof.data.IObjectData;

public class CStoryGateListData extends CObjectListData {
    public function CStoryGateListData() {
        super (CStoryGateData, CStoryGateData._heroID, CStoryGateData._gateIndex);
    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);
    }
    public function getItem(heroID:int, gateIndex:int) : CStoryGateData {
        return super.getByPrimary(heroID, gateIndex) as CStoryGateData;
    }

    public function getListByHeroID(heroID:int) : Array {
        return super.getListByKey(CStoryGateData._heroID, heroID);
    }
    public function hasHero(heroID:int) : Boolean {
        var list:Array = childList;
         for each (var data:IObjectData in list) {
            if (data[CStoryGateData._heroID] == heroID) {
                return true;
            }
        }
        return false;
    }
}
}
