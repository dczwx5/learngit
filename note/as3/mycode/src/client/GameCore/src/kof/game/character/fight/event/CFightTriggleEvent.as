//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/7/14.
//----------------------------------------------------------------------
package kof.game.character.fight.event {

import flash.events.Event;

import kof.game.core.CGameObject;

public class CFightTriggleEvent extends Event {

    /**
     * 技能链的触发条件
     */
    public static const HIT_TARGET : String = "hittargetevent";//技能击中敌方
    public static const BEING_HITTED : String = "beinghitted";//被击中
    public static const BEING_HURT : String = "beinghurt";//受伤中
    public static const BEING_KNOCKUP : String = "beingknockup";//被击飞了
    public static const GET_BULLET : String = "gotbullet";//中子弹
    public static const HURT_TARGET : String = "hurttarget";//击伤目标
    public static const T_LAND_EVENT: String = "landtoground";//落地事件
    public static const T_BLOCK_SCENE :String= "blockinscene";//到达在场景边缘
    public static const CATCH_EFFECT_SUCCEED : String = "catcheffectsucceed";//成功抓取
    /**
     * others
     */
    public static const MISSILE_EXPLOSION_END : String = "missileExplosionend";
    public static const MISSILE_EXPLOSION_BEGIN : String = 'missileexplosionbegin';
    public static const MISSILE_COLLIDE_EXPLOSION : String = 'missilecolliedexplosion'; //子弹碰撞事件
    public static const MISSILE_DEAD : String  = 'missileDead'; //子弹死亡
    public static const MISSILE_ANIMATION_END : String = "missileanimationend" ;//子弹动作播放完成
    public static const HERO_MISSILE_DEAD : String = "heromissiledead";//格斗家子弹消亡
    public static const HERO_MISSILE_ACTIVATE : String = "missileactivate" ; //格斗家子弹激活

    /**
     * network sync
     */
    public static const REQUEST_SYNC_FIGHT_HIT : String="syncfightHit";
    public static const REQUEST_SYNC_FIGHT_STATE  : String= "syncfightskill";
    public static const REQUEST_SYNC_FIGHT_STATE_VALUE : String  = "syncfightstatevalue";
    public static const REQUEST_SYNC_DODGE : String = "syncdodge";
    public static const REQUEST_SYNC_JUMP : String = "syncjump";
    public static const REQUEST_SYNC_ADDBUFF : String = "syncbuffeffect";
    public static const REQUEST_SYNC_EFFECT : String = "syncdotEffect";
    public static const REQUEST_SYNC_HEAL : String = "synchealeffect";
    public static const REQUEST_SYNC_CATCH : String = "synccatcheffect";
    public static const EVT_TIME_LINE_NODE_INSERTED : String = "timelinenodeinserted";
    public static const REQUEST_SYNC_SKILL_STATE : String  = "syncstate";
    public static const REQUEST_MISSILE_ABSORB : String = "absorbmissile";
    public static const REQUEST_SUMMON : String = "summonsomething";
    public static const REQUEST_ASK_PROPERTY : String = "askproperty";
    public static const REQUEST_RETURN_SKILL_CONSUME : String = "returnskillcomsume";
    /**
     * response sync
     */
    public static const RESPONSE_FIGHT_SKILL : String = "responsefightskill";
    public static const RESPONSE_HIT : String = "responsehit";
    public static const RESPONSE_DODGE : String = "responsedodge";
    public static const RESPONSE_FIGHT_SKILL_EXIT  : String = "responseexitskill";
    public static const RESPONSE_SYNC_PROPERTY : String = "responsesyncproperty";
    public static const RESPONSE_SYNC_CATCH : String = "responsesynccatch";
    public static const RESPONSE_ROLL_BACK : String = "responseskillrollback";
    /**
     * AI related
     */
    public static const SPELL_SKILL_BEGIN : String = "beginspellskill"; //开始释放技能
    public static const SPELL_SKILL_READY_END : String = "spellskillreadyend";//技能释放完成W
    public static const SPELL_SKILL_END : String = "spellskillend";//技能释放完成
    public static const SPELL_SKILL_FAILED : String = "spellskillfailed";//技能释放失败
    public static const ANIMATION_ACTION_END : String = "animationend";//技能动作播放完成
    public static const CONTINUE_KEY_DOWN :String = "continuekeydown";//用于几连技能按键连击
    public static const CONTINUE_KEY_UP : String = 'continuekeyup';//
    public static const COLLISION_HIT_SOMEBODY : String = "collisionhit";//碰撞框碰到sb（somebody）
    public static const SKILL_NOT_EXIST : String = "spellskillnotexsit";//该索引对应的怪物（人物）技能表中技能没配置
    public static const SKILL_HIT_NOBODY : String = "skillhitnobody";//技能没打中对方
    public static const SKILL_CHAIN_PASS_EVALUATION : String = "skillchainpassevaluation";//技能链通过条件
    public static const SKILL_CHAIN_OUTDATE : String = "skilloutdate";//手动技能链失效事件
    public static const SKILL_ACTION_BEGINE : String = "skillactionbegin";//技能动作开始
    public static const SKILL_BE_INTERRUPTED : String = "skillbeinterrupted";//技能被打断

    /**
     * UI component related
     */
    public static const EVT_PLAYER_COUNTER : String = "playercounter";//破招别人
    public static const EVT_PLAYER_CRITICALHIT : String = "playercriticalhit"; //暴击别人
    public static const EVT_PLAYER_DRIVECANCEL : String = "playerdrivecancel";
    public static const EVT_PLAYER_SUPERCANCEL : String = "playersupercancel";
    public static const EVT_PLAYER_QUICKSTANDING : String = "playerquickstanding";
    public static const EVT_PLAYER_PUCANCEL : String = "pugongcancel";//普攻被取消
    public static const EVT_BEING_CRITICALHITTED : String = "beingcriticalhit"; //被暴击

    public static const EVT_PLAYER_CONTINUSHITCNT : String = " playercontinushitcount"; //连击
    public static const EVT_NOT_ENOUGHT_AP : String = "notenoughap" ;//
    public static const EVT_NOT_ENOUGHT_DP : String = "notenoughdp" ;//
    public static const EVT_NOT_ENOUGHT_RP : String = "notenoughrp";
    public static const EVT_NOT_ENOUGHT_CD : String = "skillincd";

    /**
     * buff
     */
    public static const BUFF_ADD : String = "buffadd";
    public static const BUFF_REMOVE : String = "buffremove";
    public static const BUFF_EFFECT : String = "buffeffect";


    public function CFightTriggleEvent( type : String, theOwner : CGameObject,theParmList: Array = null)
    {
        super( type, false, true );
        m_owner = theOwner;
        m_parmList = theParmList || [];
    }

    final public function get owner() : CGameObject { return m_owner;};
    final public function get parmList() : Array { return m_parmList; };
    private var m_owner : CGameObject;
    private var m_parmList : Array;
}
}
