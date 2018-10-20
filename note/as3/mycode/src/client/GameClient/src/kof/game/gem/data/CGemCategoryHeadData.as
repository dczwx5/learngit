//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/7/5.
 */
package kof.game.gem.data {

public class CGemCategoryHeadData {

    public var type:int;// EGemMbedType
    public var icon:String;
    public var name:String;
    public var isCanMerge:Boolean;// 是否可合成
    public var hasChild:Boolean;// 是否有子列表数据

    public function CGemCategoryHeadData()
    {
    }
}
}
