//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/10/10.
 */
package kof.game.endlessTower {

import QFLib.Framework.CScene;

import flash.utils.setTimeout;

import kof.SYSTEM_ID;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.CSystemBundleEvent;
import kof.game.bundle.ISystemBundleContext;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CTarget;
import kof.game.character.display.IDisplay;
import kof.game.character.handler.CPlayHandler;
import kof.game.common.view.resultWin.CMultiplePVPResultViewHandler;
import kof.game.common.view.resultWin.CPVPResultData;
import kof.game.core.CECSLoop;
import kof.game.core.CGameObject;
import kof.game.endlessTower.data.CEndlessTowerResultData;
import kof.game.endlessTower.event.CEndlessTowerEvent;
import kof.game.endlessTower.data.CEndlessTowerResultDataProvider;
import kof.game.endlessTower.view.CEndlessTowerMainViewHandler;
import kof.game.endlessTower.view.CEndlessTowerSweepViewHandler;
import kof.game.instance.CInstanceExitProcess;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.event.CInstanceEvent;
import kof.game.item.data.CRewardData;
import kof.game.level.CLevelManager;
import kof.game.level.CLevelSystem;
import kof.game.scene.CSceneSystem;
import kof.game.endlessTower.view.CEndlessTowerResultViewHandler;
import kof.message.Level.StartLevelReadyGOResponse;

import morn.core.handlers.Handler;

/**
 * 无尽之塔系统
 * @author sprite (sprite@qifun.com)
 */
public class CEndlessTowerSystem extends CBundleSystem {

    private var m_bInitialized : Boolean;

    private var m_pMainViewHandler:CEndlessTowerMainViewHandler;
    private var m_pManager:CEndlessTowerManager;
    private var m_pNetHandler:CEndlessTowerNetHandler;
    private var m_pDataProvider:CEndlessTowerResultDataProvider;

    public function CEndlessTowerSystem( A_objBundleID : * = null )
    {
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

            m_pMainViewHandler = new CEndlessTowerMainViewHandler();
            this.addBean( m_pMainViewHandler );
            m_pMainViewHandler.closeHandler = new Handler( _onViewClosed );

            m_pNetHandler = new CEndlessTowerNetHandler();
            this.addBean( m_pNetHandler );

            m_pManager = new CEndlessTowerManager();
            this.addBean( m_pManager );

            this.addBean( new CEndlessTowerHelpHandler() );

            var pInstanceSystem:CInstanceSystem = this.stage.getSystem(CInstanceSystem) as CInstanceSystem;
            pInstanceSystem.addEventListener(CInstanceEvent.LEVEL_PLAYER_READY, _onLevelPlayerReady);
            pInstanceSystem.addEventListener(CInstanceEvent.LEVEL_PROCESS_READY_GO_BY_OTHER, _onReadyGoProcess);

            this.addEventListener(CEndlessTowerEvent.NET_RESULT, _onNetResultData);

            m_pDataProvider = new CEndlessTowerResultDataProvider();
            this.addBean(m_pDataProvider);

            this.addBean(new CEndlessTowerUIHandler());
            this.addBean(new CEndlessTowerSweepViewHandler());
        }

        return m_bInitialized;
    }

    private function _onNetResultData(event:CEndlessTowerEvent):void {
        var pInstanceSystem:CInstanceSystem = this.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        pInstanceSystem.uiHandler.hideResultPvpWinView();
        pInstanceSystem.uiHandler.uiCanvas.removePVPLoadingView();

        pInstanceSystem.startWaitAllGameObjectFinish();
        pInstanceSystem.addEventListener(CInstanceEvent.INSTANCE_ALL_GAME_OBJECT_FINISH_OR_TIME_OUT, _onInstanceAllGameObjectFinish);
    }
    private function _onInstanceAllGameObjectFinish(e:CInstanceEvent) : void {
        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstanceSystem) {
            pInstanceSystem.removeEventListener(CInstanceEvent.INSTANCE_ALL_GAME_OBJECT_FINISH_OR_TIME_OUT, _onInstanceAllGameObjectFinish);
        }

        var resultData:CEndlessTowerResultData = m_pManager.resultData;
        if(resultData)
        {
            var pvpResultData:CPVPResultData = m_pDataProvider.getResultData();
            var resultView:CMultiplePVPResultViewHandler = pInstanceSystem.getHandler(CMultiplePVPResultViewHandler) as CMultiplePVPResultViewHandler;

            resultView.data = pvpResultData;
            resultView.addDisplay();
        }
        else
        {
            pInstanceSystem.exitInstance();
        }
    }

    private function _onReadyGoProcess(e:CInstanceEvent) : void {
        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (!pInstanceSystem) {
            return ;
        }
        var isEndLess:Boolean = EInstanceType.isEndLessTower(pInstanceSystem.instanceType);
        if (!isEndLess) return ;

        var pLevelSystem:CLevelSystem = stage.getSystem(CLevelSystem) as CLevelSystem;
        if (!pLevelSystem) {
            return ;
        }

        var response:StartLevelReadyGOResponse = e.data as StartLevelReadyGOResponse;

        pLevelSystem.pause();
        pInstanceSystem.uiHandler.showRoundStartView(response);
        if (response.readyGO > 0) {
            setTimeout(pInstanceSystem.uiHandler.showReadyGoView, 2000);
        }
        setTimeout((pLevelSystem.getBean(CLevelManager) as CLevelManager).playRoundAnimation, 800, response.roundNum);

    }

    private function _onLevelPlayerReady(e:CInstanceEvent) : void {
        _setHeroTarget(0);
    }
    private function _setHeroTarget(delta:Number) : void {

        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (!pInstanceSystem) {
            return ;
        }
        pInstanceSystem.uiHandler.removeTick(_setHeroTarget);

        var isEndless:Boolean = EInstanceType.isEndLessTower(pInstanceSystem.instanceType);
        if (!isEndless) return ;

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
            pInstanceSystem.uiHandler.addTick(_setHeroTarget);
        }
    }


    override public function get bundleID() : *
    {
        return SYSTEM_ID(KOFSysTags.ENDLESS_TOWER);
    }

    override protected function onBundleStart(ctx:ISystemBundleContext):void
    {
        super.onBundleStart(ctx);

        // 登陆时主界面图标提示
        _onIconTipHandler();

        addEventListeners();
    }

    protected function addEventListeners() : void
    {
        stage.getSystem(ISystemBundleContext ).addEventListener(CSystemBundleEvent.USER_DATA,_onUserDataHandler);
        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstanceSystem)
        {
            pInstanceSystem.addEventListener(CInstanceEvent.ENTER_INSTANCE, _onEnterInstanceHandler);
        }

        this.addEventListener(CEndlessTowerEvent.BaseInfo_Update, _onEndlessInfoUpdateHandler);
        this.addEventListener(CEndlessTowerEvent.DayRewardInfo_Update, _onDailyRewardInfoUpdateHandler);
        this.addEventListener(CEndlessTowerEvent.BoxRewardInfo_Update, _onBoxRewardInfoUpdateHandler);
        this.addEventListener(CEndlessTowerEvent.SweepSucc, _onSweepSuccHandler);
    }

    protected function removeEventListeners() : void
    {
        stage.getSystem(ISystemBundleContext ).removeEventListener(CSystemBundleEvent.USER_DATA,_onUserDataHandler);
        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstanceSystem)
        {
            pInstanceSystem.removeEventListener(CInstanceEvent.ENTER_INSTANCE, _onEnterInstanceHandler);
        }

        this.removeEventListener(CEndlessTowerEvent.BaseInfo_Update, _onEndlessInfoUpdateHandler);
        this.removeEventListener(CEndlessTowerEvent.DayRewardInfo_Update, _onDailyRewardInfoUpdateHandler);
        this.removeEventListener(CEndlessTowerEvent.BoxRewardInfo_Update, _onBoxRewardInfoUpdateHandler);
        this.removeEventListener(CEndlessTowerEvent.SweepSucc, _onSweepSuccHandler);
    }

    override protected function onActivated( value : Boolean ) : void
    {
        super.onActivated( value );

        var pView : CEndlessTowerMainViewHandler = this.getHandler( CEndlessTowerMainViewHandler ) as CEndlessTowerMainViewHandler;
        if ( !pView )
        {
            LOG.logErrorMsg( "SystemBundle activated, but the CEndlessTowerMainViewHandler isn't instance." );
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

    private function _onUserDataHandler(e:CSystemBundleEvent):void
    {
    }

    private function _onEnterInstanceHandler(e:CInstanceEvent):void
    {
        if (e.type == CInstanceEvent.ENTER_INSTANCE)
        {
            var instanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
            if(EInstanceType.isEndLessTower(instanceSystem.instanceType))
            {
                instanceSystem.addExitProcess(null, CInstanceExitProcess.FLAG_ENDLESS_TOWER_AUTO, _autoChallenge, null, 9999);
                instanceSystem.addExitProcess(CEndlessTowerMainViewHandler, CInstanceExitProcess.FLAG_ENDLESS_TOWER, this.setActivated, [true], 9999);
            }
        }
    }

    private function _autoChallenge():void
    {
        if(m_pMainViewHandler)
        {
            m_pMainViewHandler.isExitInstance = true;
        }
    }

    private function _onIconTipHandler():void
    {
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleContext)
        {
            pSystemBundleContext.setUserData(this,CBundleSystem.NOTIFICATION, _helper.hasRewardCanTake());
        }
    }

    private function _onEndlessInfoUpdateHandler(e:CEndlessTowerEvent):void
    {
        _onIconTipHandler();
    }

    private function _onDailyRewardInfoUpdateHandler(e:CEndlessTowerEvent):void
    {
        _onIconTipHandler();
    }

    private function _onBoxRewardInfoUpdateHandler(e:CEndlessTowerEvent):void
    {
        _onIconTipHandler();
    }

    /**
     * 扫荡成功处理
     * @param e
     */
    private function _onSweepSuccHandler(e:CEndlessTowerEvent):void
    {
        var resultArr:Array = [];
        var rewards:Array = e.data as Array;
        var sweepView:CEndlessTowerSweepViewHandler = getHandler(CEndlessTowerSweepViewHandler)
            as CEndlessTowerSweepViewHandler;
        if(sweepView && rewards)
        {
            for(var i:int = 0; i < rewards.length; i++)
            {
                var rewardData:CRewardData = new CRewardData();
                rewardData.databaseSystem = stage.getSystem(IDatabase) as IDatabase;
                rewardData.updateDataByData(rewards[i]);
                resultArr.push(rewardData);
            }
        }

        sweepView.data = resultArr;
        sweepView.addDisplay();
    }

    /**
     * 是否处于自动挑战的状态中
     */
    public function get isInAutoChallenge():Boolean
    {
        if(m_pMainViewHandler && m_pMainViewHandler.isViewShow)
        {
            return m_pMainViewHandler.isInAutoChallenge;
        }

        return false;
    }

    public function get _helper():CEndlessTowerHelpHandler
    {
        return getHandler(CEndlessTowerHelpHandler) as CEndlessTowerHelpHandler;
    }

    override public function dispose() : void
    {
        super.dispose();

        removeEventListeners();

        m_pMainViewHandler.dispose();
        m_pMainViewHandler = null;

        m_pNetHandler.dispose();
        m_pNetHandler = null;

        m_pManager.dispose();
        m_pManager = null;
    }
}
}
