/**
 * Created by auto on 2016/5/19.
 */
package kof.game.level {

import QFLib.Framework.CObject;
import QFLib.Framework.CScene;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;

import flash.events.Event;

import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.getTimer;

import kof.data.CDataTable;
import kof.data.CDatabaseSystem;
import kof.data.CPreloadData;
import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.framework.events.CEventPriority;
import kof.game.audio.IAudio;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.display.IDisplay;
import kof.game.character.handler.CPlayHandler;
import kof.game.character.movement.CMovement;
import kof.game.character.scene.CBubblesMediator;
import kof.game.character.state.CCharacterInput;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.common.CTest;
import kof.game.core.CECSLoop;
import kof.game.core.CGameObject;
import kof.game.dataLog.CDataLog;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.event.CInstanceEvent;
import kof.game.level.event.CLevelEvent;
import kof.game.level.imp.CGameLevel;
import kof.game.level.imp.CLevelEffect;
import kof.game.level.imp.CLevelEnterProxy;
import kof.game.level.imp.CLevelGoGoGo;
import kof.game.level.imp.CLevelPortalDisplayProcess;
import kof.game.level.imp.CLevelPreload;
import kof.game.level.imp.CSceneEffect;
import kof.game.levelCommon.CLevelLog;
import kof.game.levelCommon.CLevelPath;
import kof.game.levelCommon.info.CLevelConfigInfo;
import kof.game.levelCommon.info.base.CTrunkEntityBaseData;
import kof.game.levelCommon.info.entity.CTrunkEntityMonster;
import kof.game.levelCommon.info.trunk.CTrunkConfigInfo;
import kof.game.loading.CSceneLoadingViewHandler;
import kof.game.scenario.IScenarioSystem;
import kof.game.scenario.event.CScenarioEvent;
import kof.game.scene.CSceneEvent;
import kof.game.scene.CSceneRendering;
import kof.game.scene.CSceneSystem;
import kof.game.scene.ISceneFacade;
import kof.message.Level.EnterLevelResponse;
import kof.table.Dialogue;
import kof.table.InstanceType;
import kof.table.Level;
import kof.table.PlayerDisplay;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;

import morn.core.handlers.Handler;

// 管理关卡, 场景,
public class CLevelManager extends CAbstractHandler implements IUpdatable {
    public function CLevelManager() {
        _isDispose = false;
    }
    public override function dispose()  : void {
        if (_isDispose) return ;

        super.dispose();

        clear();

        if (_enter) {
            _enter.dispose();
            _enter = null;
        }
        if (_gogogo) {
            _gogogo.dispose();
            _gogogo = null;
        }
        if (_preload) {
            _preload.dispose();
            _preload = null;
        }
        if (_portalProcess) {
            _portalProcess.dispose();
            _portalProcess = null;
        }
        if (_gameLevel) {
            _gameLevel.dispose();
            _gameLevel = null;
        }

        if(_levelEffect){
            _levelEffect.dispose();
            _levelEffect = null;
        }

        if(_sceneEffect){
            _sceneEffect.dispose();
            _sceneEffect = null;
        }

        _isDispose = true;
    }

    public function clear() : void {
        _curReallyTrunkRect = null;
        _iDispatchPlayerReadyCounter = 0;
        _isFinalLevel = false;
        _started = false;
        _indexInInstance = -1;
        _instanceType = -1;
        _levelConfigInfo = null;
        _isPlayingScenario = false;
        _isWaitingScenarioPlay = false;
        _curTrunkID = -1;
        _levelID = -1;
        _isReady = false;
        _isInstancePass = false;
        _startSceneScenarioID = -1;
        _isScenarioInstance = false;

        if (_gogogo) _gogogo.clear();
        if (_preload) _preload.clear();
        if (_portalProcess) _portalProcess.clear();
        if (_levelEffect) _levelEffect.clear();

        unlistenScenarioEvents();
    }

    override protected function onSetup():Boolean {
        var ret:Boolean = super.onSetup();
        _enter = new CLevelEnterProxy(this);
        _portalProcess = new CLevelPortalDisplayProcess(this);
        _gogogo = new CLevelGoGoGo(this);
        _preload = new CLevelPreload(this);
        _levelEffect = new CLevelEffect(this);
        _sceneEffect = new CSceneEffect(this);
        return ret;
    }

    // ===================================================================进入关卡===================================================================
    public function enterLevelForPreview(response:*) : void {
        clear();

        _indexInInstance = 0;
        _instanceType = EInstanceType.TYPE_MAIN;
        system.dispatchEvent(new CLevelEvent(CLevelEvent.ENTER, _levelID));

        _isScenarioInstance = (EInstanceType.isScenario(_instanceType));
        listenScenarioEvents();

        _system.addSequential(new Handler(_enter.enterLevelForPreview, [response]), _enter.isLoadFinish);
        _system.addSequential(new Handler(_preloadProcess, null), null);
        _system.addSequential(new Handler(_zoomCamera, null), _isLoadingSwfPlayerEnd);
        _system.addSequential(null, _isPlayerInitial);
        _system.addSequential(new Handler(_onPlayerInitialE, null), _isPassXFrame);
        _system.addSequential(new Handler(_waitToSendPlayerReady, null), null);
    }

    public function onEnter(levelIndex:int, instanceType:int, response:EnterLevelResponse, instanceTypeTable:InstanceType,
                            isFinalLevel:Boolean, preloadListData:Vector.<CPreloadData>) : void {
        clear();

        _externsPreloadListData = preloadListData;

        _isFinalLevel = isFinalLevel;
        _levelID = response.levelID;
        var ui:IUICanvas;
        ui = system.stage.getSystem(IUICanvas) as IUICanvas;
        if (ui) {
            if (EInstanceType.isClassicalMode(instanceType) && levelIndex != 0) {
                ui.showPVPLoadingView();
            } else {
                ui.showSceneLoading();
            }
        }

        _indexInInstance = levelIndex;
        _instanceType = instanceType;
        _instanceTypeTable = instanceTypeTable;
        system.dispatchEvent(new CLevelEvent(CLevelEvent.ENTER, _levelID));

        _isScenarioInstance = (EInstanceType.isScenario(_instanceType));
        listenScenarioEvents();
        _system.addSequential(new Handler(_enter.loadLevelFile, [response]), _enter.isLoadFinish);
        _system.addSequential(new Handler(_preloadProcess, null), _preload.isFinish);
        _system.addSequential(new Handler(_zoomCamera, null), _isLoadingSwfPlayerEnd);
        _system.addSequential(null, _isPlayerInitial);
        _system.addSequential(new Handler(_onPlayerInitialE, null), _isPassXFrame);
        _system.addSequential(new Handler(_waitToSendPlayerReady, null), null);

    }

        private function _preloadProcess() : Boolean {
            CTest.log("关卡开始预加载");
            var pPreloadListData:Vector.<CPreloadData> = _externsPreloadListData;
            _externsPreloadListData = null;

            CLevelLog.addDebugLog("start preload...");
            // 预加载
            _preload.load(pPreloadListData);
            return true;
        }
        private function _zoomCamera() : Boolean {
            CTest.log("设置镜头");
            var sceneSystem:CSceneSystem = system.stage.getSystem(CSceneSystem) as CSceneSystem;
            if(levelConfigInfo.levelCamera) {
                sceneSystem.scenegraph.scene.mainCamera.zoomCenterExtValue(false,levelConfigInfo.levelCamera.center.x,levelConfigInfo.levelCamera.center.y);
            }
            return true;
        }
        private function _isLoadingSwfPlayerEnd() : Boolean {
            CTest.log("等待swf播放完毕");
            var sceneLoadingView:CSceneLoadingViewHandler = ((system.stage.getSystem(CUISystem) as CUISystem).getHandler(CSceneLoadingViewHandler) as CSceneLoadingViewHandler);
            var isPlayLoadingSWF:Boolean = sceneLoadingView.isPlayLoadingSWF;
            return !isPlayLoadingSWF;
        }
        private function _isPlayerInitial() : Boolean {
            CTest.log("等待player初始化好, 等服务器创建hero的协议响应");
            var pHero:CGameObject = (system.stage.getSystem(CECSLoop).getBean(CPlayHandler) as CPlayHandler).hero;
            return pHero && pHero.isRunning;
        }

        private function _onPlayerInitialE() : Boolean {
            CTest.log("播放音乐");
            _isReady = true;
            playBgMusic();
            _iDispatchPlayerReadyCounter = 1;

            return true;
        }
        private function _isPassXFrame() : Boolean {
            _iDispatchPlayerReadyCounter++;
            return _iDispatchPlayerReadyCounter >= 3;
        }
        private function _waitToSendPlayerReady() : Boolean {
            CTest.log("发起ready事件");

            system.dispatchEvent(new CLevelEvent(CLevelEvent.PLAYER_READY, null));
            _system.netHandler.sendLevelStartRequest();

            return true;
        }
    // ========================================进入关卡=========================================================
    // 进入关卡, 全部加载完成
    public function onLevelEntered() : void {
        if (false == isEnterByScenario()) {
            // 只有不是开场剧情的时候, 才由关卡移除loading,
            // 如果是开场剧情, 等剧情开始之后去移除loading
            _onLevelEnteredC();
        } else {
            var scenarioSystem:IScenarioSystem = system.stage.getSystem(IScenarioSystem) as IScenarioSystem;
            scenarioSystem.listenEvent(_onWaitScenarioStartB);
        }
    }
        private function _onWaitScenarioStartB(event:CScenarioEvent) : void {
            if (startSceneScenarioID == event.scenarioID) {
                var scenarioSystem:IScenarioSystem = system.stage.getSystem(IScenarioSystem) as IScenarioSystem;
                if (event.type == CScenarioEvent.EVENT_SCENARIO_START) {
                    // 开场剧情处理, ready
                    _onLevelEnteredC();
                    scenarioSystem.unListenEvent(_onWaitScenarioStartB);
                }  else if (event.type == CScenarioEvent.EVENT_SCENARIO_END) {
                    // 开场剧情, 剧情开始失败, 失败时不会有Ready, 但是会有End
                    if (event.isFail) {
                        _onLevelEnteredC();
                        scenarioSystem.unListenEvent(_onWaitScenarioStartB);
                    }
                }
            }
        }
        private function _onLevelEnteredC() : void {
            var ui:IUICanvas;
            ui = system.stage.getSystem(IUICanvas) as IUICanvas;
            if (ui) {
                ui.removeAllLoadingView();
                CLevelLog.addDebugLog("remove SceneLoading...");
            }
            system.dispatchEvent(new CLevelEvent(CLevelEvent.ENTERED, _levelID));
        }

    public function onStarted() : void {
        system.dispatchEvent(new CLevelEvent(CLevelEvent.START, null));
    }
    public function onExit(levelIndex:int) : void {
        system.dispatchEvent(new CLevelEvent(CLevelEvent.EXIT, _levelID));
    }

    private function listenScenarioEvents() : void {
        // 剧情事件
        var scenarioSystem:IScenarioSystem = system.stage.getSystem(IScenarioSystem) as IScenarioSystem;
        scenarioSystem.listenEvent(_onScenarioUpdate);
    }
    private function unlistenScenarioEvents() : void {
        var scenarioSystem:IScenarioSystem = this.system.stage.getSystem(IScenarioSystem) as IScenarioSystem;
        if (scenarioSystem) {
            scenarioSystem.unListenEvent(_onScenarioUpdate);
        }
    }

    // 副本退出, 关卡离开, 副本级别的离开
    public function exitInstance() : void {
        _isInstancePass = true; // 移到instanceSystem

        var scenarioSystem:IScenarioSystem = system.stage.getSystem(IScenarioSystem) as IScenarioSystem;
        scenarioSystem.stopScenario();
        // 解锁屏
        var scene:CScene = ((system.stage.getSystem(CSceneSystem) as CSceneSystem).getBean(CSceneRendering) as CSceneRendering).scene;
        if (scene) {
            scene.mainCamera.movableBox = null;
            scene.collisionData.movableBox = null;
        }
        _system.setPlayEnable(true);

        var audio:IAudio = system.stage.getSystem(IAudio) as IAudio;
        audio.stopMusic();
    }
    // ===========================================================其他系统的事件处理===================================================================

    private function _onScenarioUpdate(event:CScenarioEvent) : void {
        if (event.type == CScenarioEvent.EVENT_SCENARIO_ENTER) {
            // 剧情开始，做一些处理
            _isPlayingScenario = true;
            _isWaitingScenarioPlay = false;

            // 暂停
            pauseLevel();
        } else if (event.type == CScenarioEvent.EVENT_SCENARIO_START) {
            system.dispatchEvent(new CLevelEvent(CLevelEvent.SCENARIO_START, null));
            (system.getBean(CLevelHandler) as CLevelHandler).sendStartPlayScenario(event.scenarioID);//剧情加载完成后开始播放（统计节点），通知服务端统计数据

        }  else if (event.type == CScenarioEvent.EVENT_SCENARIO_END) {
            // 剧情结束, 做一些处理
            _isPlayingScenario = false;
            _isWaitingScenarioPlay = false;
            system.dispatchEvent(new CLevelEvent(CLevelEvent.SCENARIO_END, {returnLevel:event.returnLevel}));

        } else if (event.type == CScenarioEvent.EVENT_SCENARIO_END_C) {
            continueLevel();
        }
    }
    public function pauseLevel() : void {
        _system.setAIEnable(false);
        _system.setPlayEnable(false);
        _system.setSkillViewEnable(false);
        
        var hero : CGameObject = (system.stage.getSystem(CECSLoop).getBean(CPlayHandler) as CPlayHandler).hero;
        if (hero && hero.isRunning) {
            _pauseProcess();
        } else {
            var pSceneFacade : ISceneFacade = system.stage.getSystem(ISceneFacade) as ISceneFacade;
            pSceneFacade.addEventListener(CSceneEvent.HERO_READY, _pauseProcess);
        }
    }
    private function _pauseProcess(e:CSceneEvent = null) : void {
        var pSceneFacade : ISceneFacade = system.stage.getSystem(ISceneFacade) as ISceneFacade;
        var hero:CGameObject = (system.stage.getSystem(CECSLoop).getBean(CPlayHandler) as CPlayHandler).hero;
        var movment:CMovement = hero.getComponentByClass(CMovement, true) as CMovement;
        movment.direction.setTo(0, 0);
        var input:CCharacterInput = hero.getComponentByClass(CCharacterInput, true) as CCharacterInput;
        input.wheel = new Point();
        pSceneFacade.removeEventListener(CSceneEvent.HERO_READY, _pauseProcess);
    }
    public function continueLevel() : void {
        _system.setPlayEnable(true);
        _system.setAIEnable(true);
        _system.setSkillViewEnable(true);
    }

    // ======================================================
    public function update(delta:Number) : void {
        // ...
        if (_gogogo) _gogogo.update(delta);
    }

    public function waitAllGameObjectFinishWinAnimation(side:int,fnAnimationFinishedCallback:Function = null, isPlayWinAnimation:Boolean = true) : void {
        var instanceSystem:CInstanceSystem = (system.stage.getSystem(CInstanceSystem) as CInstanceSystem);
        instanceSystem.instanceManager.startWaitAllGameObjectFinish();
        instanceSystem.addEventListener(CInstanceEvent.INSTANCE_ALL_GAME_OBJECT_FINISH_OR_TIME_OUT, function _onInstanceAllGameObjectFinish(e:CInstanceEvent) : void {
            var pInstanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
            if (pInstanceSystem) {
                pInstanceSystem.removeEventListener(CInstanceEvent.INSTANCE_ALL_GAME_OBJECT_FINISH_OR_TIME_OUT, _onInstanceAllGameObjectFinish);
            }
　          if (isPlayWinAnimation) {
               winAnimation(side,fnAnimationFinishedCallback);
            } else {
               fnAnimationFinishedCallback();
           }
        });
    }

    public function winAnimation(side:int,fnAnimationFinishedCallback:Function = null):void{
        var _system:CSceneSystem = (system.stage.getSystem(CSceneSystem) as CSceneSystem);
        var bool:Boolean;
        var b_allDead:Boolean = false;
        var array:Vector.<Object> = _system.findAllPlayer().concat(_system.findAllMapObjects());


        for each ( var item:CGameObject in array ){
            var isDead:Boolean = (item.getComponentByClass(CCharacterStateBoard,false) as CCharacterStateBoard).getValue(CCharacterStateBoard.DEAD);
            var modelDisplay : IDisplay = (item as CGameObject).getComponentByClass( IDisplay, true ) as IDisplay;

            if(!isDead){
                if(isShowLoseAnimation()){
                    if(item.data.side == side){
                        var iTypeOf : int = CCharacterDataDescriptor.getType( item.data );
                        var animationString:String;
                        if(iTypeOf == CCharacterDataDescriptor.TYPE_STANDBY){
                            var pTable : IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable( KOFTableConstants.PLAYER_DISPLAY );
                            var playerDisplay : PlayerDisplay = pTable.findByPrimaryKey( item.data.prototypeID );
                            animationString = playerDisplay.ActionOfSideWin;
                        }else{
                            animationString = "Win_1";
                        }
                        b_allDead = true;
                        if(bool){
                            modelDisplay.modelDisplay.playAnimation(animationString,false,true);
                        }
                        else{
                            modelDisplay.modelDisplay.playAnimation(animationString,false,true,false,0,false,0.0,fnAnimationFinishedCallback);
                            bool = true;
                        }
                    }else{
                        modelDisplay.modelDisplay.playAnimation("Lose_1",false,true);
                    }
                }else{
                    if(item.data.side == side){
                        b_allDead = true;
                        if(bool){
                            modelDisplay.modelDisplay.playAnimation("Win_1",false,true);
                        }
                        else{
                            modelDisplay.modelDisplay.playAnimation("Win_1",false,true,false,0,false,0.0,fnAnimationFinishedCallback);
                            bool = true;
                        }
                    }
                }
            }
        }
        if(b_allDead == false){
            fnAnimationFinishedCallback();
        }
    }

    private function isShowLoseAnimation():Boolean{
        var pInstanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if ( pInstanceSystem ) {
            var isPeak : Boolean = EInstanceType.isPeakGame( pInstanceSystem.instanceType )
                    || EInstanceType.isPeak1v1( pInstanceSystem.instanceType )
                    || EInstanceType.isPeakPK( pInstanceSystem.instanceType )
                    || EInstanceType.isEndLessTower( pInstanceSystem.instanceType )
                    || EInstanceType.isGuildWar(pInstanceSystem.instanceType);
            return isPeak;
        }
        return false;
    }

    public function playMonsterAnimation(params:String):void{
        var paramList:Array = params.split(",");
        var entityID:int =  paramList[0];
        var animName:String = paramList[1];
        var loop : int = paramList[ 2 ];

        var _system:CSceneSystem = (system.stage.getSystem(CSceneSystem) as CSceneSystem);
        var _monsterArr: Vector.<Object> = _system.findAllMonster();
        for each ( var item:CGameObject in _monsterArr ){
           if( item.data.entityID == entityID ){
               var modelDisplay : IDisplay = (item as CGameObject).getComponentByClass( IDisplay, true ) as IDisplay;
               if ( modelDisplay )
               {
                   modelDisplay.modelDisplay.addNextPlayAnimation(animName,loop,false,false,0,false,0.0,null);
               }
           }
        }
    }


    public function showBubble(params:String):void{
        var paramList:Array = params.split(",");
        var entityID:int =  paramList[0];
        var dialogueID:int =  paramList[1];
        var time:int = paramList[5];
        var position:int = paramList[6];

        var pDatabaseSystem : CDatabaseSystem = this.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        var dialogueTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.DIALOGUE ) as CDataTable;
        var dialogue : Dialogue = dialogueTable.findByPrimaryKey( dialogueID );

        var _system:CSceneSystem = (system.stage.getSystem(CSceneSystem) as CSceneSystem);
        var _monsterArr: Vector.<Object> = _system.findAllMonster();
        for each ( var item:CGameObject in _monsterArr ){
            if( item.data.entityID == entityID ){
                (item.getComponentByClass( CBubblesMediator, false) as CBubblesMediator).bubblesTalk(dialogue.content,time,position);
            }
        }
    }
    // ==================================================EventProcess==========================================================
    public function activeTrunkProcess() : void {
        // 激活trunk。人物一般不要越过trunk
        system.dispatchEvent(new CLevelEvent(CLevelEvent.ACTIVE_TRUNK,null));
        if (EInstanceType.isPVE(_instanceType) && false == EInstanceType.isEndLessTower(_instanceType)) {
            var isRight:Boolean = true;
            if (curTrunkData) {
                var pHero:CGameObject = (system.stage.getSystem(CECSLoop ).getBean(CPlayHandler) as CPlayHandler).hero;
                if (pHero) {
                    var ret:CVector3;
                    ret = CObject.get2DPositionFrom3D(pHero.transform.position.x, pHero.transform.position.z, pHero.transform.position.y, ret);
                    var pHero2DPos:CVector2 =  new CVector2(ret.x, ret.y);
                    isRight = pHero2DPos.x < curTrunkData.location.x;
                }
            }
            _gogogo.show(isRight);

        }
    }
    public function enterTrunkProcess() : void {
        system.dispatchEvent(new CLevelEvent(CLevelEvent.ENTER_TRUNK,null));
        if (EInstanceType.isPVE(_instanceType) && false == EInstanceType.isEndLessTower(_instanceType)) {
            _gogogo.hide();
        }
    }
    public function trunkCleanProcess() : void {

    }

    // ==================================================Message->Action==========================================================

    public function waitScenario() : void {
        _isWaitingScenarioPlay = true;
    }
    public function playBgMusic() : void {
        var audio:IAudio = system.stage.getSystem( IAudio ) as IAudio;
        if (levelRecord.BGM && levelRecord.BGM.length > 0) {
            var musicPath:String = CLevelPath.getMusicPath(levelRecord.BGM);
            audio.playMusicByPath(musicPath, int.MAX_VALUE, 0);
        }
    }
    public function activePortal() : void {
        _portalProcess.show();

        if (_isFinalLevel) {
            return ;
        }

        if (EInstanceType.isPVE(_instanceType) && false == EInstanceType.isEndLessTower(_instanceType)) {
            var pLevelRecord:Level = levelRecord;
            if (pLevelRecord && pLevelRecord.Transmit == -1) {
                // -1 : 不自动传送方式 (这种方式才需要显示gogogo)
                var isRight:Boolean = true;
                var portalList:Array = (system as CLevelSystem).getPortal();
                if (portalList && portalList[0] && portalList[0 ].location) {
                    var portalPosObject:Object = portalList[0].location;
                    var portalPos:CVector2  = new CVector2(portalPosObject.x, portalPosObject.y);

                    var pHero:CGameObject = (system.stage.getSystem(CECSLoop ).getBean(CPlayHandler) as CPlayHandler).hero;
                    if (pHero) {
                        var ret:CVector3;
                        ret = CObject.get2DPositionFrom3D(pHero.transform.position.x, pHero.transform.position.z, pHero.transform.position.y, ret);
                        var pHero2DPos:CVector2 =  new CVector2(ret.x, ret.y);
                        isRight = pHero2DPos.x < portalPos.x;
                    }
                }
                _gogogo.show(isRight);
            }
        }
    }
    // ==================================================get/set==========================================================
    private var _curReallyTrunkRect:Rectangle;
    public function setCurrentTrunkID(value:int) : void {
        this._curTrunkID = value;
    }
    public function setCurReallyTrunkRectByActiveTrunk() : void {
        // 激活trunk时, 实时trunk范围为目前角色所在的trunk与当前配置的trunk范围的并集
        if ( curTrunkData ) {
            var curConfigTrunkRect:Rectangle = curTrunkData.getTrunkRect();
            if (_curReallyTrunkRect) {
                _curReallyTrunkRect = _curReallyTrunkRect.union(curConfigTrunkRect);
            } else {
                _curReallyTrunkRect = curConfigTrunkRect;
            }
        }

    }
    // 锁屏时, 当前实时trunk范围, 和config里的trunk范围一样
    public function setCurReallyTrunkRectByEnterTrunk() : void {
        if ( curTrunkData ) {
            var curConfigTrunkRect:Rectangle = curTrunkData.getTrunkRect();
            _curReallyTrunkRect = curConfigTrunkRect;
        }
       
    }
    public function getCurReallyTrunkRect() : Rectangle {
        return _curReallyTrunkRect;
    }
    final public function get gameLevel() : CGameLevel {
        return _gameLevel;
    }
    public function set gameLevel(v:CGameLevel) : void {
        _gameLevel = v;
    }
    final public function get levelConfigInfo() : CLevelConfigInfo {
        return _levelConfigInfo;
    }
    public function set levelConfigInfo(v:CLevelConfigInfo) : void {
        _levelConfigInfo = v;
    }

    public function get curTrunkData() : CTrunkConfigInfo {
        return _levelConfigInfo ? _levelConfigInfo.getTrunkById(_curTrunkID) : null;
    }

    public function getEntityById(id:int):CTrunkEntityMonster{
        return _levelConfigInfo ? _levelConfigInfo.getEntityById(id) : null;
    }
    public function getEntranceById(id:int):CTrunkEntityMonster{
        return _levelConfigInfo ? _levelConfigInfo.getEntranceById(id) : null;
    }

    public function getTriggerById(id:int):CTrunkEntityBaseData{
        return _levelConfigInfo ? _levelConfigInfo.getTriggerById(id) : null;
    }

    // 是否正在播放剧情
    final public function get isPlayingScenario() : Boolean {
        return _isPlayingScenario;
    }
    final public function get isWaitingScenarioPlay() : Boolean {
        return _isWaitingScenarioPlay;
    }
    public function IsReady() : Boolean {
        return isReady;
    }
    public function get isReady() : Boolean {
        return _isReady;
    }
    public function set isReady(v:Boolean) : void {
        _isReady = v;
    }
    public function get isInstancePass() : Boolean {
        return _isInstancePass;
    }
    public function set isInstancePass(v:Boolean) : void {
        _isInstancePass = v;
    }
    public function get instanceType() : int {
        return _instanceType;
    }
    public function get isStart() : Boolean {
        return _started;
    }
    public function set isStart(v:Boolean) : void {
        _started = v;
    }
    public function get startSceneScenarioID() : int {
        return _startSceneScenarioID;
    }
    public function set startSceneScenarioID(v:int) : void {
        _startSceneScenarioID = v;
    }
    public function isEnterByScenario() : Boolean {
        return _startSceneScenarioID > 0;
    }
    public function get isScenarioInstance() : Boolean {
        return this._isScenarioInstance;
    }
    public function setIsScenarioInstance(value:Boolean) : void {
        this._isScenarioInstance = value;
    }

    //获取关卡中的标记点
    public function getSigenPoins(id:int):Object{
        if ( _levelConfigInfo )
            return _levelConfigInfo.getSignPoint(id);
        return null;
    }
    // ==================================================property==========================================================
    public function get m_instanceTypeTable() : InstanceType {
        return _instanceTypeTable;
    }
    public function get camprelationship() : int {
        return _instanceTypeTable.Camprelationship;
    }
    
    public function get levelTable() : IDataTable {
        if (_levelTable == null) _levelTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.LEVEL);
        return _levelTable;
    }

    public function get levelRecord() : Level {
        if ((_levelID > 0 && _levelRecord == null) || (_levelRecord && _levelRecord.ID != _levelID)) _levelRecord = levelTable.findByPrimaryKey(_levelID);
        return _levelRecord;
    }

    public function playRoundAnimation(round:int):void{
        var parm:String = "jupainvlang,Idle_"+(round+1)+",0,0";
        _sceneEffect.playAnimation(parm,function():void{
            parm = "jupainvlang,Idle_"+(round+1)+"_d,1,0";
            _sceneEffect.playAnimation(parm);
        })
    }

    public function get levelID() : int {
        return _levelID;
    }

    public function set levelID( value:int) : void {
        _levelID = value;
    }

    private function get _system() : CLevelSystem {
        return system as CLevelSystem;
    }
    public function setPlayWinAnimation( v:Boolean) : void {
        _playingWinAnimation = v;
    }
    public function getPlayWinAnimation() : Boolean {
        return _playingWinAnimation;
    }
    private var _gameLevel:CGameLevel;

    // 关卡配置等
    private var _levelConfigInfo:CLevelConfigInfo; // 关卡配置
    private var _isPlayingScenario:Boolean;
    private var _isWaitingScenarioPlay:Boolean; // 等待剧情播放, 加载剧情文件等

    private var _curTrunkID:int; // 当前trunkID, 目前只有进入关卡时, 有传放trunkID, 后面要在其他地方也传入,
    private var _levelID:int; // 当前的levelID, preview没有

    private var _isReady:Boolean; // 关卡是否准备好, 场景 是否已经加载好
    private var _isInstancePass:Boolean; // 副本是否通关
    private var _startSceneScenarioID:int; // 开场剧情ID, -1表示没有开场剧情,
    private var _isScenarioInstance:Boolean; // 是否剧情副本
    ///
    private var _enter:CLevelEnterProxy;
    private var _preload:CLevelPreload;
    private var _externsPreloadListData:Vector.<CPreloadData>;
    private var _portalProcess:CLevelPortalDisplayProcess;
    private var _gogogo:CLevelGoGoGo;
    public var _levelEffect:CLevelEffect;
    public var _sceneEffect:CSceneEffect;

    private var _levelTable:IDataTable;
    private var _levelRecord:Level;
    private var _started:Boolean; // 关卡是否已经开始, readygo已完成

    private var _indexInInstance:int; // 第几个关卡
    private var _instanceType:int = -1; // 所在副本类型
    private var _isDispose:Boolean;
    private var _instanceTypeTable:InstanceType;
    private var _isFinalLevel:Boolean; // 是否最后一个关卡

    private var _iDispatchPlayerReadyCounter:int; // 为2时处理 0->1->2

    private var _playingWinAnimation:Boolean; // 是否正在播放胜利动作
}
}
