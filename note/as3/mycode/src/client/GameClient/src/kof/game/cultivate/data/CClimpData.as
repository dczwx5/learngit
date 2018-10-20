//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/11.
 */
package kof.game.cultivate.data {

import kof.data.CObjectData;
import kof.framework.IDatabase;
import kof.game.cultivate.data.cultivate.CCultivateData;
import kof.message.ClimbTower.ClimbTowerChallengeResultResponse;
import kof.message.ClimbTower.ClimbTowerOpenBoxResponse;


public class CClimpData extends CObjectData {
    public function CClimpData(database:IDatabase) {
        setToRootData(database);

        this.addChild(CCultivateData);
    }

    // ===========================data
    public override function updateDataByData(data:Object) : void {
        // super.updateDataByData(data);

    }
    
    // ===========================rankData
    public function initialCultivateData(data:Object) : void {
        isServerData = true;
        cultivateData.clearData();
        cultivateData.isServerData = true;
        cultivateData.updateDataByData(data);
    }
    public function updateCultivateData(data:Object) : void {
        cultivateData.updateDataByData(data);
    }
    public function updateResultData(data:ClimbTowerChallengeResultResponse) : void {
        cultivateData.updateResultData(data);
    }
    public function updateRewardBoxData(data:ClimbTowerOpenBoxResponse) : void {
        cultivateData.updateRewardBoxData(data);
    }


    // ===========================reportData
    // 修行之路
    [Inline]
    public function get cultivateData() : CCultivateData {
        return getChild(0) as CCultivateData;
    }
}
}
