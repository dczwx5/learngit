//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/6/14.
 */
package kof.game.vip {

import flash.geom.Point;

import kof.SYSTEM_ID;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CFlyItemUtil;
import kof.game.common.CItemUtil;
import kof.game.common.CLang;
import kof.game.common.CRewardUtil;
import kof.game.common.CSystemRuleUtil;
import kof.game.common.view.CTweenViewHandler;
import kof.game.common.view.CViewExternalUtil;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.part.CRewardItemListView;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.player.CPlayerSystem;
import kof.game.player.event.CPlayerEvent;
import kof.game.vip.event.CVIPEvent;
import kof.table.Item;
import kof.table.VipLevel;
import kof.table.VipPrivilege;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.master.Vip.VipUI;

import morn.core.components.Box;

import morn.core.components.Button;
import morn.core.components.Component;

import morn.core.components.Dialog;
import morn.core.components.View;

import morn.core.handlers.Handler;


public class CVIPViewHandler extends CTweenViewHandler {

    private var m_bViewInitialized:Boolean;
    private var m_vipUI:VipUI;

    private var _curSelectVipLv:int;
    private var _curSelectBtn:Button;

    private var _closeHandler:Handler;

    private var m_viewExternal:CViewExternalUtil;

    public function CVIPViewHandler() {
        super( false );
    }

    override public function get viewClass() : Array {
        return [ VipUI ];
    }

    override protected function get additionalAssets() : Array
    {
        return ["frameclip_itemEffect_small.swf"];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized ) {
            this.initialize();
        }

        return m_bViewInitialized;
    }

    protected function initialize() : void {
        if ( !m_vipUI ) {
            m_vipUI = new VipUI();
            m_vipUI.btn_close.clickHandler = new Handler( _close );

            m_vipUI.box_buy.visible = false;
            m_vipUI.box_gift.visible = false;

            m_vipUI.btn_cz.clickHandler = new Handler( _onCzBtnClick );//充值按钮
            m_vipUI.btn_buy.clickHandler = new Handler( _onBuyGiftBtnClick );//购买礼包按钮

            m_vipUI.btn_get.clickHandler = new Handler( _onGetFreeGiftClick );//领取免费vip礼包

            m_vipUI.btn_getEverydayReward.clickHandler = new Handler( _onGetEverydayReward );//领取每日礼包

            var btn:Button = null;
            for(var i:int = 0 ; i < 15; i++){
                btn = m_vipUI["btn_vip" + (i+1)] as Button;
                btn.clickHandler = new Handler( _onTabBtnClick, [btn] );
            }

//            m_vipUI.list_reward.renderHandler = new Handler( _onRenderRewardItem );//礼包列表
            m_vipUI.list_reward.renderHandler = new Handler( CItemUtil.getItemRenderFunc(system) );//礼包列表
            m_vipUI.list_gift.renderHandler = new Handler( _onRenderRewardItem );//免费礼包列表

            m_viewExternal = new CViewExternalUtil(CRewardItemListView, this, m_vipUI);

            CSystemRuleUtil.setRuleTips(m_vipUI.img_tips, CLang.Get("VIP_tips"));

            m_bViewInitialized = true;
        }
    }

    public function addDisplay() : void {
        this.loadAssetsByView( viewClass, _addToDisplay );
    }

    private function _addToDisplay() : void {

        if ( onInitializeView() ) {
            invalidate();

            if ( m_vipUI )
            {
//                uiCanvas.addDialog( m_vipUI );
                setTweenData(KOFSysTags.VIP);
                showDialog(m_vipUI);

                _addEventListener();
            }

        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }


    }
    public function removeDisplay() : void {
        closeDialog(_removeDisplayB);
    }
    private function _removeDisplayB() : void {
        if ( m_vipUI ) {
            _removeEventListener();
        }
    }

    public function set closeHandler( value:Handler ):void {
        _closeHandler = value;
    }


    override protected virtual function updateData():void {
        super.updateData();

        if ( m_vipUI ) {

            updateVipInfo();

            var curVipLv:int = playSystem.playerData.vipData.vipLv;
            var index:int = 1;
            if(curVipLv <= 0){
                index = 1;
            }else{
                index = curVipLv;
            }
            _onTabBtnClick(m_vipUI["btn_vip"+index]);
        }

    }

    /**
     * 更新界面vip信息显示数据
     */
    private function updateVipInfo():void {
        if ( m_vipUI ) {

            var curVipLv:int = playSystem.playerData.vipData.vipLv;
            var nextLv:int = curVipLv + 1;
            if(nextLv>15)nextLv=15;
            var vipLvTable:VipLevel = vipManager.getNextVipLevelTableByID(nextLv);
            var curExp:Number = playSystem.playerData.vipData.vipExp;

            var maxVipLv:int = vipManager.getVipMaxLv();
            if( curVipLv >= maxVipLv ){
                //如果达到最高vip等级
                m_vipUI.box_viptxt.visible = false;
                m_vipUI.lb_max.visible = true;

                m_vipUI.clip_vipLv.index = maxVipLv;
            }else{
                m_vipUI.box_viptxt.visible = true;
                m_vipUI.lb_max.visible = false;

                m_vipUI.clip_vipLv.index = curVipLv;

                m_vipUI.txt_cz.text = "" + (vipLvTable.diamond-curExp);
                m_vipUI.txt_vip.text = "VIP" + nextLv;
                m_vipUI.clipVIP.index = nextLv;

            }

            m_vipUI.txt_pro.text = curExp + "/" + vipLvTable.diamond;
            m_vipUI.progress_vip.value = curExp / vipLvTable.diamond;
        }
    }

    private function _onTabBtnClick( btn:Button ):void {

        if( _curSelectBtn ){
            _curSelectBtn.selected = false;
        }

        _curSelectBtn = btn;
        _curSelectBtn.selected = true;

        var vipLv:int = int(btn.name);
        _curSelectVipLv = vipLv;

        m_vipUI.clip_vipprivi.num = _curSelectVipLv;
        m_vipUI.clip_vipgift.num = _curSelectVipLv;


        var vipPri:VipPrivilege = vipManager.getVipPriTableByID( _curSelectVipLv );
        if( vipPri ){
            m_vipUI.txt_dic.text = vipPri.info;

            m_vipUI.img_iconbig.skin = vipPri.pic1;
            m_vipUI.img_iconsmall1.skin = vipPri.pic2;
            m_vipUI.img_iconsmall2.skin = vipPri.pic3;
        }

        //特权列表
        var vipLvTable:VipLevel = vipManager.getVipLevelTableByID( _curSelectVipLv );
        if( vipLvTable ){

            m_vipUI.txt_oldPrice.text = "" + vipLvTable.originalPrice;
            m_vipUI.txt_curPrice.text = "" + vipLvTable.currentPrice;

            var itemTable:Item = getItemTableByID( vipLvTable.gift );
            if( itemTable ){
                var rewardData:CRewardListData = CRewardUtil.createByDropPackageID( vipSysTem.stage, int(itemTable.param2) );
                if( rewardData ){
                    m_vipUI.list_reward.dataSource = rewardData.list;
                }
            }

            if(vipLvTable.reward > 0){
//                var itemTable1:Item = getItemTableByID( vipLvTable.reward );
//                if( itemTable1 ){
                    var freeRewardData:CRewardListData = CRewardUtil.createByDropPackageID( vipSysTem.stage, vipLvTable.reward );
                    if( freeRewardData ){
                        m_vipUI.list_gift.dataSource = freeRewardData.list;
                    }
//                }
            }
            //每日奖励
            m_viewExternal.show();
            ( m_viewExternal.view as CRewardItemListView ).forceAlign = 1;
            ( m_viewExternal.view as CRewardItemListView ).updateLayout();
            m_viewExternal.setData( vipLvTable.everydayReward );
            m_viewExternal.updateWindow();

            _onUpdateEverydayreward();


        }

        _onUpdateBuyState();
        _onUpdateFreeRewardState();
    }

    /**
     * 礼包道具数据
     * @param item
     * @param index
     */
    private function _onRenderRewardItem( item:RewardItemUI,index:int ):void {
        if( item == null || item.dataSource == null )return;
        var itemData:CRewardData = item.dataSource as CRewardData;
        if (!itemData) return ;
        item.num_lable.text = itemData.num.toString();
        item.icon_image.url = itemData.iconSmall;
        item.bg_clip.index = itemData.quality;
        item.box_eff.visible = itemData.effect;
        item.clip_eff.autoPlay = itemData.effect;
        item.toolTip = new Handler(_addTips, [item]);
        item.hasTakeImg.visible = false;
    }

    private function _addTips(item:RewardItemUI) : void {
        var itemSystem:CItemSystem = vipSysTem.stage.getSystem(CItemSystem) as CItemSystem;
        itemSystem.addTips(CItemTipsView, item);
    }

    /**
     * 点击充值按钮
     */
    private function _onCzBtnClick():void {
        var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
        var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
        bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
    }

    /**
     * 点击购买礼包按钮
     */
    private function _onBuyGiftBtnClick():void {
        var vipLv:int = _curSelectVipLv;
        vipHandler.onBuyVipGiftRequestHandler( vipLv );

        var vipLvTable:VipLevel = vipManager.getVipLevelTableByID( _curSelectVipLv );
        var cost:int = vipLvTable == null ? 0 : vipLvTable.currentPrice;
        var haveDiamond : int = playSystem.playerData.currency.blueDiamond;

        //钻石不足的时候，弹出充值界面
        if ( cost > haveDiamond ) {
            var bundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            var systemBundle : ISystemBundle = bundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.PAY ) );
            bundleCtx.setUserData( systemBundle, CBundleSystem.ACTIVATED, true );
        }
    }

    /**
     * 更新特权礼包购买状态
     * @param e
     */
    private function _onUpdateBuyState( e:CVIPEvent = null ):void {
        //特权礼包是否已经购买
        if( vipManager.isBuyGift(_curSelectVipLv) ){
            m_vipUI.btn_buy.visible = false;
            m_vipUI.box_buy.visible = true;
        }else{
            m_vipUI.btn_buy.visible = true;
            m_vipUI.box_buy.visible = false;

            var curVipLv:int = playSystem.playerData.vipData.vipLv;
            if( curVipLv >= _curSelectVipLv){
                m_vipUI.btn_buy.disabled = false;
            }else{
                m_vipUI.btn_buy.disabled = true;
            }
        }
    }

    private function _onGetFreeGiftClick():void{
        var vipLv:int = _curSelectVipLv;
        vipHandler.onGetFreeVipGiftRequestHandler( vipLv );
    }
    private function _onGetEverydayReward():void{
        var vipLv:int = _curSelectVipLv;
        vipHandler.onVipEverydayRewardRequestHandler( vipLv );
    }

    public function flyItem():void
    {
        var items:Vector.<Box> = m_vipUI.list_gift.cells;
        var len:int = items.length;
        var itemUI:RewardItemUI = null;
        for(var i:int=0; i<len; i++) {
            itemUI = items[ i ] as RewardItemUI;
            if(itemUI.dataSource){
                CFlyItemUtil.flyItemToBag(itemUI, itemUI.localToGlobal(new Point()), system);
            }
        }
    }

    private function _onUpdateFreeRewardState( e:CVIPEvent = null ):void {
        //免费礼包
        var vipLvTable:VipLevel = vipManager.getVipLevelTableByID( _curSelectVipLv );
        if(vipLvTable.reward > 0){
            m_vipUI.box_gift.visible = true;
            if( vipManager.isGetFreeGift(_curSelectVipLv) ){
                m_vipUI.btn_get.label = "已领取";
                m_vipUI.btn_get.disabled = true;
            }else{
                var curVipLv:int = playSystem.playerData.vipData.vipLv;
                if( curVipLv >= _curSelectVipLv){
                    m_vipUI.btn_get.disabled = false;
                }else{
                    m_vipUI.btn_get.disabled = true;
                }
                m_vipUI.btn_get.label = "免费领取";
            }
        }else{
            m_vipUI.box_gift.visible = false;
        }
    }
    private function _onUpdateEverydayreward( evt : CVIPEvent = null ):void{
        if( evt ){
            if( m_vipUI.reward_list.item_list.dataSource ){
                var len:int = m_vipUI.reward_list.item_list.dataSource.length;
                for(var i:int = 0; i < len; i++)
                {
                    var item:Component =  m_vipUI.reward_list.item_list.getCell(i) as Component;
                    CFlyItemUtil.flyItemToBag(item, item.localToGlobal(new Point()), system);
                }
            }
        }

        m_vipUI.img_redPoint.visible = false;
        if( _curSelectVipLv > playSystem.playerData.vipData.vipLv ){
            m_vipUI.btn_getEverydayReward.label = '等级未到';
            m_vipUI.btn_getEverydayReward.disabled = true;
            m_vipUI.btn_getEverydayReward.visible = true;
        }else if( _curSelectVipLv == playSystem.playerData.vipData.vipLv ){
            if( vipManager.isGetEverydayReward( _curSelectVipLv )){
                m_vipUI.btn_getEverydayReward.label = '已领取';
                m_vipUI.btn_getEverydayReward.disabled = true;
            }else if( playSystem.playerData.vipData.vipEverydayReward.length > 0 ){
                m_vipUI.btn_getEverydayReward.label = '领取';
                m_vipUI.btn_getEverydayReward.disabled = true;
            } else{
                m_vipUI.btn_getEverydayReward.label = '领取';
                m_vipUI.btn_getEverydayReward.disabled = false;
                m_vipUI.img_redPoint.visible = true;
            }
            m_vipUI.btn_getEverydayReward.visible = true;
        }else if( _curSelectVipLv < playSystem.playerData.vipData.vipLv ){
            m_vipUI.btn_getEverydayReward.visible = false;
        }
    }

    private function _onPlayerDataHandler(evt : CPlayerEvent ):void{
        _onUpdateEverydayreward();
        _onUpdateBuyState();
        updateVipInfo();
    }

    private function _addEventListener() : void {
        system.addEventListener(CVIPEvent.VIP_BUYGIFT,_onUpdateBuyState);
        system.addEventListener(CVIPEvent.VIP_GET_FREE_GIFT,_onUpdateFreeRewardState);
        system.addEventListener(CVIPEvent.VIP_GET_EVERYDAYREWARD,_onUpdateEverydayreward);
        playSystem.addEventListener( CPlayerEvent.PLAYER_VIP_LEVEL ,_onPlayerDataHandler);
        playSystem.addEventListener( CPlayerEvent.PLAYER_VIP ,_onPlayerDataHandler);

    }

    private function _removeEventListener() : void {
        system.removeEventListener(CVIPEvent.VIP_BUYGIFT,_onUpdateBuyState);
        system.removeEventListener(CVIPEvent.VIP_GET_FREE_GIFT,_onUpdateFreeRewardState);
        system.removeEventListener(CVIPEvent.VIP_GET_EVERYDAYREWARD,_onUpdateEverydayreward);
        playSystem.removeEventListener( CPlayerEvent.PLAYER_VIP_LEVEL ,_onPlayerDataHandler);
        playSystem.removeEventListener( CPlayerEvent.PLAYER_VIP ,_onPlayerDataHandler);
    }

    private function _close():void{
        if(_closeHandler){
            _closeHandler.execute();
        }
    }

    private function get vipSysTem() : CVIPSystem {
        return system as CVIPSystem;
    }

    private function get vipManager() : CVIPManager {
        return system.getBean( CVIPManager ) as CVIPManager;
    }

    private function get vipHandler() : CVIPHandler {
        return system.getBean( CVIPHandler ) as CVIPHandler;
    }

    private function get playSystem() : CPlayerSystem {
        return system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
    }

    private function get uiSysTem() : CUISystem {
        return system.stage.getSystem(CUISystem) as CUISystem;
    }

    public function getItemTableByID(id:int) : Item{
        var itemTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.ITEM);
        return itemTable.findByPrimaryKey(id);
    }




}
}
