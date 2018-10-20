//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game {

import QFLib.Application.Component.CLifeCycleEvent;
import QFLib.DashBoard.CConsolePage;
import QFLib.DashBoard.CDashBoard;
import QFLib.Foundation;
import QFLib.Foundation.CAverager;
import QFLib.Foundation.CKeyboard;
import QFLib.Foundation.CLog;
import QFLib.Foundation.CPath;
import QFLib.Foundation.CURLFile;
import QFLib.Foundation.CURLQson;
import QFLib.Foundation.CURLSwf;
import QFLib.ResourceLoader.CPackedQsonLoader;
import QFLib.ResourceLoader.CQbinLoader;
import QFLib.ResourceLoader.CQsonLoader;
import QFLib.ResourceLoader.CResourceLoaders;
import QFLib.Utils.CHideSwfUtil;

import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.ui.Keyboard;

import kof.data.CDatabaseSystem;
import kof.framework.CAppStage;
import kof.framework.CAppSystem;
import kof.framework.CStandaloneApp;
import kof.framework.IApplication;
import kof.framework.events.CEventPriority;
import kof.game.ActivityNotice.CActivityNoticeSystem;
import kof.game.GMReport.CGMReportSystem;
import kof.game.HeroTreasure.CHeroTreasureSystem;
import kof.game.LotteryActivity.CLotteryActivitySystem;
import kof.game.OneDiamondReward.COneDiamondSystem;
import kof.game.Tutorial.CTutorSystem;
import kof.game.activityTreasure.CActivityTreasureSystem;
import kof.game.bargainCard.CBargainCardSystem;
import kof.game.bargainCard.CBuyMonthCardSystem;
import kof.game.discountStore.CDiscountStoreSystem;
import kof.game.effort.CEffortSystem;
import kof.game.activityHall.CActivityHallSystem;
import kof.game.arena.CArenaSystem;
import kof.game.artifact.CArtifactSystem;
import kof.game.audio.CAudioSystem;
import kof.game.bag.CBagSystem;
import kof.game.bootstrap.CBootstrapSystem;
import kof.game.bossChallenge.CBossChallengeSystem;
import kof.game.bundle.CSystemBundleContext;
import kof.game.chat.CChatSystem;
import kof.game.club.CClubSystem;
import kof.game.clubBoss.CClubBossSystem;
import kof.game.collectionGame.CCollectionGameSystem;
import kof.game.config.CKOFConfigSystem;
import kof.game.core.CECSLoop;
import kof.game.cultivate.CCultivateSystem;
import kof.game.diamondRoulette.CReturnDiamondSystem;
import kof.game.embattle.CEmbattleSystem;
import kof.game.endlessTower.CEndlessTowerSystem;
import kof.game.equipCard.CEquipCardSystem;
import kof.game.gameSetting.CGameSettingSystem;
import kof.game.gem.CGemSystem;
import kof.game.gemenRecharge.CGemenRechargeSystem;
import kof.game.globalBoss.CWorldBossSystem;
import kof.game.guildWar.CGuildWarSystem;
import kof.game.hangUpResult.CHUResultSystem;
import kof.game.hook.CHookSystem;
import kof.game.im.CIMChatSystem;
import kof.game.im.CIMSystem;
import kof.game.impression.CImpressionSystem;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.event.CInstanceEvent;
import kof.game.invest.CInvestSystem;
import kof.game.item.CItemSystem;
import kof.game.itemGetPath.CItemGetSystem;
import kof.game.level.CLevelSystem;
import kof.game.limitActivity.CLimitActivitySystem;
import kof.game.lobby.CLobbySystem;
import kof.game.mail.CMailSystem;
import kof.game.newServerActivity.CNewServerActivitySystem;
import kof.game.npc.CNPCSystem;
import kof.game.openServerActivity.COpenServerActivitySystem;
import kof.game.pathing.CPathingSystem;
import kof.game.pay.CPaySystem;
import kof.game.peak1v1.CPeak1v1System;
import kof.game.peakGame.CPeakGameSystem;
import kof.game.peakpk.CPeakpkSystem;
import kof.game.perfs.CGamePerfMonitor;
import kof.game.platformDownloadReward.CPlatformBoxRewardSystem;
import kof.game.platform_mobile_regist.CPlatformMobileRegistSystem;
import kof.game.player.CPlayerSystem;
import kof.game.playerCard.CPlayerCardSystem;
import kof.game.playerSuggest.CSuggestSystem;
import kof.game.playerTeam.CPlayerTeamSystem;
import kof.game.practice.CPracticeSystem;
import kof.game.rank.CRankSystem;
import kof.game.recharge.dailyRecharge.CDailyRechargeSystem;
import kof.game.recharge.firstRecharge.CFirstRechargeSystem;
import kof.game.rechargerebate.CRechargeRebateSystem;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.recruitRank.CRecruitRankSystem;
import kof.game.redPacket.CRedPacketSystem;
import kof.game.resourceInstance.CResourceInstanceSystem;
import kof.game.scenario.CScenarioSystem;
import kof.game.scene.CSceneRendering;
import kof.game.scene.CSceneSystem;
import kof.game.sevenDays.CSevenDaysSystem;
import kof.game.sevenkHall.C7KHallSystem;
import kof.game.shop.CShopSystem;
import kof.game.sign.CSignSystem;
import kof.game.story.CStorySystem;
import kof.game.streetFighter.CStreetFighterSystem;
import kof.game.strengthen.CStrengthenSystem;
import kof.game.superVip.CSuperVipSystem;
import kof.game.support.CBISupportSystem;
import kof.game.switching.CSwitchingSystem;
import kof.game.systemnotice.CSystemNoticeSystem;
import kof.game.talent.CTalentSystem;
import kof.game.task.CMainTaskSystem;
import kof.game.task.CTaskSystem;
import kof.game.taskcallup.CTaskCallUpSystem;
import kof.game.teaching.CTeachingInstanceSystem;
import kof.game.teaching.CTeachingMainInletSystem;
import kof.game.title.CTitleSystem;
import kof.game.totalConsume.CTotalConsumeSystem;
import kof.game.totalRecharge.CTotalRechargeSystem;
import kof.game.util.MESSAGE_ALERT_APPBOX;
import kof.game.vip.CVIPSystem;
import kof.game.weiClient.CWeiClientSystem;
import kof.game.welfarehall.CWelfareHallSystem;
import kof.game.yyHall.CYYHallSystem;
import kof.game.yyVip.CYYVipSystem;
import kof.game.yyWeChat.CYYWeChatSystem;
import kof.ui.CDebugStatsViewHandler;
import kof.ui.CUISystem;
import kof.util.CAssertUtils;

/**
 * AppStage for gaming.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CGameStage extends CAppStage {

    public function CGameStage() {
        super();

        LOG.logTraceMsg( "Creates a CGameStage instance ..." );
    }

    override protected function doStart() : Boolean {
        var ret : Boolean = super.doStart();

        if ( ret ) {
            // initialize dash board
            m_theDashBoard = new CDashBoard(flashStage)//( App.dialog );
            var consolePage : CConsolePage = m_theDashBoard.findPage( "ConsolePage" ) as CConsolePage;
            if( consolePage != null ) consolePage.popUpLogLevel = CLog.LOG_LEVEL_ABOVE_ERROR;

            m_theKeyboard = new CKeyboard( flashStage );
            m_theKeyboard.registerKeyCode( false, Keyboard.BACKQUOTE, onDashBoardKeyDown );
            m_theKeyboard.registerKeyCode( false, Keyboard.F1, onDashBoardKeyDown );
            m_theKeyboard.registerKeyCode( false, Keyboard.F10, onFpsMeterKeyDown );
            m_theKeyboard.registerKeyCode( false, Keyboard.BACKSLASH, onFpsMeterKeyDown );
            m_theKeyboard.registerKeyCode( false, Keyboard.SLASH, onFpsMeterKeyDown );

            this.addSystem( new CKOFConfigSystem() );

            var pConfigSystem : CKOFConfigSystem = this.getSystem( CKOFConfigSystem ) as CKOFConfigSystem;
            pConfigSystem.addEventListener( CLifeCycleEvent.AFTER_STARTING, _afterConfigSystemStartingEventHandler, false,
                    CEventPriority.DEFAULT, true );

            // UIs
            this.addSystem( new CUISystem() );
//            this.addSystem( new CVFSSystem() );
            this.addSystem( new CDatabaseSystem() );

            this.addSystem( new CAudioSystem() );//音效系统

            this.addSystem( new CECSLoop() );
            this.addSystem( new CSystemBundleContext() ); // SystemBundle supported.
            this.addSystem( new CSwitchingSystem() ); // 系统开放
            this.addSystem( new CSceneSystem() );
            this.addSystem( new CPathingSystem() ); // 寻路

            this.addSystem( new CReciprocalSystem() ); // 交互系统


            // 羁绊
            this.addSystem( new CImpressionSystem() );

            this.addSystem( new CPlayerSystem() );
            this.addSystem( new CPlayerTeamSystem() );

            this.addSystem( new CScenarioSystem() );
            this.addSystem( new CLevelSystem() );
            this.addSystem( new CInstanceSystem() );

            this.addSystem( new CBootstrapSystem() ); // 游戏启动系统，协调各个核心系统

            // instance system.
            this.addSystem( new CLobbySystem() );
            this.addSystem( new CTutorSystem() );
//            CONFIG::debug {
//                this.addSystem( new CGmSystem() );
//            }
            this.addSystem( new CChatSystem() );

            //item
            this.addSystem( new CItemSystem() );
            this.addSystem( new CBagSystem() );

            // ranking
//            this.addSystem( new CRankingSystem() );

            //npc
            this.addSystem( new CNPCSystem() );

            //pvp
//            this.addSystem( new CPvpSystem() );
            //资源副本
            this.addSystem( new CResourceInstanceSystem() );

            //embattle
            this.addSystem( new CEmbattleSystem() );

//            this.addSystem( new CMainNoticeSystem() );

            this.addSystem( new CSystemNoticeSystem() );
            //task
            this.addSystem( new CTaskSystem() );
            //任务助手
            this.addSystem( new CMainTaskSystem() );
//            //mail
            this.addSystem( new CMailSystem() );

            //vip
            this.addSystem( new CVIPSystem() );

            // 充值
            this.addSystem( new CPaySystem() );
//
//            //
            this.addSystem( new CPeakGameSystem() );
            this.addSystem( new CCultivateSystem() );
//
            //天赋
            this.addSystem( new CTalentSystem() );
            //教学副本z主界面入口
            this.addSystem( new CTeachingMainInletSystem() );
            //教学副本
            this.addSystem( new CTeachingInstanceSystem() );

//          //神器
            this.addSystem( new CArtifactSystem() );
            //练习场
            this.addSystem( new CPracticeSystem() );
            //超级VIP
            this.addSystem( new CSuperVipSystem() );
            //收藏游戏
            this.addSystem( new CCollectionGameSystem() );
            //微端
            this.addSystem( new CWeiClientSystem() );
//
//            //好友
            this.addSystem( new CIMSystem() );
            //好友聊天
            this.addSystem( new CIMChatSystem() );
//
            //商店
            this.addSystem( new CShopSystem() );
//
//            // 你提我改
            this.addSystem( new CSuggestSystem() );
//            //俱乐部
            this.addSystem( new CClubSystem() );
            //签到
            this.addSystem( new CSignSystem() );


            //任务集会所
            this.addSystem( new CTaskCallUpSystem() );
            // 角色抽卡
            this.addSystem( new CPlayerCardSystem() );
            //挂机
            this.addSystem(new CHookSystem());

            // 装备抽卡
            this.addSystem(new CEquipCardSystem());

            // 竞技场
            this.addSystem(new CArenaSystem());

            // 排行榜
            this.addSystem(new CRankSystem());

            //七天登录
            this.addSystem( new CSevenDaysSystem() );
            //世界boss
            this.addSystem(new CWorldBossSystem());



            //每日充值
            this.addSystem( new CDailyRechargeSystem());
            //物品获取系统
            this.addSystem(new CItemGetSystem());


            //活动大厅
            this.addSystem( new CActivityHallSystem() );
            //一钻礼包
            this.addSystem( new COneDiamondSystem());
            //首充
            this.addSystem( new CFirstRechargeSystem());

            //轮盘返钻
            this.addSystem( new CReturnDiamondSystem());

            //新服活动
            this.addSystem( new CNewServerActivitySystem());

            //格斗家宝藏
            this.addSystem(new CHeroTreasureSystem());
            //红包
            this.addSystem(new CRedPacketSystem());

            //招募排行
            this.addSystem( new CRecruitRankSystem());
            //超级抽抽乐
            this.addSystem( new CLotteryActivitySystem() );
            //消费积分榜活动
            this.addSystem( new CLimitActivitySystem());
            this.addSystem( new CPeak1v1System());

            //开服嘉年华活动
            this.addSystem( new COpenServerActivitySystem());

            //系统设置
            this.addSystem( new CGameSettingSystem());

            var pUISystem : CUISystem = this.getSystem( CUISystem ) as CUISystem;
            pUISystem.addEventListener( CLifeCycleEvent.AFTER_STARTING, _afterUISystemStartingEventHandler, false,
                    CEventPriority.DEFAULT, true );

            var pSceneSystem : CSceneSystem = this.getSystem( CSceneSystem ) as CSceneSystem;
            pSceneSystem.addEventListener( CLifeCycleEvent.AFTER_STARTING, _afterSceneSystemStartingEventHandler, false,
                    CEventPriority.DEFAULT, true );

            var pInstanceSystem : CInstanceSystem = this.getSystem( CInstanceSystem ) as CInstanceSystem;
            pInstanceSystem.addEventListener( CLifeCycleEvent.AFTER_STARTING, _afterInstanceSystemStartingEventHandler, false,
                    CEventPriority.DEFAULT, true );

            this.kof_framework::addBean( m_theDashBoard, UNMANAGED );

            // BI支持
            this.addSystem( new CBISupportSystem() );

            // 福利大厅
            this.addSystem( new CWelfareHallSystem() );

            // 无尽之塔
            this.addSystem( new CEndlessTowerSystem() );

            //工会boss
            this.addSystem( new CClubBossSystem());

            //挂机结算系统
            this.addSystem( new CHUResultSystem());

            this.addSystem( new CPeakpkSystem());

            // GM举报
            this.addSystem( new CGMReportSystem());

            // 等级理财
            this.addSystem( new CInvestSystem());

            // 累充返钻
            this.addSystem( new CRechargeRebateSystem());

            // YY大厅
            this.addSystem( new CYYHallSystem());

            // YY会员
            this.addSystem( new CYYVipSystem());

            // 微信
            this.addSystem( new CYYWeChatSystem());

            // 7k7k大厅
            this.addSystem( new C7KHallSystem());

            // 活动预告
            this.addSystem( new CActivityNoticeSystem());

            // 工会战
            this.addSystem( new CGuildWarSystem());
            // 成就系统
            this.addSystem( new CEffortSystem());

            this.addSystem( new CStreetFighterSystem() );

            this.addSystem( new CGamePerfMonitor() );

            this.addSystem(new CPlatformMobileRegistSystem());

            //boss挑战
            this.addSystem( new CBossChallengeSystem() );

            this.addSystem( new CPlatformBoxRewardSystem() );
            this.addSystem( new CStorySystem() );
            this.addSystem( new CTitleSystem() );
            this.addSystem( new CStrengthenSystem() );

            // 宝石
            this.addSystem( new CGemSystem() );

            //影二的修行
            this.addSystem( new CActivityTreasureSystem() );
            //哥们网充值界面
            this.addSystem( new CGemenRechargeSystem() );
            //月卡福利
            this.addSystem( new CBargainCardSystem() );
            //月卡购买
            this.addSystem( new CBuyMonthCardSystem());
            // 累计充值
            this.addSystem(new CTotalRechargeSystem());
            // 累计消费
            this.addSystem(new CTotalConsumeSystem());
            // 折扣商店
            this.addSystem(new CDiscountStoreSystem());

        }
        return ret;
    }

    private function _afterUISystemStartingEventHandler( event : CLifeCycleEvent ) : void {
        var pUISystem : CUISystem = this.getSystem( CUISystem ) as CUISystem;
        CAssertUtils.assertNotNull( pUISystem );

        pUISystem.showSceneLoading();
    }

    private function _afterConfigSystemStartingEventHandler( event : CLifeCycleEvent ) : void {
        // XXX:在ConfigSystem启动完成之前，进行外部带入配置项设定
        var pConfigSystem : CKOFConfigSystem = this.getSystem( CKOFConfigSystem ) as CKOFConfigSystem;
        var bEnableQsonLoading : Boolean = pConfigSystem.configuration.getBoolean( "enableQsonLoading" );
        var bEnablePackedQsonLoading : Boolean = pConfigSystem.configuration.getBoolean( "enablePackedQsonLoading" );
        var bEnableFileExistencePreChecking : Boolean = pConfigSystem.configuration.getBoolean( "enableFileExistencePreChecking" );
        CQsonLoader.enableQsonLoading = bEnableQsonLoading;
        CURLQson.enableQsonLoading = bEnableQsonLoading;
        CQbinLoader.enableQbinLoading = bEnableQsonLoading;
        CPackedQsonLoader.enablePackedQsonLoading = bEnablePackedQsonLoading;
        CResourceLoaders.instance().enableFileExistencePreChecking = bEnableFileExistencePreChecking;
        //CResourceLoaders.instance().enableFileExistencePreChecking = true;
        //QFLib.ResourceLoader.CQsonLoader.enableQsonLoading = false;
        //QFLib.Foundation.CURLQson.enableQsonLoading = false;

        var sCdnURI : String = pConfigSystem.configuration.getString( "CdnURI", null );
        CResourceLoaders.instance().absoluteURI = sCdnURI;

        //Foundation.Perf.enabled = true;
        if( bEnableFileExistencePreChecking )
        {
            CResourceLoaders.instance().enableFileCheckLevel = pConfigSystem.configuration.getInt( "fileCheckLevel" );
            CResourceLoaders.instance().createResourceWorker( "assets/bin/ResourceWorker.swf" );
        }

        CResourceLoaders.instance().addFatalFailedCallback( _onResourceLoadFatal );

        var sUIAssetsURI : String = pConfigSystem.configuration.getString( "uiAssetsURI", "assets/ui" );
        Config.resPath = CPath.addRightSlash( sCdnURI || "" ) + CPath.addRightSlash( sUIAssetsURI );

        m_bStandalone = pConfigSystem.configuration.getBoolean( "dummy", false );

        var consolePage : CConsolePage = m_theDashBoard.findPage( "ConsolePage" ) as CConsolePage;
        if( consolePage != null ) {
            var sPopUpLogLevelConst : String = pConfigSystem.configuration.getString( 'popUpLogLevel', 'LOG_LEVEL_WARNING' );
            if ( sPopUpLogLevelConst in CLog ) {
                consolePage.popUpLogLevel = CLog[ sPopUpLogLevelConst ];
            }
        }

        var gmAppURL : String = pConfigSystem.configuration.getString( "GMAppURL" );
        Foundation.Log.logMsg( "GM AppURL: " + gmAppURL );
        if ( gmAppURL != null && gmAppURL != "" ) {
            onLoaderGMSWF(gmAppURL);
        }

    }

    private function onLoaderGMSWF(_url:String) : void {
        var app : CAppStage = this;

        _url = CResourceLoaders.instance().assetVersion.mappingFilenameWithVersion( _url );
        var cf : CURLSwf = new CURLSwf( _url );
        cf.allowCodeImport = true;
        cf.startLoad( _onFinished, null, true );

        function _onFinished( file : CURLSwf, error : int ) : void {
            Foundation.Log.logMsg( "GM AppURL Finsihed( " + error + " ): " + _url );
            if ( error == 0 ) {
                var info : LoaderInfo = file.loader.contentLoaderInfo;
                CHideSwfUtil.hideSWF( info.bytes );
                var fun : Function = info.content[ 'startFun' ];
                fun( app );
                CKOFConfigSystem.GMSwitch = true;
            }
            else{
                CKOFConfigSystem.GMSwitch = false;
            }
        }
    }

    private function _onResourceLoadFatal( file : CURLFile, idError : int ) : void {
//        LOG.logWarningMsg("CGameStage::_onResourceLoadFatal: " + file.loadingURL + ", idError( " + idError + ")" );
        if ( idError == -3 ) {
            MESSAGE_ALERT_APPBOX( this.getSystem(CKOFConfigSystem) as CAppSystem, "当前网络异常导致无法加载游戏资源，为保证游戏体验，请重新登录！", function() : void {
                var pApplication : IApplication = getBean( IApplication ) as IApplication;
                if ( pApplication ) {
                    pApplication.eventDispatcher.dispatchEvent( new Event( CStandaloneApp.RESTART ) );
                }
            }, null, false, "重新登录");
        }
    }

    private function _afterSceneSystemStartingEventHandler( event : CLifeCycleEvent ) : void {
        // XXX: 场景系统启动之后，GameStage需要改写完成进入场景流程
        var pSceneSystem : CSceneSystem = event.currentTarget as CSceneSystem;
        CAssertUtils.assertNotNull( pSceneSystem );

        var pSceneRendering : CSceneRendering = pSceneSystem.getHandler( CSceneRendering ) as CSceneRendering;
        CAssertUtils.assertNotNull( pSceneRendering );

        pSceneRendering.addEventListener( CSceneRendering.SCENE_CFG_COMPLETE, _sceneRendering_cfgCompleteHandler, false,
                CEventPriority.DEFAULT + 1, true );
    }

    private function _sceneRendering_cfgCompleteHandler( event : Event ) : void {
        event.currentTarget.removeEventListener( event.type,
                _sceneRendering_cfgCompleteHandler );
        event.stopImmediatePropagation();
        event.preventDefault();

        m_bSceneReady = true;

        checkNextAction();
    }

    private function _afterInstanceSystemStartingEventHandler( event : CLifeCycleEvent ) : void {
        // 副本系统启动之后，GameStage需要知道副本进入以及关卡Ready。比如移除全局加载Loading，移除过场小剧情，过场小游戏等
        var pInstanceSystem : CInstanceSystem = event.currentTarget as CInstanceSystem;
        CAssertUtils.assertNotNull( pInstanceSystem );

        pInstanceSystem.addEventListener( CInstanceEvent.LEVEL_ENTERED, _instanceSystem_onLevelReadyEventHandler, false,
                CEventPriority.DEFAULT, true );
    }

    private function _instanceSystem_onLevelReadyEventHandler( event : CInstanceEvent ) : void {
        LOG.logTraceMsg( "Level ready ..." );
        makeApplicationProgressFinished();
    }

    private function onDashBoardKeyDown( keyCode : int ) : void {
        void( keyCode );
        if ( m_theKeyboard.isKeyPressed( Keyboard.CONTROL )) {
            m_theDashBoard.visible = !m_theDashBoard.visible;
        }
    }

    private function onFpsMeterKeyDown( keyCode : int ) : void {
        void(keyCode);

        var pUISys : CUISystem = this.getSystem( CUISystem ) as CUISystem;
        var pStatView : CDebugStatsViewHandler = pUISys.getHandler( CDebugStatsViewHandler ) as CDebugStatsViewHandler;
        if ( pStatView ) {
            pStatView.visible = !pStatView.visible;
        }
    }

    override protected function setStarted() : void {
        super.setStarted();

        // entered gaming stage.
        LOG.logTraceMsg( "Entered Game Stage." );
        var pApp : IApplication = this.getBean( IApplication ) as IApplication;
        if ( pApp )
            pApp.eventDispatcher.dispatchEvent( new ProgressEvent( "_applicationProgress", false, false, 2, 3 ) );

        checkNextAction();
    }

    private function uiSystem_completeHandler( event : Event ) : void {
        event.currentTarget.removeEventListener( event.type, uiSystem_completeHandler );
        checkNextAction();
    }

    protected function checkNextAction() : void {
        if ( this.isStarted ) {
            var bUICompleted : Boolean = true;
            var pUISys : CUISystem = this.getBean( CUISystem ) as CUISystem;
            if ( pUISys ) {
                if ( pUISys.countOfUIPageLoadingRequests > 0 ) {
                    pUISys.addEventListener( Event.COMPLETE, uiSystem_completeHandler, false, CEventPriority.DEFAULT, true );
                    bUICompleted = false;
                }
            }

            if ( m_bSceneReady && bUICompleted ) {
                // finish all.
                makeGameStageReady();
            }
        }
    }

    protected function makeGameStageReady() : void {
        var pSceneSystem : CSceneSystem = this.getBean( CSceneSystem );
        if ( pSceneSystem ) {
            var pRendering : CSceneRendering = pSceneSystem.getHandler( CSceneRendering ) as CSceneRendering;
            if ( pRendering ) {
                pRendering.dispatchEvent( new Event( CSceneRendering.SCENE_CFG_COMPLETE ) );

                m_bSceneReady = false;
                pRendering.addEventListener( CSceneRendering.SCENE_CFG_COMPLETE, _sceneRendering_cfgCompleteHandler, false,
                        CEventPriority.DEFAULT + 1, true );
            }
        }

        if ( m_bStandalone ) {
            makeApplicationProgressFinished();
        }
    }

    protected function makeApplicationProgressFinished() : void {
        var pApp : IApplication = this.getBean( IApplication ) as IApplication;
        if ( pApp )
            pApp.eventDispatcher.dispatchEvent( new ProgressEvent( "_applicationProgress", false, false, 3, 3 ) );

        var pUISys : CUISystem = getSystem( CUISystem ) as CUISystem;
        if ( pUISys ) {
            pUISys.showUILoading = true;
        }
    }

    override public function tickUpdate( delta : Number ) : void {

        Foundation.Perf.sectionBegin( "GameStage_Update" );

        delta = m_theAverager.count( delta );
        super.tickUpdate( delta );
        if ( m_theDashBoard != null ) m_theDashBoard.update( delta );

        Foundation.Perf.sectionEnd( "GameStage_Update" );
    }

    protected var m_theDashBoard : CDashBoard = null;
    protected var m_theKeyboard : CKeyboard = null;

    private var m_theAverager : CAverager = new CAverager( 5 );

    private var m_bSceneReady : Boolean;
    private var m_bStandalone : Boolean;

}
}

internal namespace kof_framework = "http://kof.qifun.com";

// vim:ft=as3 tw=120 ts=4 sw=4 expandtab
