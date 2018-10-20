//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/8/3.
 */
package kof.game.cultivate.data.cultivate {

import kof.data.CObjectListData;

public class CCultivateBuffListData extends CObjectListData {
    public function CCultivateBuffListData() {
        super (CCultivateBuffData, null);
    }

    public function getBuffData(buffID:int) : CCultivateBuffData {
        for each (var buffData:CCultivateBuffData in list) {
            if (buffData.ID == buffID) {
                return buffData;
            }
        }
        return null;
    }
}
}
