//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Demi.Liu on 2018-06-01.
 */
package kof.game.redPacket {

import com.greensock.TweenMax;
import com.greensock.TweenMax;

import flash.events.MouseEvent;

import kof.SYSTEM_ID;


import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.common.CItemUtil;
import kof.game.common.CLang;
import kof.game.common.view.CTweenViewHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.redPacket.data.CRedPacketInfo;
import kof.message.FighterTreasure.OpenRedEnvelopeResponse;
import kof.message.FighterTreasure.WholeServerRedEnvelopeResponse;
import kof.ui.CUISystem;
import kof.ui.master.redPacket.RedPacketUI;

import morn.core.handlers.Handler;

/**
 *@author Demi.Liu
 *@data 2018-06-01
 */
public class CRedPacketViewHandler extends CTweenViewHandler {

    private var viewUI : RedPacketUI;

    private var m_bViewInitialized : Boolean;

    private var m_pCloseHandler : Handler;

    private var m_pData : CRedPacketInfo;

    public function CRedPacketViewHandler() {
        super( false );
    }

    override public function dispose() : void {
        super.dispose();

        viewUI.mc_open.stop();
        removeDisplay();
        viewUI = null;
    }

    override public function get viewClass() : Array {
        return [ RedPacketUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized ) {
            if ( !viewUI ) {
                viewUI = new RedPacketUI();
                viewUI.closeHandler = new Handler( _onClose );
                m_bViewInitialized = true;

                viewUI.img_mask.cacheAsBitmap = true;
                viewUI.box_moveImg.cacheAsBitmap = true;
                viewUI.box_moveImg.mask = viewUI.img_mask;
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
            callLater( _addToDisplay );
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _addToDisplay():void{
        if ( viewUI && !viewUI.parent ) {
            setTweenData(KOFSysTags.RED_PACKET);
            showDialog(viewUI);
        }

        _addEventListeners();
        _initView();
    }

    private function _onClose( type : String ) : void {
        switch ( type ) {
            default:
                if ( this.closeHandler ) {
                    this.closeHandler.execute();
                }
                break;
        }

        viewUI.mc_open.stop();
        _removeEventListeners();
        if(!m_pData.isOpen){//如果红包未打开，关闭视为领取奖励
            _onOpenClickHandler();
        }

        m_pData = null;
        _redPacketManager.redPacketInfo = null;
    }

    private function _addEventListeners():void{
        viewUI.mc_open.addEventListener(MouseEvent.CLICK, _onOpenClickHandler);
        system.addEventListener(CRedPacketEvent.openRedPacketResponse, _openRedPacketHandler);
    }

    private function _removeEventListeners():void{
        viewUI.mc_open.removeEventListener(MouseEvent.CLICK, _onOpenClickHandler);
        system.removeEventListener(CRedPacketEvent.openRedPacketResponse, _openRedPacketHandler);
    }

    /**打开红包*/
    private function _onOpenClickHandler(e:MouseEvent = null):void {
        _redPacketHandler.onOpenRedEnvelopeRequest(m_pData.envelopeId);
    }

    /**打开红包响应*/
    private function _openRedPacketHandler(e:CRedPacketEvent):void{
        m_pData.isOpen = true;

        viewUI.mc_open.playFromTo(null,null,new Handler(_openRedPacketMc));
        viewUI.box_close.alpha = 0;
        viewUI.box_playerInfo.alpha = 0;
        viewUI.box_content1.visible = false;
    }

    /**打开动画效果*/
    private function _openRedPacketMc():void{
        TweenMax.delayedCall( 0.2, function () : void {
            TweenMax.to( viewUI.box_playerInfo, 0.5, {y : 17, alpha : 1} );
        });
        TweenMax.to(viewUI.box_close,0.5,{alpha:1});
        TweenMax.to(viewUI.img_moveUp, 1,{y: -200});
        TweenMax.to(viewUI.img_moveDown, 0.5,{y: 390});
        viewUI.mc_open.visible = false;

        // 头像
        var _playerData:CPlayerData = (system.stage.getSystem( CPlayerSystem ) as CPlayerSystem).playerData;
        var iconRender:Function = CItemUtil.getBigItemRenderByHeroDataFunc(system);
        viewUI.role_icon_view.dataSource = _playerData.teamData.useHeadID;
        iconRender(viewUI.role_icon_view, 0);
        viewUI.txt_name.text = _playerData.teamData.name;

        var openRedPacketInfo:OpenRedEnvelopeResponse = _redPacketManager.openRedPacketInfo;
        //promptId提示码, 0：成功，1：红包已领完 2：等级限制 3：红包不存在 4:红包重复领取
        switch (openRedPacketInfo.promptId) {
            case 0:
                viewUI.box_content2.visible = true;
                viewUI.box_content2.alpha = 0;
                TweenMax.to(viewUI.box_content2,0.5,{alpha:1});
                viewUI.txt_money.text = openRedPacketInfo.rewards[0].count;
                viewUI.hBox_money.x = viewUI.box_playerInfo.x - (viewUI.hBox_money.width - viewUI.box_playerInfo.width)/2;
                break;
            case 1:
                viewUI.box_content3.visible = true;
                viewUI.box_content3.alpha = 0;
                TweenMax.to(viewUI.box_content3,0.5,{alpha:1});
                break;
            case 2:
                var obj:Object = {v1:m_pData.levelLimit};
                viewUI.label_hint.text = CLang.Get("redPacket_opentRedPacket_msg_1",obj)

                viewUI.box_content4.visible = true;
                viewUI.box_content4.alpha = 0;
                TweenMax.to(viewUI.box_content4,0.5,{alpha:1});
                break;
            case 3:
                viewUI.box_content3.visible = true;
                viewUI.box_content3.alpha = 0;
                TweenMax.to(viewUI.box_content3,0.5,{alpha:1});
                break;
            case 4:
                _onClose("close");
                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert(CLang.Get("redPacket_opentRedPacket_msg_2"));

        }
    }

    public function removeDisplay() : void {
        closeDialog(function():void{
            //关闭界面的过程是一个缓动动画，所以延迟调用
            TweenMax.delayedCall(0.4,showNewRedPacket)
        });
    }

    private function showNewRedPacket():void{
        if(_redPacketManager.redPacketInfoListLength > 0){
            var pBundle:ISystemBundle = (system as CBundleSystem).ctx.getSystemBundle(SYSTEM_ID(KOFSysTags.RED_PACKET));
            (system as CBundleSystem).ctx.setUserData(pBundle, CBundleSystem.ACTIVATED, true);
        }
    }

    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }

    /**初始化界面*/
    private function _initView():void{
        viewUI.box_content1.visible = true;
        viewUI.box_content2.visible = false;
        viewUI.box_content3.visible = false;
        viewUI.box_content4.visible = false;

        viewUI.mc_open.visible = true;
        viewUI.mc_open.gotoAndStop(0);
        viewUI.img_moveUp.y = 1;
        viewUI.img_moveDown.y = 0;
        viewUI.box_playerInfo.y = 37;

        m_pData = _redPacketManager.redPacketInfo;

        // 头像
        var iconRender:Function = CItemUtil.getBigItemRenderByHeroDataFunc(system);
        viewUI.role_icon_view.dataSource = m_pData.headId;
        iconRender(viewUI.role_icon_view, 0);
        viewUI.txt_name.text = m_pData.roleName;
        viewUI.txt_amountMoney.text = m_pData.amount.toString();
    }

    private function get _redPacketHandler():CRedPacketHandler{
        return system.getBean(CRedPacketHandler) as CRedPacketHandler;
    }

    private function get _redPacketManager():CRedPacketManager{
        return system.getBean(CRedPacketManager) as CRedPacketManager;
    }
}
}
