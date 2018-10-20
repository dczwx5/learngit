//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/11/6.
 */
package kof.game.gameSetting {

import flash.ui.Keyboard;

import kof.data.CObjectData;

public class CGameSettingData extends CObjectData {
    public static const IsCloseSound:String = "isCloseSound";// 一键静音
    public static const IsShieldOtherPlayers:String = "isShieldOtherPlayers";// 屏蔽其他玩家
    public static const IsBanOtherAddFriend:String = "isBanOtherAddFriend";// 禁止他人添加好友
    public static const IsRefusePeakPk:String = "isRefusePeakPk";// 拒绝所有切磋邀请
//    public static const IsShieldOtherEffect:String = "isShieldOtherEffect";// 屏蔽其他玩家特效
    public static const IsShieldAll:String = "isShieldAll";// 全部屏蔽
    public static const SoundEffectValue:String = "soundEffectValue";// 音效值
    public static const MusicValue:String = "musicValue";// 音乐值
    public static const IsShieldTitle:String = "isShieldTitle";// 屏蔽称号

    public static const KeyUp:String = "KeyUp";
    public static const KeyLeft:String = "KeyLeft";
    public static const KeyDown:String = "KeyDown";
    public static const KeyRight:String = "KeyRight";
    public static const KeySwitch:String = "keySwitch";

    public static const Attack:String = "attack";
    public static const Skill1:String = "skill1";
    public static const Skill2:String = "skill2";
    public static const Skill3:String = "skill3";
    public static const Dodge:String = "dodge";
    public static const Jump:String = "jump";

    public static const NewServerActivity:String = "newServerActivity";

    public function CGameSettingData()
    {
        super();
    }

// get=============================================================================================
    public function get isCloseSound() : Boolean { return _data[IsCloseSound]; }
    public function get isShieldOtherPlayers() : Boolean { return _data[IsShieldOtherPlayers]; }
    public function get isBanOtherAddFriend() : Boolean { return _data[IsBanOtherAddFriend]; }
    public function get isRefusePeakPk() : Boolean { return _data[IsRefusePeakPk]; }
//    public function get isShieldOtherEffect() : Boolean { return _data[IsShieldOtherEffect]; }
    public function get isShieldAll() : Boolean { return _data[IsShieldAll]; }
    public function get soundEffectValue() : Number { return _data[SoundEffectValue]; }
    public function get musicValue() : Number { return _data[MusicValue]; }
    public function get isShieldTitle() : Boolean { return _data[IsShieldTitle]; }

    public function get keyUpValue() : int { return _data[KeyUp]; }
    public function get keyLeftValue() : int { return _data[KeyLeft]; }
    public function get keyDownValue() : int { return _data[KeyDown]; }
    public function get keyRightValue() : int { return _data[KeyRight]; }
    public function get keySwitchValue() : int { return _data[KeySwitch]; }

    public function get attackKeyValue() : int { return _data[Attack]; }
    public function get skill1KeyValue() : int { return _data[Skill1]; }
    public function get skill2KeyValue() : int { return _data[Skill2]; }
    public function get skill3KeyValue() : int { return _data[Skill3]; }
    public function get dodgeKeyValue() : int { return _data[Dodge]; }
    public function get jumpKeyValue() : int { return _data[Jump]; }
    public function get newServerActivity() : Array {
        if( null == _data[NewServerActivity] )
                return [];
        return _data[NewServerActivity];
    }

// set=============================================================================================
    public function set isShieldOtherPlayers(value:Boolean) : void { _data[IsShieldOtherPlayers] = value; }
    public function set isCloseSound(value:Boolean) : void { _data[IsCloseSound] = value; }
    public function set isBanOtherAddFriend(value:Boolean) : void { _data[IsBanOtherAddFriend] = value; }
    public function set isRefusePeakPk(value:Boolean) : void { _data[IsRefusePeakPk] = value; }
//    public function set isShieldOtherEffect(value:Boolean) : void { _data[IsShieldOtherEffect] = value; }
    public function set isShieldAll(value:Boolean) : void { _data[IsShieldAll] = value; }
    public function set soundEffectValue(value:Number) : void { _data[SoundEffectValue] = value; }
    public function set musicValue(value:Number) : void { _data[MusicValue] = value; }
    public function set isShieldTitle(value:Boolean) : void { _data[IsShieldTitle] = value; }

    public function set keyUpValue(value:int) : void { _data[KeyUp] = value; }
    public function set keyLeftValue(value:int) : void { _data[KeyLeft] = value; }
    public function set keyDownValue(value:int) : void { _data[KeyDown] = value; }
    public function set keyRightValue(value:int) : void { _data[KeyRight] = value; }
    public function set keySwitchValue(value:int) : void { _data[KeySwitch] = value; }

    public function set attackKeyValue(value:int) : void { _data[Attack] = value; }
    public function set skill1KeyValue(value:int) : void { _data[Skill1] = value; }
    public function set skill2KeyValue(value:int) : void { _data[Skill2] = value; }
    public function set skill3KeyValue(value:int) : void { _data[Skill3] = value; }
    public function set dodgeKeyValue(value:int) : void { _data[Dodge] = value; }
    public function set jumpKeyValue(value:int) : void { _data[Jump] = value; }
    public function set newServerActivity(value:Array) : void { _data[NewServerActivity] = value; }


    public function isDefaultUpKey():Boolean
    {
        return keyUpValue == Keyboard.W || keyUpValue == Keyboard.UP;
    }

    public function isDefaultLeftKey():Boolean
    {
        return keyLeftValue == Keyboard.A || keyLeftValue == Keyboard.LEFT;
    }

    public function isDefaultDownKey():Boolean
    {
        return keyDownValue == Keyboard.S || keyDownValue == Keyboard.DOWN;
    }

    public function isDefaultRightKey():Boolean
    {
        return keyRightValue == Keyboard.D || keyRightValue == Keyboard.RIGHT;
    }
}
}
