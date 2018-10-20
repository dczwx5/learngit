//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/18.
 */
package kof.game.arena.view {

import QFLib.Utils.HtmlUtil;

import com.greensock.TweenMax;

import flash.events.MouseEvent;

import kof.SYSTEM_ID;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.arena.CArenaHelpHandler;
import kof.game.arena.CArenaManager;
import kof.game.arena.CArenaNetHandler;
import kof.game.arena.data.CArenaBaseData;
import kof.game.arena.enum.EArenaRequestType;
import kof.game.arena.event.CArenaEvent;
import kof.game.arena.util.CArenaState;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CItemUtil;
import kof.game.common.CLang;
import kof.game.common.CRewardUtil;
import kof.game.common.CSystemRuleUtil;
import kof.game.common.hero.CHeroEmbattleListView;
import kof.game.common.view.CTweenViewHandler;
import kof.game.embattle.CEmbattleEvent;
import kof.game.embattle.CEmbattleSystem;
import kof.game.hook.CHookClientFacade
import kof.game.instance.enum.EInstanceType;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.subData.CCurrencyData;
import kof.game.shop.enum.EShopType;
import kof.message.Arena.ArenaChallengeResponse;
import kof.table.ArenaHighestRanking;
import kof.ui.CMsgAlertHandler;
import kof.ui.demo.BubblesDialogueUI;
import kof.ui.master.arena.ArenaMainWinUI;
import morn.core.components.Dialog;
import morn.core.events.UIEvent;

import morn.core.handlers.Handler;

/**
 * 竞技场主界面
 */
public class CArenaMainViewHandler extends CTweenViewHandler {

    private var m_bViewInitialized : Boolean;

    private var m_pViewUI:ArenaMainWinUI;
    private var m_pBubbleViewUI:BubblesDialogueUI;
    private var m_pCloseHandler : Handler;
    private var m_listRoleView:Array = [];
    private var _heroEmbattleList:CHeroEmbattleListView;

    public function CArenaMainViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        ret = ret && onInitialize();
        if ( loadViewByDefault ) {
            ret = ret && loadAssetsByView( viewClass );
            ret = ret && onInitializeView();
        }

        this.addBean(new CArenaFightReportViewHandler());
        this.addBean(new CArenaRewardViewHandler());
        this.addBean(new CArenaBuyTimesViewHandler());

        return ret;
    }

    override public function get viewClass() : Array
    {
        return [ ArenaMainWinUI ];
    }

    override protected function get additionalAssets():Array
    {
        return ["frameclip_item.swf"];
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
                m_pViewUI = new ArenaMainWinUI();
                m_pViewUI.closeHandler = new Handler( _onClose );
                m_pViewUI.btn_czbz.clickHandler = new Handler(_onClickCZBtn);
                m_pViewUI.btn_record.clickHandler = new Handler(_onClickRecordBtn);
                m_pViewUI.btn_refresh.clickHandler = new Handler(_onClickRefreshBtn);
                m_pViewUI.btn_reward.clickHandler = new Handler(_onClickRewardBtn);
                m_pViewUI.btn_shop.clickHandler = new Handler(_onClickShopBtn);
                m_pViewUI.btn_add.clickHandler = new Handler(_onClickBuyPower);
                m_pViewUI.btn_123.clickHandler = new Handler(_onClickBestRankHandler);
                m_pViewUI.btn_myRank.clickHandler = new Handler(_onClickMyRankHandler);

                m_pViewUI.list_rewardItem.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system));

                for(var i:int = 1; i <= 3; i++)
                {
                    var roleView : CArenaRoleView = new CArenaRoleView( system );
                    roleView.viewUI = m_pViewUI[ "view_roleBest" + i ];
                    m_listRoleView.push(roleView);
                    roleView.initialize();
                }

                for(i = 1; i <= 5; i++)
                {
                    roleView = new CArenaRoleView( system );
                    roleView.viewUI = m_pViewUI[ "view_roleCommon" + i ];
                    m_listRoleView.push(roleView);
                    roleView.initialize();
                }

                m_pViewUI.box_role.mask = m_pViewUI.img_mask;
                m_pViewUI.box_rewardInfo.mask = m_pViewUI.img_mask_hisReward;
                m_pViewUI.box_changeGroup.mask = m_pViewUI.img_mask_refresh;

                CSystemRuleUtil.setRuleTips(m_pViewUI.img_tips, CLang.Get("arena_rule"));
            }

            if(m_pBubbleViewUI == null)
            {
                m_pBubbleViewUI = new BubblesDialogueUI();
                m_pBubbleViewUI.visible = false;
                m_pBubbleViewUI.mouseEnabled = false;
                m_pBubbleViewUI.mouseChildren = false;
                m_pViewUI.addChild(m_pBubbleViewUI);
            }

            m_bViewInitialized = true;
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
        setTweenData(KOFSysTags.ARENA);
        showDialog(m_pViewUI, false, _onShowEnd);
    }

    private function _onShowEnd():void
    {
        _initView();
        _addListeners();
        _reqInfo();
        updateDisplay();

        var reportView:CArenaFightReportViewHandler = getBean(CArenaFightReportViewHandler) as CArenaFightReportViewHandler;
        if(reportView && reportView.isViewShow)
        {
            reportView.addDisplay();
        }

        var rewardView:CArenaRewardViewHandler = getBean(CArenaRewardViewHandler) as CArenaRewardViewHandler;
        if(rewardView && rewardView.isViewShow)
        {
            rewardView.addDisplay();
        }
    }

    public function removeDisplay() : void
    {
        _removeDisplayB();
        closeDialog(null);
    }

    private function _removeDisplayB() : void
    {
        if(m_bViewInitialized)
        {
            _removeListeners();

            unschedule(_hideBubbleTalk);
            unschedule(_showBubbleTalk);
            m_pBubbleViewUI.visible = false;

            (this.getBean(CArenaRewardViewHandler) as CArenaRewardViewHandler).removeDisplay();
            (this.getBean(CArenaFightReportViewHandler) as CArenaFightReportViewHandler).removeDisplay();

            for each(var roleView:CArenaRoleView in m_listRoleView)
            {
                if(roleView)
                {
                    roleView.dispose();
                }
            }

            if(m_bIsTweening)
            {
                TweenMax.killTweensOf(m_pViewUI.box_role);
                m_bIsTweening = false;
            }

            CArenaState.reset();
        }
    }

    private function _initView():void
    {
        m_pViewUI.box_tip.visible = _arenaHelp.hasRewardToTake();
        m_pViewUI.txt_free.visible = false;
        m_pViewUI.img_diamond.visible = false;
        m_pViewUI.txt_costNum.visible = false;
        m_pViewUI.btn_123.visible = true;
        m_pViewUI.btn_myRank.visible = false;
        m_pViewUI.box_rewardInfo.y = 32;
        m_pViewUI.box_rewardInfo.visible = true;
        m_pViewUI.box_changeGroup.y = 471;
        m_pViewUI.box_changeGroup.visible = false;
        m_pViewUI.box_role.x = -18;

        (m_listRoleView[7] as CArenaRoleView).viewUI.box_role.y = 127 + 5;
        m_pViewUI.btn_refresh.btnLabel.align = "left";
//        m_pViewUI.btn_refresh.btnLabel.x = 9;
        m_pViewUI.btn_refresh.btnLabel.left = 9;

        setAutoPlayWhenSwitch(1);
    }

    private function _reqInfo():void
    {
        // 出战编制信息
        var embattleSystem:CEmbattleSystem = system.stage.getSystem(CEmbattleSystem) as CEmbattleSystem;
        var heroList:Array = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.embattleManager.getHeroListByType(EInstanceType.TYPE_ARENA);
        if(heroList.length < 3)
        {
            embattleSystem.requestBestEmbattle(EInstanceType.TYPE_ARENA);
        }

        // 请求挑战者信息
//        if(ArenaUtil.isFirstOpen)
//        {
        _arenaNetHandler.arenaChangeRequest(EArenaRequestType.FirstOpen);
//            ArenaUtil.isFirstOpen = false;
//        }

        // 请求基本信息
        _arenaNetHandler.arenaBaseRequest();

        // 请求奖励信息
        _arenaNetHandler.arenaHighestAwardListRequest();
    }

    private function _onClose( type : String ) : void
    {
        switch ( type )
        {
            default:
                if ( this.m_pCloseHandler )
                {
                    this.m_pCloseHandler.execute();
                }
                break;
        }
    }

    private function _addListeners():void
    {
        system.addEventListener(CArenaEvent.AllChallenger_Update,_onAllChallengeInfoUpdateHandler);
        system.addEventListener(CArenaEvent.SingleChallenger_Update,_onOneChallengeInfoUpdateHandler);
        system.addEventListener(CArenaEvent.RewardInfo_Update,_onRewardInfoUpdateHandler);
        system.addEventListener(CArenaEvent.BaseInfo_Update,_onBaseInfoUpdateHandler);
        system.stage.getSystem(CEmbattleSystem).addEventListener(CEmbattleEvent.EMBATTLE_SUCC,_onEmbattleUpdateHandler);

        for each(var roleView:CArenaRoleView in m_listRoleView)
        {
            if(roleView)
            {
                roleView.addListeners();
            }
        }
    }

    private function _removeListeners():void
    {
        system.removeEventListener(CArenaEvent.AllChallenger_Update,_onAllChallengeInfoUpdateHandler);
        system.removeEventListener(CArenaEvent.SingleChallenger_Update,_onOneChallengeInfoUpdateHandler);
        system.removeEventListener(CArenaEvent.RewardInfo_Update,_onRewardInfoUpdateHandler);
        system.removeEventListener(CArenaEvent.BaseInfo_Update,_onBaseInfoUpdateHandler);
        system.stage.getSystem(CEmbattleSystem).removeEventListener(CEmbattleEvent.EMBATTLE_SUCC,_onEmbattleUpdateHandler);

        for each(var roleView:CArenaRoleView in m_listRoleView)
        {
            if(roleView)
            {
                roleView.removeListeners();
            }
        }
    }

    override protected function updateDisplay():void
    {
        super.updateDisplay();

        _updateChallengeTimes();
        _updateRefreshInfo();
        _updateCurrRewardInfo();
        _updateAllChallengerInfo();
        _updateRewardBtnState();
        _updateEmbattleHeroList();
    }

    /**
     * 更新挑战次数
     */
    private function _updateChallengeTimes():void
    {
        var arenaBaseData:CArenaBaseData = _arenaManager.arenaBaseData;
        if(arenaBaseData)
        {
            m_pViewUI.txt_challengeTimes.isHtml = true;
            m_pViewUI.txt_challengeTimes.text = HtmlUtil.color("挑战次数：","#FFC125");

            var currNum:int = arenaBaseData.challengeNum;
            var totalNum:int = _arenaHelp.getMaxChallengeNum();
            var color:String = currNum == 0 ? "#FF3030" : "#71C671";
            m_pViewUI.txt_challengeTimes.text += HtmlUtil.color(currNum + "/" + totalNum,color);
            m_pViewUI.btn_add.visible = currNum < totalNum;
        }
        else
        {
            m_pViewUI.txt_challengeTimes.isHtml = false;
            m_pViewUI.txt_challengeTimes.text = "挑战次数：0/0";
            m_pViewUI.txt_challengeTimes.color = 0xFFFFFF;
        }
    }

    /**
     * 当前等级段奖励信息
     */
    private function _updateCurrRewardInfo():void
    {
        var nextRankInfo:ArenaHighestRanking = _arenaHelp.getNextRankRewardInfo();
        var myRank:int = _arenaManager.getMyRank();
        var hisBestRank:int = _arenaManager.getHisBestRank();
        hisBestRank = hisBestRank == 0 ? nextRankInfo.ranking + 1 : hisBestRank;

        var dataBase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
        var dataArr:Array = dataBase.getTable(KOFTableConstants.ArenaHighestRanking ).toArray();

//        if(myRank > 0)
//        {
//            m_pViewUI.txt_currRank.isHtml = true;
//            m_pViewUI.txt_currRank.text = "最高排名奖励 " + HtmlUtil.color(hisBestRank.toString(),"#f37911") + " 名";
//        }
//        else
//        {
//            m_pViewUI.txt_currRank.isHtml = true;
//            m_pViewUI.txt_currRank.text = "达到 " + HtmlUtil.color(dataArr[0 ].ranking,"#f37911") + " 名可领取";
//        }

        if(nextRankInfo)
        {
            var arr:Array = CRewardUtil.createByDropPackageID(system.stage, nextRankInfo.dropId ).list;
            if(arr.length < 3)
            {
                for(var i:int = arr.length; i < 3; i++)
                {
                    arr.push({});
                }
            }
            m_pViewUI.list_rewardItem.dataSource = arr;

            m_pViewUI.txt_nextInfo.visible = true;
            if(myRank > 0)
            {
                m_pViewUI.txt_currRank.isHtml = true;
                m_pViewUI.txt_currRank.text = "最高排名奖励 " + HtmlUtil.color(nextRankInfo.ranking.toString(),"#f37911") + " 名";

                m_pViewUI.txt_nextInfo.isHtml = true;
                m_pViewUI.txt_nextInfo.text = HtmlUtil.color("距离该奖励还差 ","#ff66");
                m_pViewUI.txt_nextInfo.text += HtmlUtil.color((hisBestRank - nextRankInfo.ranking).toString(),"#f37911");
                m_pViewUI.txt_nextInfo.text += HtmlUtil.color(" 名","#ff66");
            }
            else
            {
                m_pViewUI.txt_currRank.isHtml = true;
                m_pViewUI.txt_currRank.text = "达到 " + HtmlUtil.color(dataArr[0 ].ranking,"#f37911") + " 名可领取";

                m_pViewUI.txt_nextInfo.isHtml = false;
                m_pViewUI.txt_nextInfo.color = 0xff66;
                m_pViewUI.txt_nextInfo.text = "暂无排名";
            }
        }
        else
        {
            arr = CRewardUtil.createByDropPackageID(system.stage, dataArr[dataArr.length-1 ].dropId).list;// 取第一名的
            if(arr.length < 3)
            {
                for(i = arr.length; i < 3; i++)
                {
                    arr.push({});
                }
            }
            m_pViewUI.list_rewardItem.dataSource = arr;

            m_pViewUI.txt_currRank.isHtml = true;
            m_pViewUI.txt_currRank.text = "最高排名奖励 " + HtmlUtil.color(dataArr[dataArr.length-1 ].ranking.toString(),"#f37911") + " 名";

            m_pViewUI.txt_nextInfo.visible = false;
        }
    }

    /**
     * 更新挑战者信息
     */
    private function _updateAllChallengerInfo():void
    {
        var dataArr:Array = _arenaManager.roleListData;
        if(dataArr && dataArr.length)
        {
            for(var i:int = 0; i < m_listRoleView.length; i++)
            {
                m_listRoleView[i ].data = dataArr[i];
            }
        }
    }

    /**
     * 气泡说话
     */
    private function _updateBubbleTalk():void
    {
        delayCall(0.2,_showBubbleTalk,null);
    }

    private function _showBubbleTalk(delta : Number):void
    {
        unschedule(_showBubbleTalk);

        var index:int;
        if(m_pViewUI.btn_myRank.visible)
        {
            if(!m_pBubbleViewUI.visible)
            {
                m_pBubbleViewUI.visible = true;
            }

            index = Math.random() * 3;
            var roleView:CArenaRoleView = m_listRoleView[index];
            var xPos:int = m_pViewUI.box_role.x + m_pViewUI.box_123.x + roleView.viewUI.x + 112;
            _arenaHelp.showBubbleDialog(m_pBubbleViewUI,_arenaHelp.getRandomTalk(),xPos,56,1);

            if(isViewShow)
            {
                schedule(2,_hideBubbleTalk);
            }
        }
    }

    private function _hideBubbleTalk(delta : Number):void
    {
        m_pBubbleViewUI.visible = false;

        unschedule(_hideBubbleTalk);

        if(isViewShow)
        {
            schedule(2,_showBubbleTalk);
        }
    }

    /**
     * 更新奖励按钮状态
     */
    private function _updateRewardBtnState():void
    {
        m_pViewUI.box_tip.visible = _arenaHelp.hasRewardToTake();
    }

    /**
     * 更新换一批状态(免费/付费)
     */
    private function _updateRefreshInfo():void
    {
        var arenaBaseData:CArenaBaseData = _arenaManager.arenaBaseData;
        if(arenaBaseData)
        {
            var costNum:int = _arenaHelp.getRefreshCostNum();

            m_pViewUI.txt_free.visible = costNum == 0;
            m_pViewUI.img_diamond.visible = costNum > 0;
            m_pViewUI.txt_costNum.visible = costNum > 0;
            if(m_pViewUI.txt_costNum.visible)
            {
                m_pViewUI.txt_costNum.text = costNum.toString();
            }

//            m_pViewUI.box_changeGroup.visible = arenaBaseData;
        }
        else
        {
            m_pViewUI.txt_free.visible = false;
            m_pViewUI.img_diamond.visible = false;
            m_pViewUI.txt_costNum.visible = false;
        }
    }

    /**
     * 更新出战编制格斗家列表
     */
    private function _updateEmbattleHeroList():void
    {
        if (_heroEmbattleList == null) {
            m_pViewUI.hero_em_list.mouseHandler = new Handler(function (e:MouseEvent, idx:int) : void {
                if (e.type == MouseEvent.CLICK) {
                    _onClickAddHandler();
                }
            });
            _heroEmbattleList = new CHeroEmbattleListView(system, m_pViewUI.hero_em_list, EInstanceType.TYPE_ARENA, null);
//            _heroEmbattleList = new CHeroEmbattleListView(system, m_pViewUI.hero_em_list, EInstanceType.TYPE_ARENA, new Handler(_onClickAddHandler));
        }
        _heroEmbattleList.updateWindow();

    }

    //事件监听更新=======================================================================================================

    /**
     * 刷新一批后信息更新
     * @param e
     */
    private function _onAllChallengeInfoUpdateHandler(e:CArenaEvent):void
    {
        _updateBubbleTalk();
        _updateAllChallengerInfo();

//        if(m_pViewUI.btn_123)
//        {
//            setAutoPlayWhenSwitch(2);
//        }
//        else
//        {
//            setAutoPlayWhenSwitch(1);
//        }

        var myRank:int = _arenaManager.getMyRank();
        m_pViewUI.box_changeGroup.visible = myRank == 0 || myRank > 30;
    }

    /**
     * 点挑战玩家后的处理
     * @param e
     */
    private function _onOneChallengeInfoUpdateHandler(e:CArenaEvent):void
    {
        if(m_pCloseHandler)
        {
            m_pCloseHandler.execute();
        }

        var response:ArenaChallengeResponse = e.data as ArenaChallengeResponse;
        if(response)
        {

        }
    }

    /**
     * 最高排名奖励信息更新
     * @param e
     */
    private function _onRewardInfoUpdateHandler(e:CArenaEvent):void
    {
        _updateCurrRewardInfo();
        m_pViewUI.box_tip.visible = _arenaHelp.hasRewardToTake();
    }

    /**
     * 基本信息更新
     * @param e
     */
    private function _onBaseInfoUpdateHandler(e:CArenaEvent):void
    {
        _updateChallengeTimes();
        _updateRefreshInfo();
    }

    private function _onEmbattleUpdateHandler(e:CEmbattleEvent):void
    {
        _updateEmbattleHeroList();
    }

    //出站编制===========================================================================================================
    private function _openEmbattle():void
    {
        var pSystemBundleCtx : ISystemBundleContext = CHookClientFacade.instance.hookSystem.stage.getSystem( ISystemBundleContext ) as
                ISystemBundleContext;
        if ( pSystemBundleCtx ) {
            var fighterCount : int = 3;
            var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.EMBATTLE ) );
            pSystemBundleCtx.setUserData( pSystemBundle, 'embattle_args', [ EInstanceType.TYPE_ARENA, fighterCount ] );
            pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, true );
        }
    }

    //点按钮处理=========================================================================================================
    /**
     * 出战编制
     */
    private function _onClickCZBtn():void
    {
        _openEmbattle();
    }

    /**
     * 战报
     */
    private function _onClickRecordBtn():void
    {
        var view:CArenaFightReportViewHandler = getBean(CArenaFightReportViewHandler) as CArenaFightReportViewHandler;
        if(view.isViewShow)
        {
            view.removeDisplay();
        }
        else
        {
            view.addDisplay();
        }
    }

    /**
     * 换一批
     */
    private function _onClickRefreshBtn():void
    {
        if(CArenaState.isInChangeGroup)
        {
            uiCanvas.showMsgAlert(CLang.Get("clientLockTips"),CMsgAlertHandler.WARNING);
            return;
        }

        var arenaBaseData:CArenaBaseData = (system.getHandler(CArenaManager) as CArenaManager).arenaBaseData;
        if(arenaBaseData == null)
        {
            uiCanvas.showMsgAlert(CLang.Get("arena_not_initialize"),CMsgAlertHandler.WARNING);
            return;
        }

        var costNum:int = _arenaHelp.getRefreshCostNum();
        var currencyData:CCurrencyData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.currency;
        if((currencyData.blueDiamond + currencyData.purpleDiamond) < costNum)
        {
            var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
            var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
            bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);

//            uiCanvas.showMsgAlert(CLang.Get("arena_money_not_enough"),CMsgAlertHandler.WARNING);
            uiCanvas.showMsgAlert("很抱歉，您的钻石不足，请前往获得",CMsgAlertHandler.WARNING);
            return;
        }

        _arenaNetHandler.arenaChangeRequest(EArenaRequestType.ChangeOne);
    }

    /**
     * 奖励
     */
    private function _onClickRewardBtn():void
    {
        var view:CArenaRewardViewHandler = getBean(CArenaRewardViewHandler) as CArenaRewardViewHandler;
        if(view.isViewShow)
        {
            view.removeDisplay();
        }
        else
        {
            view.addDisplay();
        }
    }

    /**
     * 打开竞技场商店
     */
    private function _onClickShopBtn():void
    {
        var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
        var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.MALL));
        bundleCtx.setUserData(systemBundle, "shop_type", [EShopType.SHOP_TYPE_5]);
        bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
    }

    /**
     * 点击购买挑战次数
     */
    private function _onClickBuyPower():void
    {
        if(CArenaState.isInBuyPower)
        {
            uiCanvas.showMsgAlert(CLang.Get("clientLockTips"),CMsgAlertHandler.WARNING);
            return;
        }

        var arenaBaseData:CArenaBaseData = (system.getHandler(CArenaManager) as CArenaManager).arenaBaseData;
        if(arenaBaseData == null)
        {
            uiCanvas.showMsgAlert(CLang.Get("arena_not_initialize"),CMsgAlertHandler.WARNING);
            return;
        }

        (this.getBean(CArenaBuyTimesViewHandler) as CArenaBuyTimesViewHandler).addDisplay();
    }

    private var m_bIsTweening:Boolean;
    /**
     * 点三甲格斗家按钮
     */
    private function _onClickBestRankHandler():void
    {
//        (system.stage.getSystem(IUICanvas) as CUISystem).showMultiplePVPLoadingView();
//
//        schedule(10,function():void
//        {
//            (system.stage.getSystem(IUICanvas) as CUISystem).removeMultiplePVPLoadingView();
//        });

        if(m_bIsTweening)
        {
            return;
        }

        m_pBubbleViewUI.visible = false;

        m_bIsTweening = true;
        TweenMax.to(m_pViewUI.box_role,0.5,{x:-1017,onComplete:onCompleteHandler});
        function onCompleteHandler():void
        {
            m_bIsTweening = false;
            m_pViewUI.btn_123.visible = false;
            m_pViewUI.btn_myRank.visible = true;
//            m_pViewUI.box_rewardInfo.visible = false;
//            m_pViewUI.box_changeGroup.visible = false;

            _updateBubbleTalk();
        }

        TweenMax.to(m_pViewUI.box_rewardInfo,0.5,{y:32-100});
        TweenMax.to(m_pViewUI.box_changeGroup,0.5,{y:471+40});

        setAutoPlayWhenSwitch(2);
    }

    /**
     * 点我的排名按钮
     */
    private function _onClickMyRankHandler():void
    {
        if(m_bIsTweening)
        {
            return;
        }

        unschedule(_hideBubbleTalk);
        m_pBubbleViewUI.visible = false;

        m_bIsTweening = true;
        TweenMax.to(m_pViewUI.box_role,0.5,{x:-18,onComplete:onCompleteHandler});
        function onCompleteHandler():void
        {
            m_bIsTweening = false;
            m_pViewUI.btn_123.visible = true;
            m_pViewUI.btn_myRank.visible = false;
//            m_pViewUI.box_rewardInfo.visible = true;
//            m_pViewUI.box_changeGroup.visible = true;
        }

        TweenMax.to(m_pViewUI.box_rewardInfo,0.5,{y:32});
        TweenMax.to(m_pViewUI.box_changeGroup,0.5,{y:471});

        setAutoPlayWhenSwitch(1);
    }

    private function setAutoPlayWhenSwitch(type:int):void
    {
        for(var i:int = 0; i < 3; i++)
        {
            var arenaRoleView:CArenaRoleView = m_listRoleView[i] as CArenaRoleView;
            if(arenaRoleView)
            {
                arenaRoleView.isAutoPlay = type == 2;
            }
        }

        for(i = 3; i < 8; i++)
        {
            arenaRoleView = m_listRoleView[i] as CArenaRoleView;
            if(arenaRoleView)
            {
                arenaRoleView.isAutoPlay = type == 1;
            }
        }
    }

    //渲染List==========================================================================================================


    private function _onClickAddHandler():void
    {
        _openEmbattle();
    }

    public function get closeHandler() : Handler
    {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void
    {
        m_pCloseHandler = value;
    }

    //other==================================================================================================================
    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    public function get _arenaManager():CArenaManager
    {
        return system.getHandler(CArenaManager) as CArenaManager;
    }

    public function get _arenaHelp():CArenaHelpHandler
    {
        return system.getHandler(CArenaHelpHandler) as CArenaHelpHandler;
    }

    public function get _arenaNetHandler():CArenaNetHandler
    {
        return system.getHandler(CArenaNetHandler) as CArenaNetHandler;
    }

    override public function dispose() : void
    {
        super.dispose();

        m_pViewUI = null;
        m_pBubbleViewUI = null;
        m_pCloseHandler = null;
        m_listRoleView.length = 0;
    }
}
}
