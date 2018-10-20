//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/3/9.
 */
package kof.game.yyWeChat.view {

import flash.events.MouseEvent;

import kof.SYSTEM_ID;
import kof.framework.CViewHandler;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundleContext;
import kof.game.platform.EPlatformType;
import kof.game.platform.data.CPlatformBaseData;
import kof.game.player.CPlayerSystem;
import kof.game.yyWeChat.CYYWeChatHelpHandler;
import kof.game.yyWeChat.CYYWeChatManager;
import kof.game.yyWeChat.CYYWeChatNetHandler;
import kof.game.yyHall.data.CYYRewardData;
import kof.game.yyHall.view.CYYHallViewHandler;
import kof.ui.CUISystem;
import kof.ui.platform.yy.YYCodeUI;

import morn.core.components.Dialog;

import morn.core.handlers.Handler;

public class CYYWeChatViewHandler extends CViewHandler {
    private var m_bViewInitialized : Boolean;
    private var m_pViewUI : YYCodeUI;
    private var m_pCloseHandler : Handler;
     public function CYYWeChatViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }
    override protected function onSetup() : Boolean
    {
        var ret : Boolean = super.onSetup();

        return ret;
    }



    override public function get viewClass() : Array
    {
        return [YYCodeUI];
    }

    override protected function get additionalAssets():Array
    {
        return [];
    }


    override protected function onInitializeView() : Boolean
    {
        if ( !super.onInitializeView() )
        {
            return false;
        }

        if ( !m_bViewInitialized )
        {
            if ( !m_pViewUI )
            {
                m_pViewUI = new YYCodeUI();//创建UI实例
                m_pViewUI.btn_receive.clickHandler = new Handler(_onTakeNewHandler);//领取奖励
                m_pViewUI.closeHandler = new Handler( _onClose );
                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function addDisplay() : void
    {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void
    {
        if ( onInitializeView() )
        {
//            invalidate();
            callLater( _addToDisplay );
        }
        else
        {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _addToDisplay() : void
    {
        uiCanvas.addDialog( m_pViewUI );

//        _initView();
        _addListeners();
    }


    private function _addListeners():void
    {
        m_pViewUI.txt_num.addEventListener( MouseEvent.CLICK, _onClickSerialNumberHandler);
    }

    private function _removeListeners():void
    {
        m_pViewUI.txt_num.removeEventListener( MouseEvent.CLICK, _onClickSerialNumberHandler);
    }


    private function _onClickSerialNumberHandler(e:MouseEvent):void
    {
        if(m_pViewUI.txt_num.text == "输入序列号")
        {
            m_pViewUI.txt_num.text = "";
        }
    }


    private function _onTakeNewHandler():void
    {
        //发送微信礼包激活码
      (system.getBean( CYYWeChatNetHandler ) as CYYWeChatNetHandler).serialNumberRequest( m_pViewUI.txt_num.text );
    }


    public function removeDisplay() : void
    {
        if ( m_bViewInitialized )
        {
            _removeListeners();

            if ( m_pViewUI && m_pViewUI.parent )
            {
                m_pViewUI.close( Dialog.CLOSE );
            }

         }
    }

    private function _onClose( type : String ) : void
    {
        switch ( type )
        {
            default:
                if ( this.closeHandler )
                {
                    this.closeHandler.execute();
                }
                break;
        }
    }
//property=============================================================================================================
    public function get closeHandler() : Handler
    {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void
    {
        m_pCloseHandler = value;
    }

    private function get _uiSystem():CUISystem
    {
        return system.stage.getSystem(CUISystem) as CUISystem;
    }

    private function get _helper():CYYWeChatHelpHandler
    {
        return system.getHandler(CYYWeChatHelpHandler) as CYYWeChatHelpHandler;
    }

    private function get _manager():CYYWeChatManager
    {
        return system.getHandler(CYYWeChatManager) as CYYWeChatManager;
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    override public function dispose():void
    {
        super.dispose();

        m_pViewUI = null;
        m_pCloseHandler  = null;
     }

}
}
