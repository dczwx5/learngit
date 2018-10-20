//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/5/4.
 */
package kof.game.shop.view {

import QFLib.Utils.HtmlUtil;

import kof.framework.CViewHandler;
import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.bag.data.CBagData;
import kof.game.common.CLang;
import kof.game.enum.EItemType;
import kof.game.gem.CGemManagerHandler;
import kof.game.gem.CGemSystem;
import kof.game.talent.talentFacade.talentSystem.proxy.CTalentDataManager;
import kof.table.Item;
import kof.ui.master.shop.ShopItemTipsUI;
import kof.util.CQualityColor;

/**
 * 商店物品Tips
 */
public class CShopItemTipsViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var _shopItemTipsUI:ShopItemTipsUI;

    private var _itemData:Item;
    private var _isShowEffect : Boolean;
    public function CShopItemTipsViewHandler() {
        super( false );
    }

    override public function get viewClass() : Array {
        return [ ShopItemTipsUI ];
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
        if ( _shopItemTipsUI == null ) {
            _shopItemTipsUI = new ShopItemTipsUI();

            m_bViewInitialized = true;
        }
    }

    public function showTips(itemData:Item,isShowEffect:Boolean):void {
        _itemData = itemData;
        _isShowEffect = isShowEffect;
        this.loadAssetsByView( viewClass, _addToDisplay )
    }

    private function _addToDisplay():void {

        if ( onInitializeView() ) {
            invalidate();
        }

        _shopItemTipsUI.itemUI.clip_bg.index = _itemData.quality;//品质框
        _shopItemTipsUI.itemUI.img.url = _itemData.bigiconURL + ".png";//资源路径
        _shopItemTipsUI.itemUI.box_effect.visible = _itemData.effect && _isShowEffect;
        _shopItemTipsUI.itemUI.clip_effect.autoPlay = _itemData.effect;
        _shopItemTipsUI.itemUI.txt_num.visible = false;

        var typeName : String = "unknown";
        if (CLang.hasKey("item_page_" + _itemData.page)) {
            typeName = CLang.Get("item_page_" + _itemData.page);
        } else {
            typeName = CLang.Get("item_page_4");
        }
        _shopItemTipsUI.lab_type.text = "[" + typeName + "]";

        var num : int = 0;
        if(_itemData.type == EItemType.ITEM_TYPE_701) {
            //如果是斗魂
            num = CTalentDataManager.getInstance().getTalentPointNuForSoulID( _itemData.ID );
        }
        else if(_itemData.type == EItemType.ITEM_TYPE_801)// 宝石
        {
            num = (system.stage.getSystem(CGemSystem ).getHandler(CGemManagerHandler) as CGemManagerHandler).getGemNum(_itemData.ID);
        }
        else
        {
            var bagData : CBagData = (bagSystem.getBean(CBagManager) as CBagManager).getBagItemByUid(_itemData.ID);
            if (bagData) {
                num = bagData.num;
            }
        }

        _shopItemTipsUI.lab_name.text = HtmlUtil.getHtmlText(_itemData.name,CQualityColor.getColorByQuality(_itemData.quality-1),16) ;//名称
        _shopItemTipsUI.lab_have.text = CLang.Get("item_has_num", {v1:num});
        _shopItemTipsUI.lab_dic.text =  _itemData.literatureDescription;

        _shopItemTipsUI.img_bg.height = _shopItemTipsUI.box_desc.y + _shopItemTipsUI.box_desc.height + 12;

        App.tip.addChild(_shopItemTipsUI);
    }

    private function get bagSystem() : CBagSystem {
        return system.stage.getSystem(CBagSystem) as CBagSystem;
    }
}
}
