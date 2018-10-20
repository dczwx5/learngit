//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/9/26.
 */
package kof.game.welfarehall.data {

import kof.data.CObjectData;

public class CAnnouncementData extends CObjectData {

    public static const Id:String = "id";// 公告id
    public static const Title:String = "title";// 标题
    public static const Content:String = "content";// 内容
    public static const Items:String = "items";// 详情列表
    public static const Imgs:String = "imgs";// 图片列表
    public static const Rewards:String = "rewards";// 奖励列表
    public static const StartTime:String = "data";// 公告开始时间
    public static const Version:String = "version";// 版本号
    public static const RewardState:String = "rewardState";// 0未领取 1已领取
    public static const IsPopUpEveryLogin:String = "isPopUpEveryLogin";// 是否每次登陆都显示 1是 0否
    public static const IsPopUpFirstLogin:String = "isPopUpFirstLogin";// 是否第一次登陆时显示

    public function CAnnouncementData()
    {
        super();
    }

    public static function createObjectData(id:String, title:String, content:String, items:Array, imgs:Array, rewards:Array,
                                            data:Number, version:String, rewardState:int, isPopUpEveryLogin:int,
                                            isPopUpFirstLogin:int) : Object
    {
        return {id:id, title:title, content:content, items:items, imgs:imgs, rewards:rewards, data:data, version:version,
            rewardState:rewardState, isPopUpEveryLogin:isPopUpEveryLogin, isPopUpFirstLogin:isPopUpFirstLogin};
    }

    public function get id() : String { return _data[Id]; }
    public function get title() : String { return _data[Title]; }
    public function get content() : String { return _data[Content]; }
    public function get items() : Array { return _data[Items]; }
    public function get imgs() : Array { return _data[Imgs]; }
    public function get rewards() : Array { return _data[Rewards]; }
    public function get startTime() : Number { return _data[StartTime]; }
    public function get version() : String { return _data[Version]; }
    public function get rewardState() : int { return _data[RewardState]; }
    public function get isPopUpEveryLogin() : int { return _data[IsPopUpEveryLogin]; }
    public function get isPopUpFirstLogin() : int { return _data[IsPopUpFirstLogin]; }
}
}
