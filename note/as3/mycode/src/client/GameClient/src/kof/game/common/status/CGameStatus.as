//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/12/7.
 */
package kof.game.common.status {

import kof.framework.CAppSystem;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CLang;
import kof.game.hook.CHookSystem;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;

/**
 * 状态互斥
 */
public class CGameStatus {

    private static var _currStatus:int;

    /** 处于副本地图状态 */
    public static const Status_InInstance:int = 1;
    /** 拳皇大赛匹配状态 */
    public static const Status_PeakGameMatch:int = 2;
    /** 巅峰赛匹配状态 */
    public static const Status_Peak1v1Match:int = 4;
    /** 切磋匹配状态 */
    public static const Status_PeakPKMatch:int = 8;
    /** 角色抽卡状态 */
    public static const Status_PlayerCard:int = 16;
    /** 装备抽卡状态 */
    public static const Status_EquipCard:int = 32;
    /** 挂机状态 */
    public static const Status_Hook:int = 64;

    /** 巅峰赛加载状态 */
    public static const Status_Peak1v1Loading:int = 128;
    /** 公会战匹配状态 */
    public static const Status_GuildWarMatch:int = 256;
    /** 公会战加载状态 */
    public static const Status_GuildWarLoading:int = 512;

    public static const Status_StreetFighterMatch:int = 1024;

    public function CGameStatus()
    {
    }

    /**
     * 检查当前状态
     * @param system
     * @param isShowConflicTip 是否显示状态冲突提示
     * @return
     */
    public static function checkStatus(system:CAppSystem, isShowConflicTip:Boolean = true):Boolean
    {
        if(_currStatus == 0)
        {
            return true;
        }

        var msg:String;
        if ((_currStatus & Status_InInstance) != 0) {
            msg = CLang.Get("gameStatus_InInstance");
        } else if ((_currStatus & Status_PeakGameMatch) != 0) {
            msg = CLang.Get("gameStatus_PeakGameMatch");
        } else if ((_currStatus & Status_Peak1v1Match) != 0) {
            msg = CLang.Get("gameStatus_Peak1v1Match");
        } else if ((_currStatus & Status_PeakPKMatch) != 0) {
            msg = CLang.Get("gameStatus_PeakPkMatch");
        } else if ((_currStatus & Status_PlayerCard) != 0) {
            msg = CLang.Get("gameStatus_PlayerCard");
        } else if ((_currStatus & Status_EquipCard) != 0) {
            msg = CLang.Get("gameStatus_EquipCard");
        }else if ((_currStatus & Status_Hook) != 0) {
            var ctx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
            var hookSystem:ISystemBundle = system.stage.getSystem(CHookSystem) as ISystemBundle;
            if (system != hookSystem) {
                ctx.setUserData(hookSystem, CBundleSystem.ACTIVATED, false);
                unSetStatus(Status_Hook);
                return _currStatus == 0;
            }
//            msg = CLang.Get("gameStatus_Hook");
        } else if ((_currStatus & Status_Peak1v1Loading) != 0) {
            msg = CLang.Get("gameStatus_Peak1v1Loading");
        } else if ((_currStatus & Status_GuildWarLoading) != 0) {
            msg = CLang.Get("gameStatus_GuildWarLoading");
        } else if ((_currStatus & Status_GuildWarMatch) != 0) {
            msg = CLang.Get("gameStatus_GuildWarMatch");
        } else if ((_currStatus & Status_StreetFighterMatch) != 0) {
            msg = CLang.Get("gameStatus_street_fighter_match");
        } else {
            msg = CLang.Get("gameStatus_Unknown", {v1:_currStatus});
        }

        if(isShowConflicTip && msg && system)
        {
            (system.stage.getSystem(IUICanvas) as CUISystem).showMsgAlert(msg);
        }

        return false;
    }

    /**
     * 设置状态
     * @param value (枚举 CGameStatus)
     */
    public static function setStatus(value:int):void
    {
        _currStatus = (_currStatus | value);
    }

    public static function unSetStatus(value:int) : void {
        _currStatus = (_currStatus | value) - value;
        var status:int = _currStatus;
    }

    /**
     * 重置状态
     */
    public static function resetStatus():void
    {
        _currStatus = 0;
    }

    public static function isSameStatus(value:int) : Boolean {
        return _currStatus == value;
    }
    public static function isNotStatus(value:int) : Boolean {
        return _currStatus != value;
    }
}
}
