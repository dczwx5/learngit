//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/5/4.
 */
package kof.game.shop {

import QFLib.Foundation.CTime;
import QFLib.Utils.HtmlUtil;
import QFLib.Utils.StringUtil;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;
import flash.geom.Point;

import kof.SYSTEM_ID;

import kof.framework.CViewHandler;
import kof.framework.events.CEventPriority;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CFlyItemUtil;
import kof.game.common.CLang;
import kof.game.common.view.CTweenViewHandler;
import kof.game.currency.enum.ECurrencyType;
import kof.game.pay.CPaySystem;
import kof.game.pay.CPaySystem;
import kof.game.pay.IPayViewMediator;
import kof.game.pay.IPayViewMediator;
import kof.game.player.CPlayerSystem;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.shop.data.CShopInfoData;
import kof.game.shop.data.CShopItemData;
import kof.game.shop.enum.EShopType;
import kof.game.shop.enum.EShopType;
import kof.game.shop.event.CShopEvent;
import kof.game.shop.view.CShopBuyViewHandler;
import kof.game.shop.view.CShopItemTipsViewHandler;
import kof.game.vip.CVIPManager;
import kof.game.vip.CVIPSystem;
import kof.table.Currency;
import kof.table.Item;
import kof.table.Shop;
import kof.table.ShopItem;
import kof.table.ShopRefresh;
import kof.table.VipPrivilege;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;
import kof.ui.imp_common.ItemUIUI;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.imp_common.ShopItemUI;
import kof.ui.master.shop.MysteryShopUI;
import kof.util.CQualityColor;

import morn.core.components.Box;
import morn.core.components.Button;

import morn.core.components.Button;


import morn.core.handlers.Handler;

public class CShopViewHandler extends CTweenViewHandler {

    private var m_bViewInitialized : Boolean;

    private var m_shopUI:MysteryShopUI;

    private var _closeHandler:Handler;
    private var _curSelectShopId:int;//当前选中的商店ID
    private var _curSelectTab:int;//当前选中的Tab页签
    private var _curSelectShop:CShopInfoData;

    private var _selectIndex:int = 0;//默认选中页签
    private var _shopType:int = 0;
    private var _isShowTx:Boolean = true;

    public function CShopViewHandler() {
        super( false );
    }

    override public function get viewClass() : Array {
        return [ MysteryShopUI, ShopItemUI ];
    }

    override protected function get additionalAssets():Array {
        return ["frameclip_item2.swf"];
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
        if ( !m_shopUI ) {
            m_shopUI = new MysteryShopUI();

            m_shopUI.tab_list.selectHandler = new Handler( _onTabBtnClick );
            m_shopUI.list_item.renderHandler = new Handler( _onRenderItem );
//            m_shopUI.list_item.selectHandler = new Handler( _onSelectItem );
//            m_shopUI.list_item.mouseHandler = new Handler( _onSelectItem );
            m_shopUI.close_btn.clickHandler = new Handler( _close );

            m_shopUI.btn_refresh.clickHandler = new Handler( _onRefreshClick );

            m_shopUI.btnGetBlueDiamond.addEventListener( MouseEvent.CLICK, _onGetBlueDiamond, false, CEventPriority.DEFAULT_HANDLER, true );

            m_bViewInitialized = true;
        }
    }

    private function _addEventListener() : void {
        system.addEventListener(CShopEvent.SHOP_LIST_UPDATE,_onUpdateList);//商店列表更新
        system.addEventListener(CShopEvent.SHOP_ITEM_UPDATE,_onUpdateList);//商店物品更新
    }

    private function _removeEventListener() : void {
        system.removeEventListener(CShopEvent.SHOP_LIST_UPDATE,_onUpdateList);
        system.removeEventListener(CShopEvent.SHOP_ITEM_UPDATE,_onUpdateList);
    }

    private function _onUpdateList(e:CShopEvent) : void {
        if(_shopType > 0){
//            var shopName:String = getShopNameByType(_shopType);
//            var shop:Shop = shopManager.getShopByName(shopName);
//            if(shop){
//                if(shopName) {
//                    m_shopUI.tab_list.labels = shopName;
//                    m_shopUI.tab_list.selectedIndex = 0;
//                    _onTabBtnClick( 0 );
//                }
//            }else{
//                removeDisplay();
//            }
            m_shopUI.tab_list.labels = shopManager.getTabListByType( shopManager.getGroupTypeByType( _shopType ) );
            m_shopUI.tab_list.selectedIndex = _curSelectTab;
            _onTabBtnClick( _curSelectTab );
        }else{
//            m_shopUI.tab_list.labels = shopManager.getTabList();
            m_shopUI.tab_list.labels = shopManager.getTabListByType( 1 );//主界面入口
            m_shopUI.tab_list.selectedIndex = _curSelectTab;
            _onTabBtnClick(_curSelectTab);
        }

        (shopSysTem.getBean( CShopBuyViewHandler ) as CShopBuyViewHandler).hide();//物品更新，关掉购买界面
    }

    /**
     * 显示商店界面
     * @param type 商店类型
     */
    public function addDisplay( type:int = 0, isShowTx:Boolean = true) : void {
        _shopType = type;
        _isShowTx = isShowTx;
        this.loadAssetsByView( viewClass, _addToDisplay );
    }

    private function _addToDisplay() : void {

        if ( onInitializeView() ) {
            invalidate();

            if ( m_shopUI )
            {
//                uiCanvas.addDialog( m_shopUI );
                setTweenData(KOFSysTags.MALL);
                showDialog(m_shopUI,false,_showDialogTweenEnd);

                this.schedule(1,_onCountDown);

                if(_isShowTx){
                    m_shopUI.boxBlueDiamond.visible = true;
                }else{
                    m_shopUI.boxBlueDiamond.visible = false;
                }
                _addEventListener();
            }

        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _showDialogTweenEnd():void {
        if(_shopType > 0){
//            var shopName:String = getShopNameByType(_shopType);
//            if(shopName){
//                m_shopUI.tab_list.labels = shopName;
//            }else{
////                m_shopUI.tab_list.labels = shopManager.getTabList();
//                m_shopUI.tab_list.labels = shopManager.getTabListByType( 1 );
//            }
            m_shopUI.tab_list.labels = shopManager.getTabListByType( shopManager.getGroupTypeByType( _shopType ) );
            var shopName:String = getShopNameByType(_shopType);
            for (var i:int = 0; i < m_shopUI.tab_list.items.length; i++) {
                var pBtn:Button = m_shopUI.tab_list.items[i] as Button;
                if (pBtn) {
                    var btnName:String = pBtn.btnLabel.text;
                    if (shopName == btnName) {
                        _curSelectTab = i;
                        break;
                    }
                }
            }
        }else{
//            m_shopUI.tab_list.labels = shopManager.getTabList();//设置Tab label值（由于页签数量不固定，动态生成页签）
            m_shopUI.tab_list.labels = shopManager.getTabListByType( 1 );//主界面入口
        }
        m_shopUI.tab_list.selectedIndex = _curSelectTab;
        _onTabBtnClick( _curSelectTab );
    }

    public function removeDisplay() : void {
        closeDialog(_removeDisplayB)
    }
    private function _removeDisplayB() : void {
        if ( m_shopUI ) {
            _removeEventListener();
            this.unschedule(_onCountDown);
        }
    }

    public function set closeHandler(value:Handler):void {
        _closeHandler = value;
    }

    private function _onGetBlueDiamond( event : MouseEvent ) : void {
        var vPaySystem : CPaySystem = system.stage.getSystem( CPaySystem ) as CPaySystem;
        if ( vPaySystem ) {
            var vPayMediator : IPayViewMediator = vPaySystem.getHandler( IPayViewMediator ) as IPayViewMediator;
            if ( vPayMediator ) {
                vPayMediator.requestPlatformVIP( 1 );
            }
        }
    }

    private function _onCountDown( delta : Number ):void {
        _updateItemCountDown();
        _updateShopCountDown();
    }

    private function _updateItemCountDown():void {
        if( m_shopUI.list_item.array == null )return;
        if( m_shopUI.list_item.length <= 0 )return;
        var items:Vector.<Box> = m_shopUI.list_item.cells;
        var shopItem:CShopItemData;
        var remainTime:Number;
        for each(var item:Object in items){
            shopItem = item.dataSource as CShopItemData;
            if(!shopItem) break;
            var shopItemTable:ShopItem = shopSysTem.getShopItemTableByID(shopItem.shopItemID);
            //==========modify by Lune 18.06.26 =======================================
            //特惠商店特殊处理倒计时结束，限次文本重置显示，倒计时文本隐藏
            if(shopItemTable.shopID == EShopType.SHOP_TYPE_18)
            {
                var curNum : int = shopItem.currentSellNum;
                if(shopItem.restoreTime > 0)
                {
                    remainTime = shopItem.restoreTime - CTime.getCurrServerTimestamp();
                    if( remainTime > 0 && curNum == 0){
                        item.lab_time.text = CTime.toDurTimeString(remainTime);
                        item.box_time.visible = true;
                        item.lab_xg.visible = false;
                    }else{
                        item.box_time.visible = false;
                        item.lab_xg.visible = true;
                        item.clip_state.visible = false;
                        if(shopItemTable.canBuyCount == 1) curNum = 1;
                        item.lab_xg.text = CLang.LANG_00006 +
                                HtmlUtil.getHtmlText(curNum+"","#ffeddf",13,"SimSun",true) +
                                CLang.LANG_00007 + "("+
                                HtmlUtil.getHtmlText(curNum+"/"+shopItemTable.canBuyCount,"#ffeddf",13,"SimSun",true) +")";
                    }
                }
                else
                {
                    item.box_time.visible = false;
                    item.lab_xg.visible = true;
                    item.clip_state.visible = false;
                    item.lab_xg.text = CLang.LANG_00006 +
                            HtmlUtil.getHtmlText(shopItemTable.canBuyCount+"","#ffeddf",13,"SimSun",true) +
                            CLang.LANG_00007 + "("+
                            HtmlUtil.getHtmlText(shopItemTable.canBuyCount+"/"+shopItemTable.canBuyCount,"#ffeddf",13,"SimSun",true) +")";
                }
                //==========modify by Lune 18.06.26 =======================================
                //倒计时结束，限次文本重置显示，倒计时文本隐藏
            }
            else
            {
                if( shopItem.restoreTime > 0)
                {
                    remainTime = shopItem.restoreTime - CTime.getCurrServerTimestamp();
                    if( remainTime > 0 )
                    {
                        (item as ShopItemUI).lab_time.text = CTime.toDurTimeString(remainTime);
                        item.box_time.visible = true;
                        item.lab_xg.visible = false;
                    }else{
                        item.box_time.visible = false;
                        item.lab_xg.visible = true;
                    }
                }
            }
        }


    }

    private function _updateShopCountDown():void {
        if( _curSelectShop ){
            var shop:Shop = shopManager.getShopTableByID(_curSelectShopId);
            if( shop.type == EShopType.SHOP_TYPE_1 ){
                var remainTime:Number = _curSelectShop.time - CTime.getCurrServerTimestamp();
                m_shopUI.img_remainTime.visible = true;
                m_shopUI.img_k.visible = true;
                m_shopUI.img_nextTime.visible = false;
                m_shopUI.lab_time.text = CTime.toDurTimeString( remainTime );
                m_shopUI.lab_time.visible = true;
            }else{
                m_shopUI.img_remainTime.visible = false;
            }
        }
    }

    /**点击Tab按钮*/
    private function _onTabBtnClick( tabIndex:int ):void {
        _curSelectTab = tabIndex;
        var curBtn:Button = m_shopUI.tab_list.selection as Button;
        var shop:Shop = shopManager.getShopByName(curBtn.label);
        _curSelectShopId = shop.ID;
        _curSelectShop = shopManager.getShopInfoByShopId(shop.ID);

        _updateShopCountDown();

        m_shopUI.list_item.dataSource = shopManager.getShopListByName(curBtn.label);

        m_shopUI.img_role.url = getRoleUrl(shop.role);

        m_shopUI.lab_refresh.visible = m_shopUI.btn_refresh.visible = (shop.refresh == 0?false:true);

        m_shopUI.boxBlueDiamond.visible = false;
        m_shopUI.lab_ms_main.visible = false;
        m_shopUI.box_icon_main.visible = false;

        if(shop.currencyType == 0){
            //如果货币类型为0，不显示
            m_shopUI.lab_ms.visible = false;
            m_shopUI.box_icon.visible = false;
        }else{
            if ( shop.currencyType == EShopType.SHOP_TYPE_3 && shop.type ==  EShopType.SHOP_TYPE_2 ) {
                if(_isShowTx){
                    m_shopUI.boxBlueDiamond.visible = true;
                }
                m_shopUI.lab_ms.visible = false;
                m_shopUI.box_icon.visible = false;
                m_shopUI.lab_ms_main.visible = true;
                m_shopUI.box_icon_main.visible = true;
            } else {
                m_shopUI.lab_ms.visible = true;
                m_shopUI.box_icon.visible = true;
            }

            var currencyTable:Currency = shopSysTem.getCurrencyTableByID(shop.currencyType);
            if(currencyTable){
                m_shopUI.img_icon.url = shopSysTem.getIconPath(currencyTable.source);
                m_shopUI.img_icon_main.url = shopSysTem.getIconPath(currencyTable.source);
                m_shopUI.lab_money.text = playSystem.playerData.currency.getValueByType( currencyTable.ID ) + "";
                m_shopUI.lab_money_main.text = playSystem.playerData.currency.getValueByType( currencyTable.ID ) + "";
            }
            m_shopUI.lab_ms.text = currencyTable.name + ":" + shop.currencyDesc;
            m_shopUI.lab_ms_main.text = currencyTable.name + ":" + shop.currencyDesc;
        }

//        if(_curSelectShop.time <= 0){
//            m_shopUI.lab_time.visible = false;
//            m_shopUI.img_nextTime.visible = false;
//            m_shopUI.img_remainTime.visible = false;
//            m_shopUI.img_k.visible = false;
//        }
//        else{
//            m_shopUI.lab_time.visible = true;

            var vipLv:int = playSystem.playerData.vipData.vipLv;
            var haveFreeCount:int =  shop.freeCount;//免费刷新次数
            var haveNoFreeCount:int = shop.refreshCountMax;//绑钻刷新次数上限
            var vipPri:VipPrivilege = vipManager.getVipPriTableByID( vipLv );
            if( vipPri ){
                haveFreeCount += vipPri.refreshStoreLimit;//每天免费刷新商店增加次数
                haveNoFreeCount += vipPri.refreshPayStoreLimit;//每天付费刷新商店增加次数
            }

            var remainCount:int = _curSelectShop.alreadyRefreshNum - haveFreeCount;

            //如果免费次数用完，就使用绑钻刷新
            if(remainCount >= 0){//如果免费次数为0，就是不免费
                if(shop.effectType == 1){//类型为1的是常规商店（有下次刷新时间）；类型为2是限时商店（有倒计时）
                    m_shopUI.img_nextTime.visible = true;
                    m_shopUI.img_k.visible = true;
                    m_shopUI.lab_time.text = CTime.formatHMSStr( _curSelectShop.time );
                    m_shopUI.lab_time.visible = true;

                    if(shop.type == EShopType.SHOP_TYPE_18 && vipLv < shop.vipBuyLimit){
                        m_shopUI.lab_refresh.text = StringUtil.format(CLang.LANG_00017,shop.vipBuyLimit);
                        m_shopUI.btn_refresh.visible = false;
                    }else{
                        m_shopUI.btn_refresh.visible = true;
                        m_shopUI.btn_refresh.visible = (shop.refresh == 0?false:true);
                        if( remainCount >= haveNoFreeCount ){
                            m_shopUI.lab_refresh.text = CLang.LANG_00002 + HtmlUtil.getHtmlText(0 + "/" + haveNoFreeCount,"#ff0000",14,"SimSun",true);
                        }else{
                            m_shopUI.lab_refresh.text = CLang.LANG_00002 + (haveNoFreeCount-remainCount) + "" +
                                    "/" + haveNoFreeCount;
                        }
                    }
                }
            }else{
                remainCount = haveFreeCount - _curSelectShop.alreadyRefreshNum;
                if(shop.type == EShopType.SHOP_TYPE_18){
                    m_shopUI.lab_refresh.text = StringUtil.format(CLang.LANG_00017,shop.vipBuyLimit);
                }else{
                    m_shopUI.lab_refresh.text = CLang.LANG_00001 + remainCount + "/" + haveFreeCount;
                }
                if(shop.effectType == 1){
                    m_shopUI.img_nextTime.visible = true;
                    m_shopUI.img_k.visible = true;
                    m_shopUI.lab_time.text = CTime.formatHMSStr( _curSelectShop.time );
                    m_shopUI.lab_time.visible = true;
                }
            }

        if(_curSelectShop.time <= 0){
            m_shopUI.lab_time.visible = false;
            m_shopUI.img_nextTime.visible = false;
            m_shopUI.img_remainTime.visible = false;
            m_shopUI.img_k.visible = false;
        }

//        }
    }

    /**设置ShopItem数据*/
    private function _onRenderItem(item:ShopItemUI,index:int):void {
        if( item == null || item.dataSource == null )return;
        var shopItem:CShopItemData = item.dataSource as CShopItemData;
        var shopItemTable:ShopItem = shopSysTem.getShopItemTableByID(shopItem.shopItemID);
        if( !shopItemTable ) return;
        var itemTable:Item = shopSysTem.getItemTableByID(shopItemTable.itemID);

        item.lab_name.text = HtmlUtil.getHtmlText(itemTable.name,CQualityColor.getColorByQuality(itemTable.quality-1),14) ;//名称

        item.box_zk.visible = (shopItem.discount == 10 ? false:true);

        if(shopItem.discount >= 10){
            //如果没有折扣
            item.box_yj.visible = false;
            item.box_sj.y = 148;
            item.lab_moneyCur.text = shopItemTable.price.toString();//价格
        }else{
            item.box_yj.visible = true;
            item.box_sj.y = 139;
            //售价(折扣价)
            item.lab_moneyCur.text = Math.ceil(shopItemTable.price*(shopItemTable.discount*10/100))+"";//价格
            //原价
            item.lab_money.text = shopItemTable.price.toString();//价格
        }

        item.clip_z.frame = shopItem.discount;//折扣
        item.itemUI.clip_bg.index = itemTable.quality;//品质框
        item.itemUI.img.url = itemTable.bigiconURL + ".png";//资源路径
        item.itemUI.txt_num.text = shopItemTable.itemNum.toString();//数量
        item.itemUI.box_effect.visible = itemTable.effect > 0 ? (itemTable.extraEffect == 0 || shopItemTable.itemNum >= itemTable.extraEffect) : false;
        item.itemUI.clip_effect.autoPlay = itemTable.effect;

        item.img_xy.visible = shopItemTable.valueIcon == 0?false:true;

        var currencyTable:Currency = shopSysTem.getCurrencyTableByID(shopItemTable.currencyType);
        if(currencyTable){
            item.icon_tb.url = shopSysTem.getIconPath(currencyTable.source);
            item.icon_tbCur.url = shopSysTem.getIconPath(currencyTable.source);
        }

        //商品冷却倒计时
        var colorStr:String = "#ffeddf";
        if(shopItem.restoreTime <= 0 || shopItem.currentSellNum > 0){
            item.box_time.visible = false;
            item.lab_xg.visible = true;
        }else{
            item.box_time.visible = true;
            item.lab_xg.visible = false;
        }

        //商品状态（售罄/恢复中）
        if( shopItem.currentSellNum == 0 ){
            item.clip_state.visible = true;
            if(shopItemTable.restoreTime < 0){
                item.clip_state.visible = false;
            }
        }else{
            item.clip_state.visible = false;
        }

        if( shopItemTable.restoreTime < 0){//如果商品恢复时间为-1，表示不会恢复
            if( shopItem.currentSellNum == 0 ){
                //售罄
                item.clip_state.index = 1;
                item.clip_state.visible = true;
            }else{
                //恢复
                item.clip_state.index = 0;
            }
        }else{
            if( shopItem.currentSellNum < shopItemTable.canBuyCount){
                item.clip_state.index = 0;
            }
        }


        //商品冷却倒计时
        if( shopItem.currentSellNum <= 0 ){
            //如果当前上架的数量为0
            colorStr = "#ff0000";
            item.lab_time.text = CTime.toDurTimeString(shopItem.restoreTime - CTime.getCurrServerTimestamp());
        }

        if( shopItemTable.canBuyCount < 0 ){
            //不限购
            item.lab_xg.text = CLang.LANG_00005;
        }else{
            item.lab_xg.text = CLang.LANG_00006 + HtmlUtil.getHtmlText(shopItem.currentSellNum+"",colorStr,13,"SimSun",true) +
                    CLang.LANG_00007 + "("+ HtmlUtil.getHtmlText(shopItem.currentSellNum+"/"+shopItemTable.canBuyCount,colorStr,13,"SimSun",true) +")";
        }
        item.btn_buy.clickHandler = new Handler(_onSelectItem,[item]);
        item.click_block.clickHandler = new Handler(_onSelectItem,[item]);
        item.click_block.toolTip = new Handler( _showItemTips, [ itemTable,item.itemUI.box_effect.visible ]);
    }

    /**显示物品Tips*/
    private function _showItemTips(item:Item,isShowEffect:Boolean):void {
        (system.getBean( CShopItemTipsViewHandler ) as CShopItemTipsViewHandler).showTips(item,isShowEffect);
    }

    /**选中单个的物品*/
    private function _onSelectItem(...args):void {
        var item:ShopItemUI = args[0] as ShopItemUI;
        if( item == null || item.dataSource == null )return;
        var shopItem:CShopItemData = item.dataSource as CShopItemData;

        if( shopItem.currentSellNum == 0 ){
            uiSysTem.showMsgAlert(CLang.LANG_00008);
            return;
        }

        (shopSysTem.getBean( CShopBuyViewHandler ) as CShopBuyViewHandler).show(0,shopItem,1,true);
    }

    /**点击刷新商店按钮*/
    private function _onRefreshClick() : void {
        if( _curSelectShop == null )return;

        if(shopManager.m_bShopRefreshClock){
            return;
        }

        var shop:Shop = shopManager.getShopTableByID(_curSelectShopId);

        var vipLv:int = playSystem.playerData.vipData.vipLv;
        var haveFreeCount:int =  shop.freeCount;//免费刷新次数
        var haveNoFreeCount:int = shop.refreshCountMax;//绑钻刷新次数上限
        var vipPri:VipPrivilege = vipManager.getVipPriTableByID( vipLv );
        if( vipPri ){
            haveFreeCount += vipPri.refreshStoreLimit;//每天免费刷新商店增加次数
            haveNoFreeCount += vipPri.refreshPayStoreLimit;//每天付费刷新商店增加次数
        }

        var remainCount:int = _curSelectShop.alreadyRefreshNum - haveFreeCount;

        if( _curSelectShop.alreadyRefreshNum >= (haveFreeCount+haveNoFreeCount) ){
            uiSysTem.showMsgAlert(CLang.LANG_00009);
            return;
        }

        var rTable:ShopRefresh = shopManager.getShopRefreshTable(_curSelectShopId,(remainCount<0?0:remainCount));
        if( rTable ){
            var currencyTable:Currency = shopSysTem.getCurrencyTableByID(rTable.currencyType);
            var str:String = "";
            if(rTable.currencyType == ECurrencyType.BIND_DIAMOND && _curSelectShop.alreadyRefreshNum >= haveFreeCount){
                //绑钻
                var purpleDiamond:int = playSystem.playerData.currency.purpleDiamond;
                if(rTable.currencyNum > purpleDiamond) {
                    str = StringUtil.format(CLang.LANG_00016,rTable.currencyNum,(rTable.currencyNum-purpleDiamond));
                    uiSysTem.showMsgBox(str,function():void{
                        shopHandler.onRefreshShopRequest(_curSelectShopId);

                        var haveDiamond : int = playSystem.playerData.currency.purpleDiamond + playSystem.playerData.currency.blueDiamond;
                        //钻石跟绑钻都不足的时候，弹出充值界面
                        if(rTable.currencyNum > haveDiamond)
                        {
                            var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
                            var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
                            bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
                        }
                    });
                }else{
                    str = CLang.LANG_00010 +　rTable.currencyNum + currencyTable.name + CLang.LANG_00011;
                    uiSysTem.showMsgBox(str,function():void{
                        shopHandler.onRefreshShopRequest(_curSelectShopId);
                    });
                }
            }else{
                shopHandler.onRefreshShopRequest(_curSelectShopId);
            }
        }
    }

    private function get shopSysTem() : CShopSystem {
        return system as CShopSystem;
    }

    private function get shopManager() : CShopManager {
        return system.getBean( CShopManager ) as CShopManager;
    }

    private function get shopHandler() : CShopHandler {
        return system.getBean( CShopHandler ) as CShopHandler;
    }

    private function get playSystem() : CPlayerSystem {
        return system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
    }

    private function get uiSysTem() : CUISystem {
        return system.stage.getSystem(CUISystem) as CUISystem;
    }

    private function get recippcalTem() : CReciprocalSystem {
        return system.stage.getSystem(CReciprocalSystem) as CReciprocalSystem;
    }

    private function get vipManager() : CVIPManager {
        var vipM:CVIPManager = this.vipSysTem.getBean( CVIPManager ) as CVIPManager;
        return vipM;
    }

    private function get vipSysTem() : CVIPSystem {
        return system.stage.getSystem( CVIPSystem ) as CVIPSystem;
    }

    private function _close():void{
        if(_closeHandler){
            _closeHandler.execute();
        }
    }

    private function getSelectTabIndex( type:int = EShopType.SHOP_TYPE_3 ):int{
        var tabIndex:int = 0;
        var labels:Array = shopManager.getTabList().split(",");
        var shopArr:Array = shopManager.getShopTableByType( type );
        var shop:Shop = shopArr[0];
        var index:int = labels.indexOf( shop.name );
        if( index == -1 ){
            tabIndex = 0;
        }else{
            tabIndex = index;
        }
        return tabIndex;
    }

    private function getShopNameByType( type:int = EShopType.SHOP_TYPE_3 ):String{
        var shopArr:Array = shopManager.getShopTableByType( type );
        if(shopArr == null || shopArr.length == 0)return null;
        var shop:Shop = shopArr[0];
        return shop.name;
    }

    private function getRoleUrl(roleName:String):String {
        var url:String = "icon/role/big/"+roleName+".png";
        return url;
    }


}
}
