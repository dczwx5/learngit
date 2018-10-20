/**
 * Created by auto on 2016/5/17.
 */
package kof.game.level {

import QFLib.Framework.CScene;
import QFLib.Math.CMath;

import flash.geom.Point;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;

import kof.framework.INetworking;
import kof.game.Tutorial.CTutorSystem;
import kof.game.character.handler.CPlayHandler;
import kof.game.character.scene.CSceneMediator;
import kof.game.common.system.CNetHandlerImp;
import kof.game.core.CECSLoop;
import kof.game.core.CGameObject;
import kof.game.fightui.CFightViewHandler;
import kof.game.fightui.compoment.CFighterHeadViewHandler;
import kof.game.instance.enum.EInstanceType;
import kof.game.level.event.CLevelEvent;
import kof.game.level.teaching.CTeachingHandler;
import kof.game.lobby.CLobbySystem;
import kof.game.scenario.IScenarioSystem;
import kof.game.scene.CSceneRendering;
import kof.game.scene.CSceneSystem;
import kof.game.scene.ISceneFacade;
import kof.message.CAbstractPackMessage;
import kof.message.Level.AchieveTeachEventRequest;
import kof.message.Level.ActivePortalResponse;
import kof.message.Level.ActiveTeachGoalResponse;
import kof.message.Level.ActiveTruckResponse;
import kof.message.Level.ClearanceTruckResponse;
import kof.message.Level.EachGameEndResponse;
import kof.message.Level.EndPortalRequest;
import kof.message.Level.EndScenarioRequest;
import kof.message.Level.EnterTruckResponse;
import kof.message.Level.LevelStartRequest;
import kof.message.Level.LockScreenResponse;
import kof.message.Level.PlayAnimationResponse;
import kof.message.Level.PlayBossCommingEndRequest;
import kof.message.Level.PlayBossCommingResponse;
import kof.message.Level.PlayEffectResponse;
import kof.message.Level.PlayEnemyCommingResponse;
import kof.message.Level.PlayMonsterAnimation;
import kof.message.Level.PlaySceneInfoResponse;
import kof.message.Level.PlayWinActorEndRequest;
import kof.message.Level.PlayWinActorResponse;
import kof.message.Level.RoundResponse;
import kof.message.Level.SceneLayerRollResponse;
import kof.message.Level.ShakeScreenResponse;
import kof.message.Level.ShowBubbleBoxResponse;
import kof.message.Level.ShowIntroductionUIEndRequest;
import kof.message.Level.ShowIntroductionUIResponse;
import kof.message.Level.ShowKOAnimationResponse;
import kof.message.Level.StartLevelReadyGOResponse;
import kof.message.Level.StartLevelScenrarioResponse;
import kof.message.Level.StartPlayScenarioRequest;
import kof.message.Level.StartScenarioResponse;
import kof.message.Level.TruckPassEventRequest;
import kof.message.Level.WheelWarHeroStatusListResponse;
import kof.table.InstanceContent;

// 关卡通信, 接收服务器发来的信息
public class CLevelHandler extends CNetHandlerImp {

    public function CLevelHandler() {
        super();
    }

    public override function dispose() : void {
        super.dispose();

        _messageQueue = null;
    }
    override protected function onSetup():Boolean {
        super.onSetup();
        bindHandler(LockScreenResponse, _onLockTrunk);
        bindHandler(StartScenarioResponse, _onPlayScenarioMessageHandler, true);
        bindHandler(ActivePortalResponse, _onActivePortal);
        bindHandler(PlayAnimationResponse, _onPlayAnimation);
        bindHandler(ActiveTruckResponse, _onActiveTrunk);
        bindHandler(EnterTruckResponse, _onEnterTrunk);
        bindHandler(ClearanceTruckResponse, _onCleanTrunk);
        bindHandler(PlayEffectResponse,_onPlayEffect);
        bindHandler(StartLevelReadyGOResponse,_onStartLevelReadyGOResponse);
        bindHandler(StartLevelScenrarioResponse,_onStartLevelScenarioResponse);
        bindHandler(SceneLayerRollResponse,_onSceneLayerRollResponse);
        bindHandler(PlayBossCommingResponse,_onPlayBossComingMessageHandler);
        bindHandler(PlayEnemyCommingResponse,_onPlayEnemyComingResponse);
        bindHandler(EachGameEndResponse,_onEachGameEndResponse);
        bindHandler(RoundResponse,_onRoundResponse);
        bindHandler(WheelWarHeroStatusListResponse,_onWheelWarHeroStatusListResponse);
        bindHandler(PlayMonsterAnimation,_onPlayMonsterAnimation);
        bindHandler(ShakeScreenResponse,_onShakeScreenResponse);
        bindHandler(ShowBubbleBoxResponse,_onShowBubbleBoxResponse);
        bindHandler(PlayWinActorResponse,_onPlayWinActorResponse);
        bindHandler(PlaySceneInfoResponse,_onPlaySceneInfoResponse);
        bindHandler(ActiveTeachGoalResponse,_onActiveTeachGoalResponse);
        bindHandler(ShowKOAnimationResponse,_onShowKOAnimationResponse);
        bindHandler(ShowIntroductionUIResponse,_onShowIntroductionUIResponse);

        _messageQueue = new Vector.<MessageData>();
        return true;
   }


    private function bindHandler(cls:Class, processFunc:Function, isInQueue:Boolean = true) : void {
        if (isInQueue) {
            bind(cls, function (net:INetworking, message:CAbstractPackMessage, isError:Boolean) : void {
                if (isError) return ;

                _messageQueue.push(new MessageData(processFunc, net, message, isError));
                if (_levelManager.isReady) {
                    update(1);
                }
            });
        } else {
            bind(cls, processFunc);
        }

    }

    public override function update(delta:Number) : void {
        var tutor:CTutorSystem = system.stage.getSystem(CTutorSystem) as CTutorSystem;
        if (tutor.isPlayingBattleGuide == false) {
            super.update(delta);
            if (_messageQueue && _messageQueue.length > 0) {
                while (_messageQueue.length > 0) {
                    var message:MessageData = _messageQueue.shift();
                    message.func(message.net, message.message, message.isError);
                }
            }
        }

    }

    private function get _levelManager():CLevelManager{
        return system.getBean(CLevelManager) as CLevelManager;
    }

    private function _onShowBubbleBoxResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        if (isError) return ;

        var response:ShowBubbleBoxResponse = message as ShowBubbleBoxResponse;
        _levelManager.showBubble(response.param);
    }

    private function _onPlayMonsterAnimation(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        if (isError) return ;

        var response:PlayMonsterAnimation = message as PlayMonsterAnimation;
        _levelManager.playMonsterAnimation(response.param);
    }

    //场景抖动
    private function _onShakeScreenResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        if (isError) return ;

        var response:ShakeScreenResponse = message as ShakeScreenResponse;
        var scene:ISceneFacade =  system.stage.getSystem( ISceneFacade ) as ISceneFacade;
        if(scene){
            var arr:Array = response.parameter.split(",");
            scene.shake(arr[0],arr[1],arr[2]);
        }
    }

    // //车轮战格斗家状态列表
    private function _onWheelWarHeroStatusListResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        if (isError) return ;

        var response:WheelWarHeroStatusListResponse = message as WheelWarHeroStatusListResponse;
        system.dispatchEvent(new CLevelEvent(CLevelEvent.WHEEL_WAR_HERO_STATUS_LIST, response));
        (((system.stage.getSystem(CLobbySystem) as CLobbySystem).getBean(CFightViewHandler) as CFightViewHandler).getBean(CFighterHeadViewHandler) as CFighterHeadViewHandler).setData(response);
    }

    private function _onSceneLayerRollResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        if (isError) return ;

        var response:SceneLayerRollResponse = message as SceneLayerRollResponse;
        var paramList:Array = response.param.split(",");
        var scene:CScene = ((system.stage.getSystem(CSceneSystem) as CSceneSystem).getBean(CSceneRendering) as CSceneRendering).scene;
        scene.setLayerRollingThrottle(paramList[0],paramList[1],paramList[2]);
    }

    /**
     * @锁屏消息  wait to modify
     */
    private function _onLockTrunk(net:INetworking, message:CAbstractPackMessage, isError:Boolean) : void {
        if (isError) return ;

        var response:LockScreenResponse = message as LockScreenResponse;
        var topPoint:Point = new Point(response.srcX, response.srcy);
        var bottomPoint:Point = new Point(response.desX, response.desy);
        var centerX:Number = (topPoint.x + bottomPoint.x)*0.5;
        var centerY:Number = (topPoint.y + bottomPoint.y)*0.5;
        var halfWidth:Number = CMath.abs(bottomPoint.x - topPoint.x)*0.5;
        var halfHeight:Number = CMath.abs(bottomPoint.y - topPoint.y)*0.5;

        var scene:CScene = ((system.stage.getSystem(CSceneSystem) as CSceneSystem).getBean(CSceneRendering) as CSceneRendering).scene;
        if (scene) {
            scene.mainCamera.setMovableBoxCenterExtValue(centerX, centerY, halfWidth+105, halfHeight+105*halfHeight/halfWidth, false);
            scene.collisionData.setMovableBoxCenterExtValue(centerX, centerY, halfWidth, halfHeight, false);
        }

    }

    /**
     * 播放剧情
     */
    private final function _onPlayScenarioMessageHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;

        var response:StartScenarioResponse = message as StartScenarioResponse;
        if (false == _levelManager.isScenarioInstance) {
            this.sendScenarioEnd(response.scenarioID);
            return ;
        }

        var instanceDataTable:InstanceContent= (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.INSTANCE_CONTENT ).findByPrimaryKey(response.instanceContentID);
        var isShowStartMask:Boolean = true;
        if(instanceDataTable && instanceDataTable.Type == EInstanceType.TYPE_TEACHING){
            //如果是教学副本
            isShowStartMask = false;
        }
        _levelManager.waitScenario();
        var scenarioSystem:IScenarioSystem = this.system.stage.getSystem(IScenarioSystem) as IScenarioSystem;
        var controlType:int = response.contralType;
        scenarioSystem.playScenario(response.scenarioID, controlType, sendScenarioEnd,isShowStartMask,isShowStartMask, _levelManager.startSceneScenarioID);
    }

    private final function _onPlayBossComingMessageHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        if (isError) return ;

        var response:PlayBossCommingResponse = message as PlayBossCommingResponse;
        var arr:Array = response.param.split(",");
        (system.getBean(CLevelUIHandler) as CLevelUIHandler).showBossComing(arr);
    }
    private final function _onPlayEnemyComingResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        if (isError) return ;

        var response:PlayEnemyCommingResponse = message as PlayEnemyCommingResponse;
        (system.getBean(CLevelUIHandler) as CLevelUIHandler).showMasterComing();

    }

    private final function _onActivePortal(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;

        var response:ActivePortalResponse = message as ActivePortalResponse;
        _levelManager.activePortal();
    }
    private final function _onPlayAnimation(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;

        var response:PlayAnimationResponse = message as PlayAnimationResponse;
        if(response.type == 1){
            if(response.status == 1){
                _levelManager._sceneEffect.playAnimation(response.param);
            }
            else {
                _levelManager._sceneEffect.stopAnimation(response.param);
            }
        }else{
            if(response.status == 1){
                _levelManager._levelEffect.showAnimation(response.param);
            }else{
                _levelManager._levelEffect.stopAnimation(response.param);
            }
        }

    }

    private final function _onPlayEffect(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        if (isError) return ;

        var response:PlayEffectResponse = message as PlayEffectResponse;
        if(response.type == 1){
            if(response.status == 1){
                _levelManager._sceneEffect.playEffect(response.param);
            }else{
                _levelManager._sceneEffect.stopEffect(response.param);
            }

        }else{
            if(response.status == 1){
                _levelManager._levelEffect.showEffect(response.param);
            }else{
                _levelManager._levelEffect.stopEffect(response.param);
            }
        }

    }

    private final function _onActiveTrunk(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;

        var response:ActiveTruckResponse = message as ActiveTruckResponse;
        _levelManager.setCurrentTrunkID(response.truckID);
        _levelManager.setCurReallyTrunkRectByActiveTrunk();
        _levelManager.activeTrunkProcess();
    }
    private final function _onEnterTrunk(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;

        var response:EnterTruckResponse = message as EnterTruckResponse;
        _levelManager.setCurrentTrunkID(response.truckID);
        _levelManager.setCurReallyTrunkRectByEnterTrunk();

        _levelManager.enterTrunkProcess();
    }
    private final function _onCleanTrunk(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;

        _levelManager.trunkCleanProcess();

    }

    private function _onStartLevelReadyGOResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        if (isError) return ;

        // 拳皇赛和其他副本的readyGo的时间同步, 因为其他readyGo做了1秒延迟, 所以正常情况下。两个时间没很大的差异
        var response:StartLevelReadyGOResponse = message as StartLevelReadyGOResponse;
        system.dispatchEvent(new CLevelEvent(CLevelEvent.READY_GO,  response));
    }

    private function _onStartLevelScenarioResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        if (isError) return ;

        var response:StartLevelScenrarioResponse = message as StartLevelScenrarioResponse;
        _levelManager.startSceneScenarioID = response.scenarioID;
    }

    // 拳皇大赛单回合结束
    private function _onEachGameEndResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        if (isError) return ;
        var response:EachGameEndResponse = message as EachGameEndResponse;
        var dataObj:Object = {result:response.result, playerName:response.name, heroID:response.prosession};
         system.dispatchEvent(new CLevelEvent(CLevelEvent.EACHGAME_END, dataObj));
        var scene:CSceneSystem = (system.stage.getSystem(CSceneSystem) as CSceneSystem);
        if(scene)
           scene.initialHeroShowList();
    }

    private function _onRoundResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        var response:RoundResponse = message as RoundResponse;
    }

    //胜利动作
    private function _onPlayWinActorResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        if (isError) return ;
        _levelManager.setPlayWinAnimation(true);
        _levelManager.pauseLevel();
        system.dispatchEvent(new CLevelEvent(CLevelEvent.WINACTOR_START,null));

        var response:PlayWinActorResponse = message as PlayWinActorResponse;

        if(response.playDieCameraEffect){
            _onShowKO(function():void{
                _levelManager.waitAllGameObjectFinishWinAnimation(response.winner,sendPlayWinActorEndRequest, response.winner > 0);
            })
        }else{
            if(response.winner > 0){
                _levelManager.waitAllGameObjectFinishWinAnimation(response.winner,sendPlayWinActorEndRequest, response.winner > 0);
            }
           else{
                sendPlayWinActorEndRequest();
            }
        }
    }

    private function _onShowKOAnimationResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        if (isError) return ;
        _onShowKO();
    }

    private function _onShowKO(fun:Function = null):void{
        (system as CLevelSystem).playKO();
        var pHero:CGameObject = (system.stage.getSystem(CECSLoop).getBean(CPlayHandler) as CPlayHandler).hero;
        if (pHero && pHero.isRunning) {
            var _sceneMediator:CSceneMediator =  (pHero.getComponentByClass( CSceneMediator, true ) as CSceneMediator);
            _sceneMediator.backgroundFlashInTurns(1.0, 0.1, 0xFF0000, 0xFFFFFF);
            _sceneMediator.slowMotionWithDuration(1.0, 0.38,fun);
        }
    }

    private function _onPlaySceneInfoResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        if (isError) return ;

        var response:PlaySceneInfoResponse = message as PlaySceneInfoResponse;
        var arr:Array = response.parameter.split(",");
        (system.getBean(CLevelUIHandler) as CLevelUIHandler).showSceneName(arr);
    }

    //激活教学目标
    private function _onActiveTeachGoalResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        if (isError) return ;

        var response:ActiveTeachGoalResponse = message as ActiveTeachGoalResponse;
        var entityID:int = response.entityID;
        var eventID:int = response.eventID;
        (system.getBean(CTeachingHandler) as CTeachingHandler).executeTeaching(eventID);
    }

    //显示角色登场介绍ui
    private function _onShowIntroductionUIResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if ( isError ) return;
        var response:ShowIntroductionUIResponse = message as ShowIntroductionUIResponse;
        var arr:Array = response.param.split(",");
        (system.getBean(CLevelUIHandler) as CLevelUIHandler).showIntroductionView(arr,sendShowIntroductionUIEndRequest);
    }

    // ============================================== send

    //教学目标完成
    public function sendAchieveTeachEventRequest(teachingID:int):void{
        var request : AchieveTeachEventRequest = new AchieveTeachEventRequest();
        request.eventID = teachingID;
        networking.post( request );
    }

    public function sendPlayWinActorEndRequest(obj:Object = null):void{
        var request : PlayWinActorEndRequest = new PlayWinActorEndRequest();
        request.flag = 1;
        system.dispatchEvent(new CLevelEvent(CLevelEvent.WINACTOR_END,null));
        networking.post( request );
        _levelManager.setPlayWinAnimation(false);

    }

    public function sendEndPortalRequest():void{
        var endPortal : EndPortalRequest = new EndPortalRequest();
        endPortal.portalWay = 1;
        networking.post( endPortal );
    }
    public function sendScenarioEnd(scenarioID:int) : void {
        var endScenario:EndScenarioRequest = new EndScenarioRequest();
        endScenario.scenarioID = scenarioID;
        networking.post(endScenario);
    }

    public function sendTrunkPassedEvent():void{
        var passedEvent:TruckPassEventRequest = new TruckPassEventRequest();
        passedEvent.result = 1;
        networking.post(passedEvent);
    }

    public function sendLevelStartRequest():void{
        var request:LevelStartRequest = new LevelStartRequest();
        request.result = 1;
        networking.post(request);
    }

    public function sendPlayBossComingEndRequest():void{
        var request:PlayBossCommingEndRequest = new PlayBossCommingEndRequest();
        request.param = "1";
        networking.post(request);
    }

    public function sendStartPlayScenario(scenarioID:int):void{
        var request:StartPlayScenarioRequest = new StartPlayScenarioRequest();
        request.scenarioID = scenarioID;
        networking.post(request);
    }

    public function sendShowIntroductionUIEndRequest():void{
        var request:ShowIntroductionUIEndRequest = new ShowIntroductionUIEndRequest();
        request.param = "1";
        networking.post(request);
    }

    private var _messageQueue:Vector.<MessageData>;
}
}

import kof.framework.INetworking;
import kof.message.CAbstractPackMessage;

class MessageData {
    public var func:Function;
    public var net:INetworking;
    public var message:CAbstractPackMessage;
    public var isError:Boolean;
    public function MessageData(rfunc:Function, rnet:INetworking, rmessage:CAbstractPackMessage, risError:Boolean) {
        func = rfunc;
        net = rnet;
        message = rmessage;
        isError = risError;
    }
}
