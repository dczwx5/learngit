//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/25.
 */
package kof.game.item.view {

import kof.framework.CViewHandler;
import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.bag.data.CBagData;
import kof.game.common.CLang;
import kof.game.enum.EItemType;
import kof.game.gem.CGemManagerHandler;
import kof.game.gem.CGemSystem;
import kof.game.item.CItemData;
import kof.game.item.CItemSystem;
import kof.game.player.CPlayerSystem;
import kof.game.talent.talentFacade.talentSystem.proxy.CTalentDataManager;
import kof.ui.imp_common.ItemTipsUI;

import morn.core.handlers.Handler;

/**
 * 物品信息界面(类似于物品tips,有关闭按钮的)
 */
public class CItemInfoViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;

    private var m_pViewUI:ItemTipsUI;
    private var m_pData:CItemData;
    private var m_iPosX:int = 0;
    private var m_iPosY:int = 0;

    public function CItemInfoViewHandler()
    {
        super();
    }

    override public function get viewClass() : Array {
        return [ ItemTipsUI ];
    }

    override protected function get additionalAssets():Array {
        return ["frameclip_item2.swf"];
    }

    override protected function onAssetsLoadCompleted() : void
    {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
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
                m_pViewUI = new ItemTipsUI();

                m_pViewUI.btn_close.clickHandler = new Handler(_onCloseHandler);

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

    public function removeDisplay():void
    {
        m_pViewUI.remove();
    }

    private function _addToDisplay():void
    {
//        var uiSystem:CUISystem = system.stage.getSystem(CUISystem) as CUISystem;
//        uiSystem.effectLayer.addChild(m_pViewUI);

        uiCanvas.addDialog(m_pViewUI);

        m_pViewUI.x = m_iPosX;
        m_pViewUI.y = m_iPosY;

        _initView();
    }

    private function _initView():void
    {
        if ( m_pViewUI )
        {
            m_pViewUI.mouseEnabled = true;
            m_pViewUI.mouseChildren = true;
            m_pViewUI.mc_item.txt_num.visible = false;
            m_pViewUI.btn_close.visible = true;

            if(itemData)
            {
//            if(CItemUtil.isHeroItem(itemData.ID))
//            {
//                var heroId:int = int(itemData.ID.toString().slice(5,8));
//                var heroData:CPlayerHeroData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.heroList.createHero(heroId);
//                if(heroData)
//                {
//                    var heroStar:int = int(itemData.itemRecord.param2);
//                    heroData.updateDataByData({star:heroStar});
//                    (system.stage.getSystem(CPlayerSystem ).getHandler(CHeroTipsView) as CHeroTipsView).addTips(m_tipsObj,[heroData]);
//                }
//                return;
//            }

                m_pViewUI.mc_item.img.url = itemData.iconBig;
                m_pViewUI.txt_name.text = itemData.nameWithColor;

                var typeName : String = "unknown";
                if (CLang.hasKey("item_page_" + itemData.page)) {
                    typeName = CLang.Get("item_page_" + itemData.page);
                } else {
                    typeName = CLang.Get("item_page_4");
                }
                m_pViewUI.txt_type.text = "[" + typeName + "]";

                var num : int = 0;
                if(itemData.itemRecord.type <= EItemType.ITEM_TYPE_50){
                    if(itemData.itemRecord.type == EItemType.ITEM_TYPE_8 || itemData.itemRecord.type == EItemType.ITEM_TYPE_9){
                        //战队经验， 格斗家经验不显示
                        m_pViewUI.txt_num.visible = false;
                    }else{
                        m_pViewUI.txt_num.visible = true;

                        if(itemData.itemRecord.type == EItemType.ITEM_TYPE_4){
                            m_pViewUI.txt_num.text = CLang.LANG_00200 + _playSystem.playerData.vitData.physicalStrength;
                        }else{
                            m_pViewUI.txt_num.text = CLang.LANG_00200 + _playSystem.playerData.currency.getValueByType(itemData.itemRecord.type);
                        }
                    }
                }else{
                    if(itemData.itemRecord.type == EItemType.ITEM_TYPE_701) {
                        //如果是斗魂，取斗魂仓库的数据
                        num = CTalentDataManager.getInstance().getTalentPointNuForSoulID( itemData.itemRecord.ID );
                    }
                    else if(itemData.itemRecord.type == EItemType.ITEM_TYPE_801)// 宝石
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
                    m_pViewUI.txt_num.visible = true;
                    m_pViewUI.txt_num.text = CLang.Get("item_has_num", {v1:num});
                }
                m_pViewUI.txt_cont.text =  itemData.desc;
                if(itemData.canSell) {
                    m_pViewUI.txt_price.text = CLang.Get("item_sell_price", {v1:itemData.sellPrice});
                } else {
                    m_pViewUI.txt_price.text = CLang.Get("item_can_not_sell");
                }
                m_pViewUI.box_priceT.visible = itemData.canSell;
                m_pViewUI.box_priceT.x = m_pViewUI.txt_price.x + (m_pViewUI.txt_price.width - m_pViewUI.txt_price.textField.textWidth)
                        - m_pViewUI.box_priceT.width - 10;
                m_pViewUI.mc_item.clip_bg.index = itemData.quality;
                m_pViewUI.mc_item.box_effect.visible = itemData.effect;//此处关联指向的道具是否有特效
                m_pViewUI.mc_item.clip_effect.autoPlay = itemData.effect;

                m_pViewUI.img_line.y = m_pViewUI.txt_cont.y + m_pViewUI.txt_cont.textField.textHeight + 11;
                m_pViewUI.box_bottom.y = m_pViewUI.img_line.y + 6;
                m_pViewUI.img_bg.height = m_pViewUI.box_bottom.y + m_pViewUI.box_bottom.height + 15;

                _resize();
            }
        }
    }

    private function _resize():void
    {
        var stageWidth:int = system.stage.flashStage.stageWidth;
        var stageHeight:int = system.stage.flashStage.stageHeight;
        if((m_pViewUI.x + m_pViewUI.img_bg.width) > stageWidth)
        {
            m_pViewUI.x -= (m_pViewUI.x + m_pViewUI.img_bg.width - stageWidth);
        }

        if((m_pViewUI.y + m_pViewUI.img_bg.height) > stageHeight)
        {
            m_pViewUI.y -= (m_pViewUI.y + m_pViewUI.img_bg.height - stageHeight);
        }
    }

    private function _onCloseHandler():void
    {
        removeDisplay();
    }

    public function set itemData(value:CItemData):void
    {
        m_pData = value;
    }

    public function get itemData():CItemData
    {
        return m_pData;
    }

    public function setPos(x:int, y:int):void
    {
        m_iPosX = x;
        m_iPosY = y;
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
