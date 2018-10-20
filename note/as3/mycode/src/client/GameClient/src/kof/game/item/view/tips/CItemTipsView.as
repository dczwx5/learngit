//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2016/11/21.
 */
package kof.game.item.view.tips {

import kof.framework.CViewHandler;
import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.bag.data.CBagData;
import kof.game.common.CItemUtil;
import kof.game.common.CLang;
import kof.game.common.tips.ITips;
import kof.game.enum.EItemType;
import kof.game.gem.CGemManagerHandler;
import kof.game.gem.CGemSystem;
import kof.game.item.CItemData;
import kof.game.item.CItemSystem;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.view.playerNew.CHeroTipsView;
import kof.game.talent.talentFacade.talentSystem.proxy.CTalentDataManager;
import kof.ui.demo.Bag.QualityBoxUI;
import kof.ui.imp_common.ItemTipsUI;
import kof.ui.imp_common.RewardItemUI;

import morn.core.components.Component;

// 单个物品tips
public class CItemTipsView extends CViewHandler  implements ITips {

    private var m_bagItemTipsUI:ItemTipsUI;
    private var m_tipsObj:Component;
    private var m_args:Array;
    private var m_effect:Boolean;//格子特效,受数量关联
    public function CItemTipsView() {
        super();
    }

    override public function get viewClass() : Array {
        return [ ItemTipsUI ];
    }

    override protected function get additionalAssets():Array {
        return ["frameclip_item2.swf"];
    }

    public function addTips(box:Component, args:Array = null):void{
        m_tipsObj = box;
        m_args = args;
        this.loadAssetsByView( viewClass, _addToDisplay );
    }
    public function hideTips():void{
        m_bagItemTipsUI.remove();
    }

    private function _addToDisplay():void{
        if (!m_bagItemTipsUI) m_bagItemTipsUI = new ItemTipsUI();
        m_bagItemTipsUI.mc_item.txt_num.visible = false;
        m_effect = true;
        var itemData:CItemData;

        if (m_args && m_args.length > 0) {
            var arg1:Object = m_args[0];
            if (arg1 is CItemData) {
                itemData = arg1 as CItemData;
            } else if (arg1 is int) {
                itemData = _itemSystem.getItem(arg1 as int);
            }
        } else {
            if (m_tipsObj)
            {
                itemData = (m_tipsObj.dataSource as CItemData);
                if(m_tipsObj.dataSource.hasOwnProperty("item"))
                {
                    itemData.itemRecord = m_tipsObj.dataSource.item;//如果是背包物品，会有item属性
                }
                //新增道具扫光判断条件，Tips上的道具扫光受道具源影响
                //==============================add by Lune 0617 start======================================
                if(m_tipsObj is QualityBoxUI)
                {
                    m_effect = (m_tipsObj as QualityBoxUI).box_eff.visible;
                }
                else if(m_tipsObj is RewardItemUI)
                {
                    m_effect = (m_tipsObj as RewardItemUI).box_eff.visible;
                }
                //==============================add by Lune 0617 end========================================
            }
        }

        if(itemData) {
            // var rewardData : CRewardData = (m_tipsObj.dataSource as CRewardData);
            if(CItemUtil.isHeroItem(itemData))
            {
                var heroId:int = int(itemData.ID.toString().slice(5,8));
                var heroData:CPlayerHeroData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.heroList.createHero(heroId);
                if(heroData)
                {
                    var heroStar:int = int(itemData.itemRecord.param2);
                    heroData.updateDataByData({star:heroStar});
                    (system.stage.getSystem(CPlayerSystem ).getHandler(CHeroTipsView) as CHeroTipsView).addTips(m_tipsObj,[heroData]);
                }
                return;
            }

            m_bagItemTipsUI.mc_item.img.url = itemData.iconBig;
            m_bagItemTipsUI.txt_name.text = itemData.nameWithColor;

            var typeName : String = "unknown";
            if (CLang.hasKey("item_page_" + itemData.page)) {
                typeName = CLang.Get("item_page_" + itemData.page);
            } else {
                typeName = CLang.Get("item_page_4");
            }
            m_bagItemTipsUI.txt_type.text = "[" + typeName + "]";

            var num : int = 0;
            if(itemData.itemRecord.type <= EItemType.ITEM_TYPE_50){
                if(itemData.itemRecord.type == EItemType.ITEM_TYPE_8 || itemData.itemRecord.type == EItemType.ITEM_TYPE_9){
                    //战队经验， 格斗家经验不显示
                    m_bagItemTipsUI.txt_num.visible = false;
                }else{
                    m_bagItemTipsUI.txt_num.visible = true;

                    if(itemData.itemRecord.type == EItemType.ITEM_TYPE_4){
                        m_bagItemTipsUI.txt_num.text = CLang.LANG_00200 + _playSystem.playerData.vitData.physicalStrength;
                    }else{
                        m_bagItemTipsUI.txt_num.text = CLang.LANG_00200 + _playSystem.playerData.currency.getValueByType(itemData.itemRecord.type);
                    }
                }
            }else{
                if(itemData.itemRecord.type == EItemType.ITEM_TYPE_701) {
                    //如果是斗魂，取斗魂仓库的数据
                    num = CTalentDataManager.getInstance().getTalentPointNuForSoulID( itemData.itemRecord.ID );
                }
                else if(itemData.itemRecord.type == EItemType.ITEM_TYPE_801)
                {
                    num = (system.stage.getSystem(CGemSystem ).getHandler(CGemManagerHandler) as CGemManagerHandler).getGemNum(itemData.itemRecord.ID);
                }
                else
                {
                    //取背包数据
                    var bagData : CBagData = (_bagSystem.getBean(CBagManager) as CBagManager).getBagItemByUid(itemData.itemRecord.ID);
                    if (bagData) {
                        num = bagData.num;
                    }
                }
                m_bagItemTipsUI.txt_num.visible = true;
                m_bagItemTipsUI.txt_num.text = CLang.Get("item_has_num", {v1:num});
            }
            m_bagItemTipsUI.txt_cont.text =  itemData.desc;
            if(itemData.canSell) {
                m_bagItemTipsUI.txt_price.text = CLang.Get("item_sell_price", {v1:itemData.sellPrice});
            } else {
                m_bagItemTipsUI.txt_price.text = CLang.Get("item_can_not_sell");
            }
            m_bagItemTipsUI.box_priceT.visible = itemData.canSell;
            m_bagItemTipsUI.box_priceT.x = m_bagItemTipsUI.txt_price.x + (m_bagItemTipsUI.txt_price.width - m_bagItemTipsUI.txt_price.textField.textWidth)
                    - m_bagItemTipsUI.box_priceT.width - 10;
            m_bagItemTipsUI.mc_item.clip_bg.index = itemData.quality;
            m_bagItemTipsUI.mc_item.box_effect.visible = itemData.effect && m_effect;//此处关联指向的道具是否有特效
            m_bagItemTipsUI.mc_item.clip_effect.autoPlay = itemData.effect;

//            callLater(setPos);
//            function setPos():void
//            {
                m_bagItemTipsUI.img_line.y = m_bagItemTipsUI.txt_cont.y + m_bagItemTipsUI.txt_cont.textField.textHeight + 11;
                m_bagItemTipsUI.box_bottom.y = m_bagItemTipsUI.img_line.y + 6;
                m_bagItemTipsUI.img_bg.height = m_bagItemTipsUI.box_bottom.y + m_bagItemTipsUI.box_bottom.height + 15;
//            }

            App.tip.addChild(m_bagItemTipsUI);
        }
    }

    private function get _bagSystem() : CBagSystem {
        return system.stage.getSystem(CBagSystem) as CBagSystem;
    }
    private function get _itemSystem() : CItemSystem {
        return system.stage.getSystem(CItemSystem) as CItemSystem;
    }

    private function get _playSystem() : CPlayerSystem {
        return system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
    }
}
}
