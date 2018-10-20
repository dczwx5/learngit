//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.pay {

import flash.external.ExternalInterface;

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.CSystemBundleContext;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.pay.view.CQQOpenAppViewHandler;
import kof.game.platform.EPlatformType;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.util.MESSAGE_ALERT_TIP;
import kof.ui.CMsgAlertHandler;

import morn.core.handlers.Handler;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public class CPaySystem extends CBundleSystem {

    public function CPaySystem() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() ) {
            return false;
        }

        var pViewHandler : CQQOpenAppViewHandler;
        this.addBean( new CPlayConfigData( this ) );
        this.addBean( new CPayHandler() );
        this.addBean( pViewHandler = new CQQOpenAppViewHandler() );

        pViewHandler.closeHandler = new Handler( _onViewClosed );

        return true;
    }

    override protected function onBundleStart( pCtx : ISystemBundleContext ) : void {
        super.onBundleStart( pCtx );
    }

    override protected function onBundleStop( pCtx : ISystemBundleContext ) : void {
        super.onBundleStop( pCtx );
    }

    override protected function onActivated( bActivated : Boolean ) : void {
        super.onActivated( bActivated );

        if ( bActivated ) {//累充返钻
            var bundleCtx : ISystemBundleContext = stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            var systemBundle : ISystemBundle = bundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.RECHARGEREBATE ) );
            var iStateValue : int = bundleCtx.getSystemBundleState( systemBundle );
            if( iStateValue == CSystemBundleContext.STATE_STARTED ){
                bundleCtx.setUserData( systemBundle, CBundleSystem.ACTIVATED, true );
            }
        }

        var playerSystem:CPlayerSystem = stage.getSystem(CPlayerSystem) as CPlayerSystem;
        if ( playerSystem.platform.data.platform == EPlatformType.PLATFORM_TX ) {
            var pViewHandler : CQQOpenAppViewHandler = this.getHandler( CQQOpenAppViewHandler ) as CQQOpenAppViewHandler;
            if ( !pViewHandler )
                return;

            if ( bActivated ) {
                pViewHandler.addDisplay();
            } else {
                pViewHandler.removeDisplay();
            }
        } else {
            if(bActivated) {
                var playerData:CPlayerData = playerSystem.playerData;
                if ( ExternalInterface.available ) {
                    ExternalInterface.call( "goToPay", playerData.ID, playerData.teamData.name );
                } else {
                    MESSAGE_ALERT_TIP( this, "No available case to handle pay!", CMsgAlertHandler.WARNING );
                }

                _onViewClosed();
            }
        }
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.PAY );
    }

    private function _onViewClosed() : void {
        this.setActivated( false );
    }

}
}
