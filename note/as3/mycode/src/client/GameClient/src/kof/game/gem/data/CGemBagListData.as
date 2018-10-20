//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/27.
 */
package kof.game.gem.data {

import kof.data.CObjectListData;

/**
 * 宝石包列表数据
 */
public class CGemBagListData extends CObjectListData {
    public function CGemBagListData()
    {
        super( CGemBagData, CGemBagData.GemConfigID);
    }

    public function getDataByID(id:int):CGemBagData
    {
        return this.getByPrimary(id) as CGemBagData;
    }
}
}
