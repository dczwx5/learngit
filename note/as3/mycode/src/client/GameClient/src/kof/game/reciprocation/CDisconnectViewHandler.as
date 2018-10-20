//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.reciprocation {

import flash.events.Event;

import kof.framework.CViewHandler;
import kof.framework.CStandaloneApp;
import kof.framework.IApplication;
import kof.ui.app.disconnect.DisconnectViewUI;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

/**
 * 连接断开提示
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CDisconnectViewHandler extends CViewHandler {

    private var m_pUI : DisconnectViewUI;

    /** Creates a new CDisconnectViewHandler.  */
    public function CDisconnectViewHandler() {
        super( true ); // load view by default to call onInitializeView
    }

    override public function dispose() : void {
        super.dispose();

        if ( m_pUI ) {
            m_pUI.remove();
        }
        m_pUI = null;
    }

    override public function get viewClass() : Array {
        return [ DisconnectViewUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        m_pUI = m_pUI || new DisconnectViewUI;

        m_pUI.lblMessage.text = "您与服务器的连接已断开，请重新登录！";
        m_pUI.lblTitle.text = "连接断开";

        m_pUI.closeHandler = new Handler( _onUICloseHandler );

        return Boolean( m_pUI );
    }

    private function _onUICloseHandler( type : String ) : void {
        switch ( type ) {
            case Dialog.OK:
            case Dialog.CANCEL:
            case Dialog.NO:
            case Dialog.SURE:
            case Dialog.YES:
            case Dialog.CLOSE:
            default:
                // make application restart.
                var pApplication : IApplication = system.stage.getBean( IApplication ) as IApplication;
                if ( pApplication ) {
                    pApplication.eventDispatcher.dispatchEvent( new Event( CStandaloneApp.RESTART ) );
                }
                break;
        }
    }

    override protected function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();
        if ( !ret )
            return false;

        if ( m_pUI )
            m_pUI.remove();

        return ret;
    }

    public function show() : void {
        uiCanvas.addAppPrompt( m_pUI );

        _updateDisconnectInfo();
    }

    private function _updateDisconnectInfo():void
    {
        if(m_sDisconnectReason)
        {
            m_pUI.lblMessage.text = m_sDisconnectReason;
        }
        else
        {
            m_pUI.lblMessage.text = "您与服务器的连接已断开，请重新登录！";
        }
    }

    public function hide() : void {
        if ( m_pUI )
            m_pUI.remove();

        m_sDisconnectReason = "";
    }

    private var m_sDisconnectReason:String;
    public function set disconnectReason(reason:String):void
    {
        m_sDisconnectReason = reason;
        _updateDisconnectInfo();
    }

}
}

// vim:ft=as3 tw=0 sw=4 ts=4 et
