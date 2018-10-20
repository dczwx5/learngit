//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/11/5.
//----------------------------------------------------------------------
package kof.game.character.fight.sync {

import QFLib.Foundation.CMap;

import flash.geom.Point;

import flash.net.registerClassAlias;
import flash.utils.ByteArray;
import flash.utils.getDefinitionByName;

import flash.utils.getQualifiedClassName;

import kof.game.core.CGameComponent;

public class CCharacterSyncBoard extends CGameComponent {

    /**
    public static const RAGE_POWER : String              = "RagePower";
    public static const CONSUME_RAGE_POWER : String      = "consumeRP";
    public static const DEFENSE_POWER : String           = "DefensePower";
    public static const MAX_DEFENSE_POWER : String       = "MaxDefensePower";
    public static const DEFENSE_POWER_DELTA : String     = "Defdelta";
    public static const ATTACK_POWER : String            = "AttackPower";
    public static const MAX_ATTACK_POWER : String        = "MaxAttackPower";
    public static const ATTACK_POWER_DELTA : String      = "Atkdelta";
    public static const SKILL_CD_LIST : String           = "skillcdlist";
    public static const SKILL_DIR : String               = 'skilldir';
    public static const SYNC_STATE : String              = "state";
    public static const SYNC_SUB_STATES : String         = "subStates";
    //站前的状态


    //这里是战中的状态了
    public static const BO_GUARD : String                = "guard";
    public static const BO_COUNTER : String              = "counter";
    public static const BO_CRITICAL_HIT : String         = "criticalHit";
    public static const BO_CRITICAL_COUNTER : String     = "criticalCounter";
    public static const BO_QUICKSTANDCOST : String       =    "quickStandCost";
    public static const BO_DRIVEROLLCOST : String        = "driveRollCost";
    public static const BO_PA_BODY : String              = "paBody";
    public static const BO_ON_GROUND : String            = "ground";
    public static const BO_DRIVE_CANCEL : String         = "drivecancel";

    //值对
    public static const DAMAGE_HURT : String             = "damageHurt";
    public static const CURRENT_HP : String              = "curHp";
    public static const HIT_EFFECT_POINT : String        = "hiteffectpoint";
    public static const NHEIGHT_PLAYER : String          = "height";
    public static const HIT_MOTION_RADIO : String        = 'hitmotionradio';
    //验证时间
    public static const QUEUE_SEQ_TIME : String          = "queueSeqTime";
    public static const CONTINUE_HIT_COUNT : String      = "hitcount";
    public static const HIT_BUFF_LIST : String           = 'hitbufflist';
    //抓取
    public static const CATCH_EFFECT_SEQENCE : String    = "catcheffectseqence";
    public static const BO_IGNORE_GUARD : String         = "hitignoreguardpwd";
    public static const CATCH_MOVE_DIR  : String         = "catchMoveDir";
    */
    public static const RAGE_POWER : String              = "0";
    public static const CONSUME_RAGE_POWER : String      = "1";
    public static const DEFENSE_POWER : String           = "2";
    public static const MAX_DEFENSE_POWER : String       = "3";
    public static const DEFENSE_POWER_DELTA : String     = "4";
    public static const ATTACK_POWER : String            = "5";
    public static const MAX_ATTACK_POWER : String        = "6";
    public static const ATTACK_POWER_DELTA : String      = "7";
    public static const SKILL_CD_LIST : String           = "8";
    public static const SKILL_DIR : String               = '9';
    public static const SYNC_STATE : String              = "10";
    public static const SYNC_SUB_STATES : String         = "11";
    //站前的状态


    //这里是战中的状态了
    public static const BO_GUARD : String                = "12";
    public static const BO_COUNTER : String              = "13";
    public static const BO_CRITICAL_HIT : String         = "14";
    public static const BO_CRITICAL_COUNTER : String     = "15";
    public static const BO_QUICKSTANDCOST : String       = "16";
    public static const BO_DRIVEROLLCOST : String        = "17";
    public static const BO_PA_BODY : String              = "18";
    public static const BO_ON_GROUND : String            = "19";
    public static const BO_DRIVE_CANCEL : String         = "20";

    //值对
    public static const DAMAGE_HURT : String             = "21";
    public static const CURRENT_HP : String              = "22";
    public static const HIT_EFFECT_POINT : String        = "23";
    public static const NHEIGHT_PLAYER : String          = "24";
    public static const HIT_MOTION_RADIO : String        = '25';
    //验证时间
    public static const QUEUE_SEQ_TIME : String          = "26";
    public static const CONTINUE_HIT_COUNT : String      = "27";
    public static const HIT_BUFF_LIST : String           = '28';
    //抓取
    public static const CATCH_EFFECT_SEQENCE : String    = "29";
    public static const BO_IGNORE_GUARD : String         = "30";
    public static const CATCH_MOVE_DIR  : String         = "31";

    //子弹同步
    public static const EMITTER_IDS : String = "32";

    //当前速度
    public static const CURRENT_ANIMATION_SPEED : String ="33";
    public static const MOTION_ID : String = "34";

    public static const SYNC_FIGHT_PROPERTY : Array = [ RAGE_POWER, DEFENSE_POWER, ATTACK_POWER, SKILL_DIR, MAX_ATTACK_POWER, MAX_DEFENSE_POWER ];
    public static const SYNC_SKILL_PROPERTY : Array = [ ATTACK_POWER, SKILL_DIR, MAX_ATTACK_POWER, RAGE_POWER, BO_ON_GROUND];
    public static const SYNC_HIT_PROPERTY : Array = [ DEFENSE_POWER, SKILL_DIR, MAX_DEFENSE_POWER ];
    public static const SYNC_HIT_STATUS : Array = [ BO_GUARD, BO_COUNTER, BO_CRITICAL_HIT, BO_CRITICAL_COUNTER, BO_PA_BODY, BO_ON_GROUND, HIT_BUFF_LIST ];


    public function CCharacterSyncBoard() {

    }

    override protected function onEnter() : void {
        super.onEnter();
        m_theDirMap = new CMap();
        m_theValueMap = new CMap();
        m_theDefaulMap = new CMap();

        m_theDefaulMap[ RAGE_POWER ] = 0;
        m_theDefaulMap[ DEFENSE_POWER ] = 0;
        m_theDefaulMap[ ATTACK_POWER ] = 0;
        m_theDefaulMap[ SKILL_DIR ] = 1;
        m_theDefaulMap[ BO_COUNTER ] = false;
        m_theDefaulMap[ BO_GUARD ] = false;
        m_theDefaulMap[ BO_CRITICAL_COUNTER ] = false;
        m_theDefaulMap[ BO_CRITICAL_HIT ] = false;
        m_theDefaulMap[ BO_DRIVEROLLCOST ] = false;
        m_theDefaulMap[ BO_QUICKSTANDCOST ] = false;
        m_theDefaulMap[ BO_PA_BODY ] = false;
        m_theDefaulMap[ DAMAGE_HURT ] = 0;
        m_theDefaulMap[ SKILL_CD_LIST ] = {};
        m_theDefaulMap[ HIT_EFFECT_POINT ] = null;
        m_theDefaulMap[ NHEIGHT_PLAYER ] = 0.0;
        m_theDefaulMap[ BO_ON_GROUND ] = true;
        m_theDefaulMap[ CONTINUE_HIT_COUNT ] = 0;
        m_theDefaulMap[ CATCH_EFFECT_SEQENCE ] = 0;
        m_theDefaulMap[ HIT_BUFF_LIST ] = [];
        m_theDefaulMap[ HIT_MOTION_RADIO ] = 0;
        m_theDefaulMap[ QUEUE_SEQ_TIME ] = 0.0;
        m_theDefaulMap[ DEFENSE_POWER_DELTA ] = 0;
        m_theDefaulMap[ ATTACK_POWER_DELTA ] = 0;
        m_theDefaulMap[ SYNC_STATE ] = 0;
        m_theDefaulMap[ SYNC_SUB_STATES ] = {};
        m_theDefaulMap[ CONSUME_RAGE_POWER ] = 0;
        m_theDefaulMap[ BO_DRIVE_CANCEL ] = false;
        m_theDefaulMap[ CURRENT_ANIMATION_SPEED ] = {};
        m_theDefaulMap[ MOTION_ID ] = 0;

    }

    public function setValue( key : String, value : * ) : void {
        m_theValueMap[ key ] = value;
        m_theDirMap[ key ] = true;
        m_boSyncDirty = true;
    }

    public function getValue( key : String ) : * {
        if ( key in m_theValueMap )
            return m_theValueMap[ key ];
        return undefined;
    }

    public function isValueDirty( key : String ) : Boolean {
        if ( key in m_theDirMap ) {
            return m_theDirMap[ key ];
        }
        return false;
    }

    public function resetValue( key : String ) : * {
        var defauleValue : * = m_theDefaulMap[ key ];
        var boPrimitive : Boolean = defauleValue is Boolean || defauleValue is Number || defauleValue is String;
        if ( !boPrimitive ) {
            var cls : Class = getDefinitionByName( getQualifiedClassName( defauleValue ) ) as Class;
            registerClassAlias( getQualifiedClassName( defauleValue ), cls );
            var ba : ByteArray = new ByteArray;
            ba.writeObject( defauleValue as cls );
            ba.position = 0;
            m_theValueMap[ key ] = ba.readObject() as cls;
            ba.clear();
        }
        else {
            m_theValueMap[ key ] = defauleValue;
        }

        m_theDirMap[ key ] = true;
        m_boSyncDirty = true;
    }

    public function get syncData() : Object {
        var isValueDirty : Boolean;
        var sync : Object = {};
        for ( var key : String in m_theValueMap ) {
            isValueDirty = m_theDirMap[ key ];
            if ( isValueDirty )
                sync[ key ] = m_theValueMap[ key ];
        }
        return sync;
    }

    final public function get isDirty() : Boolean {
        return m_boSyncDirty;
    }

    final public function clearAllDirty() : void {
        for ( var key : String in m_theDirMap ) {
            m_theDirMap[ key ] = false;
        }

        m_boSyncDirty = true;
    }

    override protected function onExit() : void {
        super.onExit();
        m_theDirMap.clear();
        m_theDirMap = null;

        m_theValueMap.clear();
        m_theValueMap = null;

        m_theDefaulMap.clear();
        m_theDefaulMap = null;

    }


    private var m_theValueMap : CMap;
    private var m_theDirMap : CMap;
    private var m_theDefaulMap : CMap;
    private var m_boSyncDirty : Boolean;
}
}
