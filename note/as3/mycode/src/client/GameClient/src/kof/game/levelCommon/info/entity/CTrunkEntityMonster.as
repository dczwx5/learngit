/**
 * Created by auto on 2016/7/2.
 */
package kof.game.levelCommon.info.entity {

import kof.game.levelCommon.info.appear.CTrunkAppear;
import kof.game.levelCommon.info.base.CTrunkEntityMapEntityBase;

public class CTrunkEntityMonster extends CTrunkEntityMapEntityBase {

    public var followPolicy:int; // 服务端AI用； 跟随 0:不跟随, 1关卡内跟随, 2:副本内跟随, 3:召唤师的
    public var spawnerType:int; // 出现类型？// 服务端用 0 -- 普通（过关条件需要检查该类型）1 -- 召唤刷怪点（特殊，过关条件不需要检查） 2 -- 剧情刷怪点（特殊，过关条件不需要检查）
    public var drop:Boolean; // 是否参与关卡掉落计算
    public var flag:int; // 怪物特殊标记 : 0 : 无, 1 : MonsterGroupNotSameWithlastTime
    // public var AI:int; // 工具使用
    public var count:int; // 刷怪怪物数量
    public var appearBreakable:Boolean; // : 出场时遇见敌人是否中断出场动作 true/false
    public var appearScaleFrom:Number; // 0~1, 出场缩放起始值
    public var appearScaleTime:Number; // 出场缩放时间
    public var appearEffectID:int; // 出场时特效
    public var fallStayTime:Number; // 降落落地停留时间
    public var fadeTime:Number; // 直接出现渐隐时间
    public var fallHeight:int; // 下落高度
    public var fallEffect:String; // 下落特效
    public var shakeWhenFall:Boolean; // 下落震动
    public var playSkill:int; // 技能ID
    public var playAction:String; // 动作ID
    public var isPlayAction:Boolean; // 是否播放动作
    public var loop:Boolean;//是否循环播放
    public var loopTime:Number;//播放时间
    public var moveToAvailablePosition:Boolean;//允许停留在阻挡内


    public var hideFootEffect:Boolean;//脚底特效开关
    public var appearType:int; // ELevelAppearType
    public var appear:CTrunkAppear; // 出现的方式
    public var aiPosition:Array;
    public var warnRange:Object;
    public var delay:Number;
    public var rate:Number; // 刷怪概率, 如果不通过则不刷怪, 一般配1


    /**@see EntityAppearPolicyType*/
    // public var appearPolicy:int; // 0 -- 直接出现 1 -- 走到出现位置 2 -- 跑到出现位置 3 -- 释放技能到出现位置（暂时没用到） 4 -- 从上方落下到出现位置
    // public var appearSkill:int; // 出现时使用的技能？
    // public var displayName:String; // 如：刷怪点
    // public var group:int; // ?

    // public var level:int; // 等级？

    public function CTrunkEntityMonster(data:Object) {
        super (data);


        followPolicy = data["followPolicy"];
        spawnerType = data["spawnerType"];
        drop = data["drop"];
        flag = data["flag"];
        count = data["count"];
        appearBreakable = data["appearBreakable"];
        appearScaleFrom = data["appearScaleFrom"];
        appearScaleTime = data["appearScaleTime"];
        appearEffectID = data["appearEffectID"];
        fallStayTime = data["fallStayTime"];
        fadeTime = data["fadeTime"];

        fallHeight = data["fallHeight"];
        shakeWhenFall = data["shakeWhenFall"];
        playSkill = data["playSkill"];
        fallEffect = data["fallEffect"];
        playAction = data["playAction"];
        isPlayAction = data["isPlayAction"];
        loop = data["loop"];
        loopTime = data["loopTime"];

        appearType = data["appearType"];
        appear = new CTrunkAppear(data["appear"]);
        delay = data["delay"];
        rate = data["rate"];
        aiPosition = data["aiPosition"];
        warnRange = data["warnRange"];
        hideFootEffect = data["hideFootEffect"];


    }


}
}
