//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/21.
 */
package kof.game.streetFighter {

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
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CEmbattleListData;
import kof.game.scene.CSceneSystem;
import kof.game.shop.enum.EShopType;
import kof.game.streetFighter.data.CStreetFighterData;
import kof.game.streetFighter.enum.EStreetFighterDataEventType;
import kof.game.streetFighter.event.CStreetFighterEvent;
import kof.message.Level.StartLevelReadyGOResponse;

import morn.core.handlers.Handler;
//
//blake(黄泽标) 05-29 15:47:49
//send add_street_fighter_score addScore
//blake(黄泽标) 05-29 15:48:04
////@auto 加下分就能上排行榜了
//blake(黄泽标) 2018-05-29 10:24:59
//send open_street_fighter 开启系统
//send close_street_fighter 关闭系统
public class CStreetFighterSystem extends CAppSystemImp  {
    public function CStreetFighterSystem() {
    }
    public override function get bundleID() : * {
        return SYSTEM_ID(KOFSysTags.STREET_FIGHTER);
    }
    // ===========================show/hide===========================
    override protected function onActivated(a_bActivated:Boolean) : void {
        super.onActivated(a_bActivated);

        if (isActived) {
            if (CGameStatus.isNotStatus(CGameStatus.Status_StreetFighterMatch) && CGameStatus.checkStatus(this) == false) {
                setActived(false);
            } else {
                _uiHandler.showStreetFighter();
                closeAllSystemBundle( [ SYSTEM_ID( KOFSysTags.STREET_FIGHTER ), SYSTEM_ID( KOFSysTags.SYSTEM_NOTICE ) ] );
            }
        } else {
            _uiHandler.hideStreetFighterFair();
        }
    }
    override protected function onBundleStart(ctx:ISystemBundleContext):void {
        super.onBundleStart(ctx);
        netHandler.sendGetData();
    }

    public override function dispose() : void {
        super.dispose();
        this.removeEventListener(CStreetFighterEvent.NET_EVENT_SETTLEMENT_DATA, _onNetResultData);
        var pInstanceSystem:CInstanceSystem = this.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstanceSystem) {
            pInstanceSystem.removeEventListener(CInstanceEvent.LEVEL_PLAYER_READY, _onLevelPlayerReady);
            pInstanceSystem.removeEventListener(CInstanceEvent.LEVEL_PROCESS_READY_GO_BY_OTHER, _onReadyGoProcess);

        }
    }
    override public function initialize():Boolean {
        var ret:Boolean = super.initialize();


        ret = ret && this.addBean(_redPoint = new CStreetFighterRedPoint());
        _redPoint.processNotify();

        ret = ret && this.addBean(_manager = new CStreetFighterManager());
        ret = ret && this.addBean(new CStreetFighterNetEventTransformHandler());
        ret = ret && this.addBean(_uiHandler = new CStreetFighterUIHandler());
        ret = ret && this.addBean(_netHandler = new CStreetFighterNetHandler());
        ret = ret && this.addBean(new CStreetFighterResultDataProvider());
        ret = ret && this.addBean(_instanceOverHandler = new CInstanceOverHandler(EInstanceType.TYPE_STREET_FIGHTER,
                        new Handler(_uiHandler.showResult)));

        this.registerEventType(CStreetFighterEvent.NET_EVENT_DATA);
        this.registerEventType(CStreetFighterEvent.NET_EVENT_UPDATE_DATA);
        this.registerEventType(CStreetFighterEvent.NET_EVENT_RANK_DATA);
        this.registerEventType(CStreetFighterEvent.NET_EVENT_LOADING_PROGRESS_SYNC_DATA);
        this.registerEventType(CStreetFighterEvent.NET_EVENT_LOADING_DATA);
        this.registerEventType(CStreetFighterEvent.NET_EVENT_REPORT_DATA);
        this.registerEventType(CStreetFighterEvent.NET_EVENT_MATCHING);
        this.registerEventType(CStreetFighterEvent.NET_EVENT_MATCH_DATA);
        this.registerEventType(CStreetFighterEvent.NET_EVENT_SETTLEMENT_DATA);
        this.registerEventType(CStreetFighterEvent.NET_EVENT_ENTER_ERROR);
        this.registerEventType(CStreetFighterEvent.NET_EVENT_SELECTED_HERO);
        this.registerEventType(CStreetFighterEvent.NET_EVENT_NOTIFY_CLIENT_REFRESH);
        this.registerEventType(CStreetFighterEvent.NET_EVENT_GAME_PROMT);
        this.registerEventType(CStreetFighterEvent.NET_EVENT_GET_REWARD);
        this.registerEventType(CStreetFighterEvent.NET_EVENT_SELECT_HERO_READY);
        this.registerEventType(CStreetFighterEvent.NET_EVENT_SELECT_HERO_SYNC);

        this.registerEventType(CStreetFighterEvent.DATA_EVENT);

        var pInstanceSystem:CInstanceSystem = this.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        pInstanceSystem.addEventListener(CInstanceEvent.LEVEL_PLAYER_READY, _onLevelPlayerReady);
        pInstanceSystem.addEventListener(CInstanceEvent.LEVEL_PROCESS_READY_GO_BY_OTHER, _onReadyGoProcess);

        this.addEventListener(CStreetFighterEvent.NET_EVENT_SETTLEMENT_DATA, _onNetResultData);
        _instanceOverHandler.listenEvent();

        return ret;
    }

    private function _onNetResultData(event:CStreetFighterEvent):void {
        var e : CStreetFighterEvent = event as CStreetFighterEvent;
        if (e.type == CStreetFighterEvent.NET_EVENT_SETTLEMENT_DATA) {
            var pInstanceSystem:CInstanceSystem = this.stage.getSystem(CInstanceSystem) as CInstanceSystem;
            pInstanceSystem.uiHandler.hideResultPvpWinView();
            uiHandler.uiCanvas.removePVPLoadingView();

            var streetResultData:Object = e.data as Object;
            manager.data.updateSettlementData(streetResultData);
            sendEvent(new CStreetFighterEvent(CStreetFighterEvent.DATA_EVENT, EStreetFighterDataEventType.SETTLEMENT, manager.data));

            _instanceOverHandler.instanceOverEventProcess(null);
        }
    }
    private function _onReadyGoProcess(e:CInstanceEvent) : void {
        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (!pInstanceSystem) {
            return ;
        }
        var isStreetFighter:Boolean = EInstanceType.isStreetFighter(pInstanceSystem.instanceType);
        if (!isStreetFighter) return ;

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
        var isStreetFighter:Boolean = EInstanceType.isStreetFighter(pInstanceSystem.instanceType);
        if (!isStreetFighter) return ;

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
    public function get embattleType() : int {
        return EInstanceType.TYPE_STREET_FIGHTER;
    }

    public function get embattleListData() : CEmbattleListData {
        var playerSystem:CPlayerSystem = stage.getSystem(CPlayerSystem) as CPlayerSystem;
        var emList:CEmbattleListData = playerSystem.playerData.embattleManager.getByType(embattleType);
        return emList;
    }
    public function get shopType() : int {
        return EShopType.SHOP_TYPE_5;
    }

    // ===========================get/set=============================
    [Inline]
    public function get manager() : CStreetFighterManager { return _manager; }
    [Inline]
    public function get uiHandler() : CStreetFighterUIHandler { return _uiHandler; }
    [Inline]
    public function get netHandler() : CStreetFighterNetHandler { return _netHandler; }
    [Inline]
    public function get data() : CStreetFighterData { return _manager.data; }
    public function get redPoint() : CStreetFighterRedPoint { return _redPoint; }


    private var _manager:CStreetFighterManager;
    private var _netHandler:CStreetFighterNetHandler;
    private var _uiHandler:CStreetFighterUIHandler;
    private var _redPoint:CStreetFighterRedPoint; // 小红点

    private var _instanceOverHandler:CInstanceOverHandler;

}
}
