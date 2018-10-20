//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/7/11.
 */
package kof.game.switching.view {

import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.instance.IInstanceFacade;
import kof.game.switching.enums.EFuncOpenConditionType;
import kof.game.task.CTaskSystem;
import kof.game.task.data.CTaskStateType;
import kof.table.FuncOpenCondition;
import kof.table.FunctionNotice;

/**
 * 功能预告条件检测
 */
public class CFuncNoticeDetectHandler extends CAbstractHandler {
    public function CFuncNoticeDetectHandler()
    {
        super();
    }

    /**
     * 得下一个需要预告的功能
     * @return
     */
    public function getNextNoticeItem():FunctionNotice
    {
        var arr:Array = _funcNotice.toArray();
        for each(var item:FunctionNotice in arr)
        {
            if(!_isConditionReach(item.openCondition))
            {
                return item;
            }
        }

        return null;
    }

    private function _isConditionReach(conditionId:int):Boolean
    {
        var condition:FuncOpenCondition = _funcOpenCondition.findByPrimaryKey(conditionId) as FuncOpenCondition;
        if(condition && condition.conditions && condition.conditions.length)
        {
            for(var i:int = 0; i < condition.conditions.length; i++)
            {
                var conditionType:int = condition.conditions[i];
                var param:int = condition.params[i];
                if(conditionType == EFuncOpenConditionType.Type_Plot || conditionType == EFuncOpenConditionType.Type_Elite)// 副本
                {
                    var instanceSystem : IInstanceFacade = system.stage.getSystem( IInstanceFacade ) as IInstanceFacade;
                    if(instanceSystem)
                    {
                        return instanceSystem.isInstancePass(param);
                    }
                }
                else if(conditionType == EFuncOpenConditionType.Type_Task)// 任务
                {
                    var taskSystem : CTaskSystem = system.stage.getSystem( CTaskSystem ) as CTaskSystem;
                    if (taskSystem)
                    {
                        var state : int = taskSystem.getTaskStateByTaskID(param);
                        return CTaskStateType.COMPLETE == state;
                    }
                }
            }
        }

        return false;
    }

//==========================================table==================================================
    private function get _dataBase():IDatabase
    {
        return system.stage.getSystem(IDatabase) as IDatabase;
    }

    private function get _funcNotice():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.FunctionNotice);
    }

    private function get _funcOpenCondition():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.FuncOpenCondition);
    }
}
}
