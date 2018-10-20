//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/1.
 */
package kof.game.instance.mainInstance.data {

import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.game.common.CLang;
import kof.data.CObjectData;
import kof.game.instance.enum.EInstanceType;
import kof.game.task.CTaskManager;
import kof.game.task.CTaskSystem;
import kof.game.task.data.CTaskData;
import kof.game.task.data.CTaskStateType;
import kof.table.InstanceConstant;
import kof.table.InstanceContent;
import kof.table.InstanceDialog;
import kof.table.InstanceTxt;
import kof.table.PlotTask;

public class CChapterInstanceData extends CObjectData {
    public function CChapterInstanceData() {
    }

    public static function createEmptyData(chapterID:int, instanceID:int, instanceType:int, isFirstInstance:Boolean) : Object {
        return {chapterID:chapterID, instanceType:instanceType,
            instanceID:instanceID, star:0, challengeNum:0, resetNum:0, isPass:2, isDrawReard:2, isFirstInstance:isFirstInstance};
    }
    public function get chapterID() : int { return _data[CHAPTER_ID]; } // 章ID
    public function get instanceID() : int { return _data[INSTANCE_ID]; } // 副本ID
    public function get star() : int { return _data[STAR]; } // 星级
    public function set star(value:int) : void {
        if (star < value) {
            _data[STAR] = value;
        }
    }
    public function get challengeNum() : int { return _data[CHALLENGE_NUM]; } // 今日已挑战次数
    // 剩余挑战次数
    public function get challengeCountLeft() : int {
        return constant.INSTANCE_ELITE_CHALLENGE_NUM - this.challengeNum;
    }

    public function get resetNum() : int { return _data[RESET_NUM]; } // 已重置次数
//    public function get resetCountLeft() : int {
//        return constant.INSTANCE_ELITE_RESET_NUM - resetNum;
//    }
    public function get isPass() : Boolean { return _data[IS_PASS] == 1; } // 1：已完成 2：未完成
    public function get isDrawReard() : Boolean { return _data[IS_DRAW_REWARD] == 1; } // 1：已领取 2：未领取 宝箱奖励
    public function get instanceType() : int { return _data[INSTASNCE_TYPE]; }
    public function get isFirstInstance() : int { return _data[IS_FIRST_INSTANCE]; }

    public static const CHAPTER_ID:String = "chapterID";
    public static const INSTANCE_ID:String = "instanceID";
    public static const STAR:String = "star";
    public static const CHALLENGE_NUM:String = "challengeNum";
    public static const RESET_NUM:String = "resetNum";
    public static const IS_PASS:String = "isPass";
    public static const IS_DRAW_REWARD:String = "isDrawReard";
    public static const INSTASNCE_TYPE:String = "instanceType";
    public static const IS_FIRST_INSTANCE:String = "isFirstInstance";


    // =========
    // 副本名
    public function get name() : String {
        var nameID:int = instanceRecord.Name;
        return (textTable.findByPrimaryKey(nameID) as InstanceTxt).Name;
    }
    public function get profession() : int {
        return instanceRecord.Profession;
    }
    public function get firstPassMovieUrl() : String {
//        return instanceRecord.Animation; test
        return  instanceRecord.Animation;
    }
    // 副本描述
    public function get desc() : String {
        var descID:int = instanceRecord.Desc;
        return (textTable.findByPrimaryKey(descID) as InstanceTxt).Name;
    }
//    public function get chapterID() : int {
//        return instanceRecord.Chapter;
//    }
    // 副本图标
    public function get icon() : String {
        return instanceRecord.Icon;
    }
    public function get unOpenIcon() : String {
        return instanceRecord.UnOpenIcon;
    }
    // 详细界面图标
    public function get tipsIcon() : String {
        return instanceRecord.TipsIcon;
    }
    // 副本总时间
    public function get totalTime() : int {
        return instanceRecord.DuringTime;
    }
    // 开启条件 - 等级
    public function get condLevel() : int {
        return instanceRecord.CondLv;
    }
    // 开启条件 - 前置剧情副本ID
    public function get condScenarioInstanceID() : int {
        return instanceRecord.CondInstance;
    }
    // 开启条件 - 前置精英副本ID
    public function get condEliteInstanceID() : int {
        return instanceRecord.CondElite;
    }
    // 开启条件 - 前置任务ID
    public function get condQuest() : int {
        return instanceRecord.CondQuest;
    }
    // 出战人数上限
//    public function get heroNumLimit() : int {
//        return instanceRecord.NumberLimit;
//    }
    // 推荐战力
    public function get powerRecommend() : int {
        return instanceRecord.RecommendPower;
    }
    // 宝箱奖励ID - 并非所有副本都会有
    public function get rewardExtends() : int {
        return instanceRecord.ExtendsReward;
    }
    // 首次通关奖励
    public function get rewardFirst() : int {
        return instanceRecord.FirstReward;
    }
    // 非首次通关奖励
    public function get reward() : int {
        return instanceRecord.Reward;
    }
    // 3星条件, 通关剩余时间不少于x秒
    public function get condStar3TimeLeft() : int {
        return instanceRecord.StarThirdTimeLeft;
    }
    public function get isCompleted() : Boolean {
        return isServerData;
    }
    public function get isElite() : Boolean {
        return instanceType == EInstanceType.TYPE_ELITE;
    }

    public function getIsOpenCondPass(teamLevel:int) : Boolean {
        if (isCompleted == false) {
            var needTeamLevel:int = condLevel;
            if (teamLevel < needTeamLevel) {
                return false;
            }

            if (condScenarioInstanceID > 0) {
                var instancePre:CChapterInstanceData = getInstanceByID(condScenarioInstanceID);
                if (instancePre.isCompleted == false) { return false; }
            }
            if (condEliteInstanceID > 0) {
                var instanceElitePre:CChapterInstanceData = getInstanceByID(condEliteInstanceID);
                if (instanceElitePre.isCompleted == false) { return false; }
            }
            var condQuestID:int = condQuest;
            if (condQuestID > 0) {
                var taskSystem:CTaskSystem = ((_databaseSystem as CAppSystem).stage.getSystem(CTaskSystem) as CTaskSystem);
                if (taskSystem) {
                    var taskManager:CTaskManager = taskSystem.getBean(CTaskManager) as CTaskManager;
                    var plotTaskRecord:PlotTask = taskManager.getPlotTaskTableByID(condQuestID);
                    var plotTaskState:int = taskManager.getTaskStateByTaskID(condQuestID);
                    if (plotTaskRecord) {
                        return plotTaskState >= CTaskStateType.FINISH;
                    } else {
                        return true;
                    }
                } else {
                    return true;
                }
            }
        }
        return true;
    }
    // 获得副本开启条件串
    public function getOpenCondtionTipsList(teamLevel:int) : Array {
        var ret:Array = new Array();
        var content:String;
        if (isServerData == false) {
            var needTeamLevel:int = condLevel;
            if (needTeamLevel > 0) {
                content = CLang.Get("instance_error_pre_level", {v1:needTeamLevel});
                if (teamLevel < needTeamLevel) {
                    content = CLang.Get("common_color_content_red", {v1:content});
                } else {
                    content = CLang.Get("common_color_content_green", {v1:content});
                }
                ret.push(content);
            }
            if (condScenarioInstanceID > 0) {
                var instancePre:CChapterInstanceData = getInstanceByID(condScenarioInstanceID);
                content = CLang.Get("instance_error_pre_instance", {v1:instancePre.name});
                if (instancePre.isCompleted == false) {
                    content = CLang.Get("common_color_content_red", {v1:content});
                } else {
                    content = CLang.Get("common_color_content_green", {v1:content});
                }
                ret.push(content);
            }
            if (condEliteInstanceID > 0) {
                var elitePre:CChapterInstanceData = getInstanceByID(condEliteInstanceID);
                content = CLang.Get("instance_error_elite_pre_instance", {v1:elitePre.name});
                if (elitePre.isCompleted == false) {
                    content = CLang.Get("common_color_content_red", {v1:content});
                } else {
                    content = CLang.Get("common_color_content_green", {v1:content});
                }
                ret.push(content);
            }

            var condQuestID:int = condQuest;
            if (condQuestID > 0) {
                var taskSystem:CTaskSystem = ((_databaseSystem as CAppSystem).stage.getSystem(CTaskSystem) as CTaskSystem);
                if (taskSystem) {
                    var taskManager:CTaskManager = taskSystem.getBean(CTaskManager) as CTaskManager;
                    var plotTaskRecord:PlotTask = taskManager.getPlotTaskTableByID(condQuestID);
                    var plotTaskState:int = taskManager.getTaskStateByTaskID(condQuestID);
                    if (plotTaskRecord) {
                        content = CLang.Get("instance_error_pre_task", {v1:plotTaskRecord.targerDesc});
                        if (plotTaskState < CTaskStateType.FINISH) {
                            content = CLang.Get("common_color_content_red", {v1:content});
                        } else {
                            content = CLang.Get("common_color_content_green", {v1:content});
                        }
                        ret.push(content);
                    }
                }
            }
        }

        return ret;
    }
    public function getNameByID(instanceID:int) : String {
        var instanceContent:InstanceContent = getInstanceRecordByID(instanceID);
        return (textTable.findByPrimaryKey(instanceContent.Name) as InstanceTxt).Name;
    }
    public function getDescByID(instanceID:int) : String {
        var instanceContent:InstanceContent = getInstanceRecordByID(instanceID);
        return (textTable.findByPrimaryKey(instanceContent.Desc) as InstanceTxt).Name;
    }
    public function getInstanceByID(instanceID:int) : CChapterInstanceData {
        return instance.instanceList.getByID(instanceID);
    }

    // ==============
    private function get instance() : CInstanceData {
        return _rootData as CInstanceData;
    }
    public function get constant() : InstanceConstant {
        return (_rootData as CInstanceData).constant;
    }
    public function get textTable() : IDataTable {
        if (null == _txtTable) _txtTable = _databaseSystem.getTable(KOFTableConstants.INSTANCE_TXT);
        return _txtTable;
    }
    public function get instanceRecord() : InstanceContent {
        if (null == _instanceRecord) _instanceRecord = getInstanceRecordByID(instanceID);
        return _instanceRecord;
    }
    public function get dialogRecord() : InstanceDialog {
        if (_hasLoadDialogRecord) return _dialogRecord; // 避免精英副本没有dialog数据, 重复取表数据
        if (null == _dialogRecord) {
            var findList:Array = _databaseSystem.getTable(KOFTableConstants.INSTANCE_DIALOG).findByProperty("InstanceID", instanceID);
            if (findList) {
                _dialogRecord = findList[0];
            }
            _hasLoadDialogRecord = true;
        }
        return _dialogRecord;
    }

    public function getInstanceRecordByID(instanceID:int) : InstanceContent {
        return _databaseSystem.getTable(KOFTableConstants.INSTANCE_CONTENT).findByPrimaryKey(instanceID);
    }
    private var _instanceRecord:InstanceContent;
    private var _dialogRecord:InstanceDialog;
    private var _hasLoadDialogRecord:Boolean;
    private var _txtTable:IDataTable;
}
}
