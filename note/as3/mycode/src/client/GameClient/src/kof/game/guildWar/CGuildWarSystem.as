//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/17.
 */
package kof.game.guildWar {

import QFLib.Framework.CScene;

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CTarget;
import kof.game.character.display.IDisplay;
import kof.game.character.handler.CPlayHandler;
import kof.game.club.CClubEvent;
import kof.game.club.CClubSystem;
import kof.game.common.view.resultWin.CMultiplePVPResultViewHandler;
import kof.game.common.view.resultWin.CPVPResultData;
import kof.game.core.CECSLoop;
import kof.game.core.CGameObject;
import kof.game.guildWar.data.CGuildWarData;
import kof.game.guildWar.data.CGuildWarResultDataProvider;
import kof.game.guildWar.event.CGuildWarEvent;
import kof.game.guildWar.view.CGuildWarAllotViewHandler;
import kof.game.guildWar.view.CGuildWarEndWinViewHandler;
import kof.game.guildWar.view.CGuildWarEnergyDetailViewHandler;
import kof.game.guildWar.view.CGuildWarEnergyRankViewHandler;
import kof.game.guildWar.view.CGuildWarEnergyRewardViewHandler;
import kof.game.guildWar.view.CGuildWarFirstOccupyViewHandler;
import kof.game.guildWar.view.CGuildWarGiftAllotViewHandler;
import kof.game.guildWar.view.CGuildWarGiftMethodViewHandler;
import kof.game.guildWar.view.CGuildWarInspireViewHandler;
import kof.game.guildWar.view.CGuildWarLoadingViewHandler;
import kof.game.guildWar.view.CGuildWarMainViewHandler;
import kof.game.guildWar.view.CGuildWarMatchViewHandler;
import kof.game.guildWar.view.CGuildWarResultViewHandler;
import kof.game.guildWar.view.CGuildWarStationViewHandler;
import kof.game.guildWar.view.CGuildWarUIHandler;
import kof.game.instance.CInstanceExitProcess;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.event.CInstanceEvent;
import kof.game.level.CLevelSystem;
import kof.game.scene.CSceneSystem;

import morn.core.handlers.Handler;

public class CGuildWarSystem extends CBundleSystem {

    private var m_bInitialized : Boolean;
    private var m_pMainViewHandler:CGuildWarMainViewHandler;
    private var m_pManager:CGuildWarManager;
    private var m_pNetHandler:CGuildWarNetHandler;
    private var m_pHelpHandler:CGuildWarHelpHandler;
    private var m_pGuildWarUIHandler:CGuildWarUIHandler;

    public function CGuildWarSystem( A_objBundleID : * = null ) {
        super( A_objBundleID );
    }

    override public function initialize() : Boolean
    {
        if ( !super.initialize() )
        {
            return false;
        }

        if ( !m_bInitialized )
        {
            m_bInitialized = true;

            m_pMainViewHandler = new CGuildWarMainViewHandler();
            this.addBean( m_pMainViewHandler );
            m_pMainViewHandler.closeHandler = new Handler( _onViewClosed );

            m_pManager = new CGuildWarManager();
            this.addBean( m_pManager );

            m_pNetHandler = new CGuildWarNetHandler();
            this.addBean( m_pNetHandler );

            m_pHelpHandler = new CGuildWarHelpHandler();
            this.addBean( m_pHelpHandler );

            m_pGuildWarUIHandler = new CGuildWarUIHandler();
            this.addBean(m_pGuildWarUIHandler);

            this.addBean( new CGuildWarInspireViewHandler() );
            this.addBean( new CGuildWarEndWinViewHandler() );
            this.addBean( new CGuildWarEnergyRankViewHandler() );
            this.addBean( new CGuildWarAllotViewHandler() );
            this.addBean( new CGuildWarGiftAllotViewHandler() );
            this.addBean( new CGuildWarGiftMethodViewHandler() );
            this.addBean( new CGuildWarEnergyDetailViewHandler() );
            this.addBean( new CGuildWarEnergyRewardViewHandler() );
            this.addBean( new CGuildWarResultViewHandler() );
            this.addBean( new CGuildWarStationViewHandler() );
            this.addBean( new CGuildWarEmbattleHandler() );
            this.addBean( new CGuildWarMatchViewHandler() );
            this.addBean( new CGuildWarLoadingViewHandler() );
            this.addBean( new CGuildWarLoadingHandler() );
            this.addBean( new CGuildWarResultDataProvider() );
            this.addBean( new CGuildWarFirstOccupyViewHandler() );
        }

        return m_bInitialized;
    }

    override public function get bundleID() : *
    {
        return SYSTEM_ID(KOFSysTags.GUILDWAR);
    }

    override protected function onBundleStart(ctx:ISystemBundleContext):void
    {
        super.onBundleStart(ctx);

        _reqInfo();
        addEventListeners();
    }

    private function _reqInfo():void
    {
        (getHandler( CGuildWarNetHandler ) as CGuildWarNetHandler).guildWarInfoRequest();
        (getHandler( CGuildWarNetHandler ) as CGuildWarNetHandler).guildWarSpaceClubInfoRequest();
    }

    protected function addEventListeners() : void
    {
        this.addEventListener(CGuildWarEvent.UpdateMatchInfo, _onMatchSuccHandler);
        this.addEventListener(CGuildWarEvent.ObtainSpaceShowInfo, _onObtainSpaceShowInfo);

        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstanceSystem)
        {
            pInstanceSystem.addEventListener(CInstanceEvent.END_INSTANCE, _onInstanceOverEventProcess);
            pInstanceSystem.addEventListener(CInstanceEvent.LEVEL_PLAYER_READY, _onLevelPlayerReady);
        }

        (stage.getSystem(CClubSystem) as CClubSystem).addEventListener(CClubEvent.CLUB_EXIT_SUCC, _onExitClubHandler);
        (stage.getSystem(CClubSystem) as CClubSystem).addEventListener(CClubEvent.MEMBER_INFO_MODIFY_RESPONSE, _onExitClubHandler);
    }

    protected function removeEventListeners() : void
    {
        this.removeEventListener(CGuildWarEvent.UpdateMatchInfo, _onMatchSuccHandler);
        this.removeEventListener(CGuildWarEvent.ObtainSpaceShowInfo, _onObtainSpaceShowInfo);

        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstanceSystem)
        {
            pInstanceSystem.removeEventListener(CInstanceEvent.END_INSTANCE, _onInstanceOverEventProcess);
            pInstanceSystem.removeEventListener(CInstanceEvent.LEVEL_PLAYER_READY, _onLevelPlayerReady);
        }

        (stage.getSystem(CClubSystem) as CClubSystem).removeEventListener(CClubEvent.CLUB_EXIT_SUCC, _onExitClubHandler);
        (stage.getSystem(CClubSystem) as CClubSystem).removeEventListener(CClubEvent.MEMBER_INFO_MODIFY_RESPONSE, _onExitClubHandler);
    }

    override protected function onActivated( value : Boolean ) : void
    {
        super.onActivated( value );

        var pView : CGuildWarMainViewHandler = this.getHandler( CGuildWarMainViewHandler ) as CGuildWarMainViewHandler;
        if ( !pView )
        {
            LOG.logErrorMsg( "SystemBundle activated, but the CGuildWarMainViewHandler isn't instance." );
            return;
        }

        if ( value )
        {
            pView.addDisplay();
        }
        else
        {
            _removeAllWin();
        }
    }

    private function _removeAllWin():void
    {
        (getHandler(CGuildWarMainViewHandler) as CGuildWarMainViewHandler).removeDisplay();
        (getHandler(CGuildWarInspireViewHandler) as CGuildWarInspireViewHandler).removeDisplay();
        (getHandler(CGuildWarEndWinViewHandler) as CGuildWarEndWinViewHandler).removeDisplay();
        (getHandler(CGuildWarEnergyRankViewHandler) as CGuildWarEnergyRankViewHandler).removeDisplay();
        (getHandler(CGuildWarAllotViewHandler) as CGuildWarAllotViewHandler).removeDisplay();
        (getHandler(CGuildWarGiftAllotViewHandler) as CGuildWarGiftAllotViewHandler).removeDisplay();
        (getHandler(CGuildWarGiftMethodViewHandler) as CGuildWarGiftMethodViewHandler).removeDisplay();
        (getHandler(CGuildWarEnergyDetailViewHandler) as CGuildWarEnergyDetailViewHandler).removeDisplay();
        (getHandler(CGuildWarEnergyRewardViewHandler) as CGuildWarEnergyRewardViewHandler).removeDisplay();
        (getHandler(CGuildWarResultViewHandler) as CGuildWarResultViewHandler).removeDisplay();
        (getHandler(CGuildWarStationViewHandler) as CGuildWarStationViewHandler).removeDisplay();
        (getHandler(CGuildWarFirstOccupyViewHandler) as CGuildWarFirstOccupyViewHandler).removeDisplay();
    }

    private function _onViewClosed() : void
    {
        this.setActivated( false );
    }

    public function setActived(value:Boolean):void
    {
        this.setActivated( value );
    }

    //监听==============================================================================================================
    private function _onMatchSuccHandler(e:CGuildWarEvent):void
    {
        var matchView:CGuildWarMatchViewHandler = getHandler(CGuildWarMatchViewHandler) as CGuildWarMatchViewHandler;
        if(matchView && matchView.isViewShow)
        {
            matchView.removeDisplay();
        }

        var loadingView:CGuildWarLoadingViewHandler = getHandler(CGuildWarLoadingViewHandler) as CGuildWarLoadingViewHandler;
        if(loadingView && !loadingView.isViewShow)
        {
            loadingView.addDisplay();
        }
    }

    // 副本结束等待结算
    private function _onInstanceOverEventProcess(e:CInstanceEvent) : void
    {
        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (!pInstanceSystem) {
            return ;
        }
        var isGuildWar:Boolean = EInstanceType.isGuildWar(pInstanceSystem.instanceType);
        if (!isGuildWar) return ;

        var pLevelSystem:CLevelSystem = stage.getSystem(CLevelSystem) as CLevelSystem;
        if (!pLevelSystem) return ;

        pInstanceSystem.startWaitAllGameObjectFinish();
        pInstanceSystem.addEventListener(CInstanceEvent.INSTANCE_ALL_GAME_OBJECT_FINISH_OR_TIME_OUT, _onInstanceAllGameObjectFinish);
    }

    private function _onInstanceAllGameObjectFinish(e:CInstanceEvent) : void
    {
        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstanceSystem)
        {
            pInstanceSystem.removeEventListener(CInstanceEvent.INSTANCE_ALL_GAME_OBJECT_FINISH_OR_TIME_OUT, _onInstanceAllGameObjectFinish);

            var pvpResultData:CPVPResultData = (getHandler(CGuildWarResultDataProvider) as CGuildWarResultDataProvider).getResultData();
            var instanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
            if(instanceSystem)
            {
                (instanceSystem.getHandler(CMultiplePVPResultViewHandler) as CMultiplePVPResultViewHandler).data = pvpResultData;
                (instanceSystem.getHandler(CMultiplePVPResultViewHandler) as CMultiplePVPResultViewHandler).addDisplay();
            }
        }
    }

    private function _onLevelPlayerReady(e:CInstanceEvent) : void
    {
        _setHeroTarget(0);
    }

    private function _setHeroTarget(delta:Number) : void
    {
        m_pGuildWarUIHandler.removeTick(_setHeroTarget);

        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (!pInstanceSystem) {
            return ;
        }
        var isGuildWar:Boolean = EInstanceType.isGuildWar(pInstanceSystem.instanceType);
        if (!isGuildWar) return ;

        var pHero:CGameObject  = (stage.getSystem(CECSLoop).getBean(CPlayHandler) as CPlayHandler).hero;
        var pSceneSystem:CSceneSystem = stage.getSystem(CSceneSystem) as CSceneSystem;
        var sceneObjectList:Vector.<Object>;
        var pSceneObject:CGameObject;

        var targetList:Vector.<CGameObject> = new Vector.<CGameObject>();
        if (pHero && pHero.isRunning) {
            sceneObjectList = pSceneSystem.findAllPlayer();
            for each( pSceneObject in sceneObjectList){
                if ( !CCharacterDataDescriptor.isHero( pSceneObject.data )) {
                    targetList.push(pSceneObject);
                }
            }
        }

        if (targetList && targetList.length > 0) {
            // 设置目标
            (pHero.getComponentByClass(CTarget,true) as CTarget).setTargetObjects(targetList);

            // 设置镜头
            var enemyTarget:CGameObject = targetList[0] as CGameObject;
            if (enemyTarget) {
                if (pSceneSystem.scenegraph && pSceneSystem.scenegraph.scene) {
                    var scene:CScene = pSceneSystem.scenegraph.scene;
                    scene.setCameraFollowingMode(1, 6.0, 3.0); // springFactor太小，人物移动到边界会超出去
                    var pHeroCharacterDisplay : IDisplay = pHero.getComponentByClass( IDisplay, true ) as IDisplay;
                    var pEnemyCharacterDisplay : IDisplay = enemyTarget.getComponentByClass( IDisplay, true ) as IDisplay;
                    scene.setCameraFollowingTarget(pHeroCharacterDisplay.modelDisplay, pEnemyCharacterDisplay.modelDisplay);
                }
            }
        } else {
            //
            m_pGuildWarUIHandler.addTick(_setHeroTarget);
        }
    }

    /**
     * 活动结束后的空间占领信息
     * @param e
     */
    private function _onObtainSpaceShowInfo(e:CGuildWarEvent):void
    {
        var instanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if(instanceSystem.isMainCity)
        {
            var settleView:CGuildWarResultViewHandler = getHandler(CGuildWarResultViewHandler) as CGuildWarResultViewHandler;
            if(settleView && !settleView.isViewShow)
            {
                settleView.addDisplay();
            }
        }
        else
        {
//            instanceSystem.addExitProcess(CGuildWarResultViewHandler, CInstanceExitProcess.FLAG_ARENA, this.setActivated, [true], 9999);
        }
    }

    // 退出公会
    private function _onExitClubHandler(e:CClubEvent):void
    {
        var pSystemBundleCtx : ISystemBundleContext = stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.GUILDWAR ) );
        pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, false );
    }

    public function get data() : CGuildWarData
    {
        return (getHandler(CGuildWarManager) as CGuildWarManager).data;
    }

    override public function dispose() : void
    {
        super.dispose();

        removeEventListeners();

        m_pMainViewHandler.dispose();
        m_pMainViewHandler = null;
    }
}
}
