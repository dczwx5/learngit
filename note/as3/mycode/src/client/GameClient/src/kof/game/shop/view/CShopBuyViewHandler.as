//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/5/4.
 */
package kof.game.shop.view {

import QFLib.Utils.HtmlUtil;
import QFLib.Utils.StringUtil;

import flash.events.Event;
import flash.geom.Point;

import kof.SYSTEM_ID;

import kof.framework.CViewHandler;
import kof.game.KOFSysTags;
import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.bag.data.CBagData;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CFlyItemUtil;
import kof.game.common.CLang;
import kof.game.common.CLang;
import kof.game.currency.enum.ECurrencyType;
import kof.game.player.CPlayerSystem;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.shop.CShopHandler;
import kof.game.shop.CShopManager;
import kof.game.shop.CShopSystem;
import kof.game.shop.data.CShopItemData;
import kof.game.shop.enum.EShopType;
import kof.table.Currency;
import kof.table.Item;
import kof.table.Shop;
import kof.table.ShopItem;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;
import kof.ui.master.shop.ShopBuyGiftTwoUI;
import kof.ui.master.shop.ShopBuyGiftUI;
import kof.ui.master.shop.ShopBuyUI;
import kof.util.CQualityColor;

import morn.core.components.Dialog;

import morn.core.components.TextInput;

import morn.core.handlers.Handler;

/**
 * 商店物品购买
 */
public class CShopBuyViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;

    private var _shopBuyUI:ShopBuyUI;
    private var _shopBuyGift1:ShopBuyGiftUI;
    private var _shopBuyGift2:ShopBuyGiftTwoUI;

    private var _curBuyNum:int = 1;//当前购买的数量
    private var _curShopItem:CShopItemData;
    private var _curShopTtemTable:ShopItem;

    private var _viewType:int = 0;
    private var _buyNum:int = 1;
    private var _isShowRechargeView:Boolean = false;

    private var _curShowDialog:Object;

    private var _curCanBuyMax:int = 1;//当前能购买的最大数量

    public static const MAX_VALUE:int = 999;//当前购买上限值

    public function CShopBuyViewHandler() {
        super( false );
    }

    override public function dispose() : void {
        super.dispose();
    }

    override public function get viewClass() : Array {
        return [ ShopBuyUI ];
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
        if ( _shopBuyUI == null ) {
            _shopBuyUI = new ShopBuyUI();//单个物品购买
            _shopBuyUI.closeHandler = new Handler( _onClose );

            _shopBuyUI.btn_left.clickHandler = new Handler( _onBtnLeftClick, [_shopBuyUI.lab_num] );
            _shopBuyUI.btn_right.clickHandler = new Handler( _onBtnRightClick, [_shopBuyUI.lab_num] );
            _shopBuyUI.lab_num.addEventListener( Event.CHANGE, _onTxtInputChange );

            _shopBuyUI.btn_buy.clickHandler = new Handler( _onBtnBuyClick );

            m_bViewInitialized = true;
        }

        if ( _shopBuyGift1 == null ) {
            _shopBuyGift1 = new ShopBuyGiftUI();//三选一礼包购买
            _shopBuyGift1.closeHandler = new Handler( _onClose );

            _shopBuyGift1.btn_left.clickHandler = new Handler( _onBtnLeftClick, [_shopBuyGift1.lab_num] );
            _shopBuyGift1.btn_right.clickHandler = new Handler( _onBtnRightClick, [_shopBuyGift1.lab_num] );
            _shopBuyGift1.lab_num.addEventListener( Event.CHANGE, _onTxtInputChange );

            _shopBuyGift1.btn_buy.clickHandler = new Handler( _onBtnBuyClick );
        }

        if ( _shopBuyGift2 == null ) {
            _shopBuyGift2 = new ShopBuyGiftTwoUI();//八选一礼包购买
            _shopBuyGift2.closeHandler = new Handler( _onClose );

            _shopBuyGift2.btn_left.clickHandler = new Handler( _onBtnLeftClick, [_shopBuyGift2.lab_num] );
            _shopBuyGift2.btn_right.clickHandler = new Handler( _onBtnRightClick, [_shopBuyGift2.lab_num] );
            _shopBuyGift2.lab_num.addEventListener( Event.CHANGE, _onTxtInputChange );

            _shopBuyGift2.btn_buy.clickHandler = new Handler( _onBtnBuyClick );
        }
    }

    private function _onBtnLeftClick( txtInput:TextInput ) : void {
        _curBuyNum--;
        if( _curBuyNum < 1)_curBuyNum = 1;
        txtInput.text = _curBuyNum.toString();
        _updatePriceTxt();
    }

    private function _onBtnRightClick( txtInput:TextInput ) : void {
        _curBuyNum++;
        if( _curBuyNum > _curCanBuyMax ){
            _curBuyNum = _curCanBuyMax;
            uiSysTem.showMsgAlert(CLang.LANG_00012 + _curBuyNum);
        }
        if(_curBuyNum >= MAX_VALUE){
            _curBuyNum = MAX_VALUE;
        }
        txtInput.text = _curBuyNum.toString();
        _updatePriceTxt();
    }

    private function _onTxtInputChange( event : Event ) : void {
        var txt:TextInput = event.currentTarget as TextInput;
        _curBuyNum = int(txt.text);
        if(_curBuyNum > MAX_VALUE){
            _curBuyNum = MAX_VALUE;
            txt.text = _curBuyNum.toString();
        }
        if(_curBuyNum <= 0){
            _curBuyNum = 1;
            txt.text = _curBuyNum.toString();
        }
        _updatePriceTxt();
    }

    /**
     * 显示商品购买界面
     * @param type 0单个商品购买
     *             1三选一礼包购买
     *             2八选一礼包购买
     *------------经过策划确认目前只通用单个物品购买界面，其他两个购买界面暂时不用
     * @param shopItem 商品信息
     * @param buyNum 购买数量
     * @param isShowRechargeView 是否显示充值界面（当钻石不足时）
     */
    public function show( type:int = 0, shopItem:CShopItemData = null, buyNum:int = 1, isShowRechargeView:Boolean = false ) : void {
        _viewType = type;
        _curShopItem = shopItem;
        _buyNum = buyNum;
        _isShowRechargeView = isShowRechargeView;
        this.loadAssetsByView( viewClass, _addToDisplay );
    }

    private function _addToDisplay():void {

        if ( onInitializeView() ) {
            invalidate();
        }

        _curBuyNum = _buyNum;

        _curCanBuyMax = _curShopItem.currentSellNum == -1?MAX_VALUE:_curShopItem.currentSellNum;//-1表示不限购数量，取MAX_VALUE值

        _curShopTtemTable = shopSysTem.getShopItemTableByID(_curShopItem.shopItemID);
        if(!_curShopTtemTable)
        {
            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert("配置有误");
            return;
        }
        var itemTable:Item = shopSysTem.getItemTableByID(_curShopTtemTable.itemID);

        switch( _viewType )
        {
            case 0:
                if ( _shopBuyUI ) {
                    uiCanvas.addPopupDialog( _shopBuyUI );
                    _curShowDialog = _shopBuyUI;
                }
                break;
            case 1:
                if( _shopBuyGift1 ){
                    uiCanvas.addPopupDialog( _shopBuyGift1 );
                    _curShowDialog = _shopBuyGift1;
                }
                break;
            case 2:
                if ( _shopBuyGift2 ) {
                    uiCanvas.addPopupDialog( _shopBuyGift2 );
                    _curShowDialog = _shopBuyGift2;
                }
                break;
        }

        //商品数据
        if( _curShowDialog ){
            _curShowDialog.itemUI.clip_bg.index = itemTable.quality;//品质框
            _curShowDialog.itemUI.img.url = itemTable.bigiconURL + ".png";//资源路径
            _curShowDialog.itemUI.txt_num.text = _curShopTtemTable.itemNum.toString();//数量
            _curShowDialog.itemUI.box_effect.visible = itemTable.effect > 0 ? (itemTable.extraEffect == 0 || _curShopTtemTable.itemNum >= itemTable.extraEffect) : false;
            _curShowDialog.itemUI.clip_effect.autoPlay = itemTable.effect;

            var typeName : String = "unknown";
            if (CLang.hasKey("item_page_" + itemTable.page)) {
                typeName = CLang.Get("item_page_" + itemTable.page);
            } else {
                typeName = CLang.Get("item_page_4");
            }
            _curShowDialog.lab_type.text = "[" + typeName + "]";

            var bagData : CBagData = (bagSystem.getBean(CBagManager) as CBagManager).getBagItemByUid(itemTable.ID);
            var num : int;
            if (bagData) {
                num = bagData.num;
            }

            _curShowDialog.lab_have.text = CLang.Get("item_has_num", {v1:num});//拥有数量
            _curShowDialog.box_zk.visible = (_curShopItem.discount == 10 ? false:true);//折扣标签
            _curShowDialog.clip_z.frame = _curShopItem.discount;//折扣
            _curShowDialog.lab_name.text = HtmlUtil.getHtmlText(itemTable.name,CQualityColor.getColorByQuality(itemTable.quality-1),16) ;//名称
            _curShowDialog.lab_dic.text = itemTable.literatureDescription;//物品描述
            _curShowDialog.lab_buyNum.text = _curShopTtemTable.itemNum*_curBuyNum + CLang.LANG_00013;
            _curShowDialog.lab_priceTotal.text = Math.ceil((_curShopTtemTable.price*_curBuyNum*(_curShopItem.discount*10/100))).toString();
            _curShowDialog.lab_num.text = _curBuyNum.toString();

            var currencyTable:Currency = shopSysTem.getCurrencyTableByID(_curShopTtemTable.currencyType);
            if(currencyTable){
                _curShowDialog.img_priceIcon.url = shopSysTem.getIconPath(currencyTable.source);//货币类型图标
            }

            _curShowDialog.box_bottom.y = _curShowDialog.lab_dic.y + _curShowDialog.lab_dic.height + 6;
            _curShowDialog.img_bg.height = _curShowDialog.box_bottom.y + _curShowDialog.box_bottom.height + 20;
        }
    }

    private function _updatePriceTxt() : void {
        if( _curShowDialog ){
            _curShowDialog.lab_buyNum.text = _curShopTtemTable.itemNum*_curBuyNum + CLang.LANG_00013;//总件数
            _curShowDialog.lab_priceTotal.text = Math.ceil((_curShopTtemTable.price*_curBuyNum*(_curShopItem.discount*10/100))).toString();//总价
        }
    }

    public function hide() : void {
        if( _curShowDialog ){
            (_curShowDialog as Dialog).close();
        }
    }

    public function flyItem():void {
        if(_shopBuyUI){
            CFlyItemUtil.flyItemToBag(_shopBuyUI.itemUI, new Point(system.stage.flashStage.stageWidth/2,system.stage.flashStage.stageHeight/2), system);
        }
    }

    private function _onClose( type : String ) : void {
        switch ( type ) {
            default:
                break;
        }
    }

    /**
     * 点击购买按钮
     */
    private function _onBtnBuyClick() : void {
        if( _curShopTtemTable ){
            var shop:Shop = shopManager.getShopTableByID(_curShopTtemTable.shopID);
            if(shop.type == EShopType.SHOP_TYPE_18){
                if(playSystem.playerData.vipData.vipLv <  _curShopTtemTable.vipLevelLimit){
                    uiSysTem.showMsgAlert(StringUtil.format(CLang.LANG_00018,_curShopTtemTable.vipLevelLimit));
                    return;
                }
            }

            if(_curShopTtemTable.currencyType == ECurrencyType.BIND_DIAMOND){
                var costBdDiamondNum:int = Math.ceil((_curShopTtemTable.price*_curBuyNum*(_curShopItem.discount*10/100)));
                if(_isShowRechargeView){
                    var purpleDiamond:int = playSystem.playerData.currency.purpleDiamond;
                    if(costBdDiamondNum > purpleDiamond) {
                        var haveDiamond : int = playSystem.playerData.currency.purpleDiamond + playSystem.playerData.currency.blueDiamond;
                        //钻石跟绑钻都不足的时候，弹出充值界面
                        if(costBdDiamondNum > haveDiamond){
                            var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
                            var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
                            bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
                            (system.stage.getSystem(IUICanvas) as IUICanvas).showMsgAlert("很抱歉，您的钻石不足，请前往获得");
                            hide();
                        }else{
                            recippcalTem.showCostBdDiamondMsgBox(costBdDiamondNum,function():void{
                                shopHandler.onBuyShopItemRequest(_curShopTtemTable.shopID,_curShopItem.shopItemID,_curBuyNum);
                                hide();
                            });
                        }
                    }else{
                        shopHandler.onBuyShopItemRequest(_curShopTtemTable.shopID,_curShopItem.shopItemID,_curBuyNum);
                        hide();
                    }
                }else{
                    recippcalTem.showCostBdDiamondMsgBox(costBdDiamondNum,function():void{
                        shopHandler.onBuyShopItemRequest(_curShopTtemTable.shopID,_curShopItem.shopItemID,_curBuyNum);
                        hide();
                    });
                }
            }else{
                shopHandler.onBuyShopItemRequest(_curShopTtemTable.shopID,_curShopItem.shopItemID,_curBuyNum);

                if(_curShopTtemTable.currencyType == ECurrencyType.DIAMOND)
                {
                    var blueDiamond : int = playSystem.playerData.currency.blueDiamond;
                    costBdDiamondNum = Math.ceil((_curShopTtemTable.price*_curBuyNum*(_curShopItem.discount*10/100)));
                    if ( costBdDiamondNum > blueDiamond)
                    {
                        bundleCtx = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
                        systemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
                        bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
                    }
                }

                hide();
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

    private function get bagSystem() : CBagSystem {
        return system.stage.getSystem(CBagSystem) as CBagSystem;
    }

    private function get uiSysTem() : CUISystem {
        return system.stage.getSystem(CUISystem) as CUISystem;
    }

    private function get playSystem() : CPlayerSystem {
        return system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
    }

    private function get recippcalTem() : CReciprocalSystem {
        return system.stage.getSystem(CReciprocalSystem) as CReciprocalSystem;
    }
}
}
