//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/1.
 */
package kof.game.instance.mainInstance.data {

import QFLib.Foundation;

import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.common.CLang;
import kof.game.common.data.CErrorData;
import kof.data.CObjectData;
import kof.game.instance.enum.EInstanceType;
import kof.game.item.data.CRewardListData;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.task.CTaskManager;
import kof.game.task.CTaskSystem;
import kof.game.task.data.CTaskStateType;
import kof.table.InstanceConstant;
import kof.table.PlotTask;

public class CInstanceData extends CObjectData {
    public function CInstanceData(databaseSystem:IDatabase) {
        setToRootData(databaseSystem);

        this.addChild(CChapterListData);
        this.addChild(CChapterInstanceListData);

        this.addChild(CInstanceSweepRewardListData);
        this.addChild(CRewardListData);
        this.addChild(CInstancePassRewardData);
        this.addChild(CInstancePassRewardData);
        this.addChild(CInstanceOneKeyRewardData);

    }

    // 非同步server数据, 由配置表数据创建
    public function initialData(data:Object) : void {
        chapterList.initialData(data[_chapterInfoList] as Array);
        instanceList.initialData(data[_instanceMessageList] as Array);
    }
    public override function updateDataByData(data:Object) : void {
        _hasInitialByServer = true;
        if (data.hasOwnProperty(_chapterInfoList)) chapterList.updateDataByData(data[_chapterInfoList] as Array);
        if (data.hasOwnProperty(_instanceMessageList)) instanceList.updateDataByData(data[_instanceMessageList] as Array);
    }
    //
    public function updateSweepData(data:Object) : void {
        lastSweepData.updateDataByData(data["rewardList"] as Array);
    }
    public function resetSweepData() : void {
        lastSweepData.resetChild();
    }
    public function updateChapterRewardData(data:Object) : void {
        lastChapterReward.resetChild();
        lastChapterReward.updateDataByData(data["rewardList"] as Array);
        chapterList.updateChapterReward(data["chapterID"], data["rewardIndex"])
    }
    public function updateChapterRewardListData(data:Array) : void {
        for each (var pItemData:CInstanceOneKeyRewardItemData in data) {
            var chapterData:CChapterData = chapterList.getByID(pItemData.chapterID);
            if (chapterData) {
                chapterData.updateReward(pItemData.subIndex);
            }
        }
    }
    public function updateInstancePassRewardData(data:Object) : void {
        lastInstancePassReward.updateDataByData(data);
    }
    public function updateInstanceExtendsRewardData(data:Object) : void {
        lastInstanceExtendsReward.updateDataByData(data);
    }
    public function updateOneKeyRewardData(dataList:Array) : void {
        // 奖励信息
        lastOneKeyReward.updateDataByData({dataList:dataList});
    }


    // ====================================chapter操作==========================================
    // 获得chpaterID对应章节，所获得的star数
    public function getChapterStar(instanceType:int, chapterID:int) : int {
        var list:Array = instanceList.getByChapterID(instanceType, chapterID);
        var count:int = 0;
        for each (var instanceData:CChapterInstanceData in list) {
            count += instanceData.star;
        }
        return count;
    }
    // chapterID对应章节是否完成
    public function isChapterCompleted(instanceType:int, chapterID:int) : Boolean {
        var ret:Boolean = instanceList.isChapterInstanceAllFinish(instanceType, chapterID);
        return ret;
    }
    // 获得chpaterID对应章节，是否开启
    public function isChapterOpen(instanceType:int, chapterID:int) : Boolean {
        if (chapterID == 0) return true;

        var chapter:CChapterData = chapterList.getByID(chapterID);
        if (chapter.isFirstChapter || chapter.isServerData) return true;

        var preChapter:CChapterData = getPreChapterData(instanceType, chapterID);
        var ret:Boolean = isChapterCompleted(instanceType, preChapter.chapterID);
        return ret;
    }
    // 获得与chapterID同一类型章节, 的前一个章节
    public function getPreChapterData(instanceType:int, chapterID:int) : CChapterData {
        var chapter:CChapterData = _findNearChapterData(instanceType, chapterID, true);
        return chapter;
    }
    // 获得与chapterID同一类型章节, 的下一个章节
    public function getNextChapterData(instanceType:int, chapterID:int) : CChapterData {
        var chapter:CChapterData = _findNearChapterData(instanceType, chapterID, false);
        return chapter;
    }
    private function _findNearChapterData(instanceType:int, chapterID:int, isBack:Boolean) : CChapterData {
        var chapterList:Array = this.chapterList.list;
        var chapter:CChapterData = null;
        var oriChapter:CChapterData = null;
        var findTarget:Boolean = false;
        var i:int = 0;
        if (isBack) {
            i = chapterList.length - 1;
        }
        while (isBack && i >= 0 || !isBack && i < chapterList.length) {
            chapter = chapterList[i];
            if (findTarget && chapter.instanceType == oriChapter.instanceType) {
                // 找到上一个与chpaterID同类型章节的chpaterData
                if (!isBack) {
                    // 下一个。需要检测是否开启, 未开启, 返回当前
                    if (this.isChapterOpen(instanceType, chapter.chapterID) == false) {
                        return oriChapter;
                    }
                }
                return chapter;
            }
            if (chapter.chapterID == chapterID) {
                findTarget = true;
                oriChapter = chapter;
            }
            if (isBack) { i--; } else { i++; }
        }

        return oriChapter;
    }

    public function getFirstChapterData(instanceType:int) : CChapterData {
        return chapterList.getFirstChapter(instanceType);
    }

    public function getLastChapterData(instanceType:int) : CChapterData {
        var chapterList:Array = this.chapterList.list;
        var chapter:CChapterData = null;

        var lastIndex:int = chapterList.length-1;
        for (var i:int = lastIndex; i >= 0; i--) {
            chapter = chapterList[i];
            if (chapter.instanceType == instanceType && isChapterOpen(instanceType, chapter.chapterID)) {
                return chapter;
            }
        }
        return getFirstChapterData(instanceType);
    }

    // 副本是否能打
    public function checkInstanceCanFight(instanceID:int, count:int, isSweep:Boolean, checkCondtionOnly:Boolean) : CErrorData {
        var errorData:CErrorData = new CErrorData(null);

        if (instanceID <= 0) {
            errorData.gamePromptID = 1;
            return errorData;
        }

        var curInstance:CChapterInstanceData = instanceList.getByID(instanceID);
        if(!curInstance){
            Foundation.Log.logErrorMsg("没有副本:"+instanceID);
            return null;
        }

        var playerData:CPlayerData;
        if (curInstance.isCompleted == false) {
            var needTeamLevel:int = curInstance.condLevel;
            if (needTeamLevel > 0) {
                playerData = ((_databaseSystem as CAppSystem).stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
                var teamLevel:int = playerData.teamData.level;
                if (teamLevel < needTeamLevel) {
                    errorData.gamePromptID = 1;
                    errorData.contents = [CLang.Get("instance_error_pre_level", {v1:needTeamLevel})];
                    return errorData;
                }
            }
            if (curInstance.condScenarioInstanceID > 0) {
                var instancePre:CChapterInstanceData = instanceList.getByID(curInstance.condScenarioInstanceID);
                if (instancePre.isCompleted == false) {
                    errorData.gamePromptID = 1;
                    errorData.contents = [CLang.Get("instance_error_pre_instance", {v1:instancePre.name})];
                    return errorData;
                }
            }
            if (curInstance.condEliteInstanceID > 0) {
                var instanceElitePre:CChapterInstanceData = instanceList.getByID(curInstance.condEliteInstanceID);
                if (instanceElitePre.isCompleted == false) {
                    errorData.gamePromptID = 1;
                    errorData.contents = [CLang.Get("instance_error_elite_pre_instance", {v1:instanceElitePre.name})];
                    return errorData;
                }
            }

            var condQuestID:int = curInstance.condQuest;
            if (condQuestID > 0) {
                var taskSystem:CTaskSystem = ((_databaseSystem as CAppSystem).stage.getSystem(CTaskSystem) as CTaskSystem);
                if (taskSystem) {
                    var taskManager:CTaskManager = taskSystem.getBean(CTaskManager) as CTaskManager;
                    var plotTaskRecord:PlotTask = taskManager.getPlotTaskTableByID(condQuestID);
                    var plotTaskState:int = taskManager.getTaskStateByTaskID(condQuestID);
                    if (plotTaskRecord) {
                        if (plotTaskState < CTaskStateType.FINISH) {
                            errorData.gamePromptID = 1;
                            errorData.contents = [CLang.Get("instance_error_pre_task", {v1:plotTaskRecord.targerDesc})];
                            return errorData;
                        }
                    }
                }
            }
        }

        // 只检查前置条件
        if (checkCondtionOnly) return errorData;

        if (count == 0) {
            errorData.gamePromptID = 1;
            errorData.contents = ["instance_not_enough_count"];
            return errorData;
        }
        // 体力
        var costVit:int = 0;
        if (curInstance.isElite) {
            costVit = curInstance.constant.INSTANCE_ELITE_PASS_COST_VT_NUM;
        } else {
            costVit = curInstance.constant.INSTANCE_MAIN_PASS_COST_VT_NUM;
        }
        if (costVit > 0) {
            playerData = ((_databaseSystem as CAppSystem).stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
            if (playerData.vitData.physicalStrength < costVit*count) {
                errorData.gamePromptID = 1;
                errorData.contents = ["instance_error_vit_not_enough"];
                return errorData;
            }
        } else {
            // error
            errorData.gamePromptID = 1;
            errorData.contents = ["instance_error_vit_limit"];
            return errorData;
        }

        // 次数, 精英副本与通关之后才考虑挑战次数
        // var instanceLevel:Instance = this._tableCollection.instanceTable.findByPrimaryKey(instanceID);
        if (curInstance.isElite && curInstance.isServerData) {
            if (curInstance.challengeCountLeft < count) {
                errorData.gamePromptID = 1;
                errorData.contents = ["instance_not_enough_count"];
                return errorData;
            }
        }
        if (isSweep) {
            if (curInstance.isCompleted == false) {
                errorData.gamePromptID = 1;
                errorData.contents = ["instance_not_pass"];
                return errorData;
            }
        }
        return errorData;
    }

    // 本地测试使用
    public function openAllChapter() : void {
        var cList:CChapterListData = chapterList;
        cList.loopChild(function (childData:CChapterData) : void {
            childData.isServerData = true;
        });
    }

    public function getChapterIndexByInstanceID(instanceID:int) : int {
        var instData:CChapterInstanceData = this.getInstanceContentData(instanceID);
        if (instData) {
            return getChapterIndexByChapterID(instData.instanceType, instData.chapterID);
        }
        return 0;
    }
    public function getChapterIndexByChapterID(instanceType:int, chapterID:int) : int {
        return chapterList.getChapterIndex(instanceType, chapterID);
    }

    // 根据instanceID, 或者副本数据
    // instanceType == -1, 只返回已打过的副本
    public function getInstanceContentData(instanceID:int, instanceType:int = -1) : CChapterInstanceData {
        var contentData:CChapterInstanceData = this.instanceList.getByID(instanceID);
        if (contentData) {
            return contentData;
        }
        if (instanceType == -1) {
            return null;
        }

        var data:Object = CChapterInstanceData.createEmptyData(0, instanceID, instanceType, false);
        contentData = new CChapterInstanceData();
        contentData.databaseSystem = _databaseSystem;
        contentData.updateDataByData(data);
        return contentData;
    }

	public function isInstancePass(instanceID:int) : Boolean {
        var contentData:CChapterInstanceData = this.instanceList.getByID(instanceID);
        if (contentData) {
            return contentData.isCompleted;
        }
        return false;
    }

    public function get scenarioInstancePassCount() : int {
        return getInstancePassCount(EInstanceType.TYPE_MAIN);
    }
    public function get eliteInstancePassCount() : int {
        return getInstancePassCount(EInstanceType.TYPE_ELITE);
    }
    private function getInstancePassCount(instanceType:int) : int {
        var count:int = 0;
        instanceList.loopChild(function (instanceData:CChapterInstanceData) : void {
            if (instanceData.chapterID > 0 && instanceData.instanceType == instanceType &&
                    instanceData.isCompleted && (false == EInstanceType.isPrelude(instanceData.instanceID))){
                count++;
            }
        });
        return count;
    }

    // get
    public function get chapterList() : CChapterListData { return this.getChild(0) as CChapterListData; }
    public function get instanceList() : CChapterInstanceListData { return this.getChild(1) as CChapterInstanceListData; }

    // 暂存数据
    // 扫荡奖励
    public function get lastSweepData() : CInstanceSweepRewardListData { return this.getChild(2) as CInstanceSweepRewardListData; }
    // 章节奖励
    public function get lastChapterReward() : CRewardListData { return this.getChild(3) as CRewardListData; }
    // 通关奖励
    public function get lastInstancePassReward() : CInstancePassRewardData { return this.getChild(4) as CInstancePassRewardData; }
    // 副本宝箱奖励
    public function get lastInstanceExtendsReward() : CInstancePassRewardData { return this.getChild(5) as CInstancePassRewardData; }
    // 一键领取奖励
    public function get lastOneKeyReward() : CInstanceOneKeyRewardData { return this.getChild(6) as CInstanceOneKeyRewardData; }

    public function get constant() : InstanceConstant {
        if (_constant == null) _constant = _databaseSystem.getTable(KOFTableConstants.INSTANCE_CONSTANTS).toVector()[0] as InstanceConstant;
        return _constant;
    }
    public function get contentTable() : IDataTable {
        if (_contentTable == null) _contentTable = _databaseSystem.getTable(KOFTableConstants.INSTANCE_CONTENT) as IDataTable;
        return _contentTable;
    }

    public static const _chapterInfoList:String = "chapterInfoList";
    public static const _instanceMessageList:String = "instanceMessageList";
    public static const _extraList:String = "extraList";

    private var _constant:InstanceConstant;

    private var _contentTable:IDataTable;

    [Inline]
    public function get hasInitialByServer():Boolean { return _hasInitialByServer; }
    private var _hasInitialByServer:Boolean;

    public var mainChapterOpenFlag:Boolean; // 主线章节开启标志

    public var isFirstLevelPass:Boolean; // 第一次是否打了
}
}
