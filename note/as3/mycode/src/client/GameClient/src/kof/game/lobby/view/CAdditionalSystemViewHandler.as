//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.lobby.view {

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import kof.SYSTEM_ID;

import kof.framework.CViewHandler;
import kof.framework.IDataHolder;
import kof.framework.events.CEventPriority;
import kof.game.GMReport.CGMReportSystem;
import kof.game.GMReport.Event.CGMReportEvent;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.CSystemBundleContext;
import kof.game.bundle.CSystemBundleEvent;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.gameSetting.CGameSettingData;
import kof.game.gameSetting.CGameSettingManager;
import kof.game.gameSetting.CGameSettingSystem;
import kof.game.gameSetting.event.CGameSettingEvent;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.task.CTaskSystem;
import kof.game.task.data.CTaskStateType;
import kof.table.MainView;
import kof.table.MainView.EMainViewLocation;
import kof.util.CAssertUtils;

import morn.core.components.Box;

import morn.core.components.Box;
import morn.core.components.Button;
import morn.core.components.Component;
import morn.core.components.List;
import morn.core.handlers.Handler;

/**
 * 附加系统区域（游戏大厅内）视图控制器
 *     |- 系统设置
 *     |- 邮件
 *     |- 好友
 *     |- 排行榜
 *     |- ...
 *
 * @author Jeremy (jeremy@qifun.com)
 */
internal class CAdditionalSystemViewHandler extends CViewHandler {

    private var m_pList : List;
    private var m_pDataList : Array;

    /**
     * Creates a new CAdditionalSystemViewHandler.
     */
    public function CAdditionalSystemViewHandler() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected virtual function onSetup() : Boolean {
        return super.onSetup();
    }

    public function initWith( list : List ) : Boolean {
        CAssertUtils.assertNull( m_pList );
        this.m_pList = list;
        return this.initialize();
    }

    protected function initialize() : Boolean {
        this.m_pList.dataSource = [];
        m_pList.renderHandler = new Handler( this._listItemRender );
        m_pList.mouseHandler = new Handler( this._listItemMouse );

        var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as
            ISystemBundleContext;
        if ( pSystemBundleCtx ) {
            pSystemBundleCtx.addEventListener( CSystemBundleEvent.BUNDLE_START, _onSystemBundleStateChangedHandler, false,
                    CEventPriority.DEFAULT, true );
            pSystemBundleCtx.addEventListener( CSystemBundleEvent.BUNDLE_STOP, _onSystemBundleStateChangedHandler, false,
                    CEventPriority.DEFAULT, true );
            pSystemBundleCtx.addEventListener( CSystemBundleEvent.USER_DATA, _onSystemBundleUserDataUpdated, false,
                    CEventPriority.DEFAULT, true );
        }

        system.stage.getSystem(CGameSettingSystem ).addEventListener(CGameSettingEvent.SoundSynchUpdate, _onSoundSynchUpdateHandler);

        this.updateDataList();
        this.updateDisplay();

        return true;
    }

    override protected virtual function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();
        if ( ret ) {
            var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as
                ISystemBundleContext;
            pSystemBundleCtx.removeEventListener( CSystemBundleEvent.BUNDLE_START, _onSystemBundleStateChangedHandler );
            pSystemBundleCtx.removeEventListener( CSystemBundleEvent.BUNDLE_STOP, _onSystemBundleStateChangedHandler );
            pSystemBundleCtx.removeEventListener( CSystemBundleEvent.USER_DATA, _onSystemBundleUserDataUpdated );

            system.stage.getSystem(CGameSettingSystem ).removeEventListener(CGameSettingEvent.SoundSynchUpdate, _onSoundSynchUpdateHandler);
        }

        return ret;
    }

    protected function updateDataList() : void {
        var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as
            ISystemBundleContext;

        var pDataHolder : IDataHolder = system.getBean( IDataHolder ) as IDataHolder;
        if ( pDataHolder ) {
            var pData : Array = pDataHolder.data as Array;
            if ( pData ) {
                var pFiltered : Array = pData.filter( function ( value : *, index : int, arr : Array ) : Boolean {
                    var ret : Boolean = !!(value && value.Visible && value.Location == EMainViewLocation.ADDITION);
                    if ( ret && value.Tag && pSystemBundleCtx ) {
                        // filtered by tag in SystemBundle.
//                        var iStateValue : int = pSystemBundleCtx.getSystemBundleState(
//                                pSystemBundleCtx.getSystemBundle( SYSTEM_ID( value.Tag ) ) );
//                        ret = ret && iStateValue == CSystemBundleContext.STATE_STARTED;
                    }
                    return ret;
                } );

                if ( pFiltered.length ) {
                    pFiltered.sortOn( "SortID", Array.NUMERIC );
                }

                this.dataList = pFiltered;
            }
        }
    }

    override protected virtual function updateData() : void {
        super.updateData();

        if ( m_pList ) {
            const pDataList : Array = this.dataList;
            m_pList.dataSource = pDataList;
            m_pList.repeatY = Math.ceil( pDataList.length / 4 );
            m_pList.repeatX = Math.min( pDataList.length, 4 );
            this.invalidateDisplay();
        }
    }

    override protected virtual function updateDisplay() : void {
        super.updateDisplay();

        if ( m_pList ) {
            m_pList.right = m_pList.right;
            m_pList.sendEvent( Event.RESIZE );
        }
    }

    [Inline]
    final public function get dataList() : Array {
        return m_pDataList;
    }

    [Inline]
    final public function set dataList( value : Array ) : void {
        if ( m_pDataList == value )
            return;

        m_pDataList = value;
        invalidateData();
    }

    private function _onSystemBundleStateChangedHandler( event : CSystemBundleEvent ) : void {
        this.updateDataList();
        this.invalidateDisplay();
    }

    private function _onSystemBundleUserDataUpdated( event : CSystemBundleEvent ) : void {
        if ( m_pList ) {
            m_pList.refresh();
        }
    }

    private function _listItemRender( comp : Component, idx : int ) : void {
        if ( idx < 0 || !comp || !comp.dataSource )
            return;

        var pItemData : Object = comp.dataSource;
        if ( !pItemData )
            return;

        var view : Button;
        var sIcon : String = this.getIcon( pItemData );

        if ( comp is Box ) {
            var numChildren : uint = Box( comp ).numChildren;
            for ( var i : uint = 0; i < numChildren; ++i ) {
                if ( comp.getChildAt( i ) is Button ) {
                    view = comp.getChildAt( i ) as Button;
                }
            }
        }

        if ( view ) {
            view.skin = sIcon;
        }

        comp.toolTip = getToolTip( pItemData );
    }

    protected function getIcon( pData : Object ) : String {
        var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleCtx ) {

            var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( pData.Tag ) );
            if(pSystemBundle)
            {
                return pSystemBundleCtx.getUserData( pSystemBundle, CBundleSystem.ICON, pData.Icon );
            }
        }

        if(pData.Tag == "MUTE")
        {
            var gameSettingData:CGameSettingData = (system.stage.getSystem(CGameSettingSystem ).getHandler(CGameSettingManager)
                as CGameSettingManager).gameSettingData;
            if(gameSettingData)
            {
                var icon:String = gameSettingData.isCloseSound ? "png.main.btn_mute_1" : "png.main.btn_mute_0";
                return icon;
            }
        }

        return pData.Icon;
    }

    protected function getToolTip( pData : Object ) : * {
        var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleCtx ) {
            var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( pData.Tag ) );
            return pSystemBundleCtx.getUserData( pSystemBundle, CBundleSystem.TIP_HANDLER, pData.Name );
        }
        return pData.Name;
    }

    private function _listItemMouse( event : MouseEvent, idx : int ) : void {
        var pCurrentItem : Object = m_pList.getItem( idx );
        if ( event.type == MouseEvent.CLICK ) {
            if(idx > 1)
            {
                var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as
                        ISystemBundleContext;
                if ( pSystemBundleCtx ) {
                    var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( pCurrentItem.Tag ));
                    var vCurrent : Boolean = pSystemBundleCtx.getUserData( pSystemBundle, CBundleSystem.ACTIVATED, false );
                    pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, !vCurrent );
                }
            }
            else
            {
                if(idx == 0)// 举报
                {
                    (system.stage.getSystem(CGMReportSystem) as CGMReportSystem).dispatchEvent(new CGMReportEvent(CGMReportEvent.OpenReportWin, null));
                }

                if(idx == 1)// 静音
                {
                    system.stage.getSystem(CGameSettingSystem ).dispatchEvent(new CGameSettingEvent(CGameSettingEvent.OpenOrCloseSound, null));
                }
            }
        }
    }

    private function _onSoundSynchUpdateHandler(e:Event):void
    {
        var box:Box = m_pList.getCell(1);
        var btn:Button = box.getChildAt(0) as Button;
        var gameSettingData:CGameSettingData = (system.stage.getSystem(CGameSettingSystem ).getHandler(CGameSettingManager)
        as CGameSettingManager).gameSettingData;
        btn.skin = gameSettingData.isCloseSound ? "png.main.btn_mute_1" : "png.main.btn_mute_0";
    }

    /**
     * 获取主系统任何一个icon的Global坐标
     */
    public function getAdditionalIconGlobalPointCenter(sysTagName:String):Point
    {
        if ( !m_pList || !m_pList.dataSource )
            return null;

        var point:Point;
        var len:int = m_pList.dataSource.length;
        for(var i:int = 0; i < len; i++)
        {
            var data:MainView = m_pList.getItem(i) as MainView;
            if(data && data.Tag == sysTagName)
            {
                var item:Component = m_pList.getCell(i);
                if(item) {
                    point = item.localToGlobal(new Point(0, 0));
                    point.x += item.width/2;
                    point.y += item.height/2;
                    return point;
                }
            }
        }

        return null;
    }
    /**
     * 获取主系统任何一个icon的Global坐标
     */
    public function getAdditionalIconGlobalPoint(sysTagName:String):Point
    {
        if ( !m_pList || !m_pList.dataSource )
            return null;

        var len:int = m_pList.dataSource.length;
        for(var i:int = 0; i < len; i++)
        {
            var data:MainView = m_pList.getItem(i) as MainView;
            if(data && data.Tag == sysTagName)
            {
                var item:Component = m_pList.getCell(i);
                if ( item ) {
                    return item.localToGlobal( new Point() );
                }
            }
        }

        return null;
    }

}
}

// vim:ft=as3 tw=120 ts=4 sw=4 expandtab
