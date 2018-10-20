//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/12.
 */
package kof.game.im {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.im.view.CIMChatInputViewHandler;
import kof.game.im.view.CIMChatViewHandler;

import morn.core.handlers.Handler;

public class CIMChatSystem extends CBundleSystem{

    private var m_bInitialized : Boolean;

    private var _imChatViewHandler : CIMChatViewHandler;

    private var _iMChatInputViewHandler : CIMChatInputViewHandler;

    private var _isRequestFriendData : Boolean;

    public function CIMChatSystem() {
        super();
    }
    override public function dispose() : void {
        super.dispose();
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        var pView : CIMChatViewHandler;
        if ( !m_bInitialized ) {
            m_bInitialized = true;

            this.addBean( _imChatViewHandler = new CIMChatViewHandler() );
            this.addBean( _iMChatInputViewHandler = new CIMChatInputViewHandler() );
        }

        _imChatViewHandler.closeHandler = new Handler( _onViewClosed );

        _pIMSystem.addEventListener( CIMEvent.FRIENDINFO_LIST_RESPONSE ,_onFriendDataReturn );

        return m_bInitialized;
    }
    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.FRIEND_CHAT );
    }

    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pView : CIMChatViewHandler = this.getHandler( CIMChatViewHandler ) as CIMChatViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CRankingViewHandler isn't instance." );
            return;
        }

        if ( value ) {
            _isRequestFriendData = true;
            _pIMHandler.onFriendInfoListRequest();
        } else {
            _isRequestFriendData = false;
            pView.removeDisplay();
        }
    }
    private function _onFriendDataReturn( evt : CIMEvent ):void{
        var pView : CIMChatViewHandler = this.getHandler( CIMChatViewHandler ) as CIMChatViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CRankingViewHandler isn't instance." );
            return;
        }
        if( _isRequestFriendData ){
            pView.addDisplay();
            _isRequestFriendData = false;
        }
    }

    private function _onViewClosed() : void {
        this.setActivated( false );
    }

    private function get _pIMSystem():CIMSystem{
        return stage.getSystem( CIMSystem ) as CIMSystem
    }
    private function get _pIMHandler():CIMHandler{
        return _pIMSystem.getBean( CIMHandler ) as CIMHandler
    }

}
}
