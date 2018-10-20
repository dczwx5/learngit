//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.lobby.view {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
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
import kof.ui.master.main.IconItemUI;
import kof.ui.master.main.MainUI;

import morn.core.components.Box;
import morn.core.components.Button;
import morn.core.components.Component;
import morn.core.components.FrameClip;
import morn.core.components.List;
import morn.core.handlers.Handler;

[Event(name="dataListDirty", type="flash.events.Event")]
/**
 *
 *
 * @author Jeremy (jeremy@qifun.com)
 */
internal class CSecondarySystemViewHandler extends CViewHandler {

    private var m_pAllLists : Vector.<List>;
    private var m_pDataList : Array;
    private var m_pMainUI : MainUI;

    public function CSecondarySystemViewHandler() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected virtual function onSetup() : Boolean {
        return super.onSetup();
    }

    public function initWith( pMainUI : MainUI, list : List, list_1 : List, list_2 : List, list_3 : List ) : Boolean {
        this.m_pMainUI = pMainUI;
        this.m_pAllLists = new <List>[];
        this.m_pAllLists.push( list );
        this.m_pAllLists.push( list_1 );
        this.m_pAllLists.push( list_2 );
        this.m_pAllLists.push( list_3 );

        return this.initialize();
    }

    protected function initialize() : Boolean {
        for each( var pList : List in m_pAllLists ) {
            pList.dataSource = [];
            pList.renderHandler = new Handler( this._listItemRender );
            pList.mouseHandler = new Handler( this._listItemMouse );
            pList.parent.addEventListener( Event.RESIZE, _onListResizeRequestHandler, false, CEventPriority.DEFAULT, true );
        }

        var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleCtx ) {
            pSystemBundleCtx.addEventListener( CSystemBundleEvent.BUNDLE_START, _onSystemBundleStateChangedHandler, false,
                    CEventPriority.DEFAULT, true );
            pSystemBundleCtx.addEventListener( CSystemBundleEvent.BUNDLE_STOP, _onSystemBundleStateChangedHandler, false,
                    CEventPriority.DEFAULT, true );
            pSystemBundleCtx.addEventListener( CSystemBundleEvent.USER_DATA, _onSystemBundleUserDataUpdated, false,
                    CEventPriority.DEFAULT, true );
        }

        if ( m_pMainUI ) {
            m_pMainUI.iconPeakGameFair.addEventListener( MouseEvent.CLICK, _iconPeakGameFair_mouseEventClickEventHandler, false, CEventPriority.DEFAULT, true );
            m_pMainUI.iconPeakGameFair.addEventListener( MouseEvent.MOUSE_OVER, _iconPeakGameFair_mouseEventRollOverEventHandler, false, CEventPriority.DEFAULT, true );
            m_pMainUI.iconPeakGameFair.addEventListener( MouseEvent.ROLL_OVER, _iconPeakGameFair_mouseEventRollOverEventHandler, false, CEventPriority.DEFAULT, true );
            m_pMainUI.iconPeakGameFair.fxHover.autoPlay = false;
            m_pMainUI.iconPeakGameFair.fxHover.stop();
        }

        this.updateDataList();
        this.invalidateDisplay();
        return true;
    }

    private function _iconPeakGameFair_mouseEventRollOverEventHandler( event : MouseEvent ) : void {
        event.currentTarget.removeEventListener( MouseEvent.MOUSE_OVER, _iconPeakGameFair_mouseEventRollOverEventHandler );
        event.currentTarget.removeEventListener( MouseEvent.ROLL_OVER, _iconPeakGameFair_mouseEventRollOverEventHandler );
        event.currentTarget.addEventListener( MouseEvent.MOUSE_OUT, _iconPeakGameFair_mouseEventRollOutEventHandler, false, CEventPriority.DEFAULT, true );
        event.currentTarget.addEventListener( MouseEvent.ROLL_OUT, _iconPeakGameFair_mouseEventRollOutEventHandler, false, CEventPriority.DEFAULT, true );

        m_pMainUI.iconPeakGameFair.boxFXHover.visible = true;
        m_pMainUI.iconPeakGameFair.fxHover.playFromTo();
    }

    private function _iconPeakGameFair_mouseEventRollOutEventHandler( event : MouseEvent ) : void {
        event.currentTarget.removeEventListener( MouseEvent.MOUSE_OUT, _iconPeakGameFair_mouseEventRollOutEventHandler );
        event.currentTarget.removeEventListener( MouseEvent.ROLL_OUT, _iconPeakGameFair_mouseEventRollOutEventHandler );
        event.currentTarget.addEventListener( MouseEvent.MOUSE_OVER, _iconPeakGameFair_mouseEventRollOverEventHandler );
        event.currentTarget.addEventListener( MouseEvent.ROLL_OVER, _iconPeakGameFair_mouseEventRollOverEventHandler );

        m_pMainUI.iconPeakGameFair.boxFXHover.visible = false;
        m_pMainUI.iconPeakGameFair.fxHover.stop();
    }

    private function _iconPeakGameFair_mouseEventClickEventHandler( event : MouseEvent ) : void {
        var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleCtx ) {
            var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.PEAK_GAME_FAIR) );
            var vCurrent : Boolean = pSystemBundleCtx.getUserData( pSystemBundle, CBundleSystem.ACTIVATED, false );
            pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, !vCurrent );
        }
    }

    override protected virtual function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();
        if ( ret ) {
            var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                pSystemBundleCtx.removeEventListener( CSystemBundleEvent.BUNDLE_START, _onSystemBundleStateChangedHandler );
                pSystemBundleCtx.removeEventListener( CSystemBundleEvent.BUNDLE_STOP, _onSystemBundleStateChangedHandler );
                pSystemBundleCtx.removeEventListener( CSystemBundleEvent.USER_DATA, _onSystemBundleUserDataUpdated );
            }
        }
        return ret;
    }

    protected function getCategorySortIndex( iCategory : int ) : int {
        if ( iCategory == EMainViewCategory.PLAY )
            return 0;
        else if ( iCategory == EMainViewCategory.ACT )
            return 1;
        return 0;
    }

    protected function updateDataList() : void {
        var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;

        var pDataHolder : IDataHolder = system.getBean( IDataHolder ) as IDataHolder;
        if ( pDataHolder ) {
            var pData : Array = pDataHolder.data as Array;
            if ( pData ) {
                var pFiltered : Array = pData.filter( function ( value : *, index : int, arr : Array ) : Boolean {
                    var ret : Boolean = !!(value && value.Visible && value.Location == EMainViewLocation.SECONDARY);
                    if ( ret && value.Tag && pSystemBundleCtx ) {
                        // filtered by tag in SystemBundle.
                        var iStateValue : int =
                                pSystemBundleCtx.getSystemBundleState( pSystemBundleCtx.getSystemBundle( SYSTEM_ID( value.Tag ) ) );
                        ret = ret && iStateValue == CSystemBundleContext.STATE_STARTED;
                    }
                    return ret;
                } );

                if ( pFiltered.length ) {
//                    pFiltered.sortOn( "SortID", Array.NUMERIC | Array.DESCENDING );
                    pFiltered.sort( function ( a1 : Object, a2 : Object ) : int {
                        // split by "Category" desc
                        if ( getCategorySortIndex( a1.Category ) > getCategorySortIndex( a2.Category ) )
                            return -1;
                        else if ( getCategorySortIndex( a1.Category ) < getCategorySortIndex( a2.Category ) )
                            return 1;
                        // sort on SortID desc.
                        if ( a1.SortID > a2.SortID )
                            return -1;
                        else if ( a1.SortID < a2.SortID )
                            return 1;
                        return 0;
                    } );
                }

                // Specify rule for PEAK_GAME. always be the first one.
                for ( var it : int = 0, e : int = pFiltered.length; it < e; ++it ) {
                    var pValue : Object = pFiltered[ it ];
                    if ( pValue.Tag == KOFSysTags.PEAK_GAME_FAIR ) {
                        pFiltered.splice( it, 1 );
                        pFiltered.push( pValue );
                        break;
                    }
                }

                this.dataList = pFiltered;
            }
        }

        if ( m_pMainUI ) {
            m_pMainUI.mark_rt_pg.visible = dataList.length == 0 || this.dataList[ this.dataList.length - 1 ].Tag != KOFSysTags.PEAK_GAME_FAIR;
            if ( !m_pMainUI.mark_rt_pg.visible ) {
                m_pMainUI.iconPeakGameFair.dataSource = this.dataList[ this.dataList.length - 1 ];
                _listItemRender( m_pMainUI.iconPeakGameFair, -1 );
            }
            m_pMainUI.iconPeakGameFair.visible = !m_pMainUI.mark_rt_pg.visible;
        }
    }

    override protected virtual function updateData() : void {
        super.updateData();

//        if ( m_pList ) {
//            const pDataList : Array = this.dataList;
//            m_pList.dataSource = pDataList;
//
//            if ( pDataList ) {
//                m_pList.repeatX = pDataList.length;
//            }
//        }

        this.invalidateDisplay();
    }

    override protected virtual function updateDisplay() : void {
        super.updateDisplay();

        var pContainers : Array = null;

        for each( var pList : List in m_pAllLists ) {
            if ( pList && pList.parent ) {
                pContainers = pContainers || [];
                if ( pContainers.indexOf( pList.parent ) == -1 )
                    pContainers.push( pList.parent );
            }
        }

        if ( pContainers && pContainers.length ) {
            for each ( var con : Component in pContainers ) {
                con.dispatchEvent( new Event( Event.RESIZE ) ); // resetPosition.
            }
        }
    }

//    private function updateListDisplay() : void {
//        var i : int = 0;
//        var tempDataList : Array = this.dataList.slice();
//        for (; i < m_pAllLists.length; ++i ) {
//            var pList : List = m_pAllLists[ i ];
//            if ( pList && pList.parent ) {
//                // re-calc repeatX.
//                var cell : DisplayObject = pList.getCell( 0 );
//                if ( cell ) {
//                    var nMaxRepeatX : uint = ( pList.parent.width ) / ( cell.width + pList.spaceX );
//                    var nRepeatX : int = Math.min( tempDataList.length, nMaxRepeatX );
////                    var nRepeatY : int = Math.ceil( tempDataList.length / nRepeatX );
//
////                    pList.repeatY = nRepeatY;
//                    var fillDataList : Array = tempDataList.slice( tempDataList.length - nRepeatX );
//
//                    if ( i < m_pAllLists.length - 1 ) {
//                        pList.dataSource = fillDataList;
//                        pList.repeatX = nRepeatX;
//                    } else {
//                        pList.dataSource = tempDataList.slice();
//                        pList.repeatX = tempDataList.length;
//                    }
//                    pList.repeatY = 1;
//
//                    tempDataList.splice( tempDataList.length - nRepeatX, nRepeatX );
//                }
//            }
//
//            pList.right = pList.right;
//        }
//    }

    private function updateListDisplay() : void {
        var i : int, s : int, e : int;
        var tempDataList : Array = this.dataList.slice();

        var bPeakGameFairVisible : Boolean = false;

        if ( tempDataList.length ) {
            if ( Boolean( tempDataList[ tempDataList.length - 1 ].Visible ) && tempDataList[ tempDataList.length - 1 ].Tag == KOFSysTags.PEAK_GAME_FAIR ) {
                bPeakGameFairVisible = true;
            }
        }

        for ( i = 0; i < m_pAllLists.length; ++i ) {
            var pList : List = m_pAllLists[ i ];
            if ( pList && pList.parent ) {
                // re-calc repeatX.
                var cell : DisplayObject = pList.getCell( 0 );
                if ( cell ) {

                    var nMaxRepeatX : uint = ( pList.parent.width ) / ( cell.width + pList.spaceX );

                    if ( i == 2 ) {
                        nMaxRepeatX = ( pList.parent.localToGlobal( new Point( 0, 0 ) ).x + pList.parent.width ) / (cell.width + pList.spaceX);
                    }

                    if ( bPeakGameFairVisible && i == 1 && nMaxRepeatX > 0 )
                        tempDataList.push( null );

                    // figure out which index was the Category spacer.
                    for ( s = tempDataList.length - 2, e = 0; s >= e; s-- ) {
                        if ( tempDataList[ s ] && tempDataList[ s + 1 ] && tempDataList[ s ].Category != tempDataList[ s + 1 ].Category ) {
                            break;
                        }
                    }

                    if ( s >= 0 && tempDataList[ s + 1 ] && getCategorySortIndex( tempDataList[ s + 1 ].Category ) == i ) {
                        nMaxRepeatX = Math.min( tempDataList.length - s - 1, nMaxRepeatX );
                    }

                    var nRepeatX : int = Math.min( tempDataList.length, nMaxRepeatX );
//                    var nRepeatY : int = Math.ceil( tempDataList.length / nRepeatX );

//                    pList.repeatY = nRepeatY;

                    var fillDataList : Array = tempDataList.slice( tempDataList.length - nRepeatX );

                    if ( i < m_pAllLists.length - 1 ) {
                        pList.dataSource = fillDataList;
                        pList.repeatX = nRepeatX;
                    } else {
                        pList.dataSource = tempDataList.slice();
                        pList.repeatX = tempDataList.length;
                    }
                    pList.repeatY = 1;

                    tempDataList.splice( tempDataList.length - nRepeatX, nRepeatX );
                }
            }

            pList.right = pList.right;
        }
    }

    private function _onListResizeRequestHandler( event : Event ) : void {
        this.updateListDisplay();
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
//        invalidateDisplay();

        this.dispatchEvent( new Event( "dataListDirty", false, false ) );
    }

    private function _onSystemBundleStateChangedHandler( event : CSystemBundleEvent ) : void {
        this.updateDataList();
        this.invalidateDisplay();
    }

    private function _onSystemBundleUserDataUpdated( event : CSystemBundleEvent ) : void {
        for each( var pList : List in m_pAllLists ) {
            if ( pList ) {
                pList.refresh();
            }
        }
    }

    private function _listItemRender( comp : Component, idx : int ) : void {
        if ( !comp )
            return;

        var pItemData : Object = comp.dataSource;
        if ( !pItemData ) {
            comp.visible = false;
            return;
        }

        if ( idx >= 0 && pItemData.Tag == KOFSysTags.PEAK_GAME_FAIR ) {
            comp.visible = false;
            comp = m_pMainUI.iconPeakGameFair;
        }

        var pSystemBundle : ISystemBundle;
        var pSystemBundleContext : ISystemBundleContext = system.stage.getBean( ISystemBundleContext ) as ISystemBundleContext;

        if ( pSystemBundleContext )
            pSystemBundle = pSystemBundleContext.getSystemBundle( SYSTEM_ID( pItemData.Tag ) );

        var sIcon : String = pItemData.Icon;
        var sImgText : String = pItemData.IconText;

        if ( pSystemBundle ) {
            sIcon = pSystemBundleContext.getUserData( pSystemBundle, CBundleSystem.ICON, sIcon );
        }

        var item : IconItemUI = comp as IconItemUI;
        if ( !item && comp is Box ) {
            var numChildren : uint = Box( comp ).numChildren;
            for ( var i : uint = 0; i < numChildren; ++i ) {
                if ( comp.getChildAt( i ) is Button ) {
                    var view : Button = comp.getChildAt( i ) as Button;
                    if ( view ) {
                        view.skin = sIcon;
                    }
                    break;
                }
            }
        } else if ( item is IconItemUI ) {
//            var pNotifyIcon : Component = item.getChildByName( 'notifyIcon' ) as Component;
//            var pActivated : Component = item.getChildByName( 'activated' ) as Component;
//            var pSkinIcon : Component = item.getChildByName( 'skinIcon' ) as Component;
            var pNotifyIcon : Component = item.notifyIcon;
//            var pActivated : FrameClip = item.activated;
            var pSkinIcon : Component = item.skinIcon;
            var pGlowEffect : FrameClip = item.fxGlow;
            var pSkinText : Component =  item.imgText;
            var bVisible : Boolean = true;

            try {
                if ( pSkinIcon ) pSkinIcon[ 'skin' ] = sIcon;
                if ( pSkinText ) pSkinText[ 'skin' ] = sImgText;

                if ( pItemData.Tag == KOFSysTags.PEAK_GAME_FAIR ) {
                    pSkinIcon.top = 12;
                    pSkinIcon.bottom = NaN;
                } else {
                    pSkinIcon.top = NaN;
                    pSkinIcon.bottom = 0;
                }

                if ( pNotifyIcon ) {
                    if ( pSystemBundle ) {
                        pNotifyIcon.visible = pSystemBundleContext.getUserData( pSystemBundle, CBundleSystem.NOTIFICATION, false );
                    } else {
                        pNotifyIcon.visible = false;
                    }
                }

//                if ( pActivated ) {
//                    if ( pSystemBundle ) {
//                        pActivated.visible = pSystemBundleContext.getUserData( pSystemBundle, CBundleSystem.ACTIVATED, false );
//                    } else {
//                        pActivated.visible = false;
//                    }
//
//                    if ( pActivated.visible ) {
//                        if ( !pActivated.isPlaying )
//                            pActivated.gotoAndPlay( 0 );
//                    } else {
//                        pActivated.stop();
//                    }
//                }

                if ( pGlowEffect ) {
                    if ( pSystemBundle ) {
                        pGlowEffect.visible = pSystemBundleContext.getUserData( pSystemBundle, CBundleSystem.GLOW_EFFECT, false );
                    } else {
                        pGlowEffect.visible = false;
                    }

                    if ( pGlowEffect.visible ) {
                        if ( !pGlowEffect.isPlaying )
                            pGlowEffect.gotoAndPlay( 0 );
                    } else {
                        pGlowEffect.stop();
                    }
                }

                if ( idx >= 0 && pItemData.Tag == KOFSysTags.PEAK_GAME_FAIR ) {
                    comp.visible = false;
                    if ( pSystemBundleContext ) {
                        pSystemBundle = pSystemBundleContext.getSystemBundle( SYSTEM_ID( KOFSysTags.PEAK_GAME_FAIR ) );
                        if ( pSystemBundle ) {
                            bVisible = pSystemBundleContext.getUserData( pSystemBundle, "visible", !m_pMainUI.mark_rt_pg.visible );
                        }
                    }
                } else {
                    bVisible = pSystemBundleContext.getUserData( pSystemBundle, "visible", bVisible );
                }

            } catch ( e : Error ) {
            }

            item.visible = bVisible;
        }

        if ( pSystemBundle ) {
            comp.toolTip = pSystemBundleContext.getUserData( pSystemBundle, CBundleSystem.TIP_HANDLER, pItemData.Name );
        } else {
            comp.toolTip = pItemData.Name;
        }
    }

    private function _listItemMouse( event : MouseEvent, index : int ) : void {
        var pDisplayObject : DisplayObject = event.currentTarget as DisplayObject;
        var pParent : DisplayObjectContainer = pDisplayObject as DisplayObjectContainer ? DisplayObjectContainer( pDisplayObject ) : pDisplayObject as DisplayObjectContainer;
        var pList : List;
        while ( pParent ) {
            if ( pParent is List ) {
                pList = pParent as List;
                break;
            }

            pParent = pParent.parent;
        }

        if ( !pList )
            return;

        var pIconInteractEH : CIconInteractEffectHandler = system.getHandler( CIconInteractEffectHandler ) as CIconInteractEffectHandler;
        var pCurrentItem : Object = pList.getItem( index );
        var pCellItem : Component = pList.getCell( index );

        if ( event.type == MouseEvent.CLICK ) {
            var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( pCurrentItem.Tag ) );
                var vCurrent : Boolean = pSystemBundleCtx.getUserData( pSystemBundle, CBundleSystem.ACTIVATED, false );
                pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, !vCurrent );

                if(!vCurrent)
                {
                    _recordLinkLog(pCurrentItem.Tag);
                }

                if ( pIconInteractEH ) {
                    pIconInteractEH.performMouseDownEffect( pCellItem );
                }
            }
        } else if ( event.type == MouseEvent.ROLL_OVER || event.type == MouseEvent.MOUSE_OVER ) {
            if ( pIconInteractEH ) {
                if ( pCellItem is IconItemUI ) {
                    var vIcon : IconItemUI = pCellItem as IconItemUI;
                    pIconInteractEH.performScaleEffect1( vIcon, vIcon.skinIcon, vIcon.imgBg, vIcon.imgText, null, new Point(2, 1));
                }
            }
        } else if ( event.type == MouseEvent.ROLL_OUT || event.type == MouseEvent.MOUSE_OVER ) {
            if ( pIconInteractEH ) {
                if ( pCellItem is IconItemUI ) {
                    var pIcon : IconItemUI = pCellItem as IconItemUI;
                    pIconInteractEH.endScaleEffect1( pIcon, pIcon.skinIcon, pIcon.imgBg, pIcon.imgText );
                }
            }
        }
    }

    internal function getIconGlobalPoint( sysTagName : String ) : Point {
        if ( sysTagName == KOFSysTags.PEAK_GAME_FAIR )
            return m_pMainUI.iconPeakGameFair.localToGlobal( new Point( 0, 0 ) );

        if ( !m_pAllLists )
            return null;

        for each ( var pList : List in m_pAllLists ) {
            if ( !pList )
                continue;
            var len : int = pList.dataSource.length;
            for ( var i : int = 0; i < len; i++ ) {
                var data : MainView = pList.getItem( i ) as MainView;
                if ( data && data.Tag == sysTagName ) {
                    var icon : Component = pList.getCell( i );
                    if ( icon )
                        return icon.localToGlobal( new Point( 0, 0 ) );
                }
            }
        }

        return null;
    }

    internal function getIconGlobalPointCenter( sysTagName : String ) : Point {
        var point:Point;
        if ( sysTagName == KOFSysTags.PEAK_GAME_FAIR ) {
            point = m_pMainUI.iconPeakGameFair.localToGlobal( new Point( 0, 0 ) );
            point.x += m_pMainUI.iconPeakGameFair.width/2;
            point.y += m_pMainUI.iconPeakGameFair.height/2;
            return point;
        }

        if ( !m_pAllLists )
            return null;

        for each ( var pList : List in m_pAllLists ) {
            if ( !pList )
                continue;
            var len : int = pList.dataSource.length;
            for ( var i : int = 0; i < len; i++ ) {
                var data : MainView = pList.getItem( i ) as MainView;
                if ( data && data.Tag == sysTagName ) {
                    var icon : Component = pList.getCell( i );
                    if ( icon ) {
                        point = icon.localToGlobal( new Point( 0, 0 ) );
                        point.x += icon.width / 2;
                        point.y += icon.height / 2;
                        return point;
                    }
                }
            }
        }

        return null;
    }

    /**
     * 记录打点日志
     */
    private function _recordLinkLog(sysTag:String):void
    {
        switch (sysTag)
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

// vim:ft=as3 sw=4 ts=4 tw=120 expandtab
