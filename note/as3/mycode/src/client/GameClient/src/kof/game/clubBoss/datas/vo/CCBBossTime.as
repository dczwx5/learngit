//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/10/24.
 * Time: 14:29
 */
package kof.game.clubBoss.datas.vo {

/**
 * @author yili(guoyiligo@qq.com)
 * 2017/10/24
 */
public class CCBBossTime {
    public var time:Number=0;//时间戳
    public var type:int=0;//类型，0 活动准备（图标出现），进入副本提示框，2 结束倒计时
    public function CCBBossTime() {
    }

    public function setTime(obj:Object):void{
        this.time = obj.time;
        this.type = obj.type;
    }
}
}
