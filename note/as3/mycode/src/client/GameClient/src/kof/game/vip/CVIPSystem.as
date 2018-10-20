//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/6/14.
 */
package kof.game.vip {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.lobby.CLobbySystem;
import kof.game.lobby.view.CLobbyViewHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.event.CPlayerEvent;
import kof.game.vip.event.CVIPEvent;
import kof.game.vip.view.CVIPBiliTipsView;
import kof.game.vip.view.CVIPDamenTipsView;

import morn.core.handlers.Handler;

/**
 * VIP系统
 */
public class CVIPSystem extends CBundleSystem implements ISystemBundle {

    private var m_bInitialized : Boolean;
    private var _vipManager : CVIPManager;
    private var _vipHandler : CVIPHandler;
    private var _vipViewHandler : CVIPViewHandler;
    private var _vipBiliTipsViewHandler : CVIPBiliTipsView;
    private var _vipDamenTipsViewHandler : CVIPDamenTipsView;

    public static const VIP_LEVEL_6:int = 6;
    public static const VIP_LEVEL_10:int = 10;

    public function CVIPSystem() {
        super();
    }

    override public function dispose() : void {
        super.dispose();

        _removeEventListener();
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        if ( !m_bInitialized ) {
            m_bInitialized = true;

            this.addBean( _vipManager = new CVIPManager() );
            this.addBean( _vipHandler = new CVIPHandler());
            this.addBean( _vipViewHandler = new CVIPViewHandler());
            this.addBean( _vipBiliTipsViewHandler = new CVIPBiliTipsView());
            this.addBean( _vipDamenTipsViewHandler = new CVIPDamenTipsView());
        }

        var vipView : CVIPViewHandler = this.getBean( CVIPViewHandler );
        vipView.closeHandler = new Handler( _onViewClosed );

        this._addEventListener();

        return m_bInitialized;
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.VIP );
    }

    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pView : CVIPViewHandler = this.getHandler( CVIPViewHandler ) as CVIPViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CRankingViewHandler isn't instance." );
            return;
        }

        if ( value ) {
            pView.addDisplay();
        } else {
            pView.removeDisplay();
        }
    }

    private function _addEventListener() : void {
        (stage.getSystem( CPlayerSystem ) as CPlayerSystem ).addEventListener(CPlayerEvent.PLAYER_VIP_LEVEL,_onPlayerDataUpdate);
        this.addEventListener(CVIPEvent.VIP_GET_EVERYDAYREWARD,updateVipRedIcon);
    }

    private  function _removeEventListener() : void {
        (stage.getSystem( CPlayerSystem ) as CPlayerSystem ).removeEventListener(CPlayerEvent.PLAYER_VIP_LEVEL,_onPlayerDataUpdate);
    }

    private function _onPlayerDataUpdate( e : CPlayerEvent ) : void {
        updateVipRedIcon();
    }

    private function updateVipRedIcon(e : CVIPEvent = null):void{
        var pLobbySystem:CLobbySystem = stage.getSystem( CLobbySystem ) as CLobbySystem;
        var pLobbyViewHandler:CLobbyViewHandler = pLobbySystem.getBean(CLobbyViewHandler) as CLobbyViewHandler;
        var lvl : int = (stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.vipData.vipLv;
        if(pLobbyViewHandler.pMainUI){
            pLobbyViewHandler.pMainUI.headView.vipRedIcon.visible = !vipManager.isGetEverydayReward(lvl);
        }
    }

    public function showTips():void{
//        var myVipLv:int = vipManager.playSystem.playerData.vipData.vipLv;
//        if(vipManager.isGetFreeGift(VIP_LEVEL_6) && vipManager.isGetFreeGift(VIP_LEVEL_10)){
//            return;
//        }
//        if(myVipLv < VIP_LEVEL_6){
//            _vipBiliTipsViewHandler.showTips();
//        }else if(myVipLv >= VIP_LEVEL_6){
//            _vipDamenTipsViewHandler.showTips();
//        }
    }

    private function _onViewClosed() : void {
        this.setActivated( false );
    }

    public function get vipManager() : CVIPManager {
        return getHandler( CVIPManager ) as CVIPManager;
    }

}
}
