//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/10/24.
 * Time: 14:32
 */
package kof.game.clubBoss.datas.vo {

import kof.message.ClubBoss.ClubBossInfoResponse;
import kof.message.ClubBoss.JoinClubBossResponse;

/**
 * @author yili(guoyiligo@qq.com)
 * 2017/10/24
 */
public class CCBFight {
    public var startFight:Boolean;//是否开启战斗，false 不开启，true 开启
    public var startTime:Number=0;//boss降临时间（时间戳，单位ms）
    public var diamondReviveTimes:int=0;//钻石复活次数
    public var maxHP:Number=0;//boss最大血量
    //战斗场内信息
//    public var bossId:Number=0;//boss id
    public var bossHP:Number=0;//工会boss剩余血量
    public var personal:Array=[];//伤害数据排行榜（个人）{id,name,rank,damage}
    public var club:Array=[];//伤害数据排行榜（工会）{id,name,rank,damage}

    public function CCBFight() {
    }

    public function setJoinFight(obj:JoinClubBossResponse):void{
        this.diamondReviveTimes = obj.diamondReviveTimes;
        this.maxHP = obj.maxHP;
    }

    public function setBossInfo(obj:ClubBossInfoResponse):void{
        this.bossHP = obj.hp;
        this.personal = obj.r;
        this.club = obj.c;
    }
}
}
