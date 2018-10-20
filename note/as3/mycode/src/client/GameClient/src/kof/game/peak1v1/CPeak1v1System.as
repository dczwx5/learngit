//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/23.
 */
package kof.game.peak1v1 {


import QFLib.Foundation.CTime;
import QFLib.Framework.CScene;

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.ISystemBundleContext;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CTarget;
import kof.game.character.display.IDisplay;
import kof.game.character.handler.CPlayHandler;
import kof.game.common.status.CGameStatus;
import kof.game.common.system.CAppSystemImp;
import kof.game.common.system.CInstanceOverHandler;
import kof.game.core.CECSLoop;
import kof.game.core.CGameObject;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.event.CInstanceEvent;
import kof.game.peak1v1.data.CPeak1v1Data;
import kof.game.peak1v1.enum.EPeak1v1DataEventType;
import kof.game.peak1v1.event.CPeak1v1Event;
import kof.game.peak1v1.view.imp.CPeak1v1ResultDataProvider;
import kof.game.scene.CSceneSystem;

import morn.core.handlers.Handler;
// send open_peak1v1
public class CPeak1v1System extends CAppSystemImp  {
    public function CPeak1v1System() {
    }
    public override function get bundleID() : * {
        return SYSTEM_ID(KOFSysTags.PEAK_1V1);
    }
    // ===========================show/hide===========================
    override protected function onActivated(a_bActivated:Boolean) : void {
        super.onActivated(a_bActivated);
        if (isActived) {
            if (CGameStatus.isNotStatus(CGameStatus.Status_Peak1v1Match) && CGameStatus.checkStatus(this) == false) {
                // 有互斥状态, 则不能打开
                setActived(false);
            } else {
                if (data.regState > 0) {
                    CGameStatus.setStatus(CGameStatus.Status_Peak1v1Match);
                }
                _uiHandler.showPeak1v1View();
                closeAllSystemBundle([SYSTEM_ID(KOFSysTags.PEAK_1V1)]);
            }
        } else {
            CGameStatus.unSetStatus(CGameStatus.Status_Peak1v1Match);
            _uiHandler.hidePeak1v1View();
            _uiHandler.hideAll();
        }
    }
    override protected function onBundleStart(ctx:ISystemBundleContext):void {
        super.onBundleStart(ctx);

        var dataInitialHandler:Function = function (e:CPeak1v1Event) : void {
            if (e.subEvent == EPeak1v1DataEventType.START_TIME_CHANGE_DATA) {
                var curTime:Number = CTime.getCurrServerTimestamp();
                var startTime:Number = data.showNotifyStartTime;
                var endTime:Number = data.startTime;
                var deltaTime:Number = startTime - curTime;
                if (curTime < endTime && curTime >= startTime) {
                    uiHandler.showNotifyView();
                } else if (curTime < startTime) {
                    uiHandler.DelayCall(deltaTime/1000, uiHandler.showNotifyView);
                } else {
                    // 活动ing
                }
            }
        };
        addEventListener(CPeak1v1Event.DATA_EVENT, dataInitialHandler);

        netHandler.sendGetData();
    }


    public override function dispose() : void {
        super.dispose();
        this.removeEventListener(CPeak1v1Event.NET_RESULT_DATA, _onNetResultData);
        var pInstanceSystem:CInstanceSystem = this.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstanceSystem) {
            pInstanceSystem.removeEventListener(CInstanceEvent.LEVEL_PLAYER_READY, _onLevelPlayerReady);
        }
    }
    override public function initialize():Boolean {
        var ret:Boolean = super.initialize();


        ret = ret && this.addBean(_redPoint = new CPeak1v1RedPoint());
        _redPoint.processNotify();

        ret = ret && this.addBean(_manager = new CPeak1v1Manager());
        ret = ret && this.addBean(_uiHandler = new CPeak1v1UIHandler());
        ret = ret && this.addBean(_netHandler = new CPeak1v1NetHandler());
        ret = ret && this.addBean(new CPeak1v1ResultDataProvider());
        ret = ret && this.addBean(_instanceOverHandler = new CInstanceOverHandler(EInstanceType.TYPE_PEAK_1V1,
                        new Handler(_uiHandler.showResult)));

        this.registerEventType(CPeak1v1Event.NET_EVENT_DATA);
        this.registerEventType(CPeak1v1Event.NET_EVENT_UPDATE_DATA);
        this.registerEventType(CPeak1v1Event.NET_ENEMY_PROGRESS_DATA);
        this.registerEventType(CPeak1v1Event.NET_RESULT_DATA);
        this.registerEventType(CPeak1v1Event.NET_REPORT_DATA);
        this.registerEventType(CPeak1v1Event.NET_RANKING_DATA);
        this.registerEventType(CPeak1v1Event.NET_DOWN_SINGLE_DATA);
        this.registerEventType(CPeak1v1Event.NET_MATCH_DATA);

        var pInstanceSystem:CInstanceSystem = this.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        pInstanceSystem.addEventListener(CInstanceEvent.LEVEL_PLAYER_READY, _onLevelPlayerReady);

        this.addEventListener(CPeak1v1Event.NET_RESULT_DATA, _onNetResultData);
        _instanceOverHandler.listenEvent();

        return ret;
    }

    public function update(delta:Number) : void {
    }

        // 弹结算
    private function _onNetResultData(event:CPeak1v1Event):void {
        var e : CPeak1v1Event = event as CPeak1v1Event;
        if (e.type == CPeak1v1Event.NET_RESULT_DATA) {
            var pInstanceSystem:CInstanceSystem = this.stage.getSystem(CInstanceSystem) as CInstanceSystem;
            pInstanceSystem.uiHandler.hideResultPvpWinView();
            uiHandler.uiCanvas.removePVPLoadingView();

            var resultData:Object = e.data as Object;
            manager.data.updateResultData(resultData);
            sendEvent(new CPeak1v1Event(CPeak1v1Event.DATA_EVENT, EPeak1v1DataEventType.RESULT_DATA, manager.data));

            _instanceOverHandler.instanceOverEventProcess(null);
        }
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
        var isPeak1v1:Boolean = EInstanceType.isPeak1v1(pInstanceSystem.instanceType);
        if (!isPeak1v1) return ;

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

    // ===========================get/set=============================
    [Inline]
    public function get manager() : CPeak1v1Manager { return _manager; }
    [Inline]
    public function get uiHandler() : CPeak1v1UIHandler { return _uiHandler; }
    [Inline]
    public function get netHandler() : CPeak1v1NetHandler { return _netHandler; }
    [Inline]
    public function get data() : CPeak1v1Data { return _manager.data; }




    private var _manager:CPeak1v1Manager;
    private var _netHandler:CPeak1v1NetHandler;
    private var _uiHandler:CPeak1v1UIHandler;
    private var _redPoint:CPeak1v1RedPoint; // 小红点
    private var _instanceOverHandler:CInstanceOverHandler;


}
}
