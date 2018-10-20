//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/11/3.
 */
package kof.game.instance.mainInstance.data {


// 副本通关奖励
public class CInstanceOneKeyRewardItemData {
    public function CInstanceOneKeyRewardItemData() {
    }

    public var chapterID:int; // 章节ID
    public var subIndex:int; // 章节宝箱index 1-3
    public var rewardList:Array; //

    public static const _subIndex:String = "subIndex";

}
}
