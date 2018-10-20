//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/5.
 */
package kof.game.Tutorial.tutorPlay {

import kof.game.Tutorial.data.CTutorActionInfo;
import kof.game.Tutorial.enum.ETutorActionRollBackType;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.newServerActivity.CNewServerActivitySystem;
import kof.game.task.CTaskSystem;
import kof.game.task.data.CTaskStateType;
import kof.util.CAssertUtils;

import morn.core.components.Tab;


public class CTutorActionRollBackCheck {
    public function CTutorActionRollBackCheck(tutorPlay:CTutorPlay) {
        _pTutorPlay = tutorPlay;
    }

    public function dispose() : void {
        _pTutorPlay = null;
    }

    public function canRollBack(actionInfo:CTutorActionInfo) : Boolean {
        if (_pTutorPlay == null) return false;

        var process:Function = null;
        switch (actionInfo.rollbackCondID) {
            case ETutorActionRollBackType.COND_TASK_COMPLETED :
                process = _checkTaskNotCompleted;
                break;

            case ETutorActionRollBackType.COND_INSTANCE_COMPLETED :
                process = _checkInstanceNotCompleted;
                break;
            case ETutorActionRollBackType.COND_7_DAY_NEW_SERVER_NOT_TAB1 :
                process = _check7DayNewServerNotSelectTab1;
                break;
            case ETutorActionRollBackType.COND_NOT_SELECT_TAB :
                process = _checkNotSelectTab;
                break;

        }

        if (process != null) {
            return process(actionInfo);
        }
        return false;
    }

    private function _checkTaskNotCompleted(actionInfo:CTutorActionInfo) : Boolean {
        var taskSystem:CTaskSystem = _pTutorPlay.tutorManager.system.stage.getSystem(CTaskSystem) as CTaskSystem;
        var taskID:int = (int)(actionInfo.rollBackCondParam);
        if (taskID > 0) {
            var taskState:int = taskSystem.getTaskStateByTaskID(taskID);
            if (taskState < CTaskStateType.FINISH) {
                return true;
            }
        }

        return false;
    }
    private function _checkInstanceNotCompleted(actionInfo:CTutorActionInfo) : Boolean {
        var pInstanceSystem:CInstanceSystem = _pTutorPlay.tutorManager.system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        var instanceID:int = (int)(actionInfo.rollBackCondParam);
        if (instanceID > 0) {
            var pInstanceData:CChapterInstanceData = pInstanceSystem.getInstanceByID(instanceID);
            if (pInstanceData) {
                return pInstanceData.isCompleted == false;
            }
        }

        return false;
    }
    private function _check7DayNewServerNotSelectTab1(actionInfo:CTutorActionInfo) : Boolean {
        var pNewServerSystem:CNewServerActivitySystem = _pTutorPlay.tutorManager.system.stage.getSystem(CNewServerActivitySystem) as CNewServerActivitySystem;
        if (pNewServerSystem) {
            return false == pNewServerSystem.isSelectFirstActivity();
        }
        return false;
    }
    private function _checkNotSelectTab(actionInfo:CTutorActionInfo) : Boolean {
        var param:String = actionInfo.rollBackCondParam;
        var paramList:Array = param.split(",");
        if (paramList && paramList.length >= 2) {
            var tabID:String = paramList[0] as String;
            var tabIndex:int = (int)(paramList[1]);

            var tab:Tab = CTutorUtil.GetComponentWithOutLoad(_pTutorPlay.tutorManager.system, tabID) as Tab;
            if (tab) {
                return tab.selectedIndex != tabIndex;
            } else {
                return false;
            }

        } else {
            CAssertUtils.assertTrue(false, "_checkNotSelectTab param error");
            return false;
        }

    }

    private var _pTutorPlay:CTutorPlay;

}
}
