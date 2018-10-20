//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.pay {

import QFLib.Foundation;

import flash.external.ExternalInterface;

import kof.SYSTEM_ID;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.CSystemHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.events.CEventPriority;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.pay.view.CQQOpenAppViewHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.event.CPlayerEvent;
import kof.game.vip.CVIPManager;
import kof.game.vip.CVIPSystem;
import kof.table.VipLevel;

/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CPayHandler extends CSystemHandler implements IPayViewMediator {

    /** Creates a new CPayHandler */
    public function CPayHandler() {
        super();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        if ( ret ) {
            var vPlayerSystem : CPlayerSystem = this.system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
            if ( vPlayerSystem ) {
                vPlayerSystem.addEventListener( CPlayerEvent.PLAYER_DATA, playerSystem_dataEventHandler, false,
                        CEventPriority.DEFAULT, true );
            }
        }

        return ret;
    }

    private function playerSystem_dataEventHandler( event : CPlayerEvent ) : void {
        this.updateViewData();
    }

    override protected function enterSystem( aSystem : CAppSystem ) : void {
        super.enterSystem( aSystem );
        this.updateViewData();
    }

    protected function updateViewData() : void {
        var pViewHandler : CQQOpenAppViewHandler = system.getHandler( CQQOpenAppViewHandler ) as CQQOpenAppViewHandler;
        if ( !pViewHandler )
            return;

        // Fill the product item.
        var pDB : IDatabase = system.stage.getSystem( IDatabase ) as IDatabase;
        if ( pDB ) {
            var pTable : IDataTable = pDB.getTable( KOFTableConstants.PAY_PRODUCT );
            if ( pTable ) {
                var vDataList : Array = pTable.queryList();
                vDataList.sortOn( "Price", Array.NUMERIC );

                pViewHandler.productItemList = vDataList;
            }
        }

        // Fill the VIP data.
        var vVipSystem : CVIPSystem = system.stage.getSystem( CVIPSystem ) as CVIPSystem;
        var vVipManager : CVIPManager = vVipSystem ? vVipSystem.vipManager : null;

        var vPlayerSystem : CPlayerSystem = system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
        if ( vPlayerSystem ) {
            var vPlayerData : CPlayerData = vPlayerSystem.playerData;
            if ( vPlayerData ) {
                var iMaxVipLevel : int = vVipManager ? vVipManager.getVipMaxLv() : 15;
                var iNextVipLevel : int = Math.min( iMaxVipLevel, vPlayerData.vipData.vipLv + 1 );

                pViewHandler.vipLevel = vPlayerData.vipData.vipLv;
                pViewHandler.vipLevelMax = iMaxVipLevel;
                pViewHandler.vipExp = vPlayerData.vipData.vipExp;
                pViewHandler.vipExpMax = vPlayerData.vipData.vipExp;

                if ( vVipManager ) {
                    var vVipLevel : VipLevel = vVipManager.getNextVipLevelTableByID( iNextVipLevel );
                    pViewHandler.vipExpMax = vVipLevel.diamond;
                }
            }
        }
    }

    public function requestPlatformVIP( type : int ) : void {
        if ( ExternalInterface.available ) {
            try {
                ExternalInterface.call( "createPlatformVIP", type );
            } catch ( e : Error ) {
                Foundation.Log.logErrorMsg( "Create platform VIP error caught: " + e.message );
            }
        }
    }

    public function buyProduct( theProductItem : Object ) : void {
        if ( null == theProductItem )
            return;

        if ( ExternalInterface.available ) {
            try {
                ExternalInterface.call( "pay", theProductItem );
            } catch ( e : Error ) {
                Foundation.Log.logErrorMsg( "Pay for product item [ " + theProductItem.toString() + " ] error caught: " + e.message );
            }
        }
    }

    public function requestVIP() : void {
        var pCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        if ( pCtx ) {
            var pVIPSB : ISystemBundle = pCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.VIP ) );
            if ( pVIPSB ) {
                pCtx.setUserData( pVIPSB, CBundleSystem.ACTIVATED, true );
            }
        }
    }

}
}

// vi:ft=as3 tw=120 sw=4 ts=4 expandtab tw=120
