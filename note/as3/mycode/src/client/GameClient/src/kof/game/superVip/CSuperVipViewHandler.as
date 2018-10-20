//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2017/12/1.
 */
package kof.game.superVip {

import flash.desktop.Clipboard;
import flash.desktop.ClipboardFormats;

import kof.SYSTEM_ID;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CLang;
import kof.game.common.view.CTweenViewHandler;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.event.CPlayerEvent;
import kof.table.OperatorConfig;
import kof.table.SuperVipConfig;
import kof.ui.CUISystem;
import kof.ui.master.superVIP.SuperVipUI;
import morn.core.handlers.Handler;

public class CSuperVipViewHandler extends CTweenViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:SuperVipUI;
    private var m_pCloseHandler : Handler;
    public function CSuperVipViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array {
        return [ SuperVipUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized )
        {
            if ( !m_pViewUI )
            {
                m_pViewUI = new SuperVipUI();
                m_pViewUI.closeHandler = new Handler(_onCloseHandler);
                m_pViewUI.btn_cz.clickHandler = new Handler( _onCzBtnClick );//充值按钮
                m_pViewUI.btn_copyQQ.clickHandler = new Handler( _onCopyClick,["QQ"] );//复制按钮
                m_pViewUI.btn_copyPhone.clickHandler = new Handler( _onCopyClick,["Phone"] );//复制按钮
                m_bViewInitialized = true;
                _playerSystem.addEventListener(CPlayerEvent.PLAYER_VIP, _onDataUpdate);
            }
        }

        return m_bViewInitialized;
    }

    public function addDisplay() : void {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            callLater( addToDisplay );
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }
    protected function addToDisplay() : void {
        setTweenData(KOFSysTags.SUPER_VIP);
        showDialog(m_pViewUI, false, _addToDisplayB);
    }

    protected function _addToDisplayB() : void {
        if ( m_pViewUI ){
            var svConfig:SuperVipConfig = _manager.getConfigByPlatform();
            if(!svConfig) return;
            var operator:OperatorConfig = _manager.getOperatorByID(svConfig.operatorId);
            if(!operator) return;
            m_pViewUI.img_image.url = "icon/supervip/" + operator.imgResource+".png";

            showQQTxt(operator);
            showPhoneTxt(operator);
            showWXQRCode(operator);

        }
    }

    private function _onDataUpdate(e:CPlayerEvent):void{
        var svConfig:SuperVipConfig = _manager.getConfigByPlatform();
        if(!svConfig) return;
        var operator:OperatorConfig = _manager.getOperatorByID(svConfig.operatorId);
        if(!operator) return;
        //m_pViewUI.btn_cz.visible = !_CPlayerData.vipData.superVip;

        showQQTxt(operator);
        showPhoneTxt(operator);
        showWXQRCode(operator);

    }
    private function showQQTxt(operator : OperatorConfig) : void
    {
        var bool : Boolean;
        var single : Number = _CPlayerData.vipData.singleRecharge;
        var total : Number = _CPlayerData.vipData.totalRecharge;
        if(operator.qq)
        {
            if(operator.singleRechargeQQ && !operator.totalRechargeQQ)
            {
                bool = single >= operator.singleRechargeQQ;
            }
            else if(!operator.singleRechargeQQ && operator.totalRechargeQQ)
            {
                bool = total >= operator.totalRechargeQQ;
            }
            else if(operator.singleRechargeQQ && operator.totalRechargeQQ)
            {
                bool = single >= operator.singleRechargeQQ || total >= operator.totalRechargeQQ;
            }
            m_pViewUI.btn_copyQQ.disabled = !bool;
            m_pViewUI.txt_QQ.text = bool ? operator.qq.toString() : "********";
            m_pViewUI.txt_QQContent.text = operator.qqContent;
        }
        else
        {
            m_pViewUI.btn_copyQQ.visible = m_pViewUI.txt_QQ.visible = m_pViewUI.txt_QQContent.visible = false;
        }
    }

    private function showPhoneTxt(operator : OperatorConfig) : void
    {
        var bool : Boolean;
        var single : Number = _CPlayerData.vipData.singleRecharge;
        var total : Number = _CPlayerData.vipData.totalRecharge;
        if(operator.phone)
        {
            if(operator.singleRechargePhone && !operator.totalRechargePhone)
            {
                bool = single >= operator.singleRechargePhone;
            }
            else if(!operator.singleRechargePhone && operator.totalRechargePhone)
            {
                bool = total >= operator.totalRechargePhone;
            }
            else if(operator.singleRechargePhone && operator.totalRechargePhone)
            {
                bool = single >= operator.singleRechargePhone || total >= operator.totalRechargePhone;
            }
            m_pViewUI.btn_copyPhone.disabled = !bool;
            m_pViewUI.txt_Phone.text = bool ? operator.phone.toString() : "********";
            m_pViewUI.txt_PhoneContent.text = operator.phoneContent;
        }
        else
        {
            m_pViewUI.btn_copyPhone.visible = m_pViewUI.txt_Phone.visible = m_pViewUI.txt_PhoneContent.visible = false;
        }
    }

    private function showWXQRCode(operator : OperatorConfig) : void
    {
        var bool : Boolean;
        var single : Number = _CPlayerData.vipData.singleRecharge;
        var total : Number = _CPlayerData.vipData.totalRecharge;
        if(operator.weChatImg)
        {
            if(operator.singleRechargeWeChat && !operator.totalRechargeWeChat)
            {
                bool = single >= operator.singleRechargeWeChat;
            }
            else if(!operator.singleRechargeWeChat && operator.totalRechargeWeChat)
            {
                bool = total >= operator.totalRechargeWeChat;
            }
            else if(operator.singleRechargeWeChat && operator.totalRechargeWeChat)
            {
                bool = single >= operator.singleRechargeWeChat || total >= operator.totalRechargeWeChat;
            }
            m_pViewUI.img_wx_mask.visible = !bool;
            m_pViewUI.img_wx_qrcode.visible = bool;
            m_pViewUI.img_wx_qrcode.url = "icon/superVip/" + operator.weChatImg + ".png";
            m_pViewUI.txt_WXContent.text = operator.weChatContent;
        }
        else
        {
            m_pViewUI.img_wx_mask.visible = m_pViewUI.img_wx_qrcode.visible = m_pViewUI.txt_WXContent.visible = false;
        }
    }
    public function removeDisplay() : void {
        closeDialog(_removeDisplayB);
    }
    private function _removeDisplayB() : void {
        if ( m_pViewUI ) {
            _playerSystem.removeEventListener(CPlayerEvent.PLAYER_VIP, _onDataUpdate);
            m_pViewUI.remove();
        }
    }

    private function _onCloseHandler(type:String = null):void
    {
        if(closeHandler)
        {
            closeHandler.execute();
        }
    }

    /**
     * 复制按钮
     * @param arg
     */
    private function _onCopyClick(...arg):void{
        Clipboard.generalClipboard.clear();
        var result : String = "";
        if(arg && arg[0] == "QQ")
        {
            result = m_pViewUI.txt_QQ.text;
        }
        else
        {
            result = m_pViewUI.txt_Phone.text;
        }

        Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT,result,false);
        (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( "复制成功" );
    }
    /**
     * 点击充值按钮
     */
    private function _onCzBtnClick():void {
        var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
        var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
        bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
    }

    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _CPlayerData() : CPlayerData
    {
        return (_playerSystem.getBean( CPlayerManager ) as CPlayerManager).playerData;
    }
    private function get _manager() : CSuperVipManager
    {
        return _system.getBean( CSuperVipManager ) as CSuperVipManager;
    }
    private function get _system() : CSuperVipSystem
    {
        return system as CSuperVipSystem;
    }
}
}
