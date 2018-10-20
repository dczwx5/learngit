//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/9/13.
 * 用于左上角图标的系统
 */
package kof.game.bargainCard {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.lobby.CLobbySystem;
import kof.game.lobby.view.CPlayerHeadViewHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.event.CPlayerEvent;

import morn.core.handlers.Handler;

public class CBuyMonthCardSystem extends CBundleSystem implements ISystemBundle {
    public var mainView : CBargainCardView;
    public var manager : CBargainCardManager;
    public var netHandler : CBargainCardNetHandler;

    public function CBuyMonthCardSystem() {
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.BUY_MONTH_CARD );
    }

    override public function dispose() : void {
        super.dispose();
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;
        var ret : Boolean = super.initialize();
        ret = ret && addBean( mainView = new CBargainCardView() );
        ret = ret && addBean( manager = new CBargainCardManager() );
        ret = ret && addBean( netHandler = new CBargainCardNetHandler() );
        mainView.closeHandler = new Handler( _onViewClosed );
        _playerSystem.addEventListener( CPlayerEvent.PLAYER_MONTH_AND_WEEK_CARD, _updateData );
        return ret;
    }

    override protected function onBundleStart( pCtx : ISystemBundleContext ) : void {
        var playerHead : CPlayerHeadViewHandler = stage.getSystem( CLobbySystem ).getBean( CPlayerHeadViewHandler ) as CPlayerHeadViewHandler;
        playerHead.invalidateData();
    }


    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );
        if ( value ) {
            mainView.addDisplay();
        }
        else {
            mainView.removeDisplay();
        }
    }
    protected function _updateData( e : CPlayerEvent ) : void {
        if ( e.type == CPlayerEvent.PLAYER_MONTH_AND_WEEK_CARD )
        {
            if(mainView.isOpen)//刷新界面
            {
                netHandler.onCardMonthInfoRequest();
            }
        }
    }
    private function get _playerSystem() : CPlayerSystem {
        return stage.getSystem( CPlayerSystem ) as CPlayerSystem
    }
    private function _onViewClosed() : void {
        this.setActivated( false );
        var bundleCtx : ISystemBundleContext = stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var iStateValue : int = bundleCtx.getSystemBundleState( bundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.BARGAINCARD ) ) );
        if(iStateValue)
        {
            _bargainCardSystem.onViewClosed();

        }

    }

    public function onActivatedCallBack(value : Boolean): void
    {
        super.onActivated( value );
    }
    private function get _bargainCardSystem() : CBargainCardSystem
    {
        return stage.getSystem(CBargainCardSystem) as CBargainCardSystem;
    }
}
}
