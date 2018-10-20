//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/7/5.
 */
package kof.game.gem.data {

import kof.table.Gem;

public class CGemCategoryListCellData {

    public var resultGem:Gem;// 结果宝石
    public var stuffGem:Gem;// 合成材料宝石
    public var canMergeNum:int;// 可合成数
    public var isCanMerge:Boolean;// 是否可合成

    public function CGemCategoryListCellData()
    {
    }
}
}
