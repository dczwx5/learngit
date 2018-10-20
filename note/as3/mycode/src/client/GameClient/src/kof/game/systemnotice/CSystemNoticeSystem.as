//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/2/21.
 */
package kof.game.systemnotice {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundleContext;
import kof.game.instance.CInstanceSystem;
import kof.game.lobby.CLobbySystem;
import kof.game.lobby.view.CLobbyViewHandler;

import morn.core.components.Box;

public class CSystemNoticeSystem extends CBundleSystem {

    private var _pCSystemNoticeViewHandler : CSystemNoticeViewHandler;
    private var _activityNoticeViewHandler : CActivitySmallIconViewHandler;

    private var m_bInitialized : Boolean;

    public function CSystemNoticeSystem() {
        super();
    }
    override public function dispose() : void {
        super.dispose();

        _pCSystemNoticeViewHandler.dispose();
        _activityNoticeViewHandler.dispose();
    }
    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        var pView : CSystemNoticeViewHandler;
        if ( !m_bInitialized ) {
            m_bInitialized = true;

            this.addBean( _pCSystemNoticeViewHandler = new CSystemNoticeViewHandler() );
            this.addBean( _activityNoticeViewHandler = new CActivitySmallIconViewHandler() );
        }

        return m_bInitialized;
    }

    override protected function onBundleStart(ctx:ISystemBundleContext):void
    {
        super.onBundleStart(ctx);

        _activityNoticeViewHandler.addDisplay();
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.SYSTEM_NOTICE );
    }
    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pView : CSystemNoticeViewHandler = this.getHandler( CSystemNoticeViewHandler ) as CSystemNoticeViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CRankingViewHandler isn't instance." );
            return;
        }

        var argsArr : * = ctx.getUserData( this, CBundleSystem.NOTICE_ARGS, false );
//        var argsArrI : * = ctx.getUserData( this, CBundleSystem.TAB, false );

        if ( value ) {
            ( stage.getSystem( CInstanceSystem ) as CInstanceSystem ).callWhenInMainCity( showSystemNoticeHandler,[argsArr[0]],null,null,1);
        } else {
            pView.removeDisplay();
        }
    }

    private function showSystemNoticeHandler( data : String):void{
//        var actView:CActivitySmallIconViewHandler = getHandler(CActivitySmallIconViewHandler) as CActivitySmallIconViewHandler;
//        if(actView && !actView.isViewShow)
//        {
//            actView.addDisplay();
//        }

        var pView : CSystemNoticeViewHandler = this.getHandler( CSystemNoticeViewHandler ) as CSystemNoticeViewHandler;
        pView.addDisplay( data );
    }

    private function _onViewClosed() : void {
        this.setActivated( false );
    }

    public function showNotice( type : String , sProperty : String = "activated" ):void{
        _pCSystemNoticeViewHandler.showNotice( type ,sProperty );

        noticeIconResize();
    }

    public function hideIcon( type : String ):void{
        _pCSystemNoticeViewHandler.hideIcon( type );

        noticeIconResize();
    }

    public function noticeIconResize():void {
        var pLobbySystem : CLobbySystem = stage.getSystem( CLobbySystem ) as CLobbySystem;
        var pLobbyViewHandler : CLobbyViewHandler = pLobbySystem.getBean( CLobbyViewHandler ) as CLobbyViewHandler;
        if ( pLobbyViewHandler.pMainUI ) {
            var commonBox : Box = pLobbyViewHandler.pMainUI.view_systemNotice.box_common as Box;
            var actBox : Box = pLobbyViewHandler.pMainUI.view_systemNotice.box_act as Box;
            commonBox.x = actBox.x + actBox.width + 10;

            var noticeBox:Box = pLobbyViewHandler.pMainUI.getChildByName("systemNotice") as Box;
            noticeBox.centerX = 0;
        }
    }
}
}
