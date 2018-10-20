//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/3/30.
 */
package kof.game.ActivityNotice {

import flash.events.Event;

import kof.SYSTEM_ID;
import kof.game.ActivityNotice.data.CActivityNoticeData;

import kof.game.ActivityNotice.enums.EActivityState;
import kof.game.ActivityNotice.event.CActivityNoticeEvent;

import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CItemUtil;
import kof.game.common.CRewardUtil;
import kof.game.common.view.CTweenViewHandler;
import kof.game.item.data.CRewardListData;
import kof.game.player.CPlayerSystem;
import kof.table.ActivitySchedule;
import kof.ui.CMsgAlertHandler;
import kof.ui.IUICanvas;
import kof.ui.master.activityNotice.activityNoticeUI;

import morn.core.components.Box;
import morn.core.components.Clip;

import morn.core.components.Component;

import morn.core.components.Dialog;
import morn.core.components.Image;
import morn.core.components.Image;
import morn.core.components.Image;
import morn.core.components.Label;

import morn.core.handlers.Handler;

public class CActivityScheduleViewHandler extends CTweenViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:activityNoticeUI;
    private var m_pCloseHandler : Handler;
    private var m_pCurrSelCell:Box;
    private var m_iDefaultSelActId:int;// 打开界面时默认选择的活动ID

    public function CActivityScheduleViewHandler( bLoadViewByDefault : Boolean = false ) {
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
        return [ activityNoticeUI];
    }

    override  protected function get additionalAssets() : Array
    {
        return ["activityNotice.swf","frameclip_item.swf"];
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
                m_pViewUI = new activityNoticeUI();
//                m_pViewUI.closeHandler = new Handler( _onClose );

                m_pViewUI.list_activity.renderHandler = new Handler(_renderActivityItem);
                m_pViewUI.list_item.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system));
                m_pViewUI.list_activity.selectHandler = new Handler(_onSelectHandler);
                m_pViewUI.btn_goto.clickHandler = new Handler(_onGotoHandler);
                m_pViewUI.btn_close.clickHandler = new Handler(_onCloseHandler);

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
            callLater( _tweenShow );
        }
        else
        {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _tweenShow():void
    {
        setTweenData(KOFSysTags.ACTIVITY_NOTICE);
        showDialog(m_pViewUI, false, _addToDisplay);
    }

    private function _addToDisplay() : void
    {
        uiCanvas.addDialog( m_pViewUI );

        _initView();
        _addListeners();
    }

    private function _addListeners():void
    {
        m_pViewUI.tab.addEventListener( Event.CHANGE, _onTabSelectedHandler);
        system.addEventListener(CActivityNoticeEvent.ActivityOpenStateChange, _onActStateChangeHandler);
    }

    private function _removeListeners():void
    {
        m_pViewUI.tab.removeEventListener( Event.CHANGE, _onTabSelectedHandler);
        system.removeEventListener(CActivityNoticeEvent.ActivityOpenStateChange, _onActStateChangeHandler);
    }

    private function _initView():void
    {
        if ( m_pViewUI )
        {
            m_pViewUI.tab.labels = "定时活动";
            m_pViewUI.tab.space = m_pViewUI.tab.space;
            _onTabSelectedHandler();

            _defaultSelCell();
        }
    }

    private function _defaultSelCell():void
    {
        var index:int = _getCellIndexByActId();
        m_pViewUI.list_activity.selectedIndex = index;
        m_pViewUI.panel.vScrollBar.value = 90 * index;
    }

    private function _getCellIndexByActId():int
    {
        if(m_iDefaultSelActId == 0)
        {
            return 0;
        }

        var dataArr:Array = m_pViewUI.list_activity.dataSource as Array;
        var len:int = dataArr.length;
        for(var i:int = 0; i < len; i++)
        {
            var actData:ActivitySchedule = dataArr[i] as ActivitySchedule;
            if(actData && actData.ID == m_iDefaultSelActId)
            {
                return i;
            }
        }

        return 0;
    }

    /**
     * 切换页签处理
     * @param e
     */
    private function _onTabSelectedHandler(e:Event = null):void
    {
        if(m_pViewUI.tab.selectedIndex >= 0)
        {
            var arr:Array = _helper.getActivityDatas();
            m_pViewUI.list_activity.repeatY = arr.length;
            m_pViewUI.list_activity.dataSource = arr;

//            delayCall(0.2, refresh);
//            function refresh():void
//            {
//                m_pViewUI.panel.refresh();
//                m_pViewUI.vBox.refresh();
//            }

            m_pViewUI.panel.vScrollBar.max = 45 * arr.length;
        }
    }

    private function _renderActivityItem(item:Component, index:int):void
    {
        var render : Box = item as Box;

        var data:ActivitySchedule = item.dataSource as ActivitySchedule;
        if(data)
        {
            var img_logo:Image = _getImgLogo(render);
            img_logo.visible = data.isCrossService;

            var activityName:Label = _getActivityName(render);
            activityName.text = data.actName;

            var timeInfo:Label = _getTimeInfo(render);
            var startTime:String = data.startTime.split(" ")[1];
            startTime = startTime.substr(0, 5);
            var endTime:String = data.endTime.split(" ")[1];
            endTime = endTime.substr(0, 5);
            timeInfo.text = startTime + "-" + endTime;

            var clipState:Clip = _getClipState(render);
            var state:int = _helper.getActivityState(data);
            switch(state)
            {
                case EActivityState.Type_HasEnd:
                    clipState.index = 0;
                    break;
                case EActivityState.Type_NotStart:
                    clipState.index = 2;
                    break;
                case EActivityState.Type_Processing:
                    clipState.index = 1;
                    break;
            }

            var imgBlack:Image = _getImgBlack(render);
            imgBlack.visible = state == EActivityState.Type_HasEnd;

            var openCondition:Label = _getOpenCondition(render);
            openCondition.isHtml = true;
            var conditionStr:String = data.openCondition;
            if(conditionStr)
            {
                var arr:Array = conditionStr.split("&");
                if(arr && arr.length)
                {
                    var teamLevel:int = (system.stage.getSystem(CPlayerSystem ) as CPlayerSystem).playerData.teamData.level;
                    if(teamLevel >= int(arr[0]))
                    {
                        openCondition.text = "<font color='#2feb41'>" + (arr[0] + "级") + "</font>";
                    }
                    else
                    {
                        openCondition.text = "<font color='#ff0000'>" + (arr[0] + "级") + "</font>";
                    }

                    if(arr.length > 1)
                    {
                        openCondition.text += "（每周";
                        var date:String = "";
                        var numString:String = arr[1];
                        for(var i:int = 0; i < numString.length; i++)
                        {
                            var uperCaseNum:String = _helper.getUpercaseNum(numString.charAt(i));
                            date += (uperCaseNum + "、");
                        }
                        date = date.substr(0, date.length-1);
                        openCondition.text += (date + "开启）");
                    }
                    else
                    {
                        openCondition.text += "（每日开启）";
                    }
                }
            }

            var iconUrl:String = "icon/activityNotice/activityDetail/" + data.actPicUrl.split("&")[0];
            var img_bg:Image = _getImgBg(render);
            img_bg.url = iconUrl;
        }
    }

    private function _onSelectHandler(index:int):void
    {
        if ( index == -1 )
        {
            return;
        }

        var data:ActivitySchedule = m_pViewUI.list_activity.getItem(index) as  ActivitySchedule;
        if(data)
        {
            var iconUrl:String = "icon/activityNotice/activityPreview/" + data.actPicUrl.split("&")[1];
            m_pViewUI.img_introduce.url = iconUrl;

            var rewardListData:CRewardListData = CRewardUtil.createByDropPackageID(system.stage, data.actReward);

            if(rewardListData)
            {
                var rewardArr:Array = rewardListData.list;
                m_pViewUI.list_item.dataSource = rewardArr;

                var listWidth:int = 52 * rewardArr.length + m_pViewUI.list_item.spaceX * (rewardArr.length-1);
                m_pViewUI.list_item.x = 610 + (320 - listWidth >> 1);
            }

            m_pViewUI.txt_desc.text = data.actDesc;
        }

        var clipBg:Clip;
        if(m_pCurrSelCell)
        {
            clipBg = _getClipBg(m_pCurrSelCell);
            if(clipBg)
            {
                clipBg.index = 1;
            }
        }

        var startIndex:int = m_pViewUI.list_activity.startIndex;
        m_pCurrSelCell = m_pViewUI.list_activity.getCell(startIndex + index);
        clipBg = _getClipBg(m_pCurrSelCell);
        if(clipBg)
        {
            clipBg.index = 0;
        }
    }

    private function _onGotoHandler():void
    {
        if(m_pCurrSelCell)
        {
            var data:ActivitySchedule = m_pCurrSelCell.dataSource as ActivitySchedule;
            if(data)
            {
                var idBundle : * = SYSTEM_ID( data.sysTag );
                if ( null == idBundle || undefined == idBundle )
                    return;

                var pCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
                if ( !pCtx )
                    return;

                var pSystemBundle : ISystemBundle = pCtx.getSystemBundle( idBundle );
                if ( !pSystemBundle )
                    return;

                var teamLevel:int = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.teamData.level;
                if(teamLevel < _helper.getActOpenLevel(data))
                {
                    _uiSystem.showMsgAlert("等级不足！", CMsgAlertHandler.WARNING);
                    return;
                }

                var vCurrent : Boolean = pCtx.getUserData( pSystemBundle, CBundleSystem.ACTIVATED, false );
                pCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, !vCurrent );
            }
        }
    }

    private function _onActStateChangeHandler(e:CActivityNoticeEvent):void
    {
        var arr:Array = _helper.getActivityDatas();
        if(arr && arr.length)
        {
            m_pViewUI.list_activity.repeatY = arr.length;
            m_pViewUI.list_activity.dataSource = arr;
        }
    }

    private function _onCloseHandler():void
    {
        _onClose();
    }

    public function removeDisplay() : void
    {
        closeDialog(_remove);
    }

    private function _remove():void
    {
        if ( m_bViewInitialized )
        {
            _removeListeners();

            m_pViewUI.tab.selectedIndex = 0;

            m_pViewUI.list_activity.dataSource = [];
            m_pViewUI.list_activity.selectedIndex = -1;

            if(m_pCurrSelCell)
            {
                var clipBg:Clip = _getClipBg(m_pCurrSelCell);
                if(clipBg)
                {
                    clipBg.index = 1;
                }

                m_pCurrSelCell = null;
            }

            m_iDefaultSelActId = 0;

            if ( m_pViewUI && m_pViewUI.parent )
            {
                m_pViewUI.close( Dialog.CLOSE );
            }
        }
    }

    private function _onClose( type : String = null ) : void
    {
        switch ( type )
        {
            default:
                if ( this.closeHandler )
                {
                    this.closeHandler.execute();
                }
                break;
        }
    }

//property=============================================================================================================
    public function get closeHandler() : Handler
    {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void
    {
        m_pCloseHandler = value;
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    private function get _helper():CActivityNoticeHelpHandler
    {
        return system.getHandler(CActivityNoticeHelpHandler) as CActivityNoticeHelpHandler;
    }

    private function get _uiSystem():IUICanvas
    {
        return system.stage.getSystem(IUICanvas) as IUICanvas;
    }

    private function _getClipBg(box:Box):Clip
    {
        var boxInfo:Box = box.getChildByName("box_info") as Box;
        var clipBg:Clip = boxInfo.getChildByName("clip_bg") as Clip;

        return clipBg;
    }

    private function _getImgLogo(box:Box):Image
    {
        var boxInfo:Box = box.getChildByName("box_info") as Box;
        var imgLogo:Image = boxInfo.getChildByName("img_log") as Image;

        return imgLogo;
    }

    private function _getImgBg(box:Box):Image
    {
        var boxInfo:Box = box.getChildByName("box_info") as Box;
        var imgLogo:Image = boxInfo.getChildByName("img_bg") as Image;

        return imgLogo;
    }

    private function _getActivityName(box:Box):Label
    {
        var boxInfo:Box = box.getChildByName("box_info") as Box;
        var label:Label = boxInfo.getChildByName("txt_activityName") as Label;

        return label;
    }

    private function _getOpenCondition(box:Box):Label
    {
        var boxInfo:Box = box.getChildByName("box_info") as Box;
        var boxCenter:Box = boxInfo.getChildByName("box_center") as Box;
        var boxCondition:Box = boxCenter.getChildByName("box_openCondition") as Box;
        var label:Label = boxCondition.getChildByName("txt_openCondition") as Label;

        return label;
    }

    private function _getClipState(box:Box):Clip
    {
        var boxInfo:Box = box.getChildByName("box_info") as Box;
        var clipState:Clip = boxInfo.getChildByName("clip_state") as Clip;

        return clipState;
    }

    private function _getTimeInfo(box:Box):Label
    {
        var boxInfo:Box = box.getChildByName("box_info") as Box;
        var boxTime:Box = boxInfo.getChildByName("box_time") as Box;
        var timeInfo:Label = boxTime.getChildByName("txt_timeInfo") as Label;

        return timeInfo;
    }

    private function _getImgBlack(box:Box):Image
    {
        var boxInfo:Box = box.getChildByName("box_info") as Box;
        var imgBlack:Image = boxInfo.getChildByName("img_black") as Image;

        return imgBlack;
    }

    public function set defaultSelActId(id:int):void
    {
        m_iDefaultSelActId = id;
    }

    override public function dispose():void
    {
        super.dispose();

        m_pViewUI = null;
        m_pCloseHandler  = null;
    }
}
}
