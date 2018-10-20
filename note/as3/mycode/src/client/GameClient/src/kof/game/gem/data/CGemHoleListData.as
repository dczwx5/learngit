//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/26.
 */
package kof.game.gem.data {

import kof.data.CObjectListData;

/**
 * 宝石孔列表数据
 */
public class CGemHoleListData extends CObjectListData {
    public function CGemHoleListData()
    {
        super(CGemHoleData, CGemHoleData.GemPointConfigID);
    }

    public function getHoleDataById(holeId:int) : CGemHoleData
    {
        var holeData:CGemHoleData = this.getByPrimary(holeId) as CGemHoleData;
        return holeData;
    }
}
}
