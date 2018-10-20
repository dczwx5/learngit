//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/10/24.
 * Time: 11:35
 */
package kof.game.clubBoss.datas.vo {

/**
 * @author yili(guoyiligo@qq.com)
 * 2017/10/24
 */
public class CCBMainUIInfo {
    public var bossId:Number=0;//工会boss id
    public var bossLevel:int=0;//boss等级
    public var state:int=0;//当前工会boss状态，0 准备中，1 进行中，2已击败，3未解锁
    public var heroId:Number=0;//上阵格斗家id
    public var clubName:String="";//上轮工会冠军
    public var username:String="";//上轮本会击杀玩家
    public var maxHP:Number=0;//最大血量
    public var hp:Number=0;//血量

    public function CCBMainUIInfo() {
    }

    public function decode(obj:Object):void{
        this.bossId = obj.bossId;
        this.bossLevel = obj.bossLevel;
        this.state = obj.state;
        this.heroId = obj.heroId;
        this.clubName = obj.clubName;
        this.username = obj.username;
        this.maxHP = obj.maxHP;
        this.hp = obj.hp;
    }
}
}
