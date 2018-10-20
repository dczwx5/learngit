//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/12/9.
 */
package kof.game.GMReport.view {

import QFLib.Foundation.CTime;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TextEvent;
import flash.utils.getTimer;

import kof.framework.CViewHandler;
import kof.game.GMReport.CGMReportData;
import kof.game.GMReport.CGMReportNetHandler;
import kof.game.GMReport.Event.CGMReportEvent;
import kof.game.GMReport.Event.CGMReportEvent;
import kof.game.GMReport.enum.EGMReportType;
import kof.game.GMReport.enum.ETimeType;
import kof.game.KOFSysTags;
import kof.game.common.CLang;
import kof.game.common.view.CTweenViewHandler;
import kof.ui.CUISystem;
import kof.ui.master.GMReport.GMReportUI;

import morn.core.components.CheckBox;

import morn.core.components.Dialog;

import morn.core.handlers.Handler;

public class CGMReportViewHandler extends CTweenViewHandler {

    private var m_bViewInitialized : Boolean;

    private var m_pViewUI : GMReportUI;
    private var m_pCloseHandler : Handler;
    private var m_arrCheckBox:Array = [];
//    private var m_sRoleName:String;
    private var m_iLastTime:int;
    private var m_bIsLoading:Boolean;
    private var m_pGmReportData:CGMReportData;

    public function CGMReportViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [GMReportUI];
    }

    override protected function get additionalAssets():Array
    {
        return ["GMReport.swf"];
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
                m_pViewUI = new GMReportUI();

                m_pViewUI.btn_cancel.clickHandler = new Handler(_onCloseHandler);
                m_pViewUI.btn_quickReport.clickHandler = new Handler(_onClickReportHandler);
                m_pViewUI.btn_close.clickHandler = new Handler( _onCloseHandler );

                m_pViewUI.checkBox_cheat.tag = EGMReportType.Type_Fake;
                m_pViewUI.checkBox_curse.tag = EGMReportType.Type_Fake;
                m_pViewUI.checkBox_feedback.tag = EGMReportType.Type_Hacking;
                m_pViewUI.checkBox_other.tag = EGMReportType.Type_Other;
                m_pViewUI.checkBox_pull.tag = EGMReportType.Type_Harass;
                m_pViewUI.checkBox_usePlugin.tag = EGMReportType.Type_Cheat;

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function addDisplay() : void
    {
        m_bIsLoading = true;
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
        setTweenData(KOFSysTags.GMREPORT);
        showDialog(m_pViewUI, false, _addToDisplay);
    }

    private function _addToDisplay() : void
    {
        m_bIsLoading = false;

        uiCanvas.addPopupDialog( m_pViewUI );
//        uiCanvas.addDialog( m_pViewUI );

        _initView();
        _addListeners();
    }

    private function _addListeners():void
    {
        m_pViewUI.checkBox_cheat.addEventListener(MouseEvent.CLICK, _onClickCheckBoxHandler);
        m_pViewUI.checkBox_curse.addEventListener(MouseEvent.CLICK, _onClickCheckBoxHandler);
        m_pViewUI.checkBox_feedback.addEventListener(MouseEvent.CLICK, _onClickCheckBoxHandler);
        m_pViewUI.checkBox_pull.addEventListener(MouseEvent.CLICK, _onClickCheckBoxHandler);
        m_pViewUI.checkBox_usePlugin.addEventListener(MouseEvent.CLICK, _onClickCheckBoxHandler);
        m_pViewUI.checkBox_other.addEventListener(MouseEvent.CLICK, _onClickCheckBoxHandler);

        m_pViewUI.box_year.addEventListener(MouseEvent.CLICK, _onClickDateHandler);
        m_pViewUI.box_month.addEventListener(MouseEvent.CLICK, _onClickDateHandler);
        m_pViewUI.box_day.addEventListener(MouseEvent.CLICK, _onClickDateHandler);
        m_pViewUI.box_hour.addEventListener(MouseEvent.CLICK, _onClickDateHandler);
        m_pViewUI.box_min.addEventListener(MouseEvent.CLICK, _onClickDateHandler);

        m_pViewUI.txt_content.addEventListener(Event.CHANGE, _onChangeHandler);

        system.addEventListener(CGMReportEvent.ReportSucc, _onReportSuccHandler);
        this.addEventListener(CGMReportEvent.SelectDate, _onSelectDateHandler);
    }

    private function _removeListeners():void
    {
        m_pViewUI.checkBox_cheat.removeEventListener(MouseEvent.CLICK, _onClickCheckBoxHandler);
        m_pViewUI.checkBox_curse.removeEventListener(MouseEvent.CLICK, _onClickCheckBoxHandler);
        m_pViewUI.checkBox_feedback.removeEventListener(MouseEvent.CLICK, _onClickCheckBoxHandler);
        m_pViewUI.checkBox_pull.removeEventListener(MouseEvent.CLICK, _onClickCheckBoxHandler);
        m_pViewUI.checkBox_usePlugin.removeEventListener(MouseEvent.CLICK, _onClickCheckBoxHandler);
        m_pViewUI.checkBox_other.removeEventListener(MouseEvent.CLICK, _onClickCheckBoxHandler);

        m_pViewUI.box_year.removeEventListener(MouseEvent.CLICK, _onClickDateHandler);
        m_pViewUI.box_month.removeEventListener(MouseEvent.CLICK, _onClickDateHandler);
        m_pViewUI.box_day.removeEventListener(MouseEvent.CLICK, _onClickDateHandler);
        m_pViewUI.box_hour.removeEventListener(MouseEvent.CLICK, _onClickDateHandler);
        m_pViewUI.box_min.removeEventListener(MouseEvent.CLICK, _onClickDateHandler);

        m_pViewUI.txt_content.removeEventListener(TextEvent.TEXT_INPUT, _onChangeHandler);

        system.removeEventListener(CGMReportEvent.ReportSucc, _onReportSuccHandler);
        this.removeEventListener(CGMReportEvent.SelectDate, _onSelectDateHandler);
    }

    private function _initView():void
    {
        if ( m_pViewUI )
        {
            m_arrCheckBox[0] = m_pViewUI.checkBox_cheat;
            m_arrCheckBox[1] = m_pViewUI.checkBox_curse;
            m_arrCheckBox[2] = m_pViewUI.checkBox_feedback;
            m_arrCheckBox[3] = m_pViewUI.checkBox_pull;
            m_arrCheckBox[4] = m_pViewUI.checkBox_usePlugin;
            m_arrCheckBox[5] = m_pViewUI.checkBox_other;

            m_pViewUI.img_title.visible = false;
            if(m_pGmReportData && m_pGmReportData.playerName)
            {
                m_pViewUI.txt_title.text = "您正在举报玩家" + m_pGmReportData.playerName;
            }
            else
            {
                m_pViewUI.txt_title.text = "请选择你要反馈的内容";
            }

            m_pViewUI.txt_content.maxChars = 341;
            m_pViewUI.txt_content.restrict = "^" + String.fromCharCode(12288);
            m_pViewUI.txt_leftInfo.text = "还可输入341个字";

            m_pViewUI.txt_qq.maxChars = 12;
            m_pViewUI.txt_qq.restrict = "0-9";
            m_pViewUI.txt_telphone.maxChars = 12;
            m_pViewUI.txt_telphone.restrict = "0-9";

            var currDate:Date = new Date(CTime.getCurrServerTimestamp());
            m_pViewUI.txt_year.text = currDate.fullYear.toString();
            m_pViewUI.txt_month.text = (currDate.month+1).toString();
            m_pViewUI.txt_day.text = currDate.date.toString();
            m_pViewUI.txt_hour.text = currDate.hours.toString();
            m_pViewUI.txt_min.text = currDate.minutes.toString();
        }
    }

    private function _onClickCancelHandler():void
    {
        removeDisplay();
    }

    private function _onClickReportHandler():void
    {
        if(_isCanSubmit())
        {
            var reportType:int = getReportType();
            var content:String = (m_pGmReportData && m_pGmReportData.playerName) ? (m_pGmReportData.playerName + "," + m_pViewUI.txt_content.text) : m_pViewUI.txt_content.text;
            var qq:String = m_pViewUI.txt_qq.text;
            var phone:String = m_pViewUI.txt_telphone.text;

            var date:Date = new Date();
            date.fullYear = int(m_pViewUI.txt_year.text);
            date.month = int(m_pViewUI.txt_month.text)-1;
            date.date = int(m_pViewUI.txt_day.text);
            date.hours = int(m_pViewUI.txt_hour.text);
            date.minutes = int(m_pViewUI.txt_min.text);

            var fightUUID:String = m_pGmReportData == null ? "" : m_pGmReportData.fightUUID;

            (system.getHandler(CGMReportNetHandler) as CGMReportNetHandler).gmReportRequest(reportType,content,qq,phone,date.time, fightUUID);

            this.removeDisplay();

            _uiSystem.showMsgAlert("举报信息已发送至客服");
        }
    }

    private function _isCanSubmit():Boolean
    {
        var reportType:int = getReportType();
        if(!reportType)
        {
            _uiSystem.showMsgAlert("请先选择一个类型");
            return false;
        }

        if(m_pViewUI.txt_content.text == "")
        {
            _uiSystem.showMsgAlert("内容不能为空");
            return false;
        }

        var nowTime:int = getTimer();
        var timeLimit:int = 60;
        if(m_iLastTime != 0 && (nowTime - m_iLastTime) * 0.001 < timeLimit)
        {
            _uiSystem.showMsgAlert(CLang.Get("suggest_time_tip",{v1:1}));
            return false;
        }

        m_iLastTime = getTimer();

        return true;
    }

    private function getReportType():int
    {
        for each(var checkBox:CheckBox in m_arrCheckBox)
        {
            if(checkBox.selected)
            {
                return checkBox.tag as int;
            }
        }

        return 0;
    }

    private function _onClickCheckBoxHandler(e:MouseEvent):void
    {
        for each(var checkBox:CheckBox in m_arrCheckBox)
        {
            if(checkBox != e.target)
            {
                checkBox.selected = false;
            }
        }
    }

    private function _onClickDateHandler(e:MouseEvent):void
    {
        if( e.target == m_pViewUI.btn_year || e.target == m_pViewUI.txt_year)
        {
            var menuStr:String;
            var date:Date = new Date(CTime.getCurrServerTimestamp());
            var year:int = date.fullYear;
            menuStr = year + "," + (date.fullYear-1);

            (system.getHandler(CGMReportDateMenuHandler) as CGMReportDateMenuHandler).data = menuStr;
            (system.getHandler(CGMReportDateMenuHandler) as CGMReportDateMenuHandler).addDisplay();

            return;
        }

        var dateSelectView:CDateSelectViewHandler = system.getHandler(CDateSelectViewHandler) as CDateSelectViewHandler;
        if(dateSelectView)
        {
            var timeType:int;

            if( e.target == m_pViewUI.btn_month || e.target == m_pViewUI.txt_month)
            {
                timeType = ETimeType.Type_Month;
            }

            if( e.target == m_pViewUI.btn_day || e.target == m_pViewUI.txt_day)
            {
                timeType = ETimeType.Type_Day;
            }

            if( e.target == m_pViewUI.btn_hour || e.target == m_pViewUI.txt_hour)
            {
                timeType = ETimeType.Type_Hour;
            }

            if( e.target == m_pViewUI.btn_min || e.target == m_pViewUI.txt_min)
            {
                timeType = ETimeType.Type_Min;
            }

            dateSelectView.timeType = timeType;
            dateSelectView.selMonth = int(m_pViewUI.txt_month.text);
            dateSelectView.addDisplay();
        }
    }

    private function _onChangeHandler(e:Event):void
    {
        var len:int = m_pViewUI.txt_content.text.length;
        m_pViewUI.txt_leftInfo.text = "还可输入" + (341-len) + "个字";
    }

    private function _onReportSuccHandler(e:Event):void
    {
        (system.getHandler(CGMSubmitSuccViewHandler) as CGMSubmitSuccViewHandler).addDisplay();
    }

    private function _onSelectDateHandler(e:CGMReportEvent):void
    {
        var data:Object = e.data;
        if(data)
        {
            var timeType:int = data.timeType;
            var time:int = data.time;
            if(timeType == ETimeType.Type_Year)
            {
                m_pViewUI.txt_year.text = time.toString();
            }

            if(timeType == ETimeType.Type_Day)
            {
                m_pViewUI.txt_day.text = time.toString();
            }

            if(timeType == ETimeType.Type_Month)
            {
                m_pViewUI.txt_month.text = time.toString();
            }

            if(timeType == ETimeType.Type_Hour)
            {
                m_pViewUI.txt_hour.text = time.toString();
            }

            if(timeType == ETimeType.Type_Min)
            {
                m_pViewUI.txt_min.text = time.toString();
            }
        }
    }

    public function removeDisplay() : void
    {
//        closeDialog(_remove);
        if(m_bViewInitialized)
        {
            _remove();
        }
    }

    private function _remove():void
    {
        if(m_bViewInitialized)
        {
            _removeListeners();

            if (m_pViewUI && m_pViewUI.parent)
            {
                m_pViewUI.close(Dialog.CLOSE);
            }

            if(m_arrCheckBox)
            {
                for each(var checkBox:CheckBox in m_arrCheckBox)
                {
                    checkBox.selected = false;
                }
                m_arrCheckBox.length = 0;
            }

            var menuView:CGMReportDateMenuHandler = system.getHandler(CGMReportDateMenuHandler) as CGMReportDateMenuHandler;
            if(menuView && menuView.isViewShow)
            {
                menuView.removeDisplay();
            }

            m_pViewUI.txt_content.text = "";
            m_pViewUI.txt_qq.text = "";
            m_pViewUI.txt_telphone.text = "";
            m_pViewUI.txt_year.text = "";
            m_pViewUI.txt_month.text = "";
            m_pViewUI.txt_day.text = "";
            m_pViewUI.txt_hour.text = "";
            m_pViewUI.txt_min.text = "";

            m_pGmReportData = null;
        }
    }

    private function _onCloseHandler() : void
    {
//        switch ( type )
//        {
//            default:
//                if ( this.closeHandler )
//                {
//                    this.closeHandler.execute();
//                }
//                break;
//        }

        if ( this.closeHandler )
        {
            this.closeHandler.execute();
        }
    }

    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }

    private function get _uiSystem():CUISystem
    {
        return system.stage.getSystem(CUISystem) as CUISystem;
    }

//    public function set roleName(value:String):void
//    {
//        m_sRoleName = value;
//    }

    public function set gmReportData(value:CGMReportData):void
    {
        m_pGmReportData = value;
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    public function get isLoading():Boolean
    {
        return m_bIsLoading;
    }
}
}
