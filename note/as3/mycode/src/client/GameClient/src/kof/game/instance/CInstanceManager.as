//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/6.
 */
package kof.game.instance {
import QFLib.Interface.IUpdatable;

import flash.events.Event;

import flash.utils.getTimer;

import kof.data.CDatabaseSystem;
import kof.data.CPreloadData;
import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.game.common.CDelayCall;
import kof.game.common.CTest;
import kof.game.common.view.CViewBase;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.data.CFightingInstanceMessage;
import kof.game.instance.mainInstance.data.CInstanceDataManager;
import kof.game.instance.mainInstance.data.CNumericTemplateManager;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.mainInstance.enum.EInstanceWndType;
import kof.game.instance.event.CInstanceEvent;
import kof.game.level.CLevelSystem;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.message.Level.EnterLevelResponse;
import kof.table.Exit;
import kof.table.Instance;
import kof.table.InstanceContent;
import kof.table.InstanceType;
import kof.table.NumericTemplate;

public class CInstanceManager extends CAbstractHandler implements IUpdatable {
    public function CInstanceManager() {
        clear();
    }

    public override function dispose():void {
        super.dispose();
        clear();
    }

    public function clear() : void {
        _instanceRecord = null;
        _instanceContentRecord = null;
        _exitRecord = null;
        _instanceTypeRecord = null;
        _instanceContentID = -1;
        _levelID = -1;
    }

    override protected function onSetup():Boolean {
        var ret:Boolean =  super.onSetup();
        var pDatabaseSystem:CDatabaseSystem = system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
        var playData:CPlayerData = null;
        if ((system.stage.getSystem(CPlayerSystem) as CPlayerSystem)) playData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
        _dataManager = new CInstanceDataManager(pDatabaseSystem, playData);
        _fightingInstanceMsg = new CFightingInstanceMessage();
        _numericTemplateManager = new CNumericTemplateManager(pDatabaseSystem);

        return ret;
    }


    // =======================================================================
    // 进入副本
    public function onEnterInstance(instanceContentID:int) : void {
        // 这个InstanceID, 应该不是instance.ID, 而是InstanceContent.ID

        _instanceContentID = instanceContentID;
        _indexOfLevel = 0;
        _dataManager.instanceData.lastInstancePassReward.isServerData = false;
        var dbSystem:CDatabaseSystem = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem);

        var instanceContentDataTable:IDataTable = dbSystem.getTable(KOFTableConstants.INSTANCE_CONTENT);
        _instanceContentRecord = instanceContentDataTable.findByPrimaryKey(_instanceContentID);

        if (_exitTable == null) {
            _exitTable = dbSystem.getTable(KOFTableConstants.INSTANCE_EXIT);
        }
        _exitRecord = _exitTable.findByPrimaryKey(_instanceContentRecord.Type);

        var instanceDataTable:IDataTable = dbSystem.getTable(KOFTableConstants.INSTANCE);
        _instanceRecord = instanceDataTable.findByPrimaryKey(_instanceContentRecord.InstanceID);


        var instanceTypeTable:IDataTable = dbSystem.getTable(KOFTableConstants.INSTANCE_TYPE);
        _instanceTypeRecord = instanceTypeTable.findByPrimaryKey(_instanceContentRecord.Type);

    }
    public function onInstanceFinal() : void {
        clear();
    }
    public function onEnterLevel(response:EnterLevelResponse) : void {
        _levelID = response.levelID;

        // 预加载数据一次就清空
        var pPreloadListData:Vector.<CPreloadData> = _preloadListData;
        _preloadListData = null;

        if (_indexOfLevel > 0) {
            _levelSystem.onExit(_indexOfLevel);
        }

        var isFinalLevel:Boolean = true;
        if (_instanceRecord) {
            var levelList:Array = _instanceRecord.levels.filter(function (item:Object, idx:int, arr:Array) : Boolean {
                return (item as int) > 0;
            });
            isFinalLevel = (levelList.length == (_indexOfLevel + 1));
        }
        _levelSystem.onEnter(_indexOfLevel, _instanceContentRecord.Type, response, _instanceTypeRecord, isFinalLevel, pPreloadListData);
        if (EInstanceType.isClassicalMode(instanceContentRecord.Type)) {
            _indexOfLevel = 1;
            return;
        }
        _indexOfLevel++;
    }
    // not use
    public function onLeaveLevel() : void {
        _levelID = -1;
    }
    public function saveInstanceState(instanceID:int) : void {
        // 只有剧情和精英副本需要处理
        var instanceData:CChapterInstanceData = dataManager.instanceData.getInstanceContentData(instanceID, -1);
        _fightingInstanceMsg.instanceData = instanceData;
        if (instanceData && instanceData.isCompleted) {
            _fightingInstanceMsg.isPassBefore = true;
        } else {
            _fightingInstanceMsg.isPassBefore = false;
        }
    }
    // =========================================================

    public function continueLevel() : void {
        _levelSystem.play();
    }
    // ===================================get/set=====================================

    public function startWaitAllGameObjectFinish() : void {
        _isWaitGameObjectStop = true;
        _waitAllGameOjectTimeOut = getTimer();
    }
    private var _waitAllGameOjectTimeOut:int;
    public function update(delta:Number) : void {
        if (_isWaitGameObjectStop) {
            if ((getTimer() - _waitAllGameOjectTimeOut > 5000) || isAllGameObjectStop()) {
                _isWaitGameObjectStop = false;
                _waitAllGameOjectTimeOut = -1;

                new CDelayCall(_endProcess, 1);
            }
        }
    }
    private function _endProcess() : void {
        this.system.dispatchEvent(new CInstanceEvent(CInstanceEvent.INSTANCE_ALL_GAME_OBJECT_FINISH_OR_TIME_OUT, null, null));
    }

    // ===================================get/set=====================================
    final public function get isMainCity() : Boolean {
        if (!instanceContentRecord)
                return true;
        return EInstanceType.isMainCity(instanceContentRecord.Type);
    }

    final public function get isPractice() :Boolean{
        if( !instanceContentRecord )
                return false;
        return EInstanceType.isPractice(instanceContentRecord.Type);
    }

    final public function get isTeaching() : Boolean{
        if( !instanceContentRecord )
                return false;
        return EInstanceType.isTeaching(instanceContentRecord.Type);
    }
    public function get isPVE() : Boolean{
        if( !instanceContentRecord )
                return false;
        return EInstanceType.isPVE(instanceContentRecord.Type);
    }
    public function get canQE() : Boolean{
        if( !instanceContentRecord )
            return false;
        return EInstanceType.canQE(instanceContentRecord.Type);
    }
    public function get isArena() : Boolean {
        if( !instanceContentRecord )
                return false;
        return EInstanceType.isArena( instanceContentRecord.Type );
    }

    public function get isGuildWar() : Boolean {
        if( !instanceContentRecord )
            return false;
        return EInstanceType.isGuildWar( instanceContentRecord.Type );
    }

    final public function get isPrelude() : Boolean {
        if (!instanceContentRecord)
            return false;
        return EInstanceType.isPrelude(_instanceContentID);
    }
    final public function get isFirstLevel() : Boolean {
        return _indexOfLevel == 1; // 第一个关卡进入后. _indexOfLevel会++
    }
    final public function get instanceContentID() : int {
        return _instanceContentID;
    }
    final public function get levelID() : int {
        return _levelID;
    }
    final public function get fightingInstanceMessage() : CFightingInstanceMessage {
        return _fightingInstanceMsg;
    }
    final public function get dataManager() : CInstanceDataManager {
        return _dataManager;
    }
    private function get _levelSystem() : CLevelSystem {
        return system.stage.getSystem(CLevelSystem) as CLevelSystem;
    }
    public function get instanceContentRecord() : InstanceContent {
        return _instanceContentRecord;
    }
    public function get exitRecord() : Exit {
        return _exitRecord;
    }


    public function getNumericTemplate(monsterType:int, monsterProfession:int) : NumericTemplate {
        if (_instanceTypeRecord == null) return null;
        return _numericTemplateManager.getNumericTemplate(_instanceTypeRecord.templateGroupID, monsterType, monsterProfession);
    }

    public function get rageRestoreComboInterval() : int {
        if( _instanceTypeRecord == null ) return int.MAX_VALUE;
        return _instanceTypeRecord.RageRestoreComboInterval;
    }
    // 0没有自动战斗, 1有自动战斗, 2强制自动战斗
    public function get autoFight() : int {
        if( _instanceTypeRecord == null ) return 0;
        return _instanceTypeRecord.FightAuto;
    }
//    // 自动战斗开启等级
//    public function get autoFightOpenLevel() : int {
//        if( _instanceTypeRecord == null ) return 0;
//        return _instanceTypeRecord.FightAutolgrade;
//    }
    // 自动战斗, 根据系统, 第二个开启条件
    public function get autoFightOpenSubLevel() : int {
        if( _instanceTypeRecord == null ) return 0;
        return _instanceTypeRecord.FightAutolgrade;
    }
    public function get autoFightOpenVipLevel() : int {
        if( _instanceTypeRecord == null ) return 0;
        return _instanceTypeRecord.FightAutoVip;
    }
    public function get isRecordAutoState() : Boolean {
        if( _instanceTypeRecord == null ) return false;
        return _instanceTypeRecord.record > 0;
    }
    // autoFight为1时, 自动战斗开启时间(没操作之后)
    public function get autoFightTime() : int {
        if( _instanceTypeRecord == null ) return 0;
        return _instanceTypeRecord.AutoTime;
    }
    //是否播放ko红白闪
    public function get PlayDieCameraEffect() : int {
        if( _instanceTypeRecord == null ) return 0;
        return _instanceTypeRecord.PlayDieCameraEffect;
    }
    // ===================================get/set=====================================
    public function isAllGameObjectStop() : Boolean {
        return _levelSystem.isPlayingKO == false && _levelSystem.isAllGameObjectStop();
    }
    public function addPreloadData(list:Vector.<CPreloadData>) : void {
        _preloadListData = list;
    }

    private var _preloadListData:Vector.<CPreloadData>;

    private var _instanceContentID:int; // 当前副本ID
    private var _levelID:int;
    private var _indexOfLevel:int; // start by 0

    private var _fightingInstanceMsg:CFightingInstanceMessage;
    private var _dataManager:CInstanceDataManager;
    private var _numericTemplateManager:CNumericTemplateManager;

    // tables
    private var _exitTable:IDataTable;
    private var _exitRecord:Exit;
    private var _instanceContentRecord:InstanceContent;
    private var _instanceTypeRecord:InstanceType;
    private var _instanceRecord:Instance; // 关卡副本表

    private var _isWaitGameObjectStop:Boolean;


}
}
