//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/4.
 */
package kof.game.systemnotice {

import flash.display.DisplayObject;
import flash.events.MouseEvent;

import kof.SYSTEM_ID;

import kof.data.KOFTableConstants;

import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.ActivityNotice.CActivityNoticeSystem;
import kof.game.ActivityNotice.data.CActivityNoticeData;
import kof.game.ActivityNotice.enums.EActivityState;
import kof.game.ActivityNotice.event.CActivityNoticeEvent;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CUIFactory;
import kof.game.lobby.CLobbySystem;
import kof.game.lobby.view.CLobbyViewHandler;
import kof.game.systemnotice.enum.EUpdateType;
import kof.table.ActivitySchedule;
import kof.table.ActivitySchedule;
import kof.table.MainView;
import kof.ui.master.newmsgtips.IconActivitytipsUI;

import morn.core.components.Box;
import morn.core.components.Component;
import morn.core.handlers.Handler;

/**
 * 活动小图标通知
 */
public class CActivitySmallIconViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:IconActivitytipsUI;

    /** 当前显示的活动图标数据 */
    private var m_arrData:Array = [];
    /** 当前显示的活动图标 */
    private var m_arrIcon:Array = [];

    public function CActivitySmallIconViewHandler( bLoadViewByDefault : Boolean = false ) {
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

        system.stage.getSystem(CActivityNoticeSystem ).addEventListener(CActivityNoticeEvent.ActivityOpenStateChange, _onStateChangeHandler);
        system.stage.getSystem(CActivityNoticeSystem ).addEventListener(CActivityNoticeEvent.ActivityIconInit, _onIconInitHandler);

        return ret;
    }

    override public function get viewClass() : Array
    {
        return [ IconActivitytipsUI];
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
//                m_pViewUI = new IconActivitytipsUI();

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
        if( !_actIconBox )
        {
            callLater( _addToDisplay );
        }
        else
        {
            _initView();
        }
    }

    private function _initView():void
    {
        for each(var data:CActivityNoticeData in m_arrData)
        {
            _updateDisplayInfo(data);
        }
    }

    public function removeDisplay() : void
    {
        m_pViewUI.remove();
    }

    private function _onIconInitHandler(e:CActivityNoticeEvent):void
    {
        var arr:Array = e.data as Array;
        if(arr)
        {
            m_arrData = arr;
        }

        _addToDisplay();
    }

    private function _onStateChangeHandler(e:CActivityNoticeEvent):void
    {
        var actData:CActivityNoticeData = e.data as CActivityNoticeData;

        _updateDataInfo(actData);
        _updateDisplayInfo(actData);
    }

    private function _updateDataInfo(actData:CActivityNoticeData):void
    {
        if(actData)
        {
            var currData:CActivityNoticeData = _getDataById(actData.id);
            if(currData)
            {
                if(actData.openState == 0)// 移除
                {
                    _removeDataFromArr(actData);
                }
            }
            else
            {
                if(actData.openState == 1)// 新增
                {
                    m_arrData.push(actData);
                }
            }
        }
    }

    private function _updateDisplayInfo(actData:CActivityNoticeData):void
    {
        if(actData)
        {
            var currShowIcon:Component = _getIconById(actData.id);
            if(currShowIcon)
            {
                if(actData.openState == 0)// 移除
                {
                    _updateIcon(EUpdateType.Type_Delete, actData);
                }
            }
            else
            {
                if(actData.openState == 1)// 新增
                {
                    _updateIcon(EUpdateType.Type_Add, actData);
                }
            }
        }
    }

    private function _getIconById(id:int):Component
    {
        for each(var icon:Component in m_arrIcon)
        {
            var data:CActivityNoticeData = icon.dataSource as CActivityNoticeData;
            if(data && data.id == id)
            {
                return icon;
            }
        }

        return null;
    }

    private function _getDataById(id:int):CActivityNoticeData
    {
        for each(var data:CActivityNoticeData in m_arrData)
        {
            if(data && data.id == id)
            {
                return data;
            }
        }

        return null;
    }

    private function _updateIcon(updateType:int, iconData:CActivityNoticeData):void
    {
        if(_actIconBox == null)
        {
            return;
        }

        var icon:IconActivitytipsUI;
        if(updateType == EUpdateType.Type_Add)
        {
            icon = CUIFactory.getDisplayObj(IconActivitytipsUI) as IconActivitytipsUI;
            icon.dataSource = iconData;
            icon.btn_icon.url = _getIconUrl(iconData);
            icon.toolTip = _getActNameById(iconData.id);
            icon.addEventListener(MouseEvent.CLICK, _onClickIconHandler);
            _actIconBox.addChild(icon);
            m_arrIcon.push(icon);
        }
        else if(updateType == EUpdateType.Type_Delete)
        {
            icon = _getIconById(iconData.id) as IconActivitytipsUI;
            if(icon)
            {
                _actIconBox.removeChild(icon);
                _removeIconFromArr(icon);
                _disposeIcon(icon);
            }
        }

        _iconLayout();
    }

    private function _onClickIconHandler(e:MouseEvent):void
    {
        var icon:IconActivitytipsUI = e.currentTarget as IconActivitytipsUI;
        if(!icon)
        {
            return;
        }

        var data:ActivitySchedule = (icon.dataSource as CActivityNoticeData).actData;
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

            var vCurrent : Boolean = pCtx.getUserData( pSystemBundle, CBundleSystem.ACTIVATED, false );
            pCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, !vCurrent );
        }

        _removeDataFromArr(icon.dataSource as CActivityNoticeData);

        _actIconBox.removeChild(icon);
        _removeIconFromArr(icon);
        _disposeIcon(icon);
        _iconLayout();
    }

    private function _removeIconFromArr(icon:Component):void
    {
        for(var i:int = 0; i < m_arrIcon.length; i++)
        {
            if(m_arrIcon[i] == icon)
            {
                m_arrIcon.splice(i, 1);
                return;
            }
        }
    }

    private function _removeDataFromArr(data:CActivityNoticeData):void
    {
        for(var i:int = 0; i < m_arrData.length; i++)
        {
            if(m_arrData[i] == data)
            {
                m_arrData.splice(i, 1);
                return;
            }
        }
    }

    private function _iconLayout():void
    {
        for(var i:int = 0; i < _actIconBox.numChildren; i++)
        {
            var child:Component = _actIconBox.getChildAt(i) as Component;
            if(i == 0)
            {
                child.x = 0;
            }
            else
            {
                var preChild:Component = _actIconBox.getChildAt(i - 1) as Component;
                child.x = preChild.x + preChild.width + 5;
            }
        }

        (system as CSystemNoticeSystem).noticeIconResize();
    }

    private function _getIconUrl(iconData:CActivityNoticeData):String
    {
        if(iconData && iconData.actData)
        {
            var arr:Array = _mainView.findByProperty("Tag", iconData.actData.sysTag);
            if(arr && arr.length)
            {
                var mainView:MainView = arr[0] as MainView;
                var iconUrl:String = mainView.Icon.split(".")[3] as String;
                return "icon/sysIcon/" + iconUrl + ".png";
            }
        }

        return "";
    }

    private function _getActNameById(id:int):String
    {
        var data:ActivitySchedule = _activitySchedule.findByPrimaryKey(id) as ActivitySchedule;
        if(data)
        {
            return data.actName;
        }

        return null;
    }

    private function _disposeIcon(icon:IconActivitytipsUI):void
    {
        icon.dataSource = null;
//        icon.btn_icon.clickHandler = null;
        icon.btn_icon.url = "";
        icon.toolTip = null;
        icon.removeEventListener(MouseEvent.CLICK, _onClickIconHandler);
        CUIFactory.disposeDisplayObj(icon);
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    private function get _actIconBox():Box
    {
        var pLobbySystem:CLobbySystem = system.stage.getSystem( CLobbySystem ) as CLobbySystem;
        var pLobbyViewHandler:CLobbyViewHandler = pLobbySystem.getBean(CLobbyViewHandler) as CLobbyViewHandler;
        if ( !pLobbyViewHandler.pMainUI )
            return null;
//        var notice:Box = pLobbyViewHandler.pMainUI.getChildByName("systemNotice") as Box;
        var notice:Box = pLobbyViewHandler.pMainUI.view_systemNotice.box_act as Box;
        return notice;
    }

    //table===============================================================================
    private function get _dataBase():IDatabase
    {
        return system.stage.getSystem(IDatabase) as IDatabase;
    }

    private function get _mainView():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.MAIN_VIEW);
    }

    private function get _activitySchedule():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.ActivitySchedule);
    }
}
}
