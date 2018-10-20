//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.login {

import com.greensock.TweenLite;

import flash.events.Event;
import flash.events.MouseEvent;

import kof.framework.CAbstractHandler;
import kof.framework.CAppSystem;
import kof.framework.CViewHandler;
import kof.framework.events.CEventPriority;
import kof.game.audio.CAudioConstants;
import kof.game.audio.IAudio;
import kof.ui.demo.PlayerModeSelectUI;
import kof.ui.demo.RoleHeadUI;
import kof.ui.demo.RoleSelectUI;
import kof.util.CObjectUtils;

import morn.core.components.Container;
import morn.core.components.FrameClip;
import morn.core.components.ViewStack;
import morn.core.events.UIEvent;
import morn.core.handlers.Handler;

import mx.events.Request;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public final class CPlaySelectViewHandler extends CViewHandler {

    public static const EVT_START_GAME : String = "StartGame";

    public static const RANDOM_IDX : int = 37;

    public static function get iconURI() : String {
        return "icon/role/small/";
    }

    /** @private */
    private var m_playSelectUI : RoleSelectUI;
    /** @private */
    private var m_modeSelectUI : PlayerModeSelectUI;
    /** @private */
    private var m_bPVP : Boolean;
    /** @private */
    private var m_pViews : ViewStack;
    /** @private */
    private var _selectedID : int;
    /** @private */
    private var _curRoleHeadUI : RoleHeadUI;
    /** @private */
    private var _selectedEffId : int;
    /** @private */
    private var m_pRootContainer : Container;

    /** @private */
    private var m_pAssetsNeeded : Array = [
        "role_select.swf",
        "frameclip_kof.swf",
        "fight.swf",
        "frameclip_roleselect.swf",
        "frameclip_roleshowblue.swf",
        "frameclip_roleshowred.swf",
        "frameclip_xuanfu.swf",
        "frameclip_roleshow_lukaer.swf",
        "frameclip_lukaer.swf",
        "frameclip_fight2.swf",
        "frameclip_hui.swf",
        "frameclip_time.swf"
    ];

    /**
     * Creates a new CPlaySelectViewHandler.
     */
    public function CPlaySelectViewHandler() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        ret = ret && this._loadAssets( initialize );
        return ret;
    }

    override protected function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();
        if ( ret ) {
            this.hide( true );
        }
        return ret;
    }

    private function _loadAssets( pfnFinished : Function = null ) : Boolean {
        var bLoadRequired : Boolean = false;
        for each ( var str : String in m_pAssetsNeeded ) {
            if ( !App.mloader.getResLoaded( str ) ) {
                bLoadRequired = true;
                break;
            }
        }

        if ( bLoadRequired ) {
            App.mloader.loadAssets( m_pAssetsNeeded, new Handler(
                    _loadUIAssetsCompleted, [ pfnFinished ] ), null, null, false );
        }

        if ( !bLoadRequired && null != pfnFinished ) {
            pfnFinished();
        }

        return !bLoadRequired;
    }

    //noinspection JSUnusedLocalSymbols
    private function _loadUIAssetsCompleted( ... args ) : void {
        this.makeStarted();

        if ( args && args.length > 0 && args[ 0 ] is Function ) {
            var callback : Function = args[ 0 ] as Function;
            callback();
        }
    }

    private function createViews() : void {
        if ( !m_playSelectUI ) {
            m_playSelectUI = new RoleSelectUI();
            m_playSelectUI.mask = m_playSelectUI.vewiportMask;
        }

        if ( !m_modeSelectUI ) {
            m_modeSelectUI = new PlayerModeSelectUI();
            m_modeSelectUI.centerX = m_modeSelectUI.centerY = 0;
            m_playSelectUI.btnEnter.disabled = true;
        }

        if ( !m_pRootContainer ) {
            m_pRootContainer = new Container();
            system.stage.flashStage.addChild( m_pRootContainer );
        }

        if ( !m_pViews ) {
            m_pViews = new ViewStack();
            m_pViews.setItems( [
                m_modeSelectUI,
                m_playSelectUI
            ] );

            m_pViews.left = m_pViews.right = m_pViews.top = m_pViews.bottom = 0;
            m_pViews.selectedIndex = 1;
        }
    }

    private function createHandlers() : void {
        var temp : CAbstractHandler = this.getBean( CPlaySelectRoleListLayoutHandler ) as CPlaySelectRoleListLayoutHandler;
        if ( !temp )
            this.addBean( new CPlaySelectRoleListLayoutHandler( m_playSelectUI.listHero ) );
    }

    private function initialize() : void {
        this.createViews();
        this.createHandlers();

        m_playSelectUI.addEventListener( MouseEvent.CLICK, onPlayerSelectEventBusHandler, false, 0, true );
        m_modeSelectUI.addEventListener( MouseEvent.CLICK, onModeSelectEventBusHandler, false, 0, true );

        m_playSelectUI.listHero.dataSource = [];
        m_playSelectUI.listHero.selectHandler = new Handler( listHeroSelectHandler );

        m_playSelectUI.eff_fight.visible = false;
        m_playSelectUI.eff_rolelist.visible = false;
        m_playSelectUI.eff_time.visible = false;
    }

    private function _onSwfCompleted( ... args ) : void {
        m_playSelectUI.mc_role.skin = "frameclip_roleshow_" + _selectedID;
        m_playSelectUI.mc_role.y = m_playSelectUI.box_lightL.y - m_playSelectUI.mc_role.height + 200;
    }

    private function listHeroSelectHandler( idx : int ) : void {
        var pRoleHead : RoleHeadUI = m_playSelectUI.listHero.getCell( idx ) as RoleHeadUI;

        if ( !pRoleHead.dataSource )
            return;

        if ( Boolean( pRoleHead.dataSource.disabled ) )
            return;

        m_playSelectUI.btnEnter.disabled = (idx == -1);
        if ( idx == RANDOM_IDX ) {
            m_playSelectUI.imgRoleLeft.url = null;
        } else if ( idx != -1 ) {
            TweenLite.killTweensOf( m_playSelectUI.imgRoleLeft, true );

            m_playSelectUI.imgRoleLeft.addEventListener( UIEvent.IMAGE_LOADED, _onImgRoleLeftImageLoaded, false, CEventPriority.DEFAULT, true );
            m_playSelectUI.imgRoleLeft.url = "icon/role/roleselect/role_" + (idx + 1) + ".png";

            m_playSelectUI.lblRoleSelectedLeft.text = pRoleHead.dataSource.name;

            if ( _curRoleHeadUI )
                _curRoleHeadUI.mc_selected.visible = false;
            _curRoleHeadUI = m_playSelectUI.listHero.getCell( idx ) as RoleHeadUI;
            _curRoleHeadUI.mc_selected.visible = true;

            m_playSelectUI.mc_role.skin = "";
            _selectedID = idx + 1;
            if ( !App.loader.getResLoaded( "frameclip_roleshow_" + _selectedID + ".swf" ) ) {
                App.loader.loadSWF( "frameclip_roleshow_" + _selectedID + ".swf", new Handler( _onSwfCompleted ), null, null, false );
            }

            effPlayOneTime( m_playSelectUI.mc_selecting_1 );
            effPlayOneTime( m_playSelectUI.mc_selecting_2 );
        }
    }


    private function _onImgRoleLeftImageLoaded( event : UIEvent ) : void {
        event.currentTarget.removeEventListener( event.type, _onImgRoleLeftImageLoaded );

        TweenLite.killTweensOf( m_playSelectUI.imgRoleLeft, true );

        var fCX : Number = m_playSelectUI.imgRoleLeft.centerX;

        m_playSelectUI.imgRoleLeft.centerX -= 600;

        TweenLite.to( m_playSelectUI.imgRoleLeft, 0.35, {
            centerX : fCX
        } );
    }

    private function onModeSelectEventBusHandler( event : MouseEvent ) : void {
        var target : Object = event.target;

        if ( !('name' in target) ) {
            return;
        }

        switch ( target.name ) {
            case 'PVP':
                // selected pvp
                m_pViews.selectedIndex = 1;
                break;
            case 'PVE':
                // selected pve
                m_pViews.selectedIndex = 1;
                break;
        }
    }

    private function onPlayerSelectEventBusHandler( event : MouseEvent ) : void {
        var target : Object = event.target;

        if ( !('name' in target) )
            return;

        switch ( target.name ) {
            case '开始游戏':
                // Enter game.
                selectedEff();
                break;
        }
    }

    private function selectedEff() : void {

        TweenLite.killTweensOf( m_playSelectUI.imgRoleLeft, true );
        //
        m_playSelectUI.listHero.visible =
                m_playSelectUI.box_time.visible =
                        m_playSelectUI.btnEnter.visible =
                                m_playSelectUI.effbtnEnter.visible = false;
        //L
        TweenLite.to( m_playSelectUI.imgRoleLeft, .6, {x : m_playSelectUI.imgRoleLeft.x - 600} );
        TweenLite.to( m_playSelectUI.lblRoleSelectedLeft, .5, {
            delay : .15,
            x : m_playSelectUI.lblRoleSelectedLeft.x - 600
        } );
        TweenLite.to( m_playSelectUI.box_lightL, .5, {delay : .15, x : m_playSelectUI.box_lightL.x - 600} );
        TweenLite.to( m_playSelectUI.box_lightL2, .5, {delay : .15, x : m_playSelectUI.box_lightL2.x - 600} );
        TweenLite.to( m_playSelectUI.mc_role, .5, {delay : .15, x : m_playSelectUI.mc_role.x - 600} );
        //R
        TweenLite.to( m_playSelectUI.FCRoleR, .6, {x : m_playSelectUI.FCRoleR.x + 600} );
        TweenLite.to( m_playSelectUI.lblRoleSelectedRight, .5, {
            delay : .15,
            x : m_playSelectUI.lblRoleSelectedRight.x + 600
        } );
        TweenLite.to( m_playSelectUI.box_lightR, .5, {delay : .15, x : m_playSelectUI.box_lightR.x + 600} );
        TweenLite.to( m_playSelectUI.box_lightR2, .5, {delay : .15, x : m_playSelectUI.box_lightR2.x + 600} );
        TweenLite.to( m_playSelectUI.mc_roleR, .5, {delay : .15, x : m_playSelectUI.mc_roleR.x + 600} );
        //eff
        effPlayOneTime( m_playSelectUI.eff_fight );
        effPlayOneTime( m_playSelectUI.eff_rolelist );
        effPlayOneTime( m_playSelectUI.eff_time );

        delayCall( 1, requestSelected );

    }

    private function requestSelected() : void {
        TweenLite.killTweensOf( m_playSelectUI.imgRoleLeft, true );
        TweenLite.killTweensOf( m_playSelectUI.lblRoleSelectedLeft, true );
        TweenLite.killTweensOf( m_playSelectUI.box_lightL, true );
        TweenLite.killTweensOf( m_playSelectUI.box_lightL2, true );
        TweenLite.killTweensOf( m_playSelectUI.mc_role, true );
        TweenLite.killTweensOf( m_playSelectUI.FCRoleR, true );
        TweenLite.killTweensOf( m_playSelectUI.lblRoleSelectedRight, true );
        TweenLite.killTweensOf( m_playSelectUI.box_lightR, true );
        TweenLite.killTweensOf( m_playSelectUI.box_lightR2, true );
        TweenLite.killTweensOf( m_playSelectUI.mc_roleR, true );

        var requestObject : Object = CObjectUtils.extend( {
            pvp : m_bPVP
        }, m_playSelectUI.listHero.selectedItem );

        dispatchEvent( new Request( EVT_START_GAME, false, false, requestObject ) );
    }

    private function effPlayOneTime( frameClip : FrameClip ) : void {
        frameClip.addEventListener( UIEvent.FRAME_CHANGED, onChanged );
        frameClip.gotoAndPlay( 0 );
        frameClip.visible = true;
        function onChanged() : void {
            if ( frameClip.frame >= frameClip.totalFrame - 1 ) {
                frameClip.removeEventListener( UIEvent.FRAME_CHANGED, onChanged );
                frameClip.stop();
                frameClip.visible = false;
            }
        }
    }

    override protected virtual function enterSystem( system : CAppSystem ) : void {
        super.enterSystem( system );

        this.invalidateData();

        var audio : IAudio = system.stage.getSystem( IAudio ) as IAudio;
        if ( audio )
            audio.playMusic( CAudioConstants.SELECT_ROLE, int.MAX_VALUE, 0, 0, 1 );
    }

    public function get roleID() : int {
        return int( m_playSelectUI.listHero.selectedItem.id );
    }

    public function show() : void {
        this.invalidate();
        this.callLater( _addDisplay );
    }

    private function _addDisplay() : void {
        if ( m_pRootContainer ) {
            m_pRootContainer.addChild( m_pViews );

            system.stage.flashStage.addEventListener( Event.RESIZE, _onStageResize, false, 0, true );
        } else {
            system.stage.flashStage.addChild( m_pViews );
        }
    }


    private function _onStageResize( event : Event ) : void {
        if ( m_pRootContainer ) {
            m_pRootContainer.x = m_pRootContainer.y = 0;
            m_pRootContainer.width = system.stage.flashStage.stageWidth;
            m_pRootContainer.height = system.stage.flashStage.stageHeight;
        }
    }

    public function hide( removed : Boolean = true ) : void {
        if ( !m_pViews )
            return;

        if ( removed )
            m_pViews.remove();
        else
            m_pViews.visible = false;

        if ( m_pRootContainer )
            system.stage.flashStage.removeEventListener( Event.RESIZE, _onStageResize );
    }

    override protected virtual function updateData() : void {
        super.updateData();

        var pConfigData : Array = null;
        var pConfigDataHandler : CPlaySelectConfigHandler = system.getBean( CPlaySelectConfigHandler );
        if ( pConfigDataHandler ) {
            pConfigData = pConfigDataHandler.configData;
        }

        var idx : int = 0;
        var arrProfessions : Array = [];
        var nRoleNum : int = pConfigData.length;// Math.min( m_playSelectUI.listHero.repeatX * m_playSelectUI.listHero.repeatY, 39 );
        for ( ; idx < nRoleNum; ++idx ) {
            var id : int = idx + 1;
            var name : String = "Role_" + id.toString();
            var disabled : Boolean = true;
            var icon : String = null;

            if ( idx != RANDOM_IDX ) {
                disabled = false;
            }

            if ( pConfigData ) {
                var pConfigItem : Object = pConfigData[ idx ];
                if ( pConfigItem ) {
                    id = pConfigItem.RoleID;
                    name = pConfigItem.RoleName;
                    disabled = !pConfigItem.Enable;

                    icon = iconURI + "role_" + id.toString() + '.jpg';
                }
            }

            arrProfessions.push( {
                id : id,
                name : name,
                disabled : disabled,
                icon : icon
            } );
        }

        m_playSelectUI.listHero.dataSource = arrProfessions;
    }

    override protected virtual function updateDisplay() : void {
        super.updateDisplay();

        var len : int = m_playSelectUI.listHero.array.length;

        for ( var i : int = 0; i < len; ++i ) {
            var pItemDataSource : Object = m_playSelectUI.listHero.array[ i ];
            if ( pItemDataSource && pItemDataSource.hasOwnProperty( 'id' ) && pItemDataSource.hasOwnProperty( 'disabled' ) ) {
                if ( !pItemDataSource.disabled ) {
                    m_playSelectUI.listHero.selectedIndex = i;
                    break;
                }
            }
        }
    }

}
}

import flash.events.MouseEvent;

import kof.framework.CViewHandler;
import kof.login.CPlaySelectViewHandler;
import kof.ui.demo.RoleHeadUI;

import morn.core.components.Component;
import morn.core.components.List;
import morn.core.handlers.Handler;

/**
 * 角色列表布局控制器
 *
 * @author Jeremy (jeremy@qifun.com)
 */
class CPlaySelectRoleListLayoutHandler extends CViewHandler {

    // x & y offset table.
    private static var s_listRoleHeadOffset : Array = [
        [ 2, 0 ], [ 0, -3 ], [ 0, -6 ], [ 0, -11 ], [ 0, -19 ], [ 0, -11 ], [ 0, -6 ], [ 0, -3 ], [ -2, 0 ],
        [ 1, 0 ], [ 0, -1 ], [ 0, -2 ], [ 0, -2 ], [ 0, -7 ], [ 0, -2 ], [ 0, -2 ], [ 0, -1 ], [ -1, 0 ],
        [ 1, -2 ], [ 0, 0 ], [ 0, 2 ], [ 0, 2 ], [ 0, 7 ], [ 0, 2 ], [ 0, 2 ], [ 0, 0 ], [ -1, -2 ],
        [ 2, -6 ], [ 0, 0 ], [ 0, 6 ], [ 0, 11 ], [ 0, 19 ], [ 0, 11 ], [ 0, 6 ], [ 0, 0 ], [ -2, -6 ],
        [ 2, -6 ], [ 0, 0 ], [ 0, 6 ], [ 0, 11 ], [ 0, 19 ], [ 0, 11 ], [ 0, 6 ], [ 0, 0 ], [ -2, -6 ],
        [ 2, -6 ], [ 0, 0 ], [ 0, 6 ], [ 0, 11 ], [ 0, 19 ], [ 0, 11 ], [ 0, 6 ], [ 0, 0 ], [ -2, -6 ],
        [ 328, 27 ], [ 328, 44 ], [ 343, 27 ]
    ];

    private var m_fScale : Number = 1;

    /**
     * @private
     */
    private var m_pList : List;

    /**
     * Creates a new CPlaySelectRoleListLayoutHandler.
     */
    public function CPlaySelectRoleListLayoutHandler( list : List ) {
        super();
        this.m_pList = list;
    }

    override public function dispose() : void {
        super.dispose();

        m_pList = null;
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        if ( m_pList ) {
            m_pList.renderHandler = new Handler( renderProfessionSlot );
            m_pList.mouseHandler = new Handler( listHeroMouseHandler );
        }

        return ret;
    }

    public function get list() : List {
        return m_pList;
    }

    public function get spaceScaleXY() : Number {
        return m_fScale;
    }

    public function set spaceScaleXY( value : Number ) : void {
        m_fScale = value;
    }

    public function get randomIndex() : int {
        return CPlaySelectViewHandler.RANDOM_IDX;
    }

    private function renderProfessionSlot( item : Component, idx : int ) : void {
        if ( !(item is RoleHeadUI) ) {
            return;
        }

        item.visible = item.dataSource;

        if ( !item.visible )
            return;

        var pRoleHead : RoleHeadUI = item as RoleHeadUI;

        if ( idx == randomIndex ) {
            pRoleHead.visible = false;
        } else {
            pRoleHead.imgHead.url = pRoleHead.dataSource.icon;
        }
        var nOffsetX : Number = 0;
        var nOffsetY : Number = 0;

        if ( idx < s_listRoleHeadOffset.length ) {
            nOffsetX = s_listRoleHeadOffset[ idx ][ 0 ];
            nOffsetY = s_listRoleHeadOffset[ idx ][ 1 ];

            var nColIdx : int = idx % 9;
            if ( nColIdx < 3 ) {
                nOffsetX -= 49 * m_fScale;
            }
            else if ( nColIdx > 5 ) {
                nOffsetX += 49 * m_fScale;
            }

            pRoleHead.x += nOffsetX * m_fScale;
            pRoleHead.y += nOffsetY * m_fScale;
        }
        setDefaultRoleHeadIndex( pRoleHead, idx );
        pRoleHead.disabled = false;

        pRoleHead.imgDisabled.visible = Boolean( pRoleHead.dataSource.disabled );
    }

    private static function setDefaultRoleHeadIndex( comp : Component, idx : int ) : void {
        var nColIdx : int = idx % 9;
        if ( nColIdx >= 5 ) {
            nColIdx = 9 - nColIdx;
        }
        comp.parent.setChildIndex( comp, nColIdx );
    }

    private function listHeroMouseHandler( e : MouseEvent, idx : int ) : void {
        var pRoleHead : RoleHeadUI = m_pList.getCell( idx ) as RoleHeadUI;

        if ( !pRoleHead.dataSource )
            return;

        if ( Boolean( pRoleHead.dataSource.disabled ) )
            return;
        if ( pRoleHead ) {
            if ( e.type == MouseEvent.ROLL_OVER ) {
                // ObjectUtils.addFilter(comp, s_glowFilter );
                // pop up.
                pRoleHead.parent.setChildIndex( pRoleHead, pRoleHead.parent.numChildren - 1 );
                pRoleHead.mc_roll.visible = true;
            } else if ( e.type == MouseEvent.ROLL_OUT ) {
                // ObjectUtils.clearFilter( comp, GlowFilter );
                // set default index.
                setDefaultRoleHeadIndex( pRoleHead, idx );
                pRoleHead.mc_roll.visible = false;
            }
        }
    }

}

// vi:ft=as3 tw=0

