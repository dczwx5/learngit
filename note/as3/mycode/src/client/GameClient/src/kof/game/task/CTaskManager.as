//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/1/10.
 */
package kof.game.task {

import QFLib.Interface.IUpdatable;

import flash.utils.Dictionary;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.game.instance.CInstanceSystem;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.reciprocation.popWindow.EPopWindow;
import kof.game.task.data.CTaskData;
import kof.game.task.data.CTaskStateType;
import kof.game.task.data.CTaskType;
import kof.message.Task.TaskChangeResponse;
import kof.message.Task.TaskListResponse;
import kof.table.PlotTask;
import kof.table.Task;
import kof.table.TaskActive;

public class CTaskManager extends CAbstractHandler implements IUpdatable {

    private var _taskTable:IDataTable;
    private var _plotTaskTable:IDataTable;
    private var _taskDataDic:Dictionary;
    private var _typeDic:Dictionary;
    private var _plotTaskArray:Array;
    private var _plotTaskLineArray:Array; //主线任务的任务线

    private var _curPlotTaskID : int;

//    private var _plotTaskDoneArray:Array; //当次登录之后完成的,和正在进行的主线任务
    private var _plotTaskDoneDic:Dictionary; //当次登录之后完成的,和正在进行的主线任务

    private var _dirtyAry : Array;

    public function CTaskManager() {
        super();

        _taskDataDic = new Dictionary();
        _typeDic = new Dictionary();
        _typeDic[CTaskType.PLOT_TASK] = [];
        _typeDic[CTaskType.DAILY_TASK] = [];
        _typeDic[CTaskType.LONG_LINE_TASK] = [];
        _plotTaskLineArray = [];
//        _plotTaskDoneArray = [];
        _plotTaskDoneDic = new Dictionary();
        _dirtyAry = [CTaskType.DAILY_TASK,CTaskType.LONG_LINE_TASK];
    }

    public override function dispose() : void {
        super.dispose();
    }
    protected override function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        _taskTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.TASK);
        _plotTaskTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.PLOT_TASK);
        _plotTaskArray = _plotTaskTable.toArray();
        _plotTaskArray.sortOn( _plotTaskTable.primaryKey,Array.NUMERIC );

        var plotTask : PlotTask;
        plotTask = _plotTaskArray[0];
        _plotTaskLineArray.push( plotTask.ID );

        while( plotTask.nextTaskID > 0 ){
            _plotTaskLineArray.push( plotTask.nextTaskID );
            plotTask = _plotTaskTable.findByPrimaryKey( plotTask.nextTaskID );
        }

        return ret;
    }

    // ====================================S2C==================================================
    public function initialTaskData(response:TaskListResponse) : void {
        for each (var data:Object in response.data) {
            updateToDic( data );
            if(  data[CTaskData._type] == CTaskType.PLOT_TASK ){
                _curPlotTaskID = data[CTaskData._taskID];
            }
        }
    }

    public function updateTaskData(response:TaskChangeResponse) : void {
        var pCTaskData:CTaskData;
        for each (var data:Object in response.data){
            if(data[CTaskData._modifyType] == 2){//1:增加 2：删除 3：更新
                pCTaskData = getTaskDataByTaskID(data[CTaskData._taskID]);
                addPlotTaskDoneArray( pCTaskData );
                deleteTaskDataByTaskID(data[CTaskData._taskID]);
                var ary : Array = _typeDic[data[CTaskData._type]];
                ary.splice(ary.indexOf(pCTaskData),1);
                if( pCTaskData.plotTask ){
                    _curPlotTaskID = pCTaskData.taskID;
                    _instanceSystem.callWhenInMainCity(showRewardViewHandler, [pCTaskData], null , null ,pCTaskData.plotTask.ID );//最后一个参数，越小越在队列前面
                    system.dispatchEvent( new CTaskEvent( CTaskEvent.TASK_FINISH , pCTaskData ));
//                    if( ary.length <= 0 ){
//                        system.dispatchEvent(new CTaskEvent(CTaskEvent.PLOT_TASK_UPDATE));
//                    }
                }

            } else if(data[CTaskData._modifyType] == 1){
                pCTaskData = updateToDic(data);
                if( pCTaskData.plotTask )
                    _curPlotTaskID = pCTaskData.taskID;
                addPlotTaskDoneArray( pCTaskData );
                system.dispatchEvent( new CTaskEvent( CTaskEvent.TASK_ADD , pCTaskData ));
//                if( pCTaskData.plotTask )
//                    system.dispatchEvent( new CTaskEvent( CTaskEvent.PLOT_TASK_UPDATE ) );
                if(  data[CTaskData._type] == CTaskType.DAILY_TASK || data[CTaskData._type] == CTaskType.LONG_LINE_TASK ){
                    addDirtyAry( data[CTaskData._type] );
                }
            } else{
                pCTaskData = getTaskDataByTaskID(data[CTaskData._taskID]);
                var isTypeDirty : Boolean;
                if( pCTaskData && ( data[CTaskData._type] == CTaskType.DAILY_TASK || data[CTaskData._type] == CTaskType.LONG_LINE_TASK  )
                && pCTaskData.state != data[CTaskData._state] ){
                    isTypeDirty = true;
                }
                updateToDic(data);
                if( isTypeDirty )
                    addDirtyAry( data[CTaskData._type] );
            }

        }
        system.dispatchEvent( new CTaskEvent( CTaskEvent.TASK_DATA_UPDATE_COMP ));
    }

    private function showRewardViewHandler( pCTaskData : CTaskData):void{
        var pCPlotTaskRewardViewHandler : CPlotTaskRewardViewHandler = _mainTaskSystem.getBean( CPlotTaskRewardViewHandler ) as CPlotTaskRewardViewHandler;
        var pReciprocalSystem:CReciprocalSystem = (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem);
        if(pReciprocalSystem){
            pReciprocalSystem.addEventPopWindow( EPopWindow.POP_WINDOW_2,function():void{
                pCPlotTaskRewardViewHandler.addDisplay( pCTaskData );
            }, pCTaskData.taskID);
        }
    }
//    private function showPlotDoneHandler( ):void{
//        var pPlotTaskDoneViewHandler : CPlotTaskDoneViewHandler = _mainTaskSystem.getBean( CPlotTaskDoneViewHandler ) as CPlotTaskDoneViewHandler;
//        pPlotTaskDoneViewHandler.addDisplay();
//    }
    private function updateToDic(data:Object):CTaskData{
        var pTaskData:CTaskData = getTaskDataByTaskID(data[CTaskData._taskID]);
        var isUpdate :Boolean = true;
        if(!pTaskData){
            isUpdate = false;
            pTaskData = new CTaskData();
            if( data[CTaskData._type] == CTaskType.PLOT_TASK ){
                pTaskData.plotTask = getPlotTaskTableByID(data[CTaskData._taskID]);
            }else{
                pTaskData.task = getTaskTableByID(data[CTaskData._taskID]);
            }
            _taskDataDic[data[CTaskData._taskID]] = pTaskData;
            _typeDic[data[CTaskData._type]].push(pTaskData);
        }
        pTaskData.updateDataByData(data);
        if( isUpdate && data[CTaskData._state] == CTaskStateType.FINISH ){
            system.dispatchEvent( new CTaskEvent( CTaskEvent.TASK_FINISH , pTaskData ));
        }

        if( data[CTaskData._state] == CTaskType.PLOT_TASK ){
            _typeDic[data[CTaskData._type]].sortOn(["state","taskID"], [Array.NUMERIC|Array.DESCENDING, Array.NUMERIC]);
        }else{
//            _typeDic[data[CTaskData._type]].sort( sortItem );
        }

        return pTaskData;

    }
    //策划要求的排序 ，‘领取体力’的任务放在最后面
    private function sortItem(a:CTaskData,b:CTaskData):int{
        if( !a || !b || !a.task || !b.task )
                return 0;
        if( a.state < b.state ){
            return 1;
        }else if(a.state > b.state){
            return -1;
        }else{
            if( a.task.condition == 119 && b.task.condition != 119 ){
                return 1;
            }else if( a.task.condition != 119 && b.task.condition == 119 ){
                return -1;
            }else {
                if( a.task.sort < b.task.sort ){
                    return -1;
                }else if( a.task.sort > b.task.sort ){
                    return 1;
                }else{
                    if( a.taskID < b.taskID ){
                        return -1;
                    }else if(a.taskID > b.taskID){
                        return 1;
                    }else{
                        return 0;
                    }
                }
            }
        }
    }
    public function getUserTaskList():Dictionary{
        return  _taskDataDic;
    }
    public function getTaskDataByTaskID( taskID : int ) : CTaskData{
        return  _taskDataDic[taskID];
    }
    public function getTaskStateByTaskID( taskID : int ) : int{
        var pTaskData : CTaskData = _taskDataDic[taskID];
        if( pTaskData ) {
            return pTaskData.state;
        }else if( !getCurPlotTaskData() && _plotTaskLineArray.indexOf( taskID ) != -1 && _curPlotTaskID <= 0){
            return CTaskStateType.COMPLETE;
        } else if ( !getCurPlotTaskData() && _plotTaskLineArray.indexOf( taskID ) != -1 && _curPlotTaskID > 0 && _plotTaskLineArray.indexOf( _curPlotTaskID ) >= _plotTaskLineArray.length - 1 ) {
            return CTaskStateType.COMPLETE;
        } else if( getCurPlotTaskData() && _plotTaskLineArray.indexOf( taskID ) != -1 && _plotTaskLineArray.indexOf( taskID ) < _plotTaskLineArray.indexOf( getCurPlotTaskData().taskID ) ){
            return CTaskStateType.COMPLETE;
        }else if( getCurPlotTaskData() && _plotTaskLineArray.indexOf( taskID ) != -1 && _plotTaskLineArray.indexOf( taskID ) == _plotTaskLineArray.indexOf( getCurPlotTaskData().taskID ) ){
            return CTaskStateType.CAN_DO;
        }
       return CTaskStateType.CAN_NOT_RECEIVE;
    }
    public function getCurPlotTaskData():CTaskData{
        return _typeDic[CTaskType.PLOT_TASK][0];
    }
    public function deleteTaskDataByTaskID(taskID:int):void{
        if(_taskDataDic[taskID])
            delete _taskDataDic[taskID];
    }

    public function getTaskDatasByType(type:int = 0):Array{
        return _typeDic[type];
    }
    //日常任务
    public function getTaskDatasByTypeAndSort( type:int = 0 ):Array{
        if( type != CTaskType.DAILY_TASK && type != CTaskType.LONG_LINE_TASK ){
            return _typeDic[type];
        }
        if( getTypeIsDirty( type ) ){
            deleteDirtyAry( type );
            return _typeDic[type].sort( sortItem );
        }
        return _typeDic[type];
    }
    public function getTaskDatasByTypeAndSortII( type:int = 0 ):Array{
        if( type != CTaskType.DAILY_TASK && type != CTaskType.LONG_LINE_TASK ){
            return _typeDic[type];
        }
        if( getTypeIsDirty( type ) ){
            return _typeDic[type].sort( sortItem );
        }
        return _typeDic[type];
    }

    /////////////////////////////

    //日常任务能领奖的数目
    public function get dailyTaskCanAwardNum():int{
        var num : int ;
        var ary : Array = getTaskDatasByType( CTaskType.DAILY_TASK );
        var pTaskData:CTaskData;
        for each( pTaskData in ary ){
            if( pTaskData.state == CTaskStateType.FINISH ){
                num ++;
            }
        }

        return num;
    }
    //成长任务能领奖的数目
    public function get longLineTaskCanAwardNum():int{
        var num : int ;
        var ary : Array = getTaskDatasByType( CTaskType.LONG_LINE_TASK );
        var pTaskData:CTaskData;
        for each( pTaskData in ary ){
            if( pTaskData.state == CTaskStateType.FINISH  ){
                num ++;
            }
        }
        return num;
    }

    //活跃度能领奖的数目
    public function get activeCanAwardNum():int{
        var num : int ;
        var taskActiveTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.TASK_ACTIVE );
        var taskActiveAry : Array = taskActiveTable.toArray();
        var taskActive : TaskActive;
        for each ( taskActive in taskActiveAry ){
            if( pCPlayerData.taskData.dailyQuestActiveValue >= taskActive.active  && pCPlayerData.taskData.dailyQuestActiveRewards.indexOf( taskActive.ID ) == -1 ){
                num ++;
            }
        }

        return num;

    }

    //////////////////////
    public function addPlotTaskDoneArray( pCTaskData:CTaskData ):void{
//        if( _plotTaskDoneArray.indexOf( pCTaskData ) == -1 )
//            _plotTaskDoneArray.push( pCTaskData );
        _plotTaskDoneDic[pCTaskData.taskID] = pCTaskData;
    }
    public function getPlotTaskFromDoneArray( taskID : int ):CTaskData{
//        var pCTaskData:CTaskData;
//        for each(  pCTaskData in _plotTaskDoneArray ){
//           if( taskID == pCTaskData.taskID ){
//               return pCTaskData;
//               break;
//           }
//       }
        var pCTaskData:CTaskData =  _plotTaskDoneDic[taskID];
        if( pCTaskData )
                return pCTaskData;
        return null;
    }

    public function get lastPoltTaskID():int{
        return _plotTaskLineArray[_plotTaskLineArray.length - 1];
    }


    // ======================================table================================================
    public function getTaskTableByID(taskID:int) : Task{
        return _taskTable.findByPrimaryKey(taskID);
    }
    public function getPlotTaskTableByID(taskID:int) : PlotTask{
        return _plotTaskTable.findByPrimaryKey(taskID);
    }
    public function getChapterTaskArray( chapterID : int ):Array{
        var chapterAry:Array = [];
        for each( var plotTask:PlotTask in _plotTaskArray){
            if( chapterID == plotTask.chapterID ){
                chapterAry.push( plotTask );
            }
        }
        return chapterAry;
    }

    public function update(delta:Number) : void {

    }

    public function getTypeIsDirty( type : int = 0 ) : Boolean{
        return _dirtyAry.indexOf( type ) != -1 ;
    }
    public function addDirtyAry( type : int = 0 ):void{
        if( _dirtyAry.indexOf( type ) == -1 )
            _dirtyAry.push( type );
    }
    public function deleteDirtyAry( type : int = 0 ):void{
        if( _dirtyAry.indexOf( type ) != -1 )
            _dirtyAry.splice(_dirtyAry.indexOf( type ), 1 );
    }

    private function get pCPlayerData():CPlayerData{
        var playerManager:CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean(CPlayerManager) as CPlayerManager;
        return  playerManager.playerData;
    }


    private function get _instanceSystem():CInstanceSystem{
        return system.stage.getSystem( CInstanceSystem ) as CInstanceSystem;
    }
    private function get _mainTaskSystem():CMainTaskSystem{
        return system.stage.getSystem( CMainTaskSystem ) as CMainTaskSystem;
    }

}
}
