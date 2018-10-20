//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/3.
 */
package kof.game.ActivityNotice.view {

import QFLib.Foundation.CTime;
import QFLib.Utils.CDateUtil;

import flash.events.MouseEvent;

import kof.SYSTEM_ID;

import kof.SYSTEM_ID;

import kof.data.KOFTableConstants;

import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.ActivityNotice.CActivityNoticeHelpHandler;
import kof.game.ActivityNotice.CActivityScheduleViewHandler;
import kof.game.ActivityNotice.enums.EActivityNoticeType;
import kof.game.ActivityNotice.enums.EActivityState;
import kof.game.ActivityNotice.event.CActivityNoticeEvent;
import kof.game.ActivityNotice.view.CActivityForceNoticeViewHandler;
import kof.game.ActivityNotice.view.CActivityNoticeViewHandler;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.status.CGameStatus;
import kof.game.instance.CInstanceSystem;
import kof.game.lobby.CLobbySystem;
import kof.game.lobby.view.CLobbyViewHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.event.CPlayerEvent;
import kof.table.ActivitySchedule;
import kof.table.MainView;
import kof.ui.master.activityNotice.ActivityForecastUI;

import morn.core.components.Box;

/**
 * 主界面右边常驻的活动倒计时预告
 */
public class CActivityNoticeViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:ActivityForecastUI;
    private var m_pTargetDate:Date;
    private var m_pCurrAct:ActivitySchedule;// 当前活动
    private var m_iActState:int;// 当前活动开启状态
    private var m_iOpenNoticeTime:int;// 距离当前活动开启还剩xx时间时提示(s)

    public function CActivityNoticeViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override protected function onSetup() : Boolean
    {
        var ret : Boolean = super.onSetup();
        ret = ret && onInitialize();
        if ( loadViewByDefault )
        {
            ret = ret && loadAssetsByView( viewClass );
            ret = ret && onInitializeView();
        }

        return ret;
    }

    override public function get viewClass() : Array
    {
        return [ ActivityForecastUI];
    }

//    override  protected function get additionalAssets() : Array
//    {
//        return ["activityNotice.swf"];
//    }

    override protected function onAssetsLoadCompleted() : void
    {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean
    {
        if ( !super.onInitializeView() )
        {
            return false;
        }

        if ( !m_bViewInitialized )
        {
            if ( !m_pViewUI )
            {
                m_pViewUI = new ActivityForecastUI();
//                m_pViewUI.closeHandler = new Handler( _onClose );

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function addDisplay() : void
    {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void
    {
        if ( onInitializeView() )
        {
//            invalidate();
            callLater( _addToDisplay );
        }
        else
        {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _addToDisplay() : void
    {
        var pLobbySystem:CLobbySystem = system.stage.getSystem( CLobbySystem ) as CLobbySystem;
        var pLobbyViewHandler:CLobbyViewHandler = pLobbySystem.getBean(CLobbyViewHandler) as CLobbyViewHandler;
        if ( pLobbyViewHandler.pMainUI )
        {
            var rightBox:Box = pLobbyViewHandler.pMainUI.getChildByName("right") as Box;
            if(rightBox)
            {
                var noticeBox:Box = rightBox.getChildByName("activityNotice") as Box;
                noticeBox.addChild(m_pViewUI);
                m_pViewUI.visible = false;
                rightBox.right = 4;
                rightBox.top = 180;
            }
        }

        _initView();
        _addListeners();
    }

    private function _initView():void
    {
        if ( m_pViewUI )
        {
            _updateActivityInfo();
        }
    }

    private function _addListeners():void
    {
        m_pViewUI.addEventListener(MouseEvent.CLICK, _onClickHandler);
        system.stage.getSystem(CPlayerSystem).addEventListener(CPlayerEvent.PLAYER_LEVEL_UP,_onTeamLevelUpHandler);
    }

    private function _removeListeners():void
    {
        m_pViewUI.removeEventListener(MouseEvent.CLICK, _onClickHandler);
        system.stage.getSystem(CPlayerSystem).removeEventListener(CPlayerEvent.PLAYER_LEVEL_UP,_onTeamLevelUpHandler);
    }

    private function _updateActivityInfo():void
    {
        var hasActivity:Boolean;
        var dataArr:Array = _helper.getActivityDatas();
        for each(var info:ActivitySchedule in dataArr)
        {
            if(info)
            {
                var noticeType:int = _helper.getNoticeType(info);
                if((noticeType & EActivityNoticeType.Type_3) == 0)
                {
                    continue;
                }

                if(!_helper.isReachActOpenLevel(info) || !_helper.isActivityInDate(info) || !_helper.isSystemOpen(info.sysTag))
                {
                    continue;
                }

                var state:int = _helper.getActivityState(info);
                if(state == EActivityState.Type_NotStart || state == EActivityState.Type_Processing)
                {
                    m_iActState = state;
                    m_pCurrAct = info;
                    m_iOpenNoticeTime = _getActOpenNoticeTime(info);

                    m_pViewUI.txt_openLeftTime.visible = state == EActivityState.Type_NotStart;
                    m_pViewUI.txt_processLeftTime.visible = state == EActivityState.Type_Processing;

                    var time:String = state == EActivityState.Type_NotStart ? info.startTime : info.endTime;
                    m_pTargetDate = CDateUtil.getDateByFullTimeString(time);
                    var currDate:Date = new Date(CTime.getCurrServerTimestamp());
                    m_pTargetDate.setFullYear(currDate.fullYear, currDate.month, currDate.date);

                    m_pViewUI.txt_label.text = state == EActivityState.Type_NotStart ? "距活动开启还剩" : "距活动结束还剩";

                    _updateLeftTime();
                    _updateIcon(info);

                    schedule(1, _onScheduleHandler);

                    hasActivity = true;
                    return;
                }
            }
        }

        if(!hasActivity)
        {
            removeDisplay();
        }
    }

    private function _updateLeftTime():void
    {
        var leftTime:Number = m_pTargetDate.time - CTime.getCurrServerTimestamp();
        var leftTimeStr:String = CTime.toDurTimeString(leftTime);
        m_pViewUI.txt_openLeftTime.text = m_pViewUI.txt_processLeftTime.text = leftTimeStr;

        if(m_iActState == EActivityState.Type_Processing)
        {
            if(!m_pViewUI.visible)
            {
                m_pViewUI.visible = true;
            }
        }
        else
        {
            var leftSec:int = leftTime * 0.001;
            if(m_iOpenNoticeTime > 0)
            {
                if(leftSec <= m_iOpenNoticeTime)
                {
                    if(!m_pViewUI.visible)
                    {
                        m_pViewUI.visible = true;
                    }
                }
                else
                {
                    if(m_pViewUI.visible)
                    {
                        m_pViewUI.visible = false;
                    }
                }
            }
            else
            {
                if(m_pViewUI.visible)
                {
                    m_pViewUI.visible = false;
                }
            }
        }

        m_pViewUI.visible = true;


        if(m_iActState == EActivityState.Type_NotStart)
        {
            if(leftTimeStr == "00:02:00" || leftTimeStr == "00:01:59")
            {
                var noticeType:int = _helper.getNoticeType(m_pCurrAct);
                if((noticeType & EActivityNoticeType.Type_1) == 0)
                {
                    return;
                }

                if(!CGameStatus.checkStatus(system, false))
                {
                    return;
                }

                var instanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
                if(!instanceSystem.isMainCity)
                {
                    return;
                }

                // 中间弹出的提示界面
                var forceView:CActivityForceNoticeViewHandler = system.getHandler(CActivityForceNoticeViewHandler) as CActivityForceNoticeViewHandler;
                if(forceView && !forceView.isViewShow)
                {
                    forceView.actOpenTime = m_pTargetDate.time;
                    forceView.sysTag = m_pCurrAct.sysTag;
                    forceView.actId = m_pCurrAct.ID;
                    forceView.addDisplay();
                }
            }
        }
    }

    private function _updateIcon(info:ActivitySchedule):void
    {
        if(info)
        {
            var dataArr:Array = _mainView.findByProperty("Tag", info.sysTag);
            if(dataArr && dataArr.length)
            {
                var mainView:MainView = dataArr[0] as MainView;
                var iconUrl:String = mainView.Icon.split(".")[3] as String;
                var iconTextUrl:String = mainView.IconText.split(".")[3] as String;
                m_pViewUI.img_sysIcon.url = "icon/sysIcon/" + iconUrl + ".png";
                m_pViewUI.img_sysTitle.url = "icon/sysIcon/" + iconTextUrl + ".png";
            }
            else
            {
                m_pViewUI.img_sysIcon.url = "";
                m_pViewUI.img_sysTitle.url = "";
            }
        }
    }

    private function _onScheduleHandler(delta : Number):void
    {
        _updateLeftTime();

        if(CTime.getCurrServerTimestamp() >= m_pTargetDate.time)
        {
            _updateActivityInfo();
        }
    }

    private function _onClickHandler(e:MouseEvent):void
    {
        if(m_pCurrAct)
        {
            var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
            var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(m_pCurrAct.sysTag));
            var currState:Boolean = bundleCtx.getUserData(systemBundle,CBundleSystem.ACTIVATED);
            if(!currState)
            {
                bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
            }
        }
    }

    private function _onTeamLevelUpHandler(e:CPlayerEvent):void
    {
        _updateActivityInfo();
    }

    private function _getActOpenNoticeTime(info:ActivitySchedule):int
    {
        if(info)
        {
            var arr1:Array = info.noticeType.split("&");
            for each(var str:String in arr1)
            {
                var arr2:Array = str.split("#");
                if(arr2[0] == "4" && arr2.length > 1)
                {
                    return int(arr2[1]);
                }
            }
        }

        return 0;
    }

    public function removeDisplay() : void
    {
        if(m_pViewUI)
        {
            m_pViewUI.remove();
        }

        _removeListeners();

        unschedule(_onScheduleHandler);

        m_pTargetDate = null;
        m_iActState = 0;
        m_pCurrAct = null;
        m_iOpenNoticeTime = 0;
        m_pViewUI.visible = false;
    }

//property=============================================================================================================
    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    private function get _helper():CActivityNoticeHelpHandler
    {
        return system.getHandler(CActivityNoticeHelpHandler) as CActivityNoticeHelpHandler;
    }

    private function get _dataBase():IDatabase
    {
        return system.stage.getSystem(IDatabase) as IDatabase;
    }

    private function get _mainView():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.MAIN_VIEW);
    }
}
}
