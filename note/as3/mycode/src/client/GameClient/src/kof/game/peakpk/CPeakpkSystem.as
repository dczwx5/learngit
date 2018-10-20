//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/11/27.
 */
package kof.game.peakpk {


import QFLib.Framework.CScene;

import flash.utils.setTimeout;

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.ISystemBundleContext;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CTarget;
import kof.game.character.display.IDisplay;
import kof.game.character.handler.CPlayHandler;
import kof.game.common.status.CGameStatus;
import kof.game.common.system.CAppSystemImp;
import kof.game.core.CECSLoop;
import kof.game.core.CGameObject;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.event.CInstanceEvent;
import kof.game.level.CLevelManager;
import kof.game.level.CLevelSystem;
import kof.game.peakpk.data.CPeakpkData;
import kof.game.peakpk.enum.EPeakpkDataEventType;
import kof.game.peakpk.event.CPeakpkEvent;
import kof.game.peakpk.imp.CPeakpkResultDataProvider;
import kof.game.peakpk.view.CPeakpkPlayerTips;
import kof.game.scene.CSceneSystem;
import kof.message.Level.StartLevelReadyGOResponse;

import morn.core.components.Component;

public class CPeakpkSystem extends CAppSystemImp  {
    public function CPeakpkSystem() {
    }
    public override function get bundleID() : * {
        return SYSTEM_ID(KOFSysTags.PEAK_PK);
    }
    // ===========================show/hide===========================
    override protected function onActivated(a_bActivated:Boolean) : void {
        super.onActivated(a_bActivated);
        if (isActived) {
            if ( CGameStatus.checkStatus( this ) == false ) {
                setActived( false );
            } else {
                _uiHandler.showPeakpkView();
            }
        } else {
            _uiHandler.hidePeakpkView();
        }
    }
    override protected function onBundleStart(ctx:ISystemBundleContext):void {
        super.onBundleStart(ctx);

//        netHandler.sendGetData();
    }


    public override function dispose() : void {
        super.dispose();
        this.removeEventListener(CPeakpkEvent.NET_RESULT_DATA, _onNetResultData);
        var pInstanceSystem:CInstanceSystem = this.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstanceSystem) {
            pInstanceSystem.removeEventListener(CInstanceEvent.LEVEL_PLAYER_READY, _onLevelPlayerReady);
            pInstanceSystem.removeEventListener(CInstanceEvent.LEVEL_PROCESS_READY_GO_BY_OTHER, _onReadyGoProcess);

        }
    }
    override public function initialize():Boolean {
        var ret:Boolean = super.initialize();

        ret = ret && this.addBean(_manager = new CPeakpkManager());
        ret = ret && this.addBean(_uiHandler = new CPeakpkUIHandler());
        ret = ret && this.addBean(_netHandler = new CPeakpkNetHandler());
        ret = ret && this.addBean(new CPeakpkResultDataProvider());

        this.registerEventType(CPeakpkEvent.NET_EVENT_DATA);
        this.registerEventType(CPeakpkEvent.NET_EVENT_UPDATE_DATA);
        this.registerEventType(CPeakpkEvent.NET_RESULT_DATA);
        this.registerEventType(CPeakpkEvent.NET_PK_SUCCESS_DATA_1P);
        this.registerEventType(CPeakpkEvent.NET_PK_FAIL_DATA_1P);
        this.registerEventType(CPeakpkEvent.NET_RECEIVE_REFUSE_DATA_P1);
        this.registerEventType(CPeakpkEvent.NET_RECEIVE_CONFIRM_DATA_P1);
        this.registerEventType(CPeakpkEvent.NET_RECEIVE_INVITE_DATA_2P);
        this.registerEventType(CPeakpkEvent.NET_MATCH_DATA);
        this.registerEventType(CPeakpkEvent.NET_LOADING_DATA);
        this.registerEventType(CPeakpkEvent.NET_RECEIVE_INVITE_CANCEL_DATA_P2);

        var pInstanceSystem:CInstanceSystem = this.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        pInstanceSystem.addEventListener(CInstanceEvent.LEVEL_PLAYER_READY, _onLevelPlayerReady);
        pInstanceSystem.addEventListener(CInstanceEvent.LEVEL_PROCESS_READY_GO_BY_OTHER, _onReadyGoProcess);

        this.addEventListener(CPeakpkEvent.NET_RESULT_DATA, _onNetResultData);

        return ret;
    }

    public function update(delta:Number) : void {
    }

        // 弹结算
    private function _onNetResultData(event:CPeakpkEvent):void {
        var e : CPeakpkEvent = event as CPeakpkEvent;
        if (e.type == CPeakpkEvent.NET_RESULT_DATA) {
            var pInstanceSystem:CInstanceSystem = this.stage.getSystem(CInstanceSystem) as CInstanceSystem;
            pInstanceSystem.uiHandler.hideResultPvpWinView();
            uiHandler.uiCanvas.removePVPLoadingView();

            var resultData:Object = e.data as Object;
            manager.data.updateResultData(resultData);
            sendEvent(new CPeakpkEvent(CPeakpkEvent.DATA_EVENT, EPeakpkDataEventType.RESULT_DATA, manager.data));
            pInstanceSystem.startWaitAllGameObjectFinish();
            pInstanceSystem.addEventListener(CInstanceEvent.INSTANCE_ALL_GAME_OBJECT_FINISH_OR_TIME_OUT, _onInstanceAllGameObjectFinish);
        }
    }
    private function _onInstanceAllGameObjectFinish(e:CInstanceEvent) : void {
        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstanceSystem) {
            pInstanceSystem.removeEventListener(CInstanceEvent.INSTANCE_ALL_GAME_OBJECT_FINISH_OR_TIME_OUT, _onInstanceAllGameObjectFinish);
        }

        uiHandler.showResult();
    }
    private function _onReadyGoProcess(e:CInstanceEvent) : void {
        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (!pInstanceSystem) {
            return ;
        }
        var isPeakpk:Boolean = EInstanceType.isPeakPK(pInstanceSystem.instanceType);
        if (!isPeakpk) return ;

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
    // 设置起始镜头, 目标
    private function _onLevelPlayerReady(e:CInstanceEvent) : void {
        _setHeroTarget(0);
    }
    private function _setHeroTarget(delta:Number) : void {
        uiHandler.removeTick(_setHeroTarget);

        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (!pInstanceSystem) {
            return ;
        }
        var isPeakpk:Boolean = EInstanceType.isPeakPK(pInstanceSystem.instanceType);
        if (!isPeakpk) return ;

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
            uiHandler.addTick(_setHeroTarget);
        }
    }

    public function showPlayerTips(box:Component, args:Array = null) : void {
        if (_playerTipsViewHandler) {
            _playerTipsViewHandler.addTips(box, args);
        }
    }
    // ===========================get/set=============================
    [Inline]
    public function get manager() : CPeakpkManager { return _manager; }
    [Inline]
    public function get uiHandler() : CPeakpkUIHandler { return _uiHandler; }
    [Inline]
    public function get netHandler() : CPeakpkNetHandler { return _netHandler; }
    [Inline]
    public function get data() : CPeakpkData { return _manager.data; }




    private var _manager:CPeakpkManager;
    private var _netHandler:CPeakpkNetHandler;
    private var _uiHandler:CPeakpkUIHandler;
    private var _playerTipsViewHandler:CPeakpkPlayerTips;


}
}
