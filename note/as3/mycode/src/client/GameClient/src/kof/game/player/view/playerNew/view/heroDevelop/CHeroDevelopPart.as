//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/8/17.
 */
package kof.game.player.view.playerNew.view.heroDevelop {

import QFLib.Utils.HtmlUtil;

import flash.events.MouseEvent;

import kof.SYSTEM_ID;
import kof.framework.CViewHandler;
import kof.game.KOFSysTags;
import kof.game.bag.CBagEvent;
import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.bag.data.CBagData;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CLang;
import kof.game.item.CItemData;
import kof.game.itemGetPath.CItemGetSystem;
import kof.game.player.CHeroNetHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.event.CPlayerEvent;
import kof.game.player.view.equipmentTrain.CEquTipsView;
import kof.game.player.view.playerNew.data.CHeroAttrData;
import kof.game.player.view.playerNew.panel.CHeroDevelopPanel;
import kof.game.player.view.playerNew.util.CHeroDevelopState;
import kof.game.player.view.playerNew.util.CPlayerHelpHandler;
import kof.table.Item;
import kof.table.PlayerLevelConsume;
import kof.table.PlayerQualityConsume;
import kof.table.PlayerStarConsume;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;
import kof.ui.master.jueseNew.HeroDevelopViewUI;
import kof.ui.master.jueseNew.render.HeroDevelopItemUI;
import kof.ui.master.messageprompt.GoodsItemUI;
import kof.util.CQualityColor;

import morn.core.components.Box;
import morn.core.components.Component;
import morn.core.components.Label;
import morn.core.handlers.Handler;

/**
 * 右边的格斗家培养部分
 */
public class CHeroDevelopPart extends CViewHandler{

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:HeroDevelopViewUI;
    private var m_pData:CPlayerHeroData;
    private var m_pTipsView:CEquTipsView;

    private var commonPieceCostNum:int;//用于补足的万能碎片数量
    private var commonPieceBagData:CBagData;//万能碎片背包数据
    public function CHeroDevelopPart()
    {
        super();
    }

    public function initializeView():void
    {
        m_pViewUI.list_heroInfo.renderHandler = new Handler(_renderHeroTag);
        m_pViewUI.list_attr.renderHandler = new Handler(_renderAttr);
        m_pViewUI.list_qualityConsume.renderHandler = new Handler(_renderQualityItem);
        m_pViewUI.btn_advance.clickHandler = new Handler(_onQualAdvanceHandler);
        m_pViewUI.btn_levelUp.clickHandler = new Handler(_onLevelUpHandler);
        m_pViewUI.btn_star.clickHandler = new Handler(_onStarAdvanceHandler);
        m_pViewUI.btn_desc.clickHandler = new Handler(_onClickDescHandler);

        m_pViewUI.btn_desc.toolTip = "背景介绍";

        m_pViewUI.progress_level.barLabel.y = 3;
        m_pViewUI.progress_level_di.barLabel.y = 3;
        m_pViewUI.progress_star.barLabel.y = 3;

        //万能碎片进度：
        m_pViewUI.img_common_piece.x = 0;
        m_pViewUI.img_common_piece.y = 0;
        m_pViewUI.progress_star.addChildAt(m_pViewUI.img_common_piece, 2);

        var propView:CHeroDetailPropViewHandler = system.getHandler(CHeroDetailPropViewHandler) as CHeroDetailPropViewHandler;
        if(propView)
        {
            propView.viewUI = m_pViewUI.view_detailProp;
            propView.initializeView();
            propView.removeDisplay();
        }

        m_bViewInitialized = true;
    }

    public function addListeners():void
    {
        m_pViewUI.btn_advance.addEventListener(MouseEvent.ROLL_OVER,_onBtnOverHandler);
        m_pViewUI.btn_advance.addEventListener(MouseEvent.ROLL_OUT,_onBtnOutHandler);
        m_pViewUI.btn_levelUp.addEventListener(MouseEvent.ROLL_OVER,_onBtnOverHandler);
        m_pViewUI.btn_levelUp.addEventListener(MouseEvent.ROLL_OUT,_onBtnOutHandler);
        m_pViewUI.btn_star.addEventListener(MouseEvent.ROLL_OVER,_onBtnOverHandler);
        m_pViewUI.btn_star.addEventListener(MouseEvent.ROLL_OUT,_onBtnOutHandler);
        m_pViewUI.btn_detailProp.addEventListener(MouseEvent.CLICK, _onDetailPropClickHandler);

        system.addEventListener(CPlayerEvent.HERO_DATA,_onHeroDataUpdateHandler);
        system.stage.getSystem(CBagSystem).addEventListener(CBagEvent.BAG_UPDATE, _onBagItemsChangeHandler);
        system.addEventListener(CPlayerEvent.PLAYER_LEVEL_UP,_onPlayerLevelUpHandler);
        system.addEventListener(CPlayerEvent.PLAYER_ORIGIN_CURRENCY,_onCurrencyUpdateHandler);

        this.addEventListener(CPlayerEvent.SHOW_ADD_PROGRESS, _onShowAddProgressHandler);
    }

    public function removeListeners():void
    {
        m_pViewUI.btn_levelUp.removeEventListener(MouseEvent.ROLL_OVER,_onBtnOverHandler);
        m_pViewUI.btn_levelUp.removeEventListener(MouseEvent.ROLL_OUT,_onBtnOutHandler);
        m_pViewUI.btn_star.removeEventListener(MouseEvent.ROLL_OVER,_onBtnOverHandler);
        m_pViewUI.btn_star.removeEventListener(MouseEvent.ROLL_OUT,_onBtnOutHandler);
        m_pViewUI.btn_advance.removeEventListener(MouseEvent.ROLL_OVER,_onBtnOverHandler);
        m_pViewUI.btn_advance.removeEventListener(MouseEvent.ROLL_OUT,_onBtnOutHandler);
        m_pViewUI.btn_detailProp.removeEventListener(MouseEvent.CLICK, _onDetailPropClickHandler);

        system.removeEventListener(CPlayerEvent.HERO_DATA,_onHeroDataUpdateHandler);
        system.stage.getSystem(CBagSystem).removeEventListener(CBagEvent.BAG_UPDATE, _onBagItemsChangeHandler);
        system.removeEventListener(CPlayerEvent.PLAYER_LEVEL_UP,_onPlayerLevelUpHandler);
        system.removeEventListener(CPlayerEvent.PLAYER_ORIGIN_CURRENCY,_onCurrencyUpdateHandler);

        this.removeEventListener(CPlayerEvent.SHOW_ADD_PROGRESS, _onShowAddProgressHandler);
    }

    public function initView():void
    {
        _updateDisplayState();
    }

    public function set data(value:*):void
    {
        m_pData = value as CPlayerHeroData;
        _levelUpStuffView.data = value;

        var propView:CHeroDetailPropViewHandler = system.getHandler(CHeroDetailPropViewHandler) as CHeroDetailPropViewHandler;
        if(propView && propView.isViewShow)
        {
            propView.data = m_pData;
        }
    }

    public function updateDevelopInfo():void
    {
        if(m_pData)
        {
            _updateDisplayState();
            _updateTopInfo();
            _updateIntroduceInfo();

            if(m_pData.hasData)
            {
                _updateAttrInfo();
                _updateQualityAdvanceInfo();
                _updateLevelUpInfo();
                _updateStarAdvanceInfo();
            }
        }
    }

// 界面信息更新===================================================================================================

    private function _updateDisplayState():void
    {
        m_pViewUI.box_develop.visible = m_pData.hasData;
        m_pViewUI.box_desc.visible = !m_pData.hasData;
        m_pViewUI.btn_desc.visible = m_pData.hasData;
        m_pViewUI.clip_arrow.index = 1;

        var propView:CHeroDetailPropViewHandler = system.getHandler(CHeroDetailPropViewHandler) as CHeroDetailPropViewHandler;
        if(propView)
        {
            if ( propView.isViewShow )
            {
                propView.removeDisplay();
            }
        }
    }

    private function _updateTopInfo():void
    {
        m_pViewUI.clip_career.index = m_pData.job;
        (system as CPlayerSystem).showCareerTips(m_pViewUI.clip_career);
        m_pViewUI.txt_heroName.isHtml = true;
        m_pViewUI.txt_heroName.stroke = m_pData.strokeColor;
        m_pViewUI.txt_heroName.text = _playerHelper.getHeroWholeName(m_pData);
    }

    private function _updateIntroduceInfo():void
    {
        m_pViewUI.txt_roleSet.text = _playerHelper.getRoleSet(m_pData.prototypeID);
        m_pViewUI.txt_heroDesc.text = _playerHelper.getRoleSet(m_pData.prototypeID);
        m_pViewUI.txt_desc.isHtml = true;
        m_pViewUI.txt_desc.text = _playerHelper.getRoleExpreience(m_pData.prototypeID);

        m_pViewUI.list_heroInfo.dataSource = _playerHelper.getHeroDetailInfo(m_pData.prototypeID);
    }

    /**
     * 培养属性
     */
    private function _updateAttrInfo():void
    {
        m_pViewUI.list_attr.dataSource = _playerHelper.getHeroDevelopAttrData(m_pData);
    }

    /**
     * 升阶
     */
    private function _updateQualityAdvanceInfo():void
    {
        if ( m_pData.qualityLevel.ID >= CPlayerHeroData.MAX_QUALITY_LEVEL )// 满阶
        {
            m_pViewUI.list_qualityConsume.dataSource = [];
            m_pViewUI.box_gold.visible = false;
            m_pViewUI.txt_teamLevel_qual.text = "格斗家满阶";
        }
        else
        {
            // 升下一品质消耗
            var itemIdArr:Array = [];
            var consumGold:Number = 0;
            var nextQualityCostTable:PlayerQualityConsume = m_pData.nextQualityConsume;
            if(nextQualityCostTable)
            {
                for(var i:int = 1; i <= 4; i++)
                {
                    var itemId : int = nextQualityCostTable["consumItemID" + i];
                    itemIdArr.push(itemId);
                }

                consumGold = nextQualityCostTable.consumGold;

                m_pViewUI.txt_teamLevel_qual.text = "战队" + nextQualityCostTable.teamLevel + "级开启";
                var teamLevel:int = (system as CPlayerSystem).playerData.teamData.level;
//                m_pViewUI.txt_teamLevel_qual.visible = teamLevel < nextQualityCostTable.teamLevel;
            }

            m_pViewUI.txt_teamLevel_qual.visible = false;

            m_pViewUI.list_qualityConsume.dataSource = itemIdArr;
            m_pViewUI.box_gold.visible = true;
            m_pViewUI.txt_gold.text = consumGold.toString();

            var playerData:CPlayerData = (system as CPlayerSystem).playerData;
            m_pViewUI.img_gold.url = "icon/item/small/jinbi.png";
            m_pViewUI.txt_gold.color = playerData.currency.gold >= consumGold ? 0xffffff : 0xff0000;
        }

        m_pViewUI.img_dian_qual.visible = _playerHelper.isHeroCanQualityAdvance(m_pData)
                && m_pData.qualityLevel.ID < CPlayerHeroData.MAX_QUALITY_LEVEL;
        m_pViewUI.clip_full_jie.visible = m_pData.qualityLevel.ID == CPlayerHeroData.MAX_QUALITY_LEVEL;
        m_pViewUI.btn_advance.visible = m_pData.quality < CPlayerHeroData.MAX_QUALITY_LEVEL;

        m_pViewUI.btn_advance.disabled = !m_pViewUI.img_dian_qual.visible;
        m_pViewUI.btn_advance.mouseEnabled = true;
        m_pViewUI.btn_advance.toolTip = _getNextQualPropTipInfo();

        m_pViewUI.list_qualityConsume.visible = m_pData.quality < CPlayerHeroData.MAX_QUALITY_LEVEL;
        m_pViewUI.box_gold.visible = m_pData.quality < CPlayerHeroData.MAX_QUALITY_LEVEL;
    }

    /**
     * 下阶属性预览
     */
    private function _getNextQualPropTipInfo():String
    {
        var str:String = "";
        var playerQualityConsume:PlayerQualityConsume = m_pData.nextQualityConsume;
        if(playerQualityConsume)
        {
            str += HtmlUtil.color("下一阶战队等级：" + playerQualityConsume.teamLevel + "级，", "#ffffff");
        }

        str += HtmlUtil.color("下一阶效果：", "#ffffff");
        var attrArr:Array = m_pViewUI.list_attr.dataSource as Array;
        for(var i:int = 0; i < attrArr.length; i++) {
            var attrData : CHeroAttrData = attrArr[ i ] as CHeroAttrData;

            str += ((HtmlUtil.color(attrData.getAttrNameCN(), "#ffffff") + HtmlUtil.color("+" + attrData.qualityUpValue + "，", "#00ff00")));
        }

        var len:int = str.length;
        return str.substring(0, len-8);
    }

    /**
     * 升级
     */
    private function _updateLevelUpInfo():void
    {
        m_pViewUI.txt_level.text = "Lv." + m_pData.level;
        m_pViewUI.progress_level_di.label = "";

        if ( m_pData.level == CPlayerHeroData.MAX_LEVEL )
        {
            m_pViewUI.progress_level.label = CLang.Get( "highLv" );
            m_pViewUI.progress_level.value = 1;
            m_pViewUI.progress_level_di.value = 1;
            m_pViewUI.txt_fullLevel.text = "格斗家满级" + m_pData.level + "级";
        }
        else
        {
            var progressValue : Number = 1;
            var currValue:int = m_pData.exp;
            var totalValue:int = m_pData.nextLevelConsume == null ? 0 : m_pData.nextLevelConsume.consumEXP;

            if(totalValue > 0)
            {
                progressValue = currValue / totalValue;
                m_pViewUI.progress_level.label = currValue + "/" + totalValue;
            }
            else
            {
                m_pViewUI.progress_level.label = "";
            }

            m_pViewUI.progress_level.value = progressValue;
            m_pViewUI.progress_level_di.value = progressValue;
        }

        m_pViewUI.img_dian_level.visible = _playerHelper.isHeroCanLevelUp(m_pData);
        m_pViewUI.clip_full_level.visible = m_pData.level >= CPlayerHeroData.MAX_LEVEL;
        m_pViewUI.btn_levelUp.visible = m_pData.level < CPlayerHeroData.MAX_LEVEL;
        m_pViewUI.progress_level.visible = m_pData.level < CPlayerHeroData.MAX_LEVEL;
        m_pViewUI.progress_level_di.visible = m_pData.level < CPlayerHeroData.MAX_LEVEL;
        m_pViewUI.txt_fullLevel.visible = m_pData.level >= CPlayerHeroData.MAX_LEVEL;
    }

    /**
     * 升星
     */
    private function _updateStarAdvanceInfo():void
    {
        m_pViewUI.list_star.dataSource = new Array(m_pData.star);

        if ( m_pData.star >= CPlayerHeroData.MAX_STAR_LEVEL )//满星
        {
            m_pViewUI.progress_star.value = 1;
            m_pViewUI.progress_star.label = CLang.Get("highStarLv");
            m_pViewUI.txt_teamLevel_star.visible = true;
            m_pViewUI.txt_teamLevel_star.text = "格斗家满星7星";

//            m_pViewUI.btn_get.visible = false;
//            m_pViewUI.btn_star.visible = true;
        }
        else
        {
            var progressValue : Number = 1;
            var piceData : CBagData = _bagManager.getBagItemByUid(m_pData.pieceID);
            var currValue:int = piceData == null ? 0 : piceData.num;
            var totalValue:int = m_pData.nextStarPieceCost;

            //万能碎片进度:
            commonPieceCostNum = 0;
            commonPieceBagData = null;
            m_pViewUI.img_common_piece.visible = false;
            //如果碎片不足，算出使用万能碎片代替的数量：
            if (currValue < totalValue) {
                commonPieceBagData = _playerHelper.getCommomPieceBagData(m_pData);
                var commonPieceOwnNum:int = commonPieceBagData == null ? 0 : commonPieceBagData.num;//当前拥有对应的万能碎片的数量
                commonPieceCostNum = Math.min(commonPieceOwnNum, Math.max(0, totalValue - currValue));//用于补足的万能碎片数量
            }
            //显示万能碎片进度条：
            if (commonPieceCostNum > 0) {
                m_pViewUI.img_common_piece.visible = true;
                var progresWidth:int = m_pViewUI.progress_star.comXml.@width;
                m_pViewUI.img_common_piece.width = progresWidth * (commonPieceCostNum/totalValue);
                m_pViewUI.img_common_piece.x = progresWidth * (currValue / totalValue);
            }

            if(totalValue > 0)
            {
                progressValue = currValue / totalValue;
                m_pViewUI.progress_star.label = (currValue + commonPieceCostNum) + "/" + totalValue;
            }
            else
            {
                m_pViewUI.progress_star.label = "";
            }

            m_pViewUI.progress_star.value = progressValue;

            var playerStarConsume:PlayerStarConsume = m_pData.getStarConsume(m_pData.star);
            if(playerStarConsume)
            {
                m_pViewUI.txt_teamLevel_star.text = "战队" + playerStarConsume.teamLevel + "级开启，升星提升属性百分比";
                var teamLevel:int = (system as CPlayerSystem).playerData.teamData.level;
//                m_pViewUI.txt_teamLevel_star.visible = teamLevel < playerStarConsume.teamLevel;
            }

            m_pViewUI.txt_teamLevel_star.visible = false;

//            m_pViewUI.btn_get.visible = currValue < totalValue;
//            m_pViewUI.btn_star.visible = currValue >= totalValue;
        }

        m_pViewUI.img_dian_star.visible = _playerHelper.isHeroCanStarAdvance(m_pData)
            && m_pData.star < CPlayerHeroData.MAX_STAR_LEVEL;
        m_pViewUI.clip_full_star.visible = m_pData.star >= CPlayerHeroData.MAX_STAR_LEVEL;
        m_pViewUI.btn_star.visible = m_pData.star < CPlayerHeroData.MAX_STAR_LEVEL;
        m_pViewUI.progress_star.visible = m_pData.star < CPlayerHeroData.MAX_STAR_LEVEL;
        m_pViewUI.img_chips.visible = m_pData.star < CPlayerHeroData.MAX_STAR_LEVEL;

        m_pViewUI.btn_star.toolTip = _getNextStarPropTipInfo();
    }

    /**
     * 下一星级属性预览
     */
    private function _getNextStarPropTipInfo():String
    {
        var str:String = "";
        var playerStarConsume:PlayerStarConsume = m_pData.getStarConsume(m_pData.star);
        if(playerStarConsume)
        {
            str += HtmlUtil.color("下一星战队等级：" + playerStarConsume.teamLevel + "级，", "#ffffff");
        }

        str += HtmlUtil.color("下一星效果：", "#ffffff");
        var attrArr:Array = m_pViewUI.list_attr.dataSource as Array;
        var addPercent:Number = _playerHelper.getNextStarAddPercent(m_pData) * 100;
        for(var i:int = 0; i < attrArr.length; i++) {
            var attrData : CHeroAttrData = attrArr[ i ] as CHeroAttrData;

            str += ((HtmlUtil.color("养成" + attrData.getAttrNameCN(), "#ffffff") + HtmlUtil.color("+" + addPercent + "%，", "#00ff00")));
        }

        var len:int = str.length;
        return str.substring(0, len-8);
    }

// 监听===================================================================================================
    private function _onRollOverHandler(e:MouseEvent):void
    {
        m_pViewUI.box_desc.visible = true;
        m_pViewUI.box_develop.visible = false;
    }

    private function _onRollOutHandler(e:MouseEvent):void
    {
        m_pViewUI.box_desc.visible = false;
        m_pViewUI.box_develop.visible = true;
    }

    private function _onBtnOverHandler(e:MouseEvent):void
    {
        var cells:Vector.<Box> = m_pViewUI.list_attr.cells;
        var attrArr:Array = m_pViewUI.list_attr.dataSource as Array;
        for(var i:int = 0; i < attrArr.length; i++)
        {
            var attrData:CHeroAttrData = attrArr[i] as CHeroAttrData;
            var render:Box = cells[i];
            var upValue:Label = render.getChildByName("txt_upValue") as Label;
//            var arrow:Image = render.getChildByName("img_arrow") as Image;

            if( e.target == m_pViewUI.btn_advance)
            {
                upValue.text = "+" + attrData.qualityUpValue.toString();
                upValue.visible = attrData.qualityUpValue > 0;
//                arrow.visible = attrData.qualityUpValue > 0;

                if(m_pData.quality < CPlayerHeroData.MAX_QUALITY_LEVEL)
                {
                    var nextName:String = _playerHelper.getHeroNextQualName(m_pData);
                    m_pViewUI.txt_heroName.isHtml = true;
                    m_pViewUI.txt_heroName.text = nextName;
                }
            }

            if( e.target == m_pViewUI.btn_levelUp)
            {
                upValue.text = "+" + attrData.levelUpValue.toString();
                upValue.visible = attrData.levelUpValue > 0;
//                arrow.visible = attrData.levelUpValue > 0;

                schedule(0.5, _showStuffView);
            }

            if(e.target == m_pViewUI.btn_star)
            {
                upValue.text = "+" + attrData.starUpValue.toString();
                upValue.visible = attrData.starUpValue > 0;
//                arrow.visible = attrData.starUpValue > 0;
            }
        }
    }

    private function _showStuffView(delta : Number):void
    {
        _levelUpStuffView.addDisplay(m_pViewUI, 0+30+114+3, 354+9-137);
    }

    private function _onBtnOutHandler(e:MouseEvent):void
    {
        var cells:Vector.<Box> = m_pViewUI.list_attr.cells;
        for(var i:int = 0; i < cells.length; i++)
        {
            var render:Box = cells[i];
            var upValue:Label = render.getChildByName("txt_upValue") as Label;
//            var arrow:Image = render.getChildByName("img_arrow") as Image;
            upValue.visible = false;
//            arrow.visible = false;
        }

        if( e.target == m_pViewUI.btn_levelUp)
        {
            if( e.localY < 34)
            {
                if(_levelUpStuffView.isViewShow)
                {
                    _levelUpStuffView.removeDisplay();
                }
            }

            unschedule(_showStuffView);
        }

        if( e.target == m_pViewUI.btn_advance)
        {
            m_pViewUI.txt_heroName.isHtml = true;
            m_pViewUI.txt_heroName.text = _playerHelper.getHeroWholeName(m_pData);
        }
    }

    /**
     * 打开/关闭详细属性
     * @param e
     */
    private function _onDetailPropClickHandler(e:MouseEvent):void
    {
        m_pViewUI.clip_arrow.index = m_pViewUI.clip_arrow.index == 0 ? 1 : 0;
        var propView:CHeroDetailPropViewHandler = system.getHandler(CHeroDetailPropViewHandler) as CHeroDetailPropViewHandler;
        if(propView)
        {
            if(propView.isViewShow)
            {
                propView.removeDisplay();
            }
            else
            {
                propView.data = m_pData;
                propView.parent = m_pViewUI.box_develop;
                propView.viewUI = m_pViewUI.view_detailProp;
                propView.addDisplay();
            }
        }
    }

    // 升品
    private function _onQualAdvanceHandler():void
    {
        if(CHeroDevelopState.isInQualAdvance)
        {
            (system.stage.getSystem(IUICanvas) as IUICanvas).showMsgAlert(CLang.Get("clientLockTips"));
            return;
        }

        if(m_pData)
        {
            if ( m_pData.quality >= CPlayerHeroData.MAX_QUALITY_LEVEL )
            {
                (system.stage.getSystem(IUICanvas) as IUICanvas).showMsgAlert("格斗家品阶已满！");
                return;
            }

            var nextQualityCostTable:PlayerQualityConsume = m_pData.nextQualityConsume;
            var teamLevel:int = (system as CPlayerSystem).playerData.teamData.level;
            if(nextQualityCostTable && teamLevel < nextQualityCostTable.teamLevel)
            {
                (system.stage.getSystem(IUICanvas) as IUICanvas).showMsgAlert("战队等级不足，请先将战队等级提升到"+nextQualityCostTable.teamLevel+"级");
                return;
            }

            if(m_pViewUI.txt_gold.color == 0xff0000)
            {
                _showAddGoldView();
                return;
            }

            _playerHelper.qualityResultData.oldAttr = (m_pViewUI.list_attr.dataSource as Array).concat();
            _playerHelper.qualityResultData.oldCombat = _getOldCombat();
            _playerHelper.qualityResultData.oldQualityName = _playerHelper.getHeroWholeName(m_pData);
            _playerHelper.qualityResultData.oldQualityLevelValue = m_pData.qualityLevelValue;
            _playerHelper.qualityResultData.heroId = m_pData.prototypeID;

            _heroNetHandler.sendHeroQuality(m_pData.prototypeID);
        }
    }

    private function _getOldCombat():int
    {
       return (system.getHandler(CHeroDevelopPanel) as CHeroDevelopPanel).heroCombat;
    }

    // 升级
    private function _onLevelUpHandler():void
    {
        if(CHeroDevelopState.isInLevelUpgrade)
        {
            (system.stage.getSystem(IUICanvas) as IUICanvas).showMsgAlert(CLang.Get("clientLockTips"));
            return;
        }

        if(m_pData)
        {
            if ( m_pData.level >= CPlayerHeroData.MAX_LEVEL )
            {
                (system.stage.getSystem(IUICanvas) as IUICanvas).showMsgAlert("格斗家已满级！");
                return;
            }

            var teamLevel:int = (system as CPlayerSystem).playerData.teamData.level;
            var nextLevelCostTable:PlayerLevelConsume;
            if ( m_pData.level >= CPlayerHeroData.MAX_LEVEL )//已经到顶级
            {
                nextLevelCostTable = m_pData.getLevelConsume( CPlayerHeroData.MAX_LEVEL );
            }
            else
            {
                nextLevelCostTable = m_pData.nextLevelConsume;
            }

            if(nextLevelCostTable && teamLevel < (nextLevelCostTable.teamLevel+1))// 升至下一级所需最小战队等级
            {
                (system.stage.getSystem(IUICanvas) as IUICanvas).showMsgAlert("战队等级不足，请先将战队等级提升到"+(nextLevelCostTable.teamLevel+1)+"级");
                return;
            }

            var stuffArr:Array = _playerHelper.getHeroSuccLevelUpStuff(m_pData);
            if(stuffArr.length == 0)
            {
                (system.stage.getSystem(IUICanvas) as IUICanvas).showMsgAlert("道具不足以升级！");
                return;
            }

            _playerHelper.levelResultData.oldAttr = (m_pViewUI.list_attr.dataSource as Array).concat();
            _playerHelper.levelResultData.heroId = m_pData.prototypeID;

            _heroNetHandler.sendHeroLevelUp(m_pData.prototypeID, stuffArr);
        }
    }

    // 升星
    private function _onStarAdvanceHandler():void
    {
        if(CHeroDevelopState.isInStarAdvance)
        {
            (system.stage.getSystem(IUICanvas) as IUICanvas).showMsgAlert(CLang.Get("clientLockTips"));
            return;
        }

        if(m_pData)
        {
            if ( m_pData.star >= CPlayerHeroData.MAX_STAR_LEVEL )
            {
                (system.stage.getSystem(IUICanvas) as IUICanvas).showMsgAlert("格斗家已满星！");
                return;
            }

            var pieceData : CBagData = _bagManager.getBagItemByUid(m_pData.pieceID);
            var currValue:int = pieceData == null ? 0 : pieceData.num;
            var totalValue:int = m_pData.nextStarPieceCost;


            if(currValue + commonPieceCostNum < totalValue)
            {
                _onOpenItemGetWay(m_pData.pieceID, totalValue);
            }
            else
            {
                if (commonPieceCostNum > 0) {//需要使用万能碎片补足，弹出确认框
                    var pieceCfg:Item = _bagManager.getItemTableByID(m_pData.pieceID);
                    var param:Object = {};
                    param.itemName = HtmlUtil.color(pieceCfg.name, CQualityColor.getColorByQuality(pieceCfg.quality));
                    param.itemNum = currValue;
                    param.commonItemName = HtmlUtil.color(commonPieceBagData.item.name, CQualityColor.getColorByQuality(commonPieceBagData.item.quality));
                    param.commonItemNum = commonPieceCostNum;
                    var msg:String = CLang.Get("hero_star_advance_confirm", param);
                    uiCanvas.showMsgBox(msg, _sendHeroStar, null, true, CLang.Get("common_ok"), CLang.Get("common_cancel"));
                } else {
                    _sendHeroStar();
                }

            }
        }
    }

    private function _sendHeroStar():void {
        _playerHelper.starResultData.oldAttr = (m_pViewUI.list_attr.dataSource as Array).concat();
        _playerHelper.starResultData.oldCombat = _getOldCombat();
        _playerHelper.starResultData.oldStar = m_pData.star;
        _playerHelper.starResultData.heroId = m_pData.prototypeID;

        _heroNetHandler.sendHeroStar(m_pData.prototypeID);
    }

    private function _onClickDescHandler():void
    {
        m_pViewUI.box_desc.visible = !m_pViewUI.box_desc.visible;
        m_pViewUI.box_develop.visible = !m_pViewUI.box_develop.visible;
    }

    /**
     * 物品获得途径
     */
    private function _onOpenItemGetWay(itemId:int, needNum:int):void
    {
        (system.stage.getSystem(CItemGetSystem) as CItemGetSystem).showItemGetPath(itemId,null,needNum);
    }

    /**
     * 升级、升品、升星后的更新
     */
    private function _onHeroDataUpdateHandler(e:CPlayerEvent):void
    {
        if(e.type == CPlayerEvent.HERO_DATA && m_pData.hasData)
        {
            updateDevelopInfo();

            _playerHelper.qualityResultData.newAttr = (m_pViewUI.list_attr.dataSource as Array).concat();
            _playerHelper.qualityResultData.newQualityName = m_pViewUI.txt_heroName.text;
            _playerHelper.qualityResultData.newQualityLevelValue = m_pData.qualityLevelValue;
            var newCombat:int = m_pData.battleValue;
            _playerHelper.qualityResultData.newCombat = newCombat;
            (system.getHandler(CHeroQualitySuccViewHandler) as CHeroQualitySuccViewHandler).updateInfo();

            _playerHelper.starResultData.newAttr = (m_pViewUI.list_attr.dataSource as Array).concat();
            _playerHelper.starResultData.newStar = m_pData.star;
            _playerHelper.starResultData.newCombat = newCombat;
            (system.getHandler(CHeroStarSuccViewHandler) as CHeroStarSuccViewHandler).updateInfo();

            _playerHelper.levelResultData.newAttr = _playerHelper.starResultData.newAttr;
            _levelUpPropChangeTip();
        }
    }

    /**
     * 升级属性变更提示
     */
    private function _levelUpPropChangeTip():void
    {
        if(_playerHelper.levelResultData.oldAttr && _playerHelper.levelResultData.newAttr)
        {
            var len:int = _playerHelper.levelResultData.newAttr.length;
            for(var i:int = 0; i < len; i++)
            {
                var newAttrData:CHeroAttrData = _playerHelper.levelResultData.newAttr[i];
                var oldAttrData:CHeroAttrData = _playerHelper.levelResultData.oldAttr[i];
                if(newAttrData && oldAttrData)
                {
                    var attrName:String = newAttrData.getAttrNameCN();
                    var addValue:int = newAttrData.attrBaseValue - oldAttrData.attrBaseValue;
//                    (system.stage.getSystem(IUICanvas) as CUISystem).showMsgAlert(attrName + " + " + addValue, CMsgAlertHandler.NORMAL);
                    (system.stage.getSystem(IUICanvas) as CUISystem).showPropMsgAlert(attrName, addValue, CMsgAlertHandler.NORMAL);
                }
            }

            _playerHelper.levelResultData.clearData();
        }
    }

    /**
     * 背包物品更新
     * @param e
     */
    private function _onBagItemsChangeHandler(e:CBagEvent):void
    {
        if(m_pData.hasData)
        {
            _updateQualityAdvanceInfo();
            _updateLevelUpInfo();
            _updateStarAdvanceInfo();
        }
    }

    /**
     * 战队升级
     * @param e
     */
    private function _onPlayerLevelUpHandler(e:CPlayerEvent):void
    {
        if(m_pData.hasData)
        {
            m_pViewUI.img_dian_level.visible = _playerHelper.isHeroCanLevelUp(m_pData);
            _updateQualityAdvanceInfo();
            _updateStarAdvanceInfo();
        }
    }

    /**
     * 显示预增的进度值
     * @param e
     */
    private function _onShowAddProgressHandler(e:CPlayerEvent):void
    {
        var data:Object = e.data;
        if(data)
        {
            var itemId:int = data.itemId as int;
            var itemNum:int = data.itemNum as int;
            var itemData:CItemData = _playerHelper.getItemData(itemId);
            var addExp:int = int(itemData.itemRecord.param4);
            var label:String = m_pViewUI.progress_level.label;
            if(label)
            {
                var arr:Array = label.split("/");
                if(arr && arr.length)
                {
                    var progressValue:Number = 0;
                    var currNum:int = int(arr[0]);
                    var totalNum:int = int(arr[1]);
                    if((currNum + addExp) >= totalNum)
                    {
                        progressValue = 1;
                    }
                    else
                    {
                        progressValue = (currNum + addExp) / totalNum;
                    }

                    m_pViewUI.progress_level_di.value = progressValue;
                }
            }
        }
        else
        {
            m_pViewUI.progress_level_di.value = m_pViewUI.progress_level.value;
        }
    }

    /**
     * 货币更新
     */
    private function _onCurrencyUpdateHandler(e:CPlayerEvent):void
    {
        m_pViewUI.img_dian_qual.visible = _playerHelper.isHeroCanQualityAdvance(m_pData)
                && m_pData.qualityLevel.ID < CPlayerHeroData.MAX_QUALITY_LEVEL;

        var playerData:CPlayerData = (system as CPlayerSystem).playerData;
        var ownGold:Number = playerData.currency.gold;
        var consumGold:int = int(m_pViewUI.txt_gold.text);
        m_pViewUI.txt_gold.color = (ownGold >= consumGold || ownGold < 0) ? 0xffffff : 0xff0000;
        m_pViewUI.btn_advance.disabled = !m_pViewUI.img_dian_qual.visible;
    }

// render===================================================================================================
    private function _renderHeroTag(item:Component, index:int):void
    {
        if(!(item is Box))
        {
            return;
        }

        var render:Box = item as Box;
        var data:Object = render.dataSource;
        var label:Label = render.getChildByName("txt_infoLabel") as Label;
        var content:Label = render.getChildByName("txt_infoContent") as Label;
        if(null != data)
        {
            label.text = data.label as String;
            content.isHtml = true;
            content.text = data.content as String;
        }
        else
        {
            label.text = "";
            content.text = "";
        }
    }

    private function _renderAttr(item:Component, index:int):void
    {
        if(!(item is Box))
        {
            return;
        }

        var render:Box = item as Box;
        var data:CHeroAttrData = render.dataSource as CHeroAttrData;
        var attrName:Label = render.getChildByName("txt_attrName") as Label;
        var attrValue:Label = render.getChildByName("txt_attrValue") as Label;
        var upValue:Label = render.getChildByName("txt_upValue") as Label;
//        var arrow:Image = render.getChildByName("img_arrow") as Image;
        upValue.visible = false;
//        arrow.visible = false;
        if(null != data)
        {
            attrName.text = data.getAttrNameCN();
            attrValue.text = data.attrBaseValue.toString();
        }
        else
        {
            attrName.text = "";
            attrValue.text = "";
            upValue.text = "";
//            arrow.url = "";
        }
    }

    private function _renderQualityItem(item:Component, index:int):void
    {
        if(!(item is HeroDevelopItemUI))
        {
            return;
        }

        var render:HeroDevelopItemUI = item as HeroDevelopItemUI;
        var itemId:int = render.dataSource as int;
        if(itemId)
        {
            var itemData : CItemData = _playerHelper.getItemData( itemId ); // 消耗物品
            var bagData : CBagData = _bagManager.getBagItemByUid( itemId ); // item1, 当前拥有
            var itemNum : int = 0;
            if ( !bagData )
            {
                itemNum = 0;
//                _isCanUpgrade = false;
            }
            else
            {
                itemNum = bagData.num;
            }

            render.clip_bg.index = itemData.quality;
            render.img_item.url = itemData.iconSmall;
            render.img_item.smoothing = true;
//            render.txt_num.isHtml = true;
            render.clip_eff.visible = itemData.effect;

            var needNum:int = m_pData.nextQualityConsume["numItemID" + (index + 1)] as int;
            render.link_get.clickHandler = new Handler(_onOpenItemGetWay,[itemId,needNum]);
            if (itemNum >= needNum)
            {
                render.img_black.visible = false;
//                render.txt_num.text = HtmlUtil.color(itemNum + "/" + needNum, "#ffffff");
                render.txt_num.text = itemNum + "/" + needNum;
                render.txt_num.color = 0xffffff;
                render.link_get.visible = false;
                render.addEventListener(MouseEvent.ROLL_OVER, onOverHandler);
                render.addEventListener(MouseEvent.ROLL_OUT, onOutHandler);
            }
            else
            {
                render.img_black.visible = true;
//                render.txt_num.text = HtmlUtil.color(itemNum + "/" + needNum, "#ff0000");
                render.txt_num.text = itemNum + "/" + needNum;
                render.txt_num.color = 0xff0000;
                render.link_get.visible = true;

                render.removeEventListener(MouseEvent.ROLL_OVER, onOverHandler);
                render.removeEventListener(MouseEvent.ROLL_OUT, onOutHandler);
            }

            function onOverHandler():void
            {
                if(render.txt_num.color == 0xff0000)
                {
                    return;
                }
                render.link_get.visible = true;
            }

            function onOutHandler():void
            {
                if(render.txt_num.color == 0xff0000)
                {
                    return;
                }
                render.link_get.visible = false;
            }

            if(render.txt_num.textField.textWidth > 52)
            {
                var len:int = render.txt_num.text.length;
                var startIndex:int = len - 7;
                render.txt_num.text = render.txt_num.text.substr(startIndex, len);
            }

            var goodsItem : GoodsItemUI = new GoodsItemUI();
            goodsItem.img.url = itemData.iconBig;
            goodsItem.quality_clip.index = render.clip_bg.index;
            goodsItem.txt.text = itemNum.toString();
            render.toolTip = new Handler( _showQualityTips, [ goodsItem, itemId ] );
        }
        else
        {
            render.img_black.visible = false;
            render.img_item.url = "";
            render.txt_num.text = "";
            render.link_get.visible = false;
            render.clip_eff.visible = false;
        }
    }

    private function _showQualityTips(item : GoodsItemUI, itemID : int) : void
    {
        _tipsView.showEquiMaterialTips(item, _playerHelper.getItemTableData(itemID), _playerHelper.getItemData(itemID));
    }

    public function clear():void
    {

    }

    private function _showAddGoldView() : void {
        var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as
                ISystemBundleContext;
        if ( pSystemBundleCtx ) {
            var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.BUY_MONEY ) );
            if ( pSystemBundle ) {
                pSystemBundleCtx.setUserData( pSystemBundle, "activated", true );
                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( CLang.Get( "goldNotEnough" ) );
            }
        }
    }

// property===================================================================================================
    public function set view(value:HeroDevelopViewUI):void
    {
        m_pViewUI = value;
    }

    public function get view():HeroDevelopViewUI
    {
        return m_pViewUI;
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    protected function get _playerHelper():CPlayerHelpHandler
    {
        return system.getHandler(CPlayerHelpHandler) as CPlayerHelpHandler;
    }

    private function get _bagManager():CBagManager
    {
        return system.stage.getSystem(CBagSystem ).getHandler(CBagManager) as CBagManager;
    }

    private function get _heroNetHandler():CHeroNetHandler
    {
        return system.getHandler(CHeroNetHandler) as CHeroNetHandler;
    }

    private function get _tipsView():CEquTipsView
    {
        if(m_pTipsView == null)
        {
            m_pTipsView = new CEquTipsView();
        }

        return m_pTipsView;
    }

    private function get _levelUpStuffView():CHeroLevelUpStuffView
    {
        return system.getHandler(CHeroLevelUpStuffView) as CHeroLevelUpStuffView;
    }

    override public function dispose():void
    {
        super.dispose();

        m_pViewUI = null;
        m_pData = null;
    }
}
}
