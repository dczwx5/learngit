//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/3.
 */
package kof.game.ActivityNotice.view {

import QFLib.Foundation.CTime;

import kof.SYSTEM_ID;

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.ActivityNotice.CActivityNoticeHelpHandler;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CItemUtil;
import kof.game.common.CRewardUtil;
import kof.game.common.view.CTweenViewHandler;
import kof.game.item.data.CRewardListData;
import kof.table.ActivitySchedule;
import kof.ui.CMsgAlertHandler;
import kof.ui.IUICanvas;
import kof.ui.master.activityNotice.activityNoticetypeAUI;

import morn.core.components.Dialog;

import morn.core.handlers.Handler;

/**
 * 中间强制弹框提示
 */
public class CActivityForceNoticeViewHandler extends CTweenViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:activityNoticetypeAUI;

    private var m_pSysTag:String;
    private var m_iActId:int;
    private var m_fActOpenTime:Number;
    private var m_iCount:int;
    private var m_pActData:ActivitySchedule;

    public function CActivityForceNoticeViewHandler( bLoadViewByDefault : Boolean = false ) {
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
        return [ activityNoticetypeAUI];
    }

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
                m_pViewUI = new activityNoticetypeAUI();
//                m_pViewUI.closeHandler = new Handler( _onClose );
                m_pViewUI.btn_close.clickHandler = new Handler(_onCloseHandler);
                m_pViewUI.btn_goto.clickHandler = new Handler(_onClickGotoHandler);
                m_pViewUI.list_item.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system));

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

    private function _tweenShow():void
    {
        showDialog(m_pViewUI, false, _addToDisplay);
    }

    private function _addToDisplay() : void
    {
        uiCanvas.addPopupDialog(m_pViewUI);

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

    private function _updateActivityInfo():void
    {
        _updateTitle();
        _updateItemList();
        _updateTimeInfo();

//        m_pViewUI.txt_close.text = "120s后自动关闭";
        m_pViewUI.txt_close.text = "";
        m_iCount = 119;
        schedule(1, _onScheduleHandler);
    }

    private function _updateTitle():void
    {
        var info:ActivitySchedule = _getActData();
        if(info)
        {
            m_pViewUI.txt_title.text = info.actName;
            m_pViewUI.txt_desc.text = info.actName + "活动即将开启，请格斗家做好准备";
        }
        else
        {
            m_pViewUI.txt_title.text = "";
            m_pViewUI.txt_desc.text = "";
        }
    }

    private function _updateItemList():void
    {
        var info:ActivitySchedule = _getActData();
        if(info)
        {
            var rewardListData:CRewardListData = CRewardUtil.createByDropPackageID(system.stage, info.actReward);

            if(rewardListData)
            {
                var rewardArr:Array = rewardListData.list;
                m_pViewUI.list_item.dataSource = rewardArr;

                var listWidth:int = 52 * rewardArr.length + m_pViewUI.list_item.spaceX * (rewardArr.length-1);
                m_pViewUI.list_item.x = m_pViewUI.width - listWidth >> 1;
            }
        }
        else
        {
            m_pViewUI.list_item.dataSource = [];
        }
    }

    private function _updateTimeInfo():void
    {
        var leftTimeStr:String = CTime.toDurTimeString(m_fActOpenTime - CTime.getCurrServerTimestamp());
        m_pViewUI.txt_leftTime.text = m_pViewUI.txt_leftTime.text = leftTimeStr;
    }

    private function _onScheduleHandler(delta : Number):void
    {
//        m_pViewUI.txt_close.text = m_iCount + "s后自动关闭";

        _updateTimeInfo();

//        m_iCount--;

//        if(m_iCount <= -1)
//        {
//            removeDisplay();
//        }

        if(m_pViewUI.txt_leftTime.text == "00:00:00" || m_pViewUI.txt_leftTime.text == "00:00:01")
        {
            removeDisplay();
        }
    }

    private function _addListeners():void
    {
    }

    private function _removeListeners():void
    {
    }

    private function _onCloseHandler():void
    {
        removeDisplay();
    }

    private function _onClickGotoHandler():void
    {
        if(m_pSysTag)
        {
            var idBundle : * = SYSTEM_ID( m_pSysTag );
            if ( null == idBundle || undefined == idBundle )
                return;

            var pCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            if ( !pCtx )
                return;

            var pSystemBundle : ISystemBundle = pCtx.getSystemBundle( idBundle );
            if ( !pSystemBundle )
                return;

            var info:ActivitySchedule = _getActData();
            if(!_helper.isReachActOpenLevel(info))
            {
                (system.stage.getSystem(IUICanvas) as IUICanvas).showMsgAlert("等级不足！", CMsgAlertHandler.WARNING);
                return;
            }

            var vCurrent : Boolean = pCtx.getUserData( pSystemBundle, CBundleSystem.ACTIVATED, false );
            pCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, !vCurrent );
        }

        removeDisplay();
    }

    public function removeDisplay() : void
    {
//        closeDialog(_remove);
        _remove();
    }

    public function _remove() : void
    {
        if (m_pViewUI && m_pViewUI.parent)
        {
            m_pViewUI.close(Dialog.CLOSE);
        }

        _removeListeners();

        unschedule(_onScheduleHandler);

        m_iCount = 5;
        m_pSysTag = null;
        m_iActId = 0;
        m_fActOpenTime = 0;
    }

    private function _getActData():ActivitySchedule
    {
//        if(m_pActData == null)
//        {
//            var dataArr:Array = _activitySchedule.findByProperty("sysTag", m_pSysTag);
//            if(dataArr && dataArr.length)
//            {
//                m_pActData = dataArr[0] as ActivitySchedule;
//            }
//        }

        m_pActData = _activitySchedule.findByPrimaryKey(m_iActId) as ActivitySchedule;

        return m_pActData;
    }

    private function get _helper():CActivityNoticeHelpHandler
    {
        return system.getHandler(CActivityNoticeHelpHandler) as CActivityNoticeHelpHandler;
    }

    public function set sysTag(value:String):void
    {
        m_pSysTag = value;
    }

    public function set actId(id:int):void
    {
        m_iActId = id;
    }

    public function set actOpenTime(value:Number):void
    {
        m_fActOpenTime = value;
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    private function get _dataBase():IDatabase
    {
        return system.stage.getSystem(IDatabase) as IDatabase;
    }

    private function get _activitySchedule():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.ActivitySchedule);
    }
}
}
