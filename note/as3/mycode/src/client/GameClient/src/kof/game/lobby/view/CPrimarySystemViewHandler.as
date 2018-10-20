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
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.CSystemBundleContext;
import kof.game.bundle.CSystemBundleEvent;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CLogUtil;
import kof.table.MainView;
import kof.table.MainView.EMainViewCategory;
import kof.table.MainView.EMainViewLocation;
import kof.ui.master.main.IconItemPUI;
import kof.ui.master.main.IconItemUI;
import kof.util.CAssertUtils;
import kof.util.TweenUtil;

import morn.core.components.Button;
import morn.core.components.Component;
import morn.core.components.Component;
import morn.core.components.Image;
import morn.core.components.List;
import morn.core.components.VBox;
import morn.core.handlers.Handler;

/**
 * 主要功能系统视图控制器（游戏大厅）
 *     |- 格斗家
 *     |- 战队
 *     |- 背包
 *     |- ...
 *
 * @author Jeremy (jeremy@qifun.com)
 */
internal class CPrimarySystemViewHandler extends CViewHandler {

    /** @private */
    private var m_pPrimaryList : List;
    private var m_pPrimaryList2 : List;
    /** @private */
    private var m_pDataList : Array;
    private var m_pDataList2 : Array;

    /**
     * Creates a new CPrimarySystemViewHandler.
     */
    public function CPrimarySystemViewHandler() {
        super();
    }

    override public function dispose() : void {
        super.dispose();

        if ( m_pPrimaryList )
            m_pPrimaryList.dataSource = null;
        m_pPrimaryList = null;

        if ( m_pPrimaryList2 )
            m_pPrimaryList2.dataSource = null;
        m_pPrimaryList2 = null;
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        return ret;
    }

    public function initWith( list : List, list_2 : List ) : Boolean {
        CAssertUtils.assertNull( this.m_pPrimaryList );
        CAssertUtils.assertNull( this.m_pPrimaryList2 );
        this.m_pPrimaryList = list;
        this.m_pPrimaryList2 = list_2;
        return this.initialize();
    }

    protected function initialize() : Boolean {
        m_pPrimaryList.dataSource = [];
        m_pPrimaryList.renderHandler = new Handler( this._primaryItemRender );
        m_pPrimaryList.mouseHandler = new Handler( this._primaryItemMouse );

        m_pPrimaryList2.dataSource = [];
        m_pPrimaryList2.renderHandler = new Handler( this._primaryItemRender );
        m_pPrimaryList2.mouseHandler = new Handler( this._primaryItemMouse2 );

        m_pPrimaryList.parent.addEventListener( Event.RESIZE, _onListResizeRequestHandler, false, CEventPriority.DEFAULT, true );

        var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;

        if ( pSystemBundleCtx ) {
            pSystemBundleCtx.addEventListener( CSystemBundleEvent.BUNDLE_START, _onSystemBundleStateChangedHandler, false,
                    CEventPriority.DEFAULT, true );
            pSystemBundleCtx.addEventListener( CSystemBundleEvent.BUNDLE_STOP, _onSystemBundleStateChangedHandler, false,
                    CEventPriority.DEFAULT, true );
            pSystemBundleCtx.addEventListener( CSystemBundleEvent.USER_DATA, _onSystemBundleUserDataUpdated, false,
                    CEventPriority.DEFAULT, true );
        }

        this.updateDataList();
        this.invalidateDisplay();

        return true;
    }

    override protected function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();
        this.dataList = null;
        this.dataList2 = null;

        var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;

        if ( pSystemBundleCtx ) {
            pSystemBundleCtx.removeEventListener( CSystemBundleEvent.BUNDLE_START, _onSystemBundleStateChangedHandler );
            pSystemBundleCtx.removeEventListener( CSystemBundleEvent.BUNDLE_STOP, _onSystemBundleStateChangedHandler );
            pSystemBundleCtx.removeEventListener( CSystemBundleEvent.USER_DATA, _onSystemBundleUserDataUpdated );
        }

        return ret;
    }

    protected function updateDataList() : void {
        var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;

        var pDataHolder : IDataHolder = system.getBean( IDataHolder ) as IDataHolder;
        if ( pDataHolder ) {
            var pData : Array = pDataHolder.data as Array;
            if ( pData ) {
                var pFiltered : Array = pData.filter( function ( value : *, index : int, arr : Array ) : Boolean {
                    var ret : Boolean = !!(value && value.Visible && value.Location == EMainViewLocation.PRIMARY);
                    if ( ret && value.Tag && pSystemBundleCtx ) {
                        // filtered by tag in SystemBundle.
                        var iStateValue : int = pSystemBundleCtx.getSystemBundleState( pSystemBundleCtx.getSystemBundle( SYSTEM_ID( value.Tag ) ) );
                        ret = ret && iStateValue == CSystemBundleContext.STATE_STARTED;
                    }
                    return ret;
                } );

                var arr1:Array;
                var arr2:Array;
                if ( pFiltered.length ) {

                    arr1 = pFiltered.filter(function (value : *, index : int, arr : Array):Boolean{
                        return value.Category == EMainViewCategory.ACT || value.Category == EMainViewCategory.PLAY;
                    });

                    arr1.sortOn( "SortID", Array.NUMERIC );

                    arr2 = pFiltered.filter(function (value : *, index : int, arr : Array):Boolean{
                        return value.Category == EMainViewCategory.OTHER;
                    });

                    arr2.sortOn( "SortID", Array.NUMERIC );
                }

                this.dataList = arr1 == null ? [] : arr1;
                this.dataList2 = arr2 == null ? [] : arr2;
            }
        }
    }

    override protected function updateData() : void {
        super.updateData();

        if ( m_pPrimaryList && m_pPrimaryList2) {
            const pDataList : Array = this.dataList;
            m_pPrimaryList.dataSource = pDataList;
            m_pPrimaryList.repeatY = 1;
            if ( pDataList ) {
                m_pPrimaryList.repeatX = pDataList.length;
            }

            m_pPrimaryList2.dataSource = dataList2;
            m_pPrimaryList2.repeatY = 1;
            if ( dataList2 ) {
                m_pPrimaryList2.repeatX = dataList2.length;
            }

            this.invalidateDisplay();
        }
    }

    override protected function updateDisplay() : void {
        super.updateDisplay();

        if ( m_pPrimaryList ) {
//            if ( m_pPrimaryList.parent ) {
//                m_pPrimaryList.parent.dispatchEvent( new Event( Event.RESIZE ) );
//            } else {
                m_pPrimaryList.right = m_pPrimaryList.right;
//            }
        }

        if ( m_pPrimaryList2 ) {
//            if ( m_pPrimaryList2.parent ) {
//                m_pPrimaryList2.parent.dispatchEvent( new Event( Event.RESIZE ) );
//            } else {
                m_pPrimaryList2.right = m_pPrimaryList2.right;
//            }
        }
    }

    private function _onListResizeRequestHandler( event : Event ) : void {
        if ( m_pPrimaryList && m_pPrimaryList2) {
            const pDataList : Array = this.dataList;
            m_pPrimaryList.dataSource = pDataList;
            m_pPrimaryList.repeatY = 1;
            if ( pDataList ) {
                m_pPrimaryList.repeatX = pDataList.length;
            }

            m_pPrimaryList2.dataSource = dataList2;
            m_pPrimaryList2.repeatY = 1;
            if ( dataList2 ) {
                m_pPrimaryList2.repeatX = dataList2.length;
            }

            m_pPrimaryList.right = m_pPrimaryList.right;
            m_pPrimaryList2.right = m_pPrimaryList2.right;
        }


    }

//    [Inline]
//    final public function get primaryList() : List {
//        return m_pPrimaryList;
//    }

    [Inline]
    final public function get dataList() : Array {
        return m_pDataList;
    }

    [Inline]
    final public function get dataList2() : Array {
        return m_pDataList2;
    }

    [Inline]
    final public function set dataList( value : Array ) : void {
        if ( m_pDataList == value )
            return;
        m_pDataList = value;
        this.invalidateData();
    }

    [Inline]
    final public function set dataList2( value : Array ) : void {
        if ( m_pDataList2 == value )
            return;
        m_pDataList2 = value;
        this.invalidateData();
    }

    /**
     * @private
     */
    final private function _onSystemBundleUserDataUpdated( event : CSystemBundleEvent ) : void {
        if ( m_pPrimaryList ) {
            m_pPrimaryList.refresh();
        }

        if(m_pPrimaryList2)
        {
            m_pPrimaryList2.refresh();
        }
    }

    /** @private */
    final private function _onSystemBundleStateChangedHandler( event : CSystemBundleEvent ) : void {
        this.updateDataList();
        this.invalidateDisplay();
    }

    /**
     * @private
     */
    final private function _primaryItemRender( item : Component, idx : int ) : void {
        if ( !item || idx < 0 )
            return;

        var pData : Object = item.dataSource;
        if ( !pData )
            return;

        var sIcon : String = getIcon( pData );
        var vPrimaryItemUI : IconItemPUI = item as IconItemPUI;

        var btnIcon : Button = vPrimaryItemUI.btnIcon;
//        var imgBg : Component = vPrimaryItemUI.imgBg;
        var imgText : Image = vPrimaryItemUI.imgText;

        if ( btnIcon ) {
            btnIcon.skin = sIcon;
        }

        if ( imgText ) {
            imgText.url = getIconText( pData );
        }

        var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( pData.Tag ) );

        item.visible = pSystemBundleCtx.getUserData( pSystemBundle, "visible", true );

        _updateTipState( item, idx );
    }

    protected function getIcon( pData : Object ) : String {
        var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleCtx ) {
            var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( pData.Tag ) );
            return pSystemBundleCtx.getUserData( pSystemBundle, CBundleSystem.ICON, pData.Icon );
        }
        return pData.Icon;
    }

    protected function getIconText( pData : Object ) : String {
        return pData.IconText;
    }

    private function _updateTipState( item : Component, index : int ) : void {
//        var pCurrentItem : Object = m_pPrimaryList.getItem( index );
        var pCurrentItem : Object = item.dataSource;
        var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var vToolTip : * = pCurrentItem.Name;
        if ( pSystemBundleCtx ) {
            var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( pCurrentItem.Tag ) );
            var pNotifyIcon : Component = item.getChildByName( "notifyIcon" ) as Component;

            if ( pNotifyIcon ) {
                if ( pSystemBundle ) {
                    pNotifyIcon.visible = pSystemBundleCtx.getUserData( pSystemBundle, CBundleSystem.NOTIFICATION, false );
                } else {
                    pNotifyIcon.visible = false;
                }
            }

            vToolTip = pSystemBundleCtx.getUserData( pSystemBundle, CBundleSystem.TIP_HANDLER, vToolTip );
        }

        item.toolTip = vToolTip;
    }

    /**
     * @private
     */
    final private function _primaryItemMouse( event : MouseEvent, idx : int ) : void {
        var pIconInteractEH : CIconInteractEffectHandler = system.getHandler( CIconInteractEffectHandler ) as CIconInteractEffectHandler;
        var pCurrentItem : Object = m_pPrimaryList.getItem( idx );
        var pCellItem : Component = m_pPrimaryList.getCell( idx );

        if ( event.type == MouseEvent.CLICK ) {
            var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( pCurrentItem.Tag ) );
                var vCurrent : Boolean = pSystemBundleCtx.getUserData( pSystemBundle, CBundleSystem.ACTIVATED, false );
                pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, !vCurrent );

                if ( pIconInteractEH ) {
                    pIconInteractEH.performMouseDownEffect( pCellItem );
                }

                if(!vCurrent)
                {
                    _recordLinkLog(pCurrentItem.Tag);
                }
            }
        } else if ( event.type == MouseEvent.ROLL_OVER || event.type == MouseEvent.MOUSE_OVER ) {
            if ( pIconInteractEH ) {
                if ( pCellItem is IconItemPUI ) {
                    var vIcon : IconItemPUI = pCellItem as IconItemPUI;
                    pIconInteractEH.performScaleEffect( vIcon.btnIcon, vIcon.imgBg );
                }
            }
        } else if ( event.type == MouseEvent.ROLL_OUT || event.type == MouseEvent.MOUSE_OUT ) {
            if ( pIconInteractEH ) {
                if ( pCellItem is IconItemPUI ) {
                    var pIcon : IconItemPUI = pCellItem as IconItemPUI;
                    pIconInteractEH.endScaleEffect( pIcon.btnIcon, pIcon.imgBg );
                }
            }
        }
    }

    private function _primaryItemMouse2( event : MouseEvent, idx : int ) : void {
        var pIconInteractEH : CIconInteractEffectHandler = system.getHandler( CIconInteractEffectHandler ) as CIconInteractEffectHandler;
        var pCurrentItem : Object = m_pPrimaryList2.getItem( idx );
        var pCellItem : Component = m_pPrimaryList2.getCell( idx );

        if ( event.type == MouseEvent.CLICK ) {
            var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( pCurrentItem.Tag ) );
                var vCurrent : Boolean = pSystemBundleCtx.getUserData( pSystemBundle, CBundleSystem.ACTIVATED, false );
                pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, !vCurrent );

                if ( pIconInteractEH ) {
                    pIconInteractEH.performMouseDownEffect( pCellItem );
                }

                if(!vCurrent)
                {
                    _recordLinkLog(pCurrentItem.Tag);
                }
            }
        } else if ( event.type == MouseEvent.ROLL_OVER || event.type == MouseEvent.MOUSE_OVER ) {
            if ( pIconInteractEH ) {
                if ( pCellItem is IconItemPUI ) {
                    var vIcon : IconItemPUI = pCellItem as IconItemPUI;
                    pIconInteractEH.performScaleEffect( vIcon.btnIcon, vIcon.imgBg );
                }
            }
        } else if ( event.type == MouseEvent.ROLL_OUT || event.type == MouseEvent.MOUSE_OUT ) {
            if ( pIconInteractEH ) {
                if ( pCellItem is IconItemPUI ) {
                    var pIcon : IconItemPUI = pCellItem as IconItemPUI;
                    pIconInteractEH.endScaleEffect( pIcon.btnIcon, pIcon.imgBg );
                }
            }
        }
    }

    /**
     * 获取主系统任何一个icon的Global坐标
     */
    public function getPrimaryIconGlobalPointCenter( sysTagName : String ) : Point {
        var listArr:Array = [m_pPrimaryList, m_pPrimaryList2];
        for each(var list:List in listArr)
        {
            if ( !list || !list.dataSource )
            {
                continue;
            }

            var point : Point;
            if ( list && list.dataSource ) {
                var len : int = list.dataSource.length;
                for ( var i : int = 0; i < len; i++ ) {
                    var data : MainView = list.getItem( i ) as MainView;
                    if ( data && data.Tag == sysTagName ) {
                        var icon : Component = list.getCell( i );
                        var item : IconItemUI = icon as IconItemUI;
                        if ( item ) {
                            point = item.skinIcon.localToGlobal( new Point() );
                            point.x += item.skinIcon.width / 2;
                            point.y += item.skinIcon.height / 2;
                            return point;
                        } else if ( icon ) {
                            point = icon.localToGlobal( new Point( 0, 0 ) );
                            point.x += icon.width / 2;
                            point.y += icon.height / 2;
                            return point;
                        }
                    }
                }
            }
        }

        return null;
    }

    /**
     * 获取主系统任何一个icon的Global坐标
     */
    public function getPrimaryIconGlobalPoint( sysTagName : String ) : Point {
        var listArr:Array = [m_pPrimaryList, m_pPrimaryList2];

        for each(var list:List in listArr)
        {
            if ( !list || !list.dataSource )
            {
                continue;
            }

            var len : int = list.dataSource.length;
            for ( var i : int = 0; i < len; i++ ) {
                var data : MainView = list.getItem( i ) as MainView;
                if ( data && data.Tag == sysTagName ) {
                    var icon : Component = list.getCell( i );
                    var item : IconItemUI = icon as IconItemUI;
                    if ( item ) {
                        return item.skinIcon.localToGlobal( new Point() );
                    } else if ( icon ) {
                        return icon.localToGlobal( new Point( 0, 0 ) );
                    }
                }
            }
        }

        return null;
    }

    /**
     * 图标发光
     */
    public function shineIcon( sysTagName : String ) : void {
        var listArr:Array = [m_pPrimaryList, m_pPrimaryList2];

        for each(var list:List in listArr)
        {
            if ( !list || !list.dataSource )
            {
                continue;
            }

            var len : int = list.dataSource.length;
            for ( var i : int = 0; i < len; i++ ) {
                var data : MainView = list.getItem( i ) as MainView;
                if ( data && data.Tag == sysTagName ) {
                    var icon : Component = list.getCell( i );
                    if ( icon ) {
                        TweenUtil.lighting( icon, 0.4, 1, 0, null, null, 0xFFCC00 );
                        return;
                    }
                }
            }
        }
    }

    /**
     * 记录打点日志
     */
    private function _recordLinkLog(sysTag:String):void
    {
        switch ( sysTag )
        {
            case KOFSysTags.MALL:
                CLogUtil.recordLinkLog(system, 10030);
                break;
            case KOFSysTags.FIRST_RECHARGE:
                CLogUtil.recordLinkLog(system, 10005);
                break;
            case KOFSysTags.ONE_DIAMOND_REWARD:
                CLogUtil.recordLinkLog(system, 10008);
                break;
            case KOFSysTags.DAILY_RECHARGE:
                CLogUtil.recordLinkLog(system, 10010);
                break;
            case KOFSysTags.WELFARE_HALL:
                CLogUtil.recordLinkLog(system, 10012);
                break;
            case KOFSysTags.INVEST:
                CLogUtil.recordLinkLog(system, 10016);
                break;
            case KOFSysTags.ACTIVITY_HALL:
                CLogUtil.recordLinkLog(system, 10022);
                break;
            case KOFSysTags.DIAMOND_ROULETTE:
                CLogUtil.recordLinkLog(system, 10026);
                break;
            case KOFSysTags.ACTIVITY_LOTTERY:
                CLogUtil.recordLinkLog(system, 10028);
                break;
            case KOFSysTags.HERO_TREASURE:
                CLogUtil.recordLinkLog(system, 10032);
                break;
            case KOFSysTags.NEW_SERVER_ACTIVITY:
                CLogUtil.recordLinkLog(system, 10036);
                break;
            case KOFSysTags.RECRUIT_RANK:
                CLogUtil.recordLinkLog(system, 10037);
                break;
            case KOFSysTags.DISCOUNT_STORE:
                CLogUtil.recordLinkLog(system, 10038);
                break;
            case KOFSysTags.TOTAL_RECHARGE:
                CLogUtil.recordLinkLog(system, 10039);
                break;
            case KOFSysTags.TOTAL_CONSUME:
                CLogUtil.recordLinkLog(system, 10040);
                break;
            case KOFSysTags.BARGAINCARD:
                CLogUtil.recordLinkLog(system, 10041);
                break;
        }
    }
}
}
