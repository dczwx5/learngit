//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/7/25.
 */
package kof.game.talent.talentFacade.talentSystem.data {

import kof.data.CObjectListData;

public class CTalentMeltingListData extends CObjectListData {
    public function CTalentMeltingListData()
    {
        super (CTalentMeltingData, CTalentMeltingData.Type);
    }

    public function getMeltData(type:int) : CTalentMeltingData
    {
        var data:CTalentMeltingData = this.getByPrimary(type) as CTalentMeltingData;
        return data;
    }
}
}
