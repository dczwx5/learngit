/**
 * Created by auto on 2016/5/28.
 */
package preview.game.levelServer {

import QFLib.Interface.IUpdatable;

import flash.events.Event;

import kof.framework.CAbstractHandler;
import kof.game.level.CLevelManager;
import kof.game.level.CLevelSystem;
import kof.game.levelCommon.CLevelLog;
import kof.game.levelCommon.Enum.ELevelEventType;
import kof.game.levelCommon.info.CLevelConfigInfo;
import kof.game.levelCommon.info.base.CTrunkEntityBaseData;
import kof.game.levelCommon.info.trunk.CTrunkConfigInfo;
import preview.game.levelServer.data.CLevelSceneObjectData;
import preview.game.levelServer.event.map.CTrunkMonsterDeadEvent;
import preview.game.levelServer.trunkState.CLevelTrunkPortalState;
import preview.game.levelServer.trunkState.CLevelTrunkState;
import preview.game.levelServer.trunkState.CLevelTrunkUnreadyState;
import kof.game.scene.CSceneHandler;
import kof.game.scene.CSceneSystem;

public class CLevelServer extends CAbstractHandler implements IUpdatable{
    public function CLevelServer() {
    }
    public override function dispose() : void {
        super.dispose();

    }
    protected override function onSetup() : Boolean {
//        if (_dummyServer.getBean(CDummyLoginHandler)) {
//            _dummyServer.getBean(CDummyLoginHandler).dispose();
//            _dummyServer.removeBean(_dummyServer.getBean(CDummyLoginHandler));
//        }
//        if (_dummyServer.getBean(CDummyMapInstanceHandler)) {
//            _dummyServer.getBean(CDummyMapInstanceHandler).dispose();
//            _dummyServer.removeBean(_dummyServer.getBean(CDummyMapInstanceHandler));
//        }


        var ret:Boolean = super.onSetup();
        _triggerHandler = new CLevelServerTriggerHandler(this); // trigger
        _serverEnventManager = new CLevelServerEventManager(this); // 服务器处理事件
        _serverHandler = new CLevelServerHandler(this);
        _sender = new CLevelServerSender(this);
        _passHandler = new CLevelServerTrunkPassHandler(this);
        _deadData = new CLevelServerEntityDeadHandler(this);
        _sceneObjectHandler = new CLevelServerSceneObjectHandler(this);
        return ret;
    }
    public function update(delta:Number) : void {
        if (!_isRunning) return ;

        if (false == this.isPauseGame()) {
            if (_curTrunkState) {
                _curTrunkState = _curTrunkState.checkNextState(); // 这个来驱动
            }
            if (_triggerHandler) _triggerHandler.update(delta);

            _serverEnventManager.update(delta);
        }
    }

    public function passedStateFun():void{
        _curTrunkState = new CLevelTrunkPortalState(this);
    }

    public function checkPass() : Boolean {
        return _passHandler.checkPass();
    }
    public function isKillMonsterGoal() : Boolean {
        return _passHandler.isKillMonsterGoal();
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // 发起进入level, 从level开始, 其实应该是从fb开始, 但这里不需要了
    public function enterLevel(fileName:String, heroId:String) : void {
        _heroIDList = heroId.split(",");
        var levelSystem:CLevelSystem = system.stage.getSystem(CLevelSystem) as CLevelSystem;
        var levelManager:CLevelManager = levelSystem.getBean(CLevelManager) as CLevelManager;
        // 正常流程是, 服务器先去读配置, 然后通知前台进入level, 这里把加载配置的工作就交给前台去做
//        levelManager.addEventListener(ELevelEventType.EVENT_LEVEL_LOAD_COMPLETED, enterLevelB);
        _sender.enterLevel(fileName);
    }
    private function enterLevelB(e:Event) : void {
        var levelSystem:CLevelSystem = system.stage.getSystem(CLevelSystem) as CLevelSystem;
        var levelManager:CLevelManager = levelSystem.getBean(CLevelManager) as CLevelManager;
        CLevelLog.addDebugLog("server work");

        // 前台已经加载且创建好场景
//        levelManager.removeEventListener(ELevelEventType.EVENT_LEVEL_LOAD_COMPLETED, enterLevelB);
        // ((system.stage.getSystem(CSceneSystem) as CSceneSystem).getBean(CSceneRendering) as CSceneRendering).scene.mainCamera.setFollowingMode(1);
        _levelInfo = levelManager.levelConfigInfo;
        var firstTrunkInfo:CTrunkConfigInfo = _levelInfo.getTrunkById(100);
        _curServerTrunkData = new CLevelServerTrunkData(firstTrunkInfo, null, false);
        _curTrunkState = new CLevelTrunkUnreadyState(this);
        _isRunning = true;
        if (_sceneObjectHandler) _sceneObjectHandler.clear();
    }
    // test
    public function killOneMonster() : void {
        var monster:CLevelSceneObjectData = this.sceneObjectHandler.getFirstMonster();
        if(monster){
            var sceneSystem:CSceneSystem = (system.stage.getSystem(CSceneSystem) as CSceneSystem);
            (sceneSystem.getBean(CSceneHandler) as CSceneHandler).removeMonster(monster.uniID);
            dispatchEvent(new CTrunkMonsterDeadEvent(ELevelEventType.MONSTER_DIE, monster.entityType, monster.objectID, monster.uniID));
        }
    }

    public function killOneTeammates() : void {
        var monster:CLevelSceneObjectData = this.sceneObjectHandler.getFirstTeammates();
        if(monster){
            var sceneSystem:CSceneSystem = (system.stage.getSystem(CSceneSystem) as CSceneSystem);
            (sceneSystem.getBean(CSceneHandler) as CSceneHandler).removeMonster(monster.uniID);
            dispatchEvent(new CTrunkMonsterDeadEvent(ELevelEventType.MONSTER_DIE, monster.entityType, monster.objectID, monster.uniID));
        }
    }

    public function killAllMonster() : void {
        var sceneSystem:CSceneSystem = (system.stage.getSystem(CSceneSystem) as CSceneSystem);
        var procFun:Function = function (object:CLevelSceneObjectData) : void {
            (sceneSystem.getBean(CSceneHandler) as CSceneHandler).removeMonster(object.uniID);
            dispatchEvent(new CTrunkMonsterDeadEvent(ELevelEventType.MONSTER_DIE, object.entityType, object.objectID, object.uniID));
        };
        this.sceneObjectHandler.loopAllObject(procFun);
    }

    public function killAllTeammates():void{
        var sceneSystem:CSceneSystem = (system.stage.getSystem(CSceneSystem) as CSceneSystem);

        var vec:Vector.<CLevelSceneObjectData> = this.sceneObjectHandler.getAllTeammates();
        for each (var object:CLevelSceneObjectData in vec)
        {
            (sceneSystem.getBean(CSceneHandler) as CSceneHandler).removeMonster(object.uniID);
            dispatchEvent(new CTrunkMonsterDeadEvent(ELevelEventType.MONSTER_DIE, object.entityType, object.objectID, object.uniID));
        }
    }

    public function killAllEnemy() : void {
        var sceneSystem:CSceneSystem = (system.stage.getSystem(CSceneSystem) as CSceneSystem);

        var vec:Vector.<CLevelSceneObjectData> = this.sceneObjectHandler.getAllEnemy();
        for each (var object:CLevelSceneObjectData in vec)
        {
            (sceneSystem.getBean(CSceneHandler) as CSceneHandler).removeMonster(object.uniID);
            dispatchEvent(new CTrunkMonsterDeadEvent(ELevelEventType.MONSTER_DIE, object.entityType, object.objectID, object.uniID));
        }
    }

// ===========================================================其他系统的事件处理===================================================================
    public function onScenarioStart(isAllControl:int) : void {
        // 剧情开始，做一些处理
        _isPlayingScenario = true;
        _isAllControl = isAllControl > 0;
        // 暂时怪物AI
        // 暂时触发器的工作

    }
    public function onScenarioEnd(scenarioID:int) : void {
        // 剧情结束, 做一些处理
        _isPlayingScenario = false;
        _isAllControl = true;
        // 恢复怪物AI
        // 恢复触发器工作
    }
    public function onClientReady() : void {
        _clientReady = true;
        _sender.spawnHero();
    }
    //////////////////////////////////////操作//////////////////////////////////////////////////////////
    public function createTrigger(trunkID:int, trunkEntityInfo:CTrunkEntityBaseData) : void {
        if (trunkID == this._curServerTrunkData.trunkInfo.ID) {
            _triggerHandler.createTrigger(_curServerTrunkData.trunkInfo, trunkEntityInfo);
        }
    }

    public function deactiveTrigger(type:int, triggerID:int):void{
        _triggerHandler.deactiveTrigger(type,triggerID);
    }

    final public function get triggerHandler() : CLevelServerTriggerHandler {
        return _triggerHandler;
    }

    final public function get curTrunksState() : CLevelTrunkState{
        return _curTrunkState;
    }
    final public function get curTrunkData() : CLevelServerTrunkData {
        return _curServerTrunkData;
    }

    // 进入下一个trunk需要清理的对象, 需要放到这里
    public function nextTrunk() : void {
        _curServerTrunkData = _curServerTrunkData.nextTrunk;
        this._triggerHandler.clearAll();
        this._deadData.reset();
        // _sceneObjectHandler.reset();
    }

    final public function get serverEnventManager() : CLevelServerEventManager {
        return _serverEnventManager;
    }
    final public function get levelInfo() : CLevelConfigInfo {
        return _levelInfo;
    }
    final public function get sender() : CLevelServerSender {
        return _sender;
    }
    // 是否正在播放剧情
    final public function get isPlayingScenario() : Boolean {
        return _isPlayingScenario;
    }
    public function isPauseGame() : Boolean {
        return _isPlayingScenario && _isAllControl;
    }

    public function get heroIDList() : Array {
        return _heroIDList;
    }

    //
    final public function get deadData() : CLevelServerEntityDeadHandler {
        return this._deadData;
    }
    final public function get sceneObjectHandler() : CLevelServerSceneObjectHandler {
        return this._sceneObjectHandler;
    }
    private var _triggerHandler:CLevelServerTriggerHandler;
    private var _serverEnventManager:CLevelServerEventManager;
    private var _serverHandler:CLevelServerHandler;
    private var _sender:CLevelServerSender;
    private var _passHandler:CLevelServerTrunkPassHandler;

    private var _isRunning:Boolean = false;
    private var _clientReady:Boolean = false;
    //
    private var _curTrunkState:CLevelTrunkState;
    private var _curServerTrunkData:CLevelServerTrunkData; // 当前trunk进行到哪个节点数据

    private var _isPlayingScenario:Boolean; // 是否正在播放剧情
    private var _isAllControl:Boolean; // 是否完全控制

    // 下个trunk需要清除的数据
    private var _deadData:CLevelServerEntityDeadHandler; // 已死亡对象
    // 切换关卡需要清除的数据
    private var _levelInfo:CLevelConfigInfo;
    private var _sceneObjectHandler:CLevelServerSceneObjectHandler; // 场景存在的对象

    private var _heroIDList:Array;
}
}
