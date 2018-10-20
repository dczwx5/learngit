//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/26.
 */
package kof.game.gem.data {

import kof.data.CObjectListData;

/**
 * 所有页的宝石孔数据
 */
public class CGemPageListData extends CObjectListData {
    public function CGemPageListData()
    {
        super(CGemPageData, CGemPageData.PageType);
    }

    public function getDataByPage(pageType:int):CGemPageData
    {
        return this.getByPrimary(pageType) as CGemPageData;
    }
}
}
