//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/3.
 */
package kof.game.Tutorial.data {

import kof.framework.IDataTable;
import kof.table.TutorAction;
import kof.table.TutorGroup;

public class CTutorGroupInfo extends CTutorInfoBase {
    public function CTutorGroupInfo(tutorData:CTutorData, tutorGroupID:int) {
        super (tutorData);

        _tutorGroupID = tutorGroupID;
        _groupRecord = _tutorData.tutorGroupTable.findByPrimaryKey(_tutorGroupID);

        _createActionList();
    }
    private function _createActionList() : void {
        var actionTable:IDataTable = _tutorData.tutorActionTable;
        var findList:Array = actionTable.findByProperty("GroupID", _tutorGroupID) as Array;
        _tutorActionList = new Array();

        var actionInfo:CTutorActionInfo;
        var actionInfoRecord:TutorAction;
        for (var i:int = 0; i < findList.length; i++) {
            actionInfoRecord = findList[i];
            actionInfo = new CTutorActionInfo(_tutorData, this, actionInfoRecord);
            if (actionInfo.isSurrender == false) {
                _tutorActionList[_tutorActionList.length] = actionInfo;
            }
        }
    }

    public override function dispose() : void {
        super.dispose();
        _tutorGroupID = -1;
        _groupRecord = null;
        for each (var actionInfo:CTutorActionInfo in _tutorActionList) {
            actionInfo.dispose();
        }
        _tutorActionList = null;
    }

    // 根据ActionID获得组里的动作
    public function getActionByID(actionID:int) : CTutorActionInfo {
        for each (var actionInfo:CTutorActionInfo in _tutorActionList) {
            if (actionInfo.ID == actionID) {
                return actionInfo;
            }
        }
        return null;
    }
    // 获得组里的，下一步动作
    public function getNextActionByID(actionID:int) : CTutorActionInfo {
        var actionInfo:CTutorActionInfo = getActionByID(actionID);
        if (actionInfo.nextActionID > 0) {
            var nextActionInfo:CTutorActionInfo = getActionByID(actionInfo.nextActionID);
            return nextActionInfo;
        }
        return null;
    }
    public function hasNext() : Boolean {
        return this.nextGroupID > 0;
    }

    public function get firstAction() : CTutorActionInfo {
        if (_firstAction != null) return _firstAction;

        if (_tutorActionList.length == 1) {
            _firstAction = _tutorActionList[0];
            return _firstAction;
        }

        for each (var actionInfo:CTutorActionInfo in _tutorActionList) {
            if (!_firstAction) {
                _firstAction = actionInfo;
            } else {
                if (_firstAction.ID > actionInfo.ID) {
                    _firstAction = actionInfo;
                }
            }
        }
        return _firstAction;
    }

    public function getPreAction(infoID:int) : CTutorActionInfo {
        var firstAction:CTutorActionInfo = this.firstAction;
        if (firstAction == null) return null;

        var findActionInfo:CTutorActionInfo = firstAction;
        while (findActionInfo != null) {
            if (findActionInfo.ID == infoID) {
                // 找到自己的Action了, 后面不会再有了
                findActionInfo = null;
                break;
            }
            if (findActionInfo.nextActionID == infoID) {
                // findi
                break ;
            }

            findActionInfo = getNextActionByID(findActionInfo.ID);
        }

        return findActionInfo;
    }

    public function get lastAction() : CTutorActionInfo {
        if (_lastAction != null) return _lastAction;

        for each (_lastAction in _tutorActionList) {
            if (_lastAction.nextActionID == 0) {
                break;
            }
        }
        return _lastAction;
    }

    // 生效的动作长度, 可用于判断完成动作的数量, 如果这个数量不正确, 请把表里不需要的动作的Surrender = 1
    [Inline]
    public function get validActionCount() : int {
        return _tutorActionList.length;
    }

    public function get ID() : int { return groupRecord.ID; }
    // 下一个指引组ID
    [Inline]
    public function get nextGroupID() : int { return groupRecord.NextID; } // 0为无后续指引
    [Inline]
    public function get isAutoFinish() : int { return groupRecord.AutoFinish; } // 0-不自动完成, 1-自动完成
    [Inline]
    public function get isNeedRestart() : int { return groupRecord.NeedRestart; } // 断线是否重新引导 0-不重新引导 1-重新引导
    [Inline]
    public function get completeMainQuestCondID() : int { return groupRecord.CompleteMainQuestCondID; } // 触发该引导需要完成主线任务id
    [Inline]
    public function get doingMainQuestCondID() : int { return groupRecord.DoingMainQuestCondID; } // 触发该引导需要接到主线任务id
    [Inline]
    public function get primaryView() : int { return groupRecord.PrimaryViewCondID; } // 0： 回到副本，1：回到主城
    [Inline]
    public function get hasMask() : Boolean { return groupRecord.HasMask > 0; } // 0 没蒙板, 1有蒙板
    public function get isAutoFindValidAction() : Boolean { return true; } //return hasMask == false; }
    [Inline]
    public function get maskAlpha() : Number { return groupRecord.MaskAlpha; } // 蒙板透明度
    [Inline]
    public function get finishCond() : int { return groupRecord.GroupFinishCondID; } // 组完成条件ID, 如果组条件完成了, 则整个完成
    [Inline]
    public function get finishCondParam() : Array { return groupRecord.FinishCondParam; } // 完成条件参数
    [Inline]
    public function get tutorActionList() : Array { return _tutorActionList; }
    [Inline]
    public function get groupRecord() : TutorGroup { return _groupRecord; }

    private var _groupRecord:TutorGroup;
    private var _tutorGroupID:int;
    private var _tutorActionList:Array;

    private var _firstAction:CTutorActionInfo;
    private var _lastAction:CTutorActionInfo;
}
}
