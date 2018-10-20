//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/10/10.
 */
package kof.game.endlessTower.view {

import com.greensock.TweenMax;

import flash.events.Event;

import flash.events.MouseEvent;
import flash.geom.Point;

import kof.SYSTEM_ID;
import kof.framework.CShowDialogTweenData;
import kof.framework.CViewHandler;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.bag.CBagEvent;
import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.bag.data.CBagData;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.character.property.CBasePropertyData;
import kof.game.common.CItemUtil;
import kof.game.common.CLang;
import kof.game.common.CRewardUtil;
import kof.game.common.CSystemRuleUtil;
import kof.game.common.hero.CHeroEmbattleListView;
import kof.game.common.status.CGameStatus;
import kof.game.common.view.CTweenViewHandler;
import kof.game.common.view.rewardTips.CRewardTips;
import kof.game.embattle.CEmbattleEvent;
import kof.game.embattle.CEmbattleSystem;
import kof.game.endlessTower.CEndlessTowerHelpHandler;
import kof.game.endlessTower.CEndlessTowerManager;
import kof.game.endlessTower.CEndlessTowerNetHandler;
import kof.game.endlessTower.CEndlessTowerUIHandler;
import kof.game.endlessTower.data.CEndlessTowerBoxData;
import kof.game.endlessTower.data.CEndlessTowerHeroData;
import kof.game.endlessTower.data.CEndlessTowerLayerData;
import kof.game.endlessTower.data.CEndlessTowerLayerData;
import kof.game.endlessTower.data.CEndlessTowerResultData;
import kof.game.endlessTower.enmu.EEndlessTowerLayerDataType;
import kof.game.endlessTower.enmu.ERewardTakeState;
import kof.game.endlessTower.event.CEndlessTowerEvent;
import kof.game.endlessTower.util.CEndlessUtil;
import kof.game.hook.CHookClientFacade;
import kof.game.instance.enum.EInstanceType;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.lobby.CLobbySystem;
import kof.game.lobby.view.CLobbyViewHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerHeroData;
import kof.game.rank.data.CRankConst;
import kof.game.shop.enum.EShopType;
import kof.table.EndlessTowerConst;
import kof.table.EndlessTowerLayerConfig;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;
import kof.ui.imp_common.HeroItemSmallUI;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.master.endlessTower.ETFloorItemUI;
import kof.ui.master.endlessTower.EndlessTowerWinUI;
import kof.util.TweenUtil;

import morn.core.components.Box;

import morn.core.components.Clip;

import morn.core.components.Component;

import morn.core.components.Dialog;
import morn.core.components.FrameClip;

import morn.core.handlers.Handler;

public class CEndlessTowerMainViewHandler extends CTweenViewHandler {

    private var m_bViewInitialized : Boolean;

    private var m_pViewUI : EndlessTowerWinUI;
    private var m_pCloseHandler : Handler;
    private var _heroEmbattleList:CHeroEmbattleListView;

    private var m_pCurrSelData:CEndlessTowerLayerData;
    private var m_pPropertyData:CBasePropertyData;
    private var m_iCurrPage:int = -1;
    private var m_iCurrSelIndex:int = -1;

    private var m_bIsAutoChallenge:Boolean;
    private var m_bIsExitInstance:Boolean;

    public function CEndlessTowerMainViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override protected function onSetup() : Boolean
    {
        var ret : Boolean = super.onSetup();
        _reqBaseInfo();

        return ret;
    }

    override public function get viewClass() : Array
    {
        return [ EndlessTowerWinUI ];
    }

    override protected function get additionalAssets() : Array
    {
        return ["endlesstower.swf", "frameclip_task.swf"];
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
                m_pViewUI = new EndlessTowerWinUI();

                m_pViewUI.closeHandler = new Handler( _onClose );
                m_pViewUI.btn_czbz.clickHandler = new Handler(_onClickCZBtn);
                m_pViewUI.btn_challenge.clickHandler = new Handler(_onClickChallenge);
                m_pViewUI.list_layer.repeatY = 11;
                m_pViewUI.list_layer.renderHandler = new Handler(_renderLayer);
                m_pViewUI.list_layer.selectHandler = new Handler(_onSelectHandler);

                m_pViewUI.btn_left.clickHandler = new Handler(_onClickLeftBtnHandler);
                m_pViewUI.btn_right.clickHandler = new Handler(_onClickRightBtnHandler);
                m_pViewUI.btn_reward.clickHandler = new Handler(_onClickRwardBtnHandler);
                m_pViewUI.btn_rank.clickHandler = new Handler(_onClickRankBtnHandler);
                m_pViewUI.btn_add.clickHandler = new Handler(_onClickAddBtnHandler);

                m_pViewUI.btn_up.clickHandler = new Handler(_onClickUpHandler);
                m_pViewUI.btn_down.clickHandler = new Handler(_onClickDownHandler);
                m_pViewUI.checkBox.clickHandler = new Handler(_onClickCheckBoxHandler);

                m_pViewUI.list_rewardItem.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system));
                CSystemRuleUtil.setRuleTips(m_pViewUI.img_tips, CLang.Get("endlessTower_rule"));

                m_pViewUI.img_door.mask = m_pViewUI.img_mask_door;
                m_pViewUI.panel.mask = m_pViewUI.img_mask_list;

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

    private function _addToDisplay() : void
    {
        setTweenData(KOFSysTags.ENDLESS_TOWER);
        showDialog(m_pViewUI, false, _onShowEnd);
    }

    private function _onShowEnd():void
    {
        _initView();
        _addListeners();
        _reqBaseInfo();
        _reqEmbattleInfo();
    }

    public function removeDisplay() : void {
        closeDialog(_removeDisplayB);

    }
    private function _removeDisplayB() : void {
        if(m_bViewInitialized)
        {
            _removeListeners();

            unschedule(_onAutoChallengeHandler);

            if (m_pViewUI && m_pViewUI.parent)
            {
                m_pViewUI.close(Dialog.CLOSE);
            }

            if(m_pCurrSelData)
            {
                m_pCurrSelData = null;
            }

            m_pViewUI.list_layer.dataSource = [];
//            m_pViewUI.list_rewardItem.dataSource = [];

            CEndlessUtil.currTakeBoxIndex = -1;
            m_pViewUI.list_layer.selectedIndex = -1;
            m_pPropertyData = null;

            if(TweenMax.isTweening(m_pViewUI.panel))
            {
                TweenMax.killTweensOf(m_pViewUI.panel);
            }

            if(TweenMax.isTweening(m_pViewUI.img_door))
            {
                TweenMax.killTweensOf(m_pViewUI.img_door);
            }

            for(var i:int = 0; i < m_pViewUI.list_layer.cells.length; i++)
            {
                var cell:ETFloorItemUI = m_pViewUI.list_layer.getCell(i) as ETFloorItemUI;
                if(cell)
                {
                    cell.removeEventListener(MouseEvent.ROLL_OVER, _onRollOverHandler);
                    cell.removeEventListener(MouseEvent.ROLL_OUT, _onRollOutHandler);
                }
            }

            for(i = 0; i < 8; i++)
            {
                var boxNum : int = i + 1;
                var box : Component = m_pViewUI[ "img_box_" + boxNum ];

                TweenMax.killTweensOf(box);
                box.filters = null;
            }

            m_iCurrPage = -1;
            m_iCurrSelIndex = -1;
            m_bIsExitInstance = false;
        }
    }

    private function _initView():void
    {
        delayCall(0.2,setData);
        function setData():void
        {
//            m_pViewUI.panel.vScrollBar.thumbPercent = 0.08;
            _defaultSelLayer();
        }

        m_pViewUI.panel.vScrollBar.mouseEnabled = false;

        updateDisplay();

        _fallDownAnimation();
    }

    private function _addListeners():void
    {
        system.stage.getSystem(CEmbattleSystem).addEventListener(CEmbattleEvent.EMBATTLE_SUCC,_onEmbattleUpdateHandler);
        system.addEventListener(CEndlessTowerEvent.DayRewardInfo_Update, _onDayRewardUpdateHandler);
        system.addEventListener(CEndlessTowerEvent.BoxRewardInfo_Update, _onBoxRewardUpdateHandler);
        system.stage.getSystem(CBagSystem).addEventListener(CBagEvent.BAG_UPDATE, _onBagItemUpdateHandler);
    }

    private function _removeListeners():void
    {
        system.stage.getSystem(CEmbattleSystem).removeEventListener(CEmbattleEvent.EMBATTLE_SUCC,_onEmbattleUpdateHandler);
        system.removeEventListener(CEndlessTowerEvent.DayRewardInfo_Update, _onDayRewardUpdateHandler);
        system.removeEventListener(CEndlessTowerEvent.BoxRewardInfo_Update, _onBoxRewardUpdateHandler);
        system.stage.getSystem(CBagSystem).removeEventListener(CBagEvent.BAG_UPDATE, _onBagItemUpdateHandler);

        m_pViewUI.panel.vScrollBar.changeHandler = null;
    }

    private function _reqEmbattleInfo():void
    {
        // 出战编制信息
        var embattleSystem:CEmbattleSystem = system.stage.getSystem(CEmbattleSystem) as CEmbattleSystem;
        var heroList:Array = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.embattleManager.getHeroListByType(EInstanceType.TYPE_ENDLESS_TOWER);
        if(heroList.length == 0)
        {
            embattleSystem.requestBestEmbattle(EInstanceType.TYPE_ENDLESS_TOWER);
        }
    }

    private function _reqBaseInfo():void
    {
        (system.getHandler(CEndlessTowerNetHandler) as CEndlessTowerNetHandler).endlessTowerDataRequest();
    }

    private function _defaultSelLayer():void
    {
        var currLayer:int = _manager.baseData.maxPassedLayer;
        var arr:Array = m_pViewUI.list_layer.dataSource as Array;
        if(arr && arr.length)
        {
            var currIndex:int;
            var nextIndex:int;
            var len:int = arr.length;
            for(var i:int = len - 1; i >= 0; i--)
            {
                var layer:int = (arr[i] as CEndlessTowerLayerData).layerId;
                var dataType:int = (arr[i] as CEndlessTowerLayerData).type;

                if(currLayer == layer && dataType == EEndlessTowerLayerDataType.Type_Hero)
                {
                    currIndex = i;
                }

                if(layer == (currLayer + 1) && dataType == EEndlessTowerLayerDataType.Type_Hero)
                {
                    nextIndex = i;

                    if(nextIndex == 0)// 最后一关
                    {
                        nextIndex = currIndex;
                    }
                }
            }

//            if(_helper.isBoxTaked(currLayer))
//            {
                m_pViewUI.list_layer.selectedIndex = nextIndex;
                m_pViewUI.panel.vScrollBar.value = (nextIndex-2) * 170 + 153;
//            }
//            else
//            {
//                m_pViewUI.list_layer.selectedIndex = currIndex;
//                m_pViewUI.panel.vScrollBar.value = (currIndex-2) * 170 + 153;
//            }
        }
    }

    private function _fallDownAnimation():void
    {
        TweenMax.fromTo(m_pViewUI.panel, 1, {y:-380-200}, {y:54});
        TweenMax.fromTo(m_pViewUI.img_door, 1, {y:146-200}, {y:580, onComplete:onCompleteHandler});

        function onCompleteHandler():void
        {
            m_pViewUI.panel.vScrollBar.changeHandler = new Handler(_onScrollChange);

            var resultData:CEndlessTowerResultData = (system.getHandler(CEndlessTowerManager) as CEndlessTowerManager).resultData;
            var isWin:Boolean = resultData == null ? false : resultData.isWin;
            if(m_bIsExitInstance && isWin)
            {
                autoChallenge();
            }
        }
    }

    override protected function updateDisplay():void
    {
        _updateEmbattleHeroList();
        _updateLayerInfo();
        _updateLayerAndExtraInfo();
        _updateRewardInfo();
        _updateDailyRewardTips();
        _updateConsumeInfo();
        _updateCurrPassLayer();
        _updateBtnState();
        _updateCheckBox();
    }

    /**
     * 更新出战编制格斗家列表
     */
    private function _updateEmbattleHeroList():void
    {
        if (_heroEmbattleList == null)
        {
            m_pViewUI.list_hero.mouseHandler = new Handler(function (e:MouseEvent, idx:int) : void {
                if (e.type == MouseEvent.CLICK) {
                    _onClickAddHandler();
                }
            });
            _heroEmbattleList = new CHeroEmbattleListView(system, m_pViewUI.list_hero, EInstanceType.TYPE_ENDLESS_TOWER, null);
//            _heroEmbattleList = new CHeroEmbattleListView(system, m_pViewUI.list_hero, EInstanceType.TYPE_ENDLESS_TOWER, new Handler(_onClickAddHandler));
        }
        _heroEmbattleList.updateWindow();
    }

    private function _onClickAddHandler():void
    {
        _openEmbattle();
    }

    //出站编制===========================================================================================================
    private function _openEmbattle():void
    {
        var pSystemBundleCtx : ISystemBundleContext = CHookClientFacade.instance.hookSystem.stage.getSystem( ISystemBundleContext ) as
                ISystemBundleContext;
        if ( pSystemBundleCtx )
        {
            var fighterCount : int = 3;
            var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.EMBATTLE ) );

//            var layerData:CEndlessTowerLayerData = m_pViewUI.list_layer.selectedItem as CEndlessTowerLayerData;
            if(m_pCurrSelData == null)
            {
                return;
            }

            var enemyListData:Array = _helper.getEmbattleEnemyList(m_pCurrSelData.dataArr);
            for (var i:int = 0; i < enemyListData.length; i++)
            {
                var enemyData:CPlayerHeroData = enemyListData[i];
                if (enemyData)
                {
                    enemyData.setHp(1);
                    enemyData.setMaxHp(1);
                }
            }

            pSystemBundleCtx.setUserData( pSystemBundle, 'embattle_args', [EInstanceType.TYPE_ENDLESS_TOWER, fighterCount, true, true, true, enemyListData]);
            pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, true );
        }
    }

    private function _updateLayerInfo():void
    {
        var currLayer:int = _manager.baseData.maxPassedLayer;
        var layerDatas:Array = _helper.getTenLayerData(currLayer);

        if(m_pViewUI.list_layer.repeatY != layerDatas.length)
        {
            m_pViewUI.list_layer.repeatY = layerDatas.length;
            m_pViewUI.panel.refresh();
        }

        m_pViewUI.list_layer.dataSource = layerDatas;

        var layer:int = (layerDatas[layerDatas.length - 1] as CEndlessTowerLayerData).layerId;
        _currPage = Math.ceil(layer / 40);
    }

    /**
     * 层数和挑战者列表
     */
    private function _updateLayerAndExtraInfo():void
    {
        if(m_pCurrSelData)
        {
            m_pViewUI.txt_layer.num = m_pCurrSelData.layerId;
            m_pViewUI.txt_layer.centerX = 0;

            var info:EndlessTowerLayerConfig = _helper.getLayerConfigInfo(m_pCurrSelData.layerId);
            if(info)
            {
                m_pViewUI.txt_requireLevel.text = info.needLevel + "级";

                if(m_pPropertyData == null)
                {
                    m_pPropertyData = new CBasePropertyData();
                    m_pPropertyData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
                }

                // 推荐属性
                m_pPropertyData.clearAll();
                var attrInfo:String = info.suggestProperty;
                var arr:Array = attrInfo.split(":");
                var attrType:int = int(arr[0]);
                var attrValue:int = int(arr[1]);
                var attrNameEN:String;
                if(attrType == 1)
                {
                    attrNameEN = CBasePropertyData._Attack;
                    m_pPropertyData.Attack = attrValue;
                }
                else if(attrType == 2)
                {
                    attrNameEN = CBasePropertyData._Defense;
                    m_pPropertyData.Defense = attrValue;
                }

                m_pViewUI.txt_suggestPropLabel.text = CLang.Get("endless_suggestPropLabel", {v1:m_pPropertyData.getAttrNameCN(attrNameEN)});
                m_pViewUI.txt_suggestPropValue.text = CLang.Get("endless_suggestPropValue", {v1:attrValue});

                m_pViewUI.txt_powerRecover.text = info.describeBuff ? info.describeBuff : "";
            }
        }
    }

    /**
     * 通关奖励
     */
    private function _updateRewardInfo():void
    {
        if(m_pCurrSelData)
        {
            m_pViewUI.img_firstReward.visible = _helper.isFirstPass(m_pCurrSelData.layerId);
            m_pViewUI.img_commonReward.visible = !_helper.isFirstPass(m_pCurrSelData.layerId);
            var dropId:int = _helper.getPassRewardDropId(m_pCurrSelData.layerId);
            var rewardListData:CRewardListData = CRewardUtil.createByDropPackageID(system.stage, dropId);

            if(rewardListData)
            {
                var rewardArr:Array = rewardListData.list;
                m_pViewUI.list_rewardItem.dataSource = rewardArr;

                var listWidth:int = 52 * rewardArr.length + m_pViewUI.list_rewardItem.spaceX * (rewardArr.length-1);
                m_pViewUI.list_rewardItem.x = 290 - listWidth >> 1;
                _updatePageBtnState();
            }
            else
            {
                m_pViewUI.list_rewardItem.dataSource = [];
                m_pViewUI.btn_left.visible = false;
                m_pViewUI.btn_right.visible = false;
            }
        }
    }

    private function _updateDailyRewardTips():void
    {
        m_pViewUI.btn_reward.dataSource = _helper.getEveryDayBoxRewardId();
        m_pViewUI.btn_reward.label = "";
        var currLayer:int = _manager.baseData.maxPassedLayer;
        var dayRewardTakeLayer:int = _manager.baseData.dayRewardTakeLayer;
        var status:int;
        if(currLayer == dayRewardTakeLayer)
        {
            status = CRewardTips.REWARD_STATUS_HAS_REWARD;
        }
        else
        {
            status = CRewardTips.REWARD_STATUS_CAN_REWARD;
        }

        var itemSystem:CItemSystem = system.stage.getSystem(CItemSystem) as CItemSystem;
        var tipsHandler:Handler = new Handler(itemSystem.showRewardTips, [m_pViewUI.btn_reward, [CLang.Get("endless_DailyReward_tips_desc"), status, 1]]);
        m_pViewUI.btn_reward.toolTip = tipsHandler;

        m_pViewUI.img_dian.visible = _helper.hasDailyReward();
    }

    private function _updatePageBtnState():void
    {
        var dataArr:Array = m_pViewUI.list_rewardItem.dataSource as Array;
        if(dataArr && dataArr.length)
        {
            m_pViewUI.btn_left.visible = dataArr.length > 4;
            m_pViewUI.btn_right.visible = dataArr.length > 4;
            m_pViewUI.btn_left.disabled = m_pViewUI.list_rewardItem.page == 0;
            m_pViewUI.btn_right.disabled = m_pViewUI.list_rewardItem.page == (m_pViewUI.list_rewardItem.totalPage-1);
        }
        else
        {
            m_pViewUI.btn_left.visible = false;
            m_pViewUI.btn_right.visible = false;
        }
    }

    /**
     * 消耗道具
     */
    private function _updateConsumeInfo():void
    {
        var constInfo:EndlessTowerConst =  _helper.getTowerConstInfo();
        if(constInfo)
        {
            m_pViewUI.txt_ticket.text = "挑战券*" + constInfo.challengeCostItemNum.toString();

            var bagManager:CBagManager = system.stage.getSystem(CBagSystem ).getHandler(CBagManager) as CBagManager;
            var bagData : CBagData = bagManager.getBagItemByUid( constInfo.challengeCostItemId );
//            m_pViewUI.txt_ticket.color = (bagData && bagData.num > 0) ? 0xffffff : 0xff0000;

            var ownNum:int = bagData == null ? 0 : bagData.num;
            m_pViewUI.txt_ownTicket.text = "(拥有:" + ownNum + ")";

            if(m_pViewUI.img_ticket.toolTip == null)
            {
                m_pViewUI.img_ticket.toolTip = new Handler( _showTips, [m_pViewUI.img_ticket, _helper.getConsumeItemId()] );
            }
        }
    }

    /**
     * 物品tips
     * @param item
     * @param itemId
     */
    private function _showTips(item:Component,itemId:int):void
    {
        (system.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView, item, [itemId]);
    }

    /**
     * 当前通关层
     */
    private function _updateCurrPassLayer():void
    {
        var currLayer:int = _manager.baseData.maxPassedLayer;

        m_pViewUI.txt_currLayer.text = CLang.Get("endless_currPassLayer", {v1:currLayer});
    }

    /**
     * 挑战/扫荡
     */
    private function _updateBtnState():void
    {
        if(m_pCurrSelData)
        {
            var currLayer:int = _manager.baseData.maxPassedLayer;
            m_pViewUI.btn_challenge.label = m_pCurrSelData.layerId <= currLayer ? "扫荡关卡" : "开始挑战";
        }
    }

    private function _updateCheckBox():void
    {
        m_pViewUI.checkBox.label = "勾选自动挑战下一关";
        m_pViewUI.checkBox.labelSize = 14;
        m_pViewUI.checkBox.selected = m_bIsAutoChallenge;
    }

    /**
     * 每日奖励领取状态
     */
    private function _updateDailyRewardState():void
    {
        _updateDailyRewardTips();
    }

    /**
     * 宝箱领取后的更新操作
     */
    private function _updateBoxRewardState():void
    {
        m_pViewUI.list_layer.refresh();
    }

    //点按钮处理=========================================================================================================
    /**
     * 出战编制
     */
    private function _onClickCZBtn():void
    {
        _openEmbattle();
    }

    private function _onClickChallenge():void
    {
        if(!CGameStatus.checkStatus(system))
        {
            return;
        }

        if(m_pCurrSelData)
        {
            var currLayer:int = _manager.baseData.maxPassedLayer;
            var selLayer : int = m_pCurrSelData.layerId;

            if(selLayer > currLayer)
            {
                if(!selLayer)
                {
                    (system.stage.getSystem(CUISystem) as CUISystem).showMsgAlert("请先选择要挑战的关卡");
                    return;
                }
                _netHandler.endlessTowerChallengeRequest(selLayer);
            }
            else
            {
                if(!selLayer)
                {
                    (system.stage.getSystem(CUISystem) as CUISystem).showMsgAlert("请先选择要扫荡的关卡");
                    return;
                }
                _netHandler.endlessTowerSweepRequest(selLayer, 1);
            }
        }
    }

    private function _onClickLeftBtnHandler():void
    {
        _updatePageBtnState();
    }

    private function _onClickRightBtnHandler():void
    {
        _updatePageBtnState();
    }

    private function _onClickRwardBtnHandler():void
    {
        if(_manager.baseData.dayRewardTakeLayer != _manager.baseData.maxPassedLayer)
        {
            _netHandler.takeDayReward();
        }
        else
        {
            (system.stage.getSystem(CUISystem) as CUISystem).showMsgAlert("无奖励可领取");
        }
    }

    private function _onClickRankBtnHandler():void
    {
        var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
        var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.RANKING));
        bundleCtx.setUserData(systemBundle, CBundleSystem.RANK_TYPE, [5]);
        bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
    }

    private function _onClickAddBtnHandler():void
    {
        var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
        var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.MALL));
        bundleCtx.setUserData(systemBundle, "shop_type", [EShopType.SHOP_TYPE_3]);
        bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
    }

    private function _onClickUpHandler():void
    {
        _currPage = _currPage + 1;
        _updateLayerInfoOnPage();
    }

    private function _onClickDownHandler():void
    {
        _currPage = _currPage - 1;
        _updateLayerInfoOnPage();
    }

    private function _updateLayerPageBtnState():void
    {
        var maxPage:int = Math.ceil(_helper.maxLayer / 40);
        m_pViewUI.btn_up.disabled = _currPage == maxPage;
        m_pViewUI.btn_down.disabled = _currPage == 1;
    }

    /**
     * 翻页时更新中间层级信息
     */
    private function _updateLayerInfoOnPage():void
    {
        var layerDatas:Array = _helper.getLayerDataByPage(_currPage);

        if(m_pViewUI.list_layer.repeatY != layerDatas.length)
        {
            m_pViewUI.list_layer.repeatY = layerDatas.length;
            m_pViewUI.panel.refresh();
            m_pViewUI.list_layer.selectedIndex = -1;
        }

        m_pViewUI.list_layer.dataSource = layerDatas;
        m_pViewUI.panel.vScrollBar.value = m_pViewUI.panel.vScrollBar.max-1;
        m_pViewUI.panel.vScrollBar.mouseEnabled = false;
    }

    /**
     * 进度条宝箱tips信息
     */
    private function _updateProgressBoxTipInfo():void
    {
        var startLayer:int = (_currPage - 1) * 40 + 1;

        for(var i:int = 0; i < 8; i++)
        {
            var layerId:int = startLayer + 5 * (i + 1) - 1;

            var state : int = _helper.getLayerBoxTakeState(layerId, 0);
            var boxDatas:Array = _helper.getBoxDatasById(layerId);
            var boxNum:int = i+1;
            var box:Component = m_pViewUI["img_box_"+boxNum ];
            box.dataSource = (boxDatas[0 ] as CEndlessTowerBoxData).boxRewardId;

            var status:int = _getStatus(state);
            var itemSystem:CItemSystem = system.stage.getSystem(CItemSystem) as CItemSystem;
            var tipsHandler:Handler = new Handler(itemSystem.showRewardTips, [box, [CLang.Get("endless_boxReward_tips_desc",{v1:layerId}), status, 1]]);
            box.toolTip = tipsHandler;

            if(state == ERewardTakeState.CanTake)
            {
                if(!TweenMax.isTweening(box))
                {
                    TweenUtil.lighting(box, 0.4, -1);
                }
            }
            else
            {
                if(TweenMax.isTweening(box))
                {
                    TweenMax.killTweensOf(box);
                    box.filters = null;
                }
            }
        }
    }

    /**
     * 进度条信息
     */
    private function _updateProgressInfo():void
    {
        var currLayer:int = _manager.baseData.maxPassedLayer;
        var inPage:int = Math.ceil(currLayer / 40);
        if(inPage < _currPage)
        {
            m_pViewUI.progress_bar.value = 0;
        }
        else if(inPage > _currPage)
        {
            m_pViewUI.progress_bar.value = 1;
        }
        else
        {
            m_pViewUI.progress_bar.value = currLayer / (_currPage * 40);
        }
    }

    private function _onSelectHandler(index:int):void
    {
        if(index == -1)
        {
            return;
        }

        var layerData:CEndlessTowerLayerData = m_pViewUI.list_layer.getItem(index) as CEndlessTowerLayerData;
        if(layerData.type == EEndlessTowerLayerDataType.Type_Box)
        {
            return;
        }

        var layer:int;
        var maxPassedLayer:int = _manager.baseData.maxPassedLayer;
//        if(_helper.isBoxTaked(maxPassedLayer))
//        {
            layer = maxPassedLayer + 1;
//        }
//        else
//        {
//            layer = maxPassedLayer;
//        }

        if(layerData.layerId > layer)
        {
            return;
        }

        m_pCurrSelData = layerData;

        var cell1:ETFloorItemUI = m_pViewUI.list_layer.getCell(m_iCurrSelIndex) as ETFloorItemUI;
        if(cell1)
        {
            cell1.clip_select.visible = false;
        }

        var cell2:ETFloorItemUI = m_pViewUI.list_layer.getCell(index) as ETFloorItemUI;
        if(cell2)
        {
            cell2.clip_select.visible = true;
        }

        m_iCurrSelIndex = index;

        _updateLayerAndExtraInfo();
        _updateRewardInfo();
        _updateConsumeInfo();
        _updateBtnState();
    }

    private function _onScrollChange(value:int) : void
    {
        var max:int = m_pViewUI.panel.vScrollBar.max;
        var min:int = m_pViewUI.panel.vScrollBar.min;

        if(value >= max)
        {
            var firstInLayer:int = _getFirstInLayer();
            if(firstInLayer > 1)
            {
                var currLayerDatas:Array = m_pViewUI.list_layer.dataSource as Array;
                var layerDatas:Array = _helper.getPrevLayerData(firstInLayer, currLayerDatas);

                // 滚动条长度
                if(m_pViewUI.list_layer.repeatY != layerDatas.length)
                {
                    m_pViewUI.list_layer.repeatY = layerDatas.length;
                    m_pViewUI.panel.refresh();
                    m_pViewUI.list_layer.selectedIndex = -1;
                }

                m_pViewUI.list_layer.dataSource = layerDatas;
                m_pViewUI.panel.vScrollBar.value = 1;
                m_pViewUI.panel.vScrollBar.mouseEnabled = false;

                // 左边进度信息
                var layer:int = (layerDatas[layerDatas.length - 1] as CEndlessTowerLayerData).layerId;
                _currPage = Math.ceil(layer / 40);
            }
        }

        if(value <= min)
        {
            var lastInLayer:int = _getLastInLayer();
            if(lastInLayer < _helper.maxLayer)
            {
                currLayerDatas = m_pViewUI.list_layer.dataSource as Array;
                layerDatas = _helper.getNextLayerData(lastInLayer, currLayerDatas);

                if(m_pViewUI.list_layer.repeatY != layerDatas.length)
                {
                    m_pViewUI.list_layer.repeatY = layerDatas.length;
                    m_pViewUI.panel.refresh();
                    m_pViewUI.list_layer.selectedIndex = -1;
                }

                m_pViewUI.list_layer.dataSource = layerDatas;
                m_pViewUI.panel.vScrollBar.value = m_pViewUI.panel.vScrollBar.max-1;
                m_pViewUI.panel.vScrollBar.mouseEnabled = false;

                layer = (layerDatas[layerDatas.length - 1] as CEndlessTowerLayerData).layerId;
                _currPage = Math.ceil(layer / 40);
            }
        }
    }

    private function _getFirstInLayer():int
    {
        var arr:Array = m_pViewUI.list_layer.dataSource as Array;
        if(arr && arr.length)
        {
            var layerData:CEndlessTowerLayerData = arr[arr.length-1] as CEndlessTowerLayerData;
            return layerData.layerId;
        }

        return 0;
    }

    private function _getLastInLayer():int
    {
        var arr:Array = m_pViewUI.list_layer.dataSource as Array;
        if(arr && arr.length)
        {
            var layerData:CEndlessTowerLayerData = arr[0] as CEndlessTowerLayerData;
            return layerData.layerId;
        }

        return 0;
    }

    private function _onClose( type : String ) : void
    {
        switch ( type )
        {
            default:
                if ( this.closeHandler )
                {
                    this.closeHandler.execute();
                }
                break;
        }
    }

    private function _onClickCheckBoxHandler():void
    {
        isAutoChallenge = m_pViewUI.checkBox.selected;
    }

//事件监听==========================================================================================================
    private function _onEmbattleUpdateHandler(e:CEmbattleEvent):void
    {
        _updateEmbattleHeroList();
    }

    private function _onDayRewardUpdateHandler(e:CEndlessTowerEvent):void
    {
        _updateDailyRewardState();
    }

    private function _onBoxRewardUpdateHandler(e:CEndlessTowerEvent):void
    {
        _updateBoxRewardState();
        _updateProgressBoxTipInfo();

        _defaultSelLayer();
    }

    private function _onBagItemUpdateHandler(e:Event):void
    {
        _updateConsumeInfo();
    }


//渲染List==========================================================================================================
    private function _renderLayer(item:Component, index:int):void
    {
        if ( !(item is ETFloorItemUI) )
        {
            return;
        }

        var render:ETFloorItemUI = item as ETFloorItemUI;
        render.mouseChildren = true;
        render.mouseEnabled = true;
        var layerData:CEndlessTowerLayerData = render.dataSource as CEndlessTowerLayerData;
        if(layerData)
        {
//            render.img_heroBg.visible = layerData.type == EEndlessTowerLayerDataType.Type_Hero;
            render.txt_layer.visible = layerData.type == EEndlessTowerLayerDataType.Type_Hero;
            render.item_0.visible = layerData.type == EEndlessTowerLayerDataType.Type_Hero;
            render.item_1.visible = layerData.type == EEndlessTowerLayerDataType.Type_Hero;
            render.item_2.visible = layerData.type == EEndlessTowerLayerDataType.Type_Hero;
            render.box_layerBox.visible = layerData.type == EEndlessTowerLayerDataType.Type_Box;
            var currLayer:int = _manager.baseData.maxPassedLayer == 0 ? 1 : _manager.baseData.maxPassedLayer;
//            render.img_currLayer.visible = layerData.layerId == currLayer && layerData.type == EEndlessTowerLayerDataType.Type_Hero;
            render.img_pass.visible = layerData.layerId <= currLayer;

            if(layerData.type == EEndlessTowerLayerDataType.Type_Hero)
            {
                _renderHeroInfo(render,index);
            }
            else if(layerData.type == EEndlessTowerLayerDataType.Type_Box)
            {
                _renderBoxInfo(render);
            }

            if(index == m_iCurrSelIndex && m_pCurrSelData && m_pCurrSelData.layerId == layerData.layerId)
            {
                render.clip_select.visible = true;
            }
            else
            {
                render.clip_select.visible = false;
            }
        }
        else
        {
            render.txt_layer.text = "";
//            render.img_heroBg.visible = false;
            render.item_0.visible = false;
            render.item_1.visible = false;
            render.item_2.visible = false;
            render.box_layerBox.visible = false;
            render.img_pass.visible = false;
            render.clip_select.visible = false;
        }
    }

    private function _onRollOverHandler(e:MouseEvent):void
    {
        var item:ETFloorItemUI = e.target as ETFloorItemUI;
        if(item && item.dataSource)
        {
            var layerData:CEndlessTowerLayerData = item.dataSource as CEndlessTowerLayerData;
            if(layerData && layerData.type == EEndlessTowerLayerDataType.Type_Hero)
            {
                var layer:int;
                var maxPassedLayer:int = _manager.baseData.maxPassedLayer;
//                if(_helper.isBoxTaked(maxPassedLayer))
//                {
                    layer = maxPassedLayer + 1;
//                }
//                else
//                {
//                    layer = maxPassedLayer;
//                }

                if(layerData.layerId <= layer)
                {
//                    item.clip_select.visible = true;
                }
            }
        }
    }

    private function _onRollOutHandler(e:MouseEvent):void
    {
        var item:ETFloorItemUI = e.target as ETFloorItemUI;
        if(item)
        {
//            item.clip_select.visible = false;
        }
    }

    /**
     * 每层的格斗家信息
     * @param render
     * @param index
     */
    private function _renderHeroInfo(render:ETFloorItemUI, index:int):void
    {
        render.item_0.visible = false;
        render.item_1.visible = false;
        render.item_2.visible = false;

        render.clip_titleBg.visible = true;

        var layerData:CEndlessTowerLayerData = render.dataSource as CEndlessTowerLayerData;
        var currLayer:int = _manager.baseData.maxPassedLayer;
        var heroArr:Array = layerData.dataArr;
        for(var i:int = 0; i < heroArr.length; i++)
        {
            var heroData:CEndlessTowerHeroData = heroArr[i];
            var heroItem:HeroItemSmallUI = render["item_" + i];
            heroItem.visible = true;
            render.txt_layer.text = "第 " + heroData.layerId + " 层";
            render.txt_layer.centerX = 0;

            heroItem.icon_image.visible = true;
            heroItem.quality_clip.index = _helper.getQualityColor(heroData.quality) + 1;
//            var currLayer:int = _manager.baseData.maxPassedLayer == 0 ? 1 : _manager.baseData.maxPassedLayer;
            if(heroData.layerId > currLayer)
            {
                if(heroData.layerId == currLayer + 1)
                {
                    heroItem.icon_image.url = CPlayerPath.getHeroSmallIconPath(heroData.heroId);
                    heroItem.icon_image.width = 46;
                    heroItem.icon_image.height = 46;
                }
                else
                {
                    heroItem.icon_image.url = "icon/item/small/wenhao.png";
                    heroItem.icon_image.width = 44;
                    heroItem.icon_image.height = 44;

                    heroItem.dataSource = _helper.getPassRewardDropId(heroData.layerId);
                    var status:int = _getStatus(ERewardTakeState.CannotTake);
                    var itemSystem:CItemSystem = system.stage.getSystem(CItemSystem) as CItemSystem;
                    var tipsHandler:Handler = new Handler(itemSystem.showRewardTips, [heroItem, [CLang.Get("endless_reward_tips_desc"), status, 1]]);
                    heroItem.toolTip = tipsHandler;
                }
            }
            else
            {
                heroItem.icon_image.url = CPlayerPath.getHeroSmallIconPath(heroData.heroId);
                heroItem.icon_image.width = 46;
                heroItem.icon_image.height = 46;

            }
        }

        if(layerData.layerId <= currLayer)
        {
            render.clip_titleBg.index = heroArr.length > 1 ? 1 : 0;
            render.img_pass.visible = true;

            if(layerData.layerId == currLayer && !_helper.isBoxTaked(currLayer))
            {
//                render.clip_select.visible = true;
//                m_iCurrSelIndex = index;
            }
        }
        else
        {
            if(layerData.layerId == currLayer + 1)// 即将打的那一层
            {
                render.clip_titleBg.index = heroArr.length > 1 ? 1 : 0;
                render.img_pass.visible = false;
            }
            else
            {
                render.clip_titleBg.index = 2;
                render.img_pass.visible = false;
            }
        }

        var boxWidth:int = 59 * heroArr.length - 4;
        var dtX:int = 208 - boxWidth >> 1;
        render.item_0.x = 174-20 + dtX;
        render.item_1.x = 174-20 + dtX + 59;
        render.item_2.x = 174-20 + dtX + 59 * 2;
    }

    /**
     * 每层的宝箱信息
     * @param render
     */
    private function _renderBoxInfo(render:ETFloorItemUI):void
    {
        render.clip_box_0.visible = false;
        render.clip_box_1.visible = false;
        render.clip_box_2.visible = false;

        render.frameclip_eff_0.visible = false;
        render.frameclip_eff_1.visible = false;
        render.frameclip_eff_2.visible = false;

        render.img_pass.visible = false;
        render.clip_titleBg.visible = false;

        var layerData:CEndlessTowerLayerData = render.dataSource as CEndlessTowerLayerData;
        var boxArr:Array = layerData.dataArr;
        if(boxArr && boxArr.length)
        {
            var layerId:int = layerData.layerId;
            for(var i:int = 0; i < boxArr.length; i++)
            {
                var box:Clip = render["clip_box_" + i] as Clip;
                var effect:FrameClip = render["frameclip_eff_" + i] as FrameClip;

                var boxData:CEndlessTowerBoxData = boxArr[i];
                var count : int = 0;
                var dropId : int = boxData.boxRewardId;
                box.visible = dropId > 0;

                if(dropId)
                {
                    count++;

                    var state : int = _helper.getLayerBoxTakeState(layerId, i);
                    effect.visible = state == ERewardTakeState.CanTake;
                    effect.autoPlay = state == ERewardTakeState.CanTake;

//                    box.toolTip = new Handler(_showBoxTips, [dropId, layerId, i]);
                    box.dataSource = dropId;
                    box.index = state == ERewardTakeState.HasTake ? 1 : 0;

                    var status:int = _getStatus(state);
                    var itemSystem:CItemSystem = system.stage.getSystem(CItemSystem) as CItemSystem;
                    var tipsHandler:Handler = new Handler(itemSystem.showRewardTips, [box, [CLang.Get("endless_boxReward_tips_desc",{v1:layerData.layerId}), status, 1]]);
                    box.toolTip = tipsHandler;
                    box.tag = {layerId:layerId, boxIndex:i};
                    box.addEventListener(MouseEvent.CLICK, _onClickLayerBoxHandler);
                }
            }
            var boxWidth:int = 78 * count;
            render.box_layerBox.x = 170-20 + (223 - boxWidth >> 1);
        }
    }

    private function _getStatus(state:int):int
    {
        var status:int;
        switch (state)
        {
            case ERewardTakeState.HasTake:
                status = CRewardTips.REWARD_STATUS_HAS_REWARD;
                break;
            case ERewardTakeState.CannotTake:
                status = CRewardTips.REWARD_STATUS_OTHER_1;
                break;
            case ERewardTakeState.CanTake:
                status = CRewardTips.REWARD_STATUS_CAN_REWARD;
                break;
        }

        return status;
    }

    /**
     * 点击领取宝箱
     */
    private function _onClickLayerBoxHandler(e:MouseEvent):void
    {
        var box:Component = e.target as Component;
        var layerId:int = box.tag.layerId as int;
        var boxIndex:int = box.tag.boxIndex as int;

        if(boxIndex == CEndlessUtil.currTakeBoxIndex)
        {
            (system.stage.getSystem(IUICanvas) as IUICanvas).showMsgAlert(CLang.Get("clientLockTips"));
            return;
        }

        var state:int = _helper.getLayerBoxTakeState(layerId,boxIndex);
        if(state == ERewardTakeState.CannotTake)
        {
            (system.stage.getSystem(IUICanvas) as IUICanvas).showMsgAlert("请先通关前置关卡！");
            return;
        }

        if(state == ERewardTakeState.HasTake)
        {
            (system.stage.getSystem(IUICanvas) as IUICanvas).showMsgAlert("宝箱已领取！");
            return;
        }

        if(state == ERewardTakeState.CanTake)
        {
            _netHandler.takePassBoxReward(layerId, boxIndex);
        }
    }

    public function autoChallenge():void
    {
        delayCall(3, _onAutoChallengeHandler);
    }

    private function _onAutoChallengeHandler():void
    {
        if(m_bIsAutoChallenge)
        {
            _onClickChallenge();
        }
    }

//property==========================================================================================================
    public function get closeHandler() : Handler
    {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void
    {
        m_pCloseHandler = value;
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    private function get _manager():CEndlessTowerManager
    {
        return system.getHandler(CEndlessTowerManager) as CEndlessTowerManager;
    }

    private function get _helper():CEndlessTowerHelpHandler
    {
        return system.getHandler(CEndlessTowerHelpHandler) as CEndlessTowerHelpHandler;
    }

    private function get _netHandler():CEndlessTowerNetHandler
    {
        return system.getHandler(CEndlessTowerNetHandler) as CEndlessTowerNetHandler;
    }

    private function get _currPage():int
    {
        return m_iCurrPage;
    }

    private function set _currPage(value:int):void
    {
        if(m_iCurrPage != value)
        {
            m_iCurrPage = value;

            _updateLayerPageBtnState();
            _updateProgressBoxTipInfo();
            _updateProgressInfo();
        }
    }

    public function set isAutoChallenge(value:Boolean):void
    {
        m_bIsAutoChallenge = value;
    }

    public function get isInAutoChallenge():Boolean
    {
        var resultData:CEndlessTowerResultData = (system.getHandler(CEndlessTowerManager) as CEndlessTowerManager).resultData;
        var isWin:Boolean = resultData == null ? false : resultData.isWin;
        return m_bIsAutoChallenge && m_bIsExitInstance && isWin;
    }

    public function set isExitInstance(value:Boolean):void
    {
        m_bIsExitInstance = value;
    }

    override public function dispose() : void
    {
        super.dispose();
    }
}
}
