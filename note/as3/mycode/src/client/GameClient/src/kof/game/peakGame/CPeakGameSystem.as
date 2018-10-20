//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/6.
 */
package kof.game.peakGame {

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
import kof.game.common.system.CInstanceOverHandler;
import kof.game.core.CECSLoop;
import kof.game.core.CGameObject;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.event.CInstanceEvent;
import kof.game.level.CLevelManager;
import kof.game.level.CLevelSystem;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.peakGame.enum.EPeakGameDataEventType;
import kof.game.peakGame.enum.EPeakGameWndType;
import kof.game.peakGame.event.CPeakGameEvent;
import kof.game.peakGame.imp.CPeakResultDataProvider;
import kof.game.peakGame.view.main.CPeakGameTipViewHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CEmbattleListData;
import kof.game.scene.CSceneSystem;
import kof.game.shop.enum.EShopType;
import kof.message.Level.StartLevelReadyGOResponse;

import morn.core.handlers.Handler;

public class CPeakGameSystem extends CAppSystemImp  {
    public function CPeakGameSystem() {
    }
    public override function get bundleID() : * {
        return SYSTEM_ID(KOFSysTags.PEAK_GAME_FAIR);
    }
    // ===========================show/hide===========================
    override protected function onActivated(a_bActivated:Boolean) : void {
        super.onActivated(a_bActivated);

        if (isActived) {
            if (CGameStatus.isNotStatus(CGameStatus.Status_PeakGameMatch) && CGameStatus.checkStatus(this) == false) {
                setActived(false);
            } else {
                _iPlayType = EPeakGameWndType.PLAY_TYPE_FAIR;
                _uiHandler.showPeakGame( EPeakGameWndType.PLAY_TYPE_FAIR );
                closeAllSystemBundle( [ SYSTEM_ID( KOFSysTags.PEAK_GAME_FAIR ), SYSTEM_ID( KOFSysTags.SYSTEM_NOTICE ) ] );
            }
        } else {
            _uiHandler.hidePeakGameFair();
        }
    }
    override protected function onBundleStart(ctx:ISystemBundleContext):void {
        super.onBundleStart(ctx);
        netHandler.sendGetData(EPeakGameWndType.PLAY_TYPE_FAIR);
    }

    // =============fair bundle==================

    public override function dispose() : void {
        super.dispose();
        this.removeEventListener(CPeakGameEvent.NET_EVENT_SETTLEMENT_DATA, _onNetResultData);
        var pInstanceSystem:CInstanceSystem = this.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstanceSystem) {
            pInstanceSystem.removeEventListener(CInstanceEvent.LEVEL_PLAYER_READY, _onLevelPlayerReady);
            pInstanceSystem.removeEventListener(CInstanceEvent.LEVEL_PROCESS_READY_GO_BY_OTHER, _onReadyGoProcess);

        }
    }
    override public function initialize():Boolean {
        var ret:Boolean = super.initialize();


        ret = ret && this.addBean(_redPoint = new CPeakGameRedPoint());
        _redPoint.processNotify();

        ret = ret && this.addBean(_manager = new CPeakGameManager());
        ret = ret && this.addBean(_uiHandler = new CPeakGameUIHandler());
        ret = ret && this.addBean(_handler = new CPeakGameHandler());
        ret = ret && this.addBean(new CPeakResultDataProvider());
        ret = ret && this.addBean(_instanceOverHandler = new CInstanceOverHandler(EInstanceType.TYPE_PEAK_GAME_FAIR,
                        new Handler(_uiHandler.showResult)));
        ret = ret && this.addBean(new CPeakGameTipViewHandler());

        this.registerEventType(CPeakGameEvent.NET_EVENT_DATA);
        this.registerEventType(CPeakGameEvent.NET_EVENT_UPDATE_DATA);

        this.registerEventType(CPeakGameEvent.NET_EVENT_MATCHING);
        this.registerEventType(CPeakGameEvent.NET_EVENT_MATCH_DATA);
        this.registerEventType(CPeakGameEvent.NET_EVENT_HONOUR_DATA);
        this.registerEventType(CPeakGameEvent.NET_EVENT_REPORT_DATA);
        this.registerEventType(CPeakGameEvent.NET_EVENT_RANK_DATA);
        this.registerEventType(CPeakGameEvent.NET_EVENT_LOADING_DATA);
        this.registerEventType(CPeakGameEvent.NET_EVENT_SETTLEMENT_DATA);
        this.registerEventType(CPeakGameEvent.NET_EVENT_ENTER_ERROR);
        this.registerEventType(CPeakGameEvent.NET_EVENT_NOTIFY_CLIENT_REFRESH);

        this.registerEventType(CPeakGameEvent.DATA_EVENT);

        var pInstanceSystem:CInstanceSystem = this.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        pInstanceSystem.addEventListener(CInstanceEvent.LEVEL_PLAYER_READY, _onLevelPlayerReady);
        pInstanceSystem.addEventListener(CInstanceEvent.LEVEL_PROCESS_READY_GO_BY_OTHER, _onReadyGoProcess);

        this.addEventListener(CPeakGameEvent.NET_EVENT_SETTLEMENT_DATA, _onNetResultData);
        _instanceOverHandler.listenEvent();

        return ret;
    }

    private function _onNetResultData(event:CPeakGameEvent):void {
        var e : CPeakGameEvent = event as CPeakGameEvent;
        if (e.type == CPeakGameEvent.NET_EVENT_SETTLEMENT_DATA) {
            var pInstanceSystem:CInstanceSystem = this.stage.getSystem(CInstanceSystem) as CInstanceSystem;
            pInstanceSystem.uiHandler.hideResultPvpWinView();
            uiHandler.uiCanvas.removePVPLoadingView();

            var peakData:Object = e.data[0] as Object;
            var playType:int = e.data[1] as int;
            manager.data.updateSettlementData(peakData);
            sendEvent(new CPeakGameEvent(CPeakGameEvent.DATA_EVENT, EPeakGameDataEventType.SETTLEMENT, manager.data));

            _instanceOverHandler.instanceOverEventProcess(null);
        }
    }
    private function _onReadyGoProcess(e:CInstanceEvent) : void {
        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (!pInstanceSystem) {
            return ;
        }
        var isPeak:Boolean = EInstanceType.isPeakGame(pInstanceSystem.instanceType);
        if (!isPeak) return ;

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
        uiHandler.removeTick(_setHeroTarget);

        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (!pInstanceSystem) {
            return ;
        }
        var isPeak:Boolean = EInstanceType.isPeakGame(pInstanceSystem.instanceType);
        if (!isPeak) return ;

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

    // ====================util==========================
    public function get playType() : int {
        return _iPlayType;
    }
    public function get embattleType() : int {
        return (_iPlayType == EPeakGameWndType.PLAY_TYPE_NORMAL) ? EInstanceType.TYPE_PEAK_GAME : EInstanceType.TYPE_PEAK_GAME_FAIR;
    }
    public function get instanceType() : int {
        return (_iPlayType == EPeakGameWndType.PLAY_TYPE_NORMAL) ? EInstanceType.TYPE_PEAK_GAME : EInstanceType.TYPE_PEAK_GAME_FAIR;
    }

    public function get embattleListData() : CEmbattleListData {
        var playerSystem:CPlayerSystem = stage.getSystem(CPlayerSystem) as CPlayerSystem;
        var emList:CEmbattleListData = playerSystem.playerData.embattleManager.getByType(embattleType);
        return emList;
    }
    public function get shopType() : int {
        return (_iPlayType == EPeakGameWndType.PLAY_TYPE_NORMAL) ? EShopType.SHOP_TYPE_5 : EShopType.SHOP_TYPE_5;
    }
    public function get isShowQuality() : Boolean {
        if (_iPlayType == EPeakGameWndType.PLAY_TYPE_NORMAL) {
            return true;
        } else {
            return false;
        }
    }
    public function get isShowLevel() : Boolean {
        if (_iPlayType == EPeakGameWndType.PLAY_TYPE_NORMAL) {
            return true;
        } else {
            return false;
        }
    }
    // ===========================get/set=============================
    [Inline]
    public function get manager() : CPeakGameManager { return _manager; }
    [Inline]
    public function get uiHandler() : CPeakGameUIHandler { return _uiHandler; }
    [Inline]
    public function get netHandler() : CPeakGameHandler { return _handler; }
    [Inline]
    public function get peakGameData() : CPeakGameData { return _manager.data; }
    public function get redPoint() : CPeakGameRedPoint { return _redPoint; }


    private var _manager:CPeakGameManager;
    private var _handler:CPeakGameHandler;
    private var _uiHandler:CPeakGameUIHandler;
    private var _redPoint:CPeakGameRedPoint; // 小红点

    private var _iPlayType:int; // 当前类型
    private var _instanceOverHandler:CInstanceOverHandler;

}
}
