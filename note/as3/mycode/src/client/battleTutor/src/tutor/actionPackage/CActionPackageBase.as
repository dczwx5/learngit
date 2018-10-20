//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/27.
 */
package tutor.actionPackage {

import action.CActionBase;
import action.EKeyCode;

import kof.game.core.CGameObject;

import tutor.CTutorBase;

public class CActionPackageBase {
    public function CActionPackageBase() {
        totalPressCount = 3; // 默认3下
    }

    public virtual function buildAction() : CActionBase {
        return null; // need to override
    }

    public function getKeyCodeList() : Array {
        var ret:Array = new Array(keyList.length);
        for (var i:int = 0; i < keyList.length; i++) {
            ret[i] = EKeyCode.getKeyCodeByKey(keyList[i]);
        }
        return ret;
    }

    public function get key1() : String { return keyList[0]; }
    public function get key2() : String {
        if (keyList.length > 1)
            return keyList[1];
        else
            return key1;
    }
    public function get key3() : String {
        if (keyList.length > 2)
            return keyList[2];
        else
            return key1;
    }

    public function get content1() : String {
        return contentList[0];
    }
    public function get content2() : String {
        if (contentList.length > 1)
            return contentList[1];
        else
            return content1;
    }
    public function get content3() : String {
        if (contentList.length > 2)
            return contentList[2];
        else
            return content1;
    }
    public var tutorBase:CTutorBase;
    public var keyList:Array;
    public var contentList:Array;
    public var flyCount:int;
    public var forcePressKey:Boolean;

    public var _viewClass:Class;

    public var totalPressCount:int; // qte次数1 or 3, 或其他需要按键 次数的都可以用
    public var pressCount:int; // 当次按键 次数

    public var isMoveTo:Boolean;
    public var toX:Number;
    public var toY:Number;
    public var isMovePixel:Boolean = true;
    public var skillIDList:Array;

    public var destObject:CGameObject;
    public var srcObject:CGameObject;

    public var _audioID:String;
    public var _audioID2:String;
    public var _audioID3:String;

    // QTE
    public var _isAutoPlayOpen:Boolean; // 是否已经开始自动播放
    public var _needAutoPlay:Boolean; // 是否需要自动播放 - 被按键中断后就不需要了，或者一开始按了键也不需要
    public var _autoPlayStartTime:int;
    public const AUTO_PLAY_TIME:int = 5000;
    public const AUTO_STOP_QTE_TIME:int = 1000;

    public var _autoPlayKey2WaitTime:int = 0; // 等多久时间, 自动按key2
    public var _autoPlayKey3WaitTime:int = 0; // 等多久时间, 自动按key3
    public var _lastSkillAutoUseTime:int; // 上一次技能使用时间

    public var _maskShowed:Boolean = false;

    public var _isCloseQte:Boolean = false;

    public var _uploadGuideStep1:int;
    public var _uploadGuideStep2:int;
    public var _uploadGuideStep3:int;
    public var _UIO:Boolean;

    public var _showUIOClip:Boolean;
    public var _descIndex:int;

    public var _showJClip : Boolean;
    public var _showSpaceClip : Boolean;
}
}
