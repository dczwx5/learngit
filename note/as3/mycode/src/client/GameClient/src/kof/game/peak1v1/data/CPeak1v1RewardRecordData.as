//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/11/1.
 */
package kof.game.peak1v1.data {


// 奖励表数据封装, 原数据不好处理
public class CPeak1v1RewardRecordData {
    public function CPeak1v1RewardRecordData() {
    }

    public var ID:int;
    public var type:int;
    public var startValue:int; // 条件下限
    public var endValue:int; // 条件上限
    public var reward:int;

    public static const SORT_FLAG:String = "startValue";
}
}
