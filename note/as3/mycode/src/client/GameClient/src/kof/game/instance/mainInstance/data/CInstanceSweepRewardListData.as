//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/1.
 */
package kof.game.instance.mainInstance.data {

import kof.data.CObjectListData;
import kof.game.item.data.CRewardListData;

public class CInstanceSweepRewardListData  extends CObjectListData {
    public function CInstanceSweepRewardListData() {
        super(CRewardListData, null);
    }

    public override function updateDataByData(data:Object) : void {
        this.resetChild();
        var tempList:Array = data as Array;
        var list:Array = new Array(tempList.length);

        for (var i:int = 0; i < tempList.length; i++) {
            list[i] = (tempList[i] as Object)["rewardMap"];
        }
        super.updateDataByData(list);
    }
}
}
