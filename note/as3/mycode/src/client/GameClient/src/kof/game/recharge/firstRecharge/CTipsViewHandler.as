//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Burgess on 2017/8/23.
 */
package kof.game.recharge.firstRecharge {

import QFLib.Foundation.CMap;

import flash.events.Event;

import flash.events.MouseEvent;

import kof.SYSTEM_ID;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.hero.CHeroSpriteUtil;
import kof.game.instance.CInstanceSystem;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.event.CPlayerEvent;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.reciprocation.popWindow.EPopWindow;
import kof.table.FirstRechargeTipsConfig;
import kof.ui.CUISystem;
import kof.ui.master.firstRechargetips.firstRechargeTipsUI;

import morn.core.components.Dialog;
import morn.core.components.SpriteBlitFrameClip;
import morn.core.handlers.Handler;

public class CTipsViewHandler extends CViewHandler{
    public function CTipsViewHandler()
    {
        super (false);
    }
    override public function dispose() : void {
        super.dispose();
        m_pUI = null;
        m_mapAwakeTips.clear();
        m_mapAwakeTips = null;
        m_pUI.removeEventListener(Event.REMOVED_FROM_STAGE, _hideHero);
        _removeListeners();
        unschedule(_update);
    }

    private var m_pUI : firstRechargeTipsUI;
    private var m_bViewInitialized : Boolean;
    private var m_pCloseHandler : Handler;
    private var m_mapAwakeTips : CMap;
    private var m_fCountDownTime : Number;
    private var m_pFrameClip : SpriteBlitFrameClip;

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        _storeConfigInfo();
        system.stage.getSystem( CPlayerSystem ).addEventListener( CPlayerEvent.PLAYER_LEVEL_UP, _levelPromote );
        return ret;
    }

    override public function get viewClass() : Array {
        return [ firstRechargeTipsUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        onInitializeView();
    }
    public function get isViewShow():Boolean
    {
        if(m_pUI && m_pUI.parent)
        {
            return true;
        }

        return false;
    }
    override protected function onInitializeView() : Boolean
    {
        if ( !super.onInitializeView() )
        {
            return false;
        }

        if ( !m_bViewInitialized )
        {
            if ( !m_pUI )
            {
                m_pUI = new firstRechargeTipsUI();
                m_pUI.closeHandler = new Handler( _onClose );
                m_bViewInitialized = true;
                m_pFrameClip =  m_pUI.clipCharacter_2 as SpriteBlitFrameClip;
                m_pUI.addEventListener(Event.REMOVED_FROM_STAGE, _hideHero);
            }
        }

        return m_bViewInitialized;
    }

    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }

    private function _onClose(type : String) : void
    {
        if ( this.closeHandler )
        {
            this.closeHandler.execute();
        }
        var pReciprocalSystem:CReciprocalSystem = (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem);
        if(pReciprocalSystem){
            pReciprocalSystem.removeEventPopWindow( EPopWindow.POP_WINDOW_17 );
        }
    }

    public function show() : void
    {
        this.loadAssetsByView( viewClass, _showTips );
        _addListeners();
    }

    private function _update(deltaTime : Number) : void
    {
        m_fCountDownTime -= deltaTime;
        if (m_fCountDownTime < 0)
        {
            removeDisplay();
            m_fCountDownTime = 0;
            unschedule(_update);
        }
    }

    public function showActiveTips(countDownTime : int = 0) : void
    {
        var pSystemBundleContext : ISystemBundleContext = system.stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        var pSystemBundle : ISystemBundle = pSystemBundleContext.getSystemBundle( SYSTEM_ID(KOFSysTags.FIRST_RECHARGE) );
        if ( pSystemBundleContext && pSystemBundle)
        {
            if (pSystemBundleContext.getSystemBundleState(pSystemBundle) == 1)
            {
                if (countDownTime != 0)
                {
                    m_fCountDownTime = countDownTime;
                }
                addDisplay();
            }
        }
    }

    public function addDisplay() : void {
        this.loadAssetsByView( viewClass, _showDisplay );
        _addListeners();
    }

    protected function _showTips() : void {
        _showDisplay( true );
    }

    protected function _showDisplay( tips : Boolean = false ) : void
    {
        if ( onInitializeView() )
        {
            _attachHeroByID(108);

            invalidate();
            var pReciprocalSystem:CReciprocalSystem = (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem);
            if(pReciprocalSystem){
                pReciprocalSystem.addEventPopWindow( EPopWindow.POP_WINDOW_17,function():void{
                    callLater( _addToDisplay, tips  );
                } );
            }
        }
        else
        {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _addToDisplay( tips : Boolean = false ) : void
    {
        if ( tips ) {
            m_pUI.x = m_pUI.y = 0;
            App.tip.addChild( m_pUI );
            this.system.stage.flashStage.dispatchEvent( new MouseEvent( MouseEvent.MOUSE_MOVE ));
        } else
            uiCanvas.addDialog( m_pUI );

        schedule(1, _update);
    }

    private function _levelPromote(e : CPlayerEvent) : void
    {
        if (m_mapAwakeTips.find( playerData.teamData.level))
        {
            m_fCountDownTime = m_mapAwakeTips[ playerData.teamData.level];
            if (m_fCountDownTime < -0.09)
            {
                m_fCountDownTime = 100000;
            }
            var instanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
            if(instanceSystem)
            {
                instanceSystem.callWhenInMainCity(showActiveTips,[m_fCountDownTime],null,null,1);
            }
            m_mapAwakeTips.remove(playerData.teamData.level);
        }
    }

    private function _addListeners():void
    {
        if (m_pUI)
            m_pUI.addEventListener(MouseEvent.CLICK, _onClickHandler);
    }

    public function removeDisplay() : void
    {
        if(m_bViewInitialized)
        {
            _removeListeners();

            if (m_pUI && m_pUI.parent)
            {
                m_pUI.close(Dialog.CLOSE);

            }
        }

        var pReciprocalSystem:CReciprocalSystem = (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem);
        if(pReciprocalSystem){
            pReciprocalSystem.removeEventPopWindow( EPopWindow.POP_WINDOW_17 );
        }
    }
    private function _removeListeners():void
    {
        if (m_pUI)
            m_pUI.removeEventListener(MouseEvent.CLICK, _onClickHandler);
        if(m_mapAwakeTips.length<=0){
            system.stage.getSystem( CPlayerSystem ).removeEventListener( CPlayerEvent.PLAYER_LEVEL_UP, _levelPromote );
        }
    }

    private function _onClickHandler(e:MouseEvent):void
    {

        if( e.target == m_pUI.btn_recharge)
        {
            var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
            var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
            bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);

            removeDisplay();
        }
        else if ( e.target == m_pUI.btn_close)
        {
            this.closeHandler.execute();
            removeDisplay();
        }

    }

    private function _storeConfigInfo() : void
    {

        var configArray:Array = _getRechargeConfigInfo();
        if(configArray)
        {
            m_mapAwakeTips = new CMap();
            var count : int = configArray.length;
            var config : FirstRechargeTipsConfig;
            for (var i : int = 0; i < count; ++i)
            {
                config = configArray[i] as FirstRechargeTipsConfig;
                m_mapAwakeTips.add(config.level, config.continueTime);
            }
        }
    }

    private function _getRechargeConfigInfo() : Array
    {
        var table:IDataTable = (system.stage.getSystem(CDatabaseSystem) as IDatabase).getTable(KOFTableConstants.FirstRechargeTips);
        if(table)
        {
            return table.toArray();
        }

        return null;
    }
    private function get playerData() : CPlayerData {
        var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
        return playerManager.playerData;
    }

    private function _attachHeroByID(heroID : int) : void
    {
        var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
        var playerData : CPlayerData = playerManager.playerData;
        var heroData : CPlayerHeroData = playerData.heroList.getHero(heroID);

        CHeroSpriteUtil.setSkin( system.stage.getSystem( CUISystem ) as CAppSystem, m_pFrameClip, heroData, false, "Skill_14", true );
    }
    private function _hideHero(e : Event) : void
    {
        CHeroSpriteUtil.setSkin( system.stage.getSystem( CUISystem ) as CAppSystem, m_pFrameClip, null, false);

        var pReciprocalSystem:CReciprocalSystem = (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem);
        if(pReciprocalSystem){
            pReciprocalSystem.removeEventPopWindow( EPopWindow.POP_WINDOW_17 );
        }
    }

}
}
