//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2017/12/11.
 */
package kof.game.weiClient {

import QFLib.Utils.CFlashVersion;

import flash.events.MouseEvent;
import flash.geom.Point;
import flash.net.URLRequest;
import flash.net.navigateToURL;

import kof.framework.CViewHandler;
import kof.game.KOFSysTags;
import kof.game.common.CFlyItemUtil;
import kof.game.common.CRewardUtil;
import kof.game.common.view.CTweenViewHandler;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.ui.imp_common.ItemUIUI;
import kof.ui.master.weiClient.WeiClientViewUI;

import morn.core.components.Component;

import morn.core.components.Dialog;

import morn.core.handlers.Handler;

public class CWeiClientViewHandler extends CTweenViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:WeiClientViewUI;
    private var m_pCloseHandler : Handler;
    public function CWeiClientViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array {
        return [ WeiClientViewUI ];
    }

    override protected function get additionalAssets() : Array
    {
        return ["frameclip_item2.swf"];
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
                m_pViewUI = new WeiClientViewUI();
                m_pViewUI.closeHandler = new Handler(_onCloseHandler);
                m_bViewInitialized = true;

                m_pViewUI.list_reward.renderHandler = new Handler( _onRenderItem );//礼包列表

                var rewardData:CRewardListData = CRewardUtil.createByDropPackageID( system.stage, playerData.playerConstant.MicroClientReward );
                if( rewardData ){
                    m_pViewUI.list_reward.dataSource = rewardData.list;
                }

                m_pViewUI.btn_downLoading.visible = CFlashVersion.isDesktop() ? false : true;
                m_pViewUI.btn_get.visible = CFlashVersion.isDesktop() ? true : false;
            }
        }

        return m_bViewInitialized;
    }

    private function _onRenderItem(box:Component, idx:int) : void {
        var item:ItemUIUI = box as ItemUIUI;
        if (item == null) return ;

        if (item.dataSource == null) {
            item.visible = false;
            return ;
        }
        item.visible = true;
        var itemData:CRewardData = item.dataSource as CRewardData;
        if (!itemData) return ;
//        item.txt_num.visible = _isShowItemCount;
        item.txt_num.text = itemData.num.toString();
        item.img.url = itemData.iconBig;
        item.clip_bg.index = itemData.quality;
        item.toolTip = new Handler(_addTips, [item]);

        item.clip_effect.visible = itemData.effect;
        if (item.clip_effect.visible) {
            item.clip_effect.autoPlay = true;
            item.circle_effect.play();
        } else {
            item.clip_effect.autoPlay = false;
            item.circle_effect.stop();
        }
    }

    public function flyItem():void
    {
        var len:int = m_pViewUI.list_reward.dataSource.length;
        for(var i:int = 0; i < len; i++)
        {
            var item:Component =  m_pViewUI.list_reward.getCell(i) as Component;
            CFlyItemUtil.flyItemToBag(item, item.localToGlobal(new Point()), system);
        }
    }

    private function _addTips(item:Component) : void {
        var itemSystem:CItemSystem = system.stage.getSystem(CItemSystem) as CItemSystem;
        itemSystem.addTips(CItemTipsView, item);
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
        setTweenData(KOFSysTags.WEI_CLIENT);
        showDialog(m_pViewUI, false, _addToDisplayB);
    }
    private function _addToDisplayB() : void {
        if ( m_pViewUI ){
            m_pViewUI.btn_downLoading.addEventListener(MouseEvent.CLICK, _onClick);
            m_pViewUI.btn_get.addEventListener(MouseEvent.CLICK, _onGetClick);
        }
    }

    private function _onGetClick(e:MouseEvent):void{
        (system.getHandler(CWeiClientHandler) as CWeiClientHandler).sendMicroClientRewardRequest();
    }

    private function _onClick(e:MouseEvent):void{
        var urlStr:String = system.stage.configuration.getString( 'external.wdUrl', system.stage.configuration.getString( 'wdUrl' ) );
        var url:URLRequest = new URLRequest(urlStr);
        navigateToURL(url,"_blank");
    }
    public function removeDisplay() : void {
        closeDialog(_removeDisplayB);
    }
    private function _removeDisplayB() : void {
        if ( m_pViewUI ) {
            m_pViewUI.btn_downLoading.removeEventListener(MouseEvent.CLICK, _onClick);
            m_pViewUI.btn_get.removeEventListener(MouseEvent.CLICK, _onGetClick);
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

    private function get playerData() : CPlayerData
    {
        var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
        return playerManager.playerData;
    }
}
}
