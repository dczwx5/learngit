//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/8/4.
 * Time: 10:15
 */
package kof.game.globalBoss.datas.vo {

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/8/4
     */
    public class CWBFightData {
        // 世界boss场内信息
        public var bossHP : Number = 0;// 世界boss剩余血量
        public var rank : Array = [];// 伤害数据排行榜 {roleId:xx,damage:xx,name:xx,heroId:xx}, 过滤掉未在榜上的玩家
        public var rankBase : Array = [];// 基础列表

        //复活
        public var result : int = 0;// 复活原因： 0 自动复活，1 钻石复活
        // 刷新假人信息
        public var infos : Array = [];// 假人信息集合
        //鼓舞
//        public var goldInspireTimes : int = 0;// 金币鼓舞次数
//        public var diamondInspireTimes : int = 0;// 钻石鼓舞次数
        // 玩家是否在世界boss中状态变化
        public var roleId : Number = 1;// 角色id
        public var inWorldBoss : Boolean = true;//是否在世界boss中
        // 世界boss血量百分比聊天频道推送
        public var percent : int = 1;// 剩余血量百分比

        public var selfData:Object;

        public function CWBFightData() {
        }
    }
}
