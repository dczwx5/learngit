//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/18.
 */
package kof.game.arena {

import QFLib.Framework.CScene;

import flash.utils.getTimer;

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.arena.event.CArenaEvent;
import kof.game.arena.view.CArenaAnimationViewHandler;
import kof.game.arena.view.CArenaBuyTimesViewHandler;
import kof.game.arena.view.CArenaFightReportViewHandler;
import kof.game.arena.view.CArenaResultViewHandler;
import kof.game.arena.view.CArenaMainViewHandler;
import kof.game.arena.view.CArenaRewardViewHandler;
import kof.game.arena.view.CArenaRoleEmbattleTipsView;
import kof.game.arena.view.CArenaUIHandler;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CTarget;
import kof.game.character.display.IDisplay;
import kof.game.character.handler.CPlayHandler;
import kof.game.character.scene.CSceneMediator;
import kof.game.common.CDelayCall;
import kof.game.common.loading.CLoadingEvent;
import kof.game.common.view.resultWin.CMultiplePVPResultViewHandler;
import kof.game.common.view.resultWin.CPVPResultViewHandler;
import kof.game.core.CECSLoop;
import kof.game.core.CGameObject;
import kof.game.fightui.compoment.CSkillViewHandler;
import kof.game.instance.CInstanceExitProcess;
import kof.game.instance.CInstanceManager;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.CInstanceUIHandler;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.mainInstance.enum.EInstanceWndType;
import kof.game.instance.event.CInstanceEvent;
import kof.game.level.CLevelSystem;
import kof.game.loading.CPVPLoadingData;
import kof.game.loading.CSceneLoadingViewHandler;
import kof.game.lobby.CLobbySystem;
import kof.game.scene.CSceneSystem;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;

import morn.core.components.Component;

import morn.core.handlers.Handler;

/**
 * 竞技场系统
 * @author sprite (sprite@qifun.com)
 */
public class CArenaSystem extends CBundleSystem {

    private var m_bInitialized : Boolean;

    private var m_pMainViewHandler:CArenaMainViewHandler;
    private var m_pManager:CArenaManager;
    private var m_pNetHandler:CArenaNetHandler;
    private var m_pArenaUIHandler:CArenaUIHandler;
    private var m_iCurrChallengeRank:int;// 当前挑战对象

    public function CArenaSystem()
    {
        super();
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

            m_pMainViewHandler = new CArenaMainViewHandler();
            this.addBean( m_pMainViewHandler );

            m_pNetHandler = new CArenaNetHandler();
            this.addBean( m_pNetHandler );

            m_pManager = new CArenaManager();
            this.addBean( m_pManager );

            this.addBean( new CArenaAnimationViewHandler() );
            this.addBean( new CArenaBuyTimesViewHandler() );
            this.addBean( new CArenaFightReportViewHandler() );
//            this.addBean( new CArenaResultViewHandler() );
            this.addBean( new CArenaRewardViewHandler() );
            this.addBean( new CArenaHelpHandler() );
//            this.addBean( new CArenaRoleEmbattleTipsView() );
            m_pArenaUIHandler = new CArenaUIHandler();
            this.addBean(m_pArenaUIHandler);
        }

        m_pMainViewHandler = m_pMainViewHandler || this.getHandler( CArenaMainViewHandler ) as CArenaMainViewHandler;
        m_pMainViewHandler.closeHandler = new Handler( _onViewClosed );

        return m_bInitialized;
    }

    override public function get bundleID() : *
    {
        return SYSTEM_ID(KOFSysTags.ARENA);
    }

    override protected function onBundleStart(ctx:ISystemBundleContext):void
    {
        super.onBundleStart(ctx);

        // 登陆时主界面图标提示
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleContext)
        {
            pSystemBundleContext.setUserData(this,CBundleSystem.NOTIFICATION,_arenaHelp.hasRewardToTake());
        }

        _addEventListeners();
    }

    protected function _addEventListeners() : void
    {
        this.addEventListener(CArenaEvent.RewardInfo_Update,_onRewardInfoUpdateHandler);
        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstanceSystem) {
            pInstanceSystem.addEventListener(CInstanceEvent.END_INSTANCE, _onInstanceOverEventProcess);
            pInstanceSystem.addEventListener(CInstanceEvent.LEVEL_PLAYER_READY, _onLevelPlayerReady);
            pInstanceSystem.addEventListener(CInstanceEvent.ENTER_INSTANCE, _onEnterInstanceHandler);
        }
    }

    protected function _removeEventListeners() : void
    {
        this.removeEventListener(CArenaEvent.RewardInfo_Update,_onRewardInfoUpdateHandler);
        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstanceSystem) {
            pInstanceSystem.removeEventListener(CInstanceEvent.END_INSTANCE, _onInstanceOverEventProcess);
            pInstanceSystem.removeEventListener(CInstanceEvent.LEVEL_PLAYER_READY, _onLevelPlayerReady);
            pInstanceSystem.removeEventListener(CInstanceEvent.ENTER_INSTANCE, _onEnterInstanceHandler);
        }
    }

    private function _onInstanceOverEventProcess(e:CInstanceEvent) : void {
        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (!pInstanceSystem) {
            return ;
        }
        var isArena:Boolean = EInstanceType.isArena(pInstanceSystem.instanceType);
        if (!isArena) return ;

        var pLevelSystem:CLevelSystem = stage.getSystem(CLevelSystem) as CLevelSystem;
        if (!pLevelSystem) return ;

        pInstanceSystem.startWaitAllGameObjectFinish();
        pInstanceSystem.addEventListener(CInstanceEvent.INSTANCE_ALL_GAME_OBJECT_FINISH_OR_TIME_OUT, _onInstanceAllGameObjectFinish);
    }

    private function _onInstanceAllGameObjectFinish(e:CInstanceEvent) : void {
        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstanceSystem) {
            pInstanceSystem.removeEventListener(CInstanceEvent.INSTANCE_ALL_GAME_OBJECT_FINISH_OR_TIME_OUT, _onInstanceAllGameObjectFinish);

            var resultView:CMultiplePVPResultViewHandler = pInstanceSystem.getHandler(CMultiplePVPResultViewHandler ) as CMultiplePVPResultViewHandler;
            resultView.data = (getHandler(CArenaManager) as CArenaManager).resultData;
            resultView.addDisplay();
        }
    }

    private function _onLevelPlayerReady(e:CInstanceEvent) : void
    {
        _setHeroTarget(0);
    }

    private function _setHeroTarget(delta:Number) : void
    {
        m_pArenaUIHandler.removeTick(_setHeroTarget);

        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (!pInstanceSystem) {
            return ;
        }
        var isArena:Boolean = EInstanceType.isArena(pInstanceSystem.instanceType);
        if (!isArena) return ;

        var pHero:CGameObject  = (stage.getSystem(CECSLoop).getBean(CPlayHandler) as CPlayHandler).hero;
        var pSceneSystem:CSceneSystem = stage.getSystem(CSceneSystem) as CSceneSystem;
        var sceneObjectList:Vector.<Object>;
        var pSceneObject:CGameObject;

        var targetList:Vector.<CGameObject> = new Vector.<CGameObject>();
        if (pHero && pHero.isRunning) {
            sceneObjectList = pSceneSystem.findAllPlayer();
            for each( pSceneObject in sceneObjectList){
                if ( !CCharacterDataDescriptor.isHero( pSceneObject.data ) && pSceneObject.data.side == 2) {
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
            m_pArenaUIHandler.addTick(_setHeroTarget);
        }
    }

    private function _onEnterInstanceHandler(e:CInstanceEvent):void
    {
        if (e.type == CInstanceEvent.ENTER_INSTANCE)
        {
            var instanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
            if(EInstanceType.isArena(instanceSystem.instanceType))
            {
                instanceSystem.addExitProcess(CArenaMainViewHandler, CInstanceExitProcess.FLAG_ARENA, this.setActivated, [true], 9999);

                var ui:IUICanvas = stage.getSystem(IUICanvas) as IUICanvas;
                if (ui)
                {
                    var pvpLoadingData:CPVPLoadingData = (getHandler(CArenaManager) as CArenaManager).getArenaLoadingData();
                    ui.showMultiplePVPLoadingView(pvpLoadingData);
//                    addPreloadListener();
                }

                var skillViewHandler:CSkillViewHandler = stage.getSystem(CLobbySystem ).getHandler(CSkillViewHandler) as CSkillViewHandler;
                if(skillViewHandler)
                {
                    skillViewHandler.hideAllSkillItemssss();
                }
            }

            if(EInstanceType.isMainCity(instanceSystem.instanceType))
            {
                skillViewHandler = stage.getSystem(CLobbySystem).getHandler(CSkillViewHandler) as CSkillViewHandler;
                if(skillViewHandler)
                {
                    skillViewHandler.showAllSkillItems();
                }
            }
        }
    }

    override protected function onActivated( value : Boolean ) : void
    {
        super.onActivated( value );

        var pView : CArenaMainViewHandler = this.getHandler( CArenaMainViewHandler ) as CArenaMainViewHandler;
        if ( !pView )
        {
            LOG.logErrorMsg( "SystemBundle activated, but the CArenaMainViewHandler isn't instance." );
            return;
        }

        if ( value )
        {
            pView.addDisplay();
        }
        else
        {
            pView.removeDisplay();
        }
    }

    private function _onViewClosed() : void
    {
        this.setActivated( false );
    }

    private function _onRewardInfoUpdateHandler(e:CArenaEvent):void
    {
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleContext)
        {
            pSystemBundleContext.setUserData(this,CBundleSystem.NOTIFICATION,_arenaHelp.hasRewardToTake());
        }
    }

    public function addPreloadListener():void
    {
        stage.getSystem(CUISystem ).addEventListener(CLoadingEvent.VIRTUAL_LOAD_FINISHED,_onPreloadingComplHandler);
    }

    /**
     * 预加载完成
     */
    private function _onPreloadingComplHandler(e:CLoadingEvent):void
    {
        stage.getSystem(CUISystem ).removeEventListener(CLoadingEvent.VIRTUAL_LOAD_FINISHED,_onPreloadingComplHandler);
//        (getHandler(CArenaNetHandler) as CArenaNetHandler).arenaChallengeRequest(m_iCurrChallengeRank);
    }

    public function addTips(tipsClass:Class, item:Component, args:Array = null) : void
    {
        m_pArenaUIHandler.addTips(tipsClass, item, args);
    }

    private function get _arenaHelp():CArenaHelpHandler
    {
       return this.getHandler(CArenaHelpHandler) as CArenaHelpHandler;
    }

    public function get currChallengeRank():int
    {
        return m_iCurrChallengeRank;
    }

    public function set currChallengeRank(value:int):void
    {
        m_iCurrChallengeRank = value;
    }

    override public function dispose() : void
    {
        super.dispose();

        _removeEventListeners();

        m_pMainViewHandler.dispose();
        m_pMainViewHandler = null;

        m_pNetHandler.dispose();
        m_pNetHandler = null;

        m_pManager.dispose();
        m_pManager = null;
    }
}
}
