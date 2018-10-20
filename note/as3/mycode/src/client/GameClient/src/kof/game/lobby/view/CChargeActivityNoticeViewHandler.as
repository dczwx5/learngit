//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/9/12.
 */
package kof.game.lobby.view {

import QFLib.Foundation.CTime;

import flash.events.Event;

import flash.events.MouseEvent;

import kof.SYSTEM_ID;

import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.events.CEventPriority;
import kof.game.KOFSysTags;
import kof.game.OneDiamondReward.COneDiamondEvent;
import kof.game.OneDiamondReward.COneDiamondSystem;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.CSystemBundleContext;
import kof.game.bundle.CSystemBundleEvent;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.lobby.CChargeActivityHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.event.CPlayerEvent;
import kof.game.recharge.dailyRecharge.CDailyRechargeSystem;
import kof.game.recharge.event.CDailyRechargeEvent;
import kof.game.recharge.event.CFirstRechargeEvent;
import kof.game.recharge.firstRecharge.CFirstRechargeSystem;
import kof.table.ChargeActivityNotice;
import kof.ui.master.main.MainUI;

import morn.core.components.Box;
import morn.core.components.Image;
import morn.core.components.Label;

public class CChargeActivityNoticeViewHandler extends CViewHandler {

    private var m_pViewUI:Box;
    private var m_pCurrAct:ChargeActivityNotice;
    private var m_iLeftTime:int;

    public function CChargeActivityNoticeViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    public function addDisplay():void
    {
        var mainUI:MainUI = (system.getHandler(CLobbyViewHandler) as CLobbyViewHandler).pMainUI;
        if(mainUI)
        {
            m_pViewUI = mainUI.box_activityNotice;
            _addDisplay();
        }
        else
        {
            callLater(_show);
        }
    }

    private function _show():void
    {
        addDisplay();
    }

    private function _addDisplay():void
    {
        if(m_pViewUI)
        {
            var playerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
            var currActivityId:int = playerData.activityNoticeId;
//            var currActivityId:int = 1;

            if(currActivityId)
            {
                var currActivity:ChargeActivityNotice = _getCurrActivity(currActivityId);
                if(currActivity)
                {
                    _startNotice(currActivity);
                }
            }
            else
            {
                m_pViewUI.visible = false;

                var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;

                var firstAct:ChargeActivityNotice = _getFirstActivity();
                if ( pSystemBundleCtx && firstAct)
                {
                    var firstSystem:ISystemBundle = pSystemBundleCtx.getSystemBundle(SYSTEM_ID(firstAct.sysTag));
                    var state:int = pSystemBundleCtx.getSystemBundleState(firstSystem);
                    if(state != CSystemBundleContext.STATE_STARTED)
                    {
                        pSystemBundleCtx.addEventListener( CSystemBundleEvent.BUNDLE_START, _onSystemBundleStateChangedHandler, false,
                                CEventPriority.DEFAULT, true );
                    }
                }
            }

        }
    }

    private function _startNotice(act:ChargeActivityNotice):void
    {
        m_pViewUI.visible = true;
        m_pCurrAct = act;
        m_iLeftTime = act.duration;
        _updateLeftTime(m_iLeftTime);
        unschedule(_onSchedule);
        schedule(1, _onSchedule);
        (system.getHandler(CChargeActivityHandler) as CChargeActivityHandler).activityNoticeIdUpdateRequest(m_pCurrAct.ID);

        _updateActIcon();

        if(!m_pViewUI.hasEventListener(MouseEvent.CLICK))
        {
            m_pViewUI.addEventListener(MouseEvent.CLICK, _onClickHandler);
        }

        _addActListeners();
    }

    private function _addActListeners():void
    {
        system.stage.getSystem(CFirstRechargeSystem ).addEventListener(CFirstRechargeEvent.StateChange, _onFirstRechargeStateChange);
        system.stage.getSystem(COneDiamondSystem ).addEventListener(COneDiamondEvent.StateChange, _onOneDiamondStateChange);
        system.stage.getSystem(CPlayerSystem ).addEventListener(CPlayerEvent.PLAYER_MONTH_AND_WEEK_CARD, _onMonthCardStateChange);
        system.stage.getSystem(CDailyRechargeSystem ).addEventListener(CDailyRechargeEvent.StateChange, _onDailyRechargeStateChange);
    }

    private function _removeActListeners():void
    {
        system.stage.getSystem(CFirstRechargeSystem ).removeEventListener(CFirstRechargeEvent.StateChange, _onFirstRechargeStateChange);
        system.stage.getSystem(COneDiamondSystem ).removeEventListener(COneDiamondEvent.StateChange, _onOneDiamondStateChange);
        system.stage.getSystem(CPlayerSystem ).removeEventListener(CPlayerEvent.PLAYER_MONTH_AND_WEEK_CARD, _onMonthCardStateChange);
        system.stage.getSystem(CDailyRechargeSystem ).removeEventListener(CDailyRechargeEvent.StateChange, _onDailyRechargeStateChange);
    }

    private function _onSchedule(delta:Number):void
    {
        m_iLeftTime--;
        _updateLeftTime(m_iLeftTime);

        if(m_iLeftTime <= 0)
        {
            _switchNextAct();
        }
    }

    // 更新下一个活动的显示
    private function _switchNextAct():void
    {
        var nextAct:ChargeActivityNotice = _getNextActivity();
        if(nextAct)
        {
            m_pCurrAct = nextAct;
            m_iLeftTime = m_pCurrAct.duration;

            _updateActIcon();

            (system.getHandler(CChargeActivityHandler) as CChargeActivityHandler).activityNoticeIdUpdateRequest(m_pCurrAct.ID);
        }
        else
        {
            removeDisplay();
            (system.getHandler(CChargeActivityHandler) as CChargeActivityHandler).activityNoticeIdUpdateRequest(0);
        }
    }

    private function _updateLeftTime(leftTime:int):void
    {
        var leftTimeStr:String = CTime.toDurTimeString(leftTime*1000);
        _label_leftTime.text = leftTimeStr;
    }

    private function _updateActIcon():void
    {
        if(m_pCurrAct)
        {
            _img_icon.url = "icon/main/hdts_0" + m_pCurrAct.ID + ".png";
        }
        else
        {
            _img_icon.url = "";
        }
    }

    private function _getCurrActivity(id:int):ChargeActivityNotice
    {
        var actList:Array = _getActivityList();
        for each (var info:ChargeActivityNotice in actList)
        {
            if(info.ID == id)
            {
                return info;
            }
        }

        return null;
    }

    private function _getNextActivity():ChargeActivityNotice
    {
        if(m_pCurrAct)
        {
            var nextId:int = m_pCurrAct.ID + 1;
            var actArr:Array = _getActivityList();
            for each(var info:ChargeActivityNotice in actArr)
            {
                if(info && info.ID == nextId)
                {
                    return info;
                }
            }
        }

        return null;
    }

    private function _onClickHandler(e:MouseEvent):void
    {
        if(m_pCurrAct)
        {
            var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
            var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(m_pCurrAct.sysTag));
            var currState:int = bundleCtx.getUserData(systemBundle, CBundleSystem.ACTIVATED);
            bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, !currState);
        }
    }

    private function _onSystemBundleStateChangedHandler(e:CSystemBundleEvent):void
    {
        var act:ChargeActivityNotice = _getFirstActivity();
        if(act)
        {
            if( e.bundle && e.bundle.bundleID == SYSTEM_ID(act.sysTag))
            {
                _startNotice(act);
            }
        }
    }

    // 首充后更新
    private function _onFirstRechargeStateChange(e:CFirstRechargeEvent):void
    {
        var state:int = e.data as int;
        if(state > 0 && m_pCurrAct && m_pCurrAct.sysTag == KOFSysTags.FIRST_RECHARGE)
        {
            _switchNextAct();
        }
    }

    // 一钻礼包领取后更新
    private function _onOneDiamondStateChange(e:COneDiamondEvent):void
    {
        var state:int = e.data as int;
        if(state == 2 && m_pCurrAct && m_pCurrAct.sysTag == KOFSysTags.ONE_DIAMOND_REWARD)
        {
            _switchNextAct();
        }
    }

    // 月卡获取状态更新
    private function _onMonthCardStateChange(e:CPlayerEvent):void
    {
        var playerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
        if(playerData && playerData.monthAndWeekCardData)
        {
            if((playerData.monthAndWeekCardData.goldCardState == 1 || playerData.monthAndWeekCardData.silverCardState == 1)
                    && m_pCurrAct && m_pCurrAct.sysTag == KOFSysTags.BARGAINCARD)
            {
                _switchNextAct();
            }
        }
    }

    // 每日首充状态更新
    private function _onDailyRechargeStateChange(e:CDailyRechargeEvent):void
    {
        var chargeNum:int = e.data as int;
        if(chargeNum >= 100 && m_pCurrAct && m_pCurrAct.sysTag == KOFSysTags.DAILY_RECHARGE)
        {
            _switchNextAct();
        }
    }

    public function removeDisplay():void
    {
        unschedule(_onSchedule);

        if(m_pViewUI)
        {
            m_pViewUI.visible = false;
            m_pViewUI.removeEventListener(MouseEvent.CLICK, _onClickHandler);
        }

        var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;

        if ( pSystemBundleCtx )
        {
            pSystemBundleCtx.removeEventListener( CSystemBundleEvent.BUNDLE_START, _onSystemBundleStateChangedHandler);
        }

        _removeActListeners();

        m_pCurrAct = null;
    }

    private function _getActivityList():Array
    {
        var arr:Array = _chargeActivityNotice.toArray();
        arr.sortOn("priority", Array.NUMERIC);
        return arr;
    }

    private function _getFirstActivity():ChargeActivityNotice
    {
        var actList:Array = _getActivityList();
        if(actList && actList.length)
        {
            var act:ChargeActivityNotice = actList[0] as ChargeActivityNotice;
            return act;
        }

        return null;
    }

    private function get _label_leftTime():Label
    {
        return m_pViewUI.getChildByName("txt_leftTime") as Label;
    }

    private function get _img_icon():Image
    {
        return m_pViewUI.getChildByName("img_noticeIcon") as Image;
    }

    //table===============================================================================
    private function get _dataBase():IDatabase
    {
        return system.stage.getSystem(IDatabase) as IDatabase;
    }

    private function get _chargeActivityNotice():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.ChargeActivityNotice);
    }
}
}
