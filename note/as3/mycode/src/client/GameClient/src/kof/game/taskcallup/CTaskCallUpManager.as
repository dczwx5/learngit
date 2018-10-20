//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/19.
 */
package kof.game.taskcallup {

import QFLib.Foundation.CTime;
import QFLib.Interface.IUpdatable;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.game.taskcallup.data.CCallUpAcceptedData;
import kof.game.taskcallup.data.CCallUpListData;
import kof.message.TaskCallUp.TaskCallUpListResponse;
import kof.table.TaskCallUp;
import kof.table.TeamAddition;

public class CTaskCallUpManager extends CAbstractHandler implements IUpdatable {

    public var usedHeroList : Array;//所有已使用的英雄

    public var callUpList : Array;//待召集任务列表

    public var acceptedCallUpList : Array;//进行中召集任务列表

    public var callUpLimit : int;//剩余可接受召集次数

    public var refresh : int;//当前手动刷新次数

    public var refreshTime : Number;//当前手动刷新次数

    public var cancel : int;//已取消次数

    public var taskCallUpRewardRequestTaskId : int;//召集令领奖任务ID

    public var taskQuicklyFinishTaskId : int;//召集令快速完成任务ID

    public function CTaskCallUpManager() {
        super();

        usedHeroList = [];
        callUpList = [];
        acceptedCallUpList = [];

    }
    public function update(delta:Number) : void {
    }
    /////////////////////////////////////////////////////////////////////////////////
    public function updateCallUpInfo( response:TaskCallUpListResponse ):void{
        updateCallUpList( response.callUpList );
        updateUsedHeroList( response.heroList );
        updateAcceptedCallUpList( response.acceptedCallUpList );

        callUpLimit = response.callUpLimit;
        refresh = response.refresh;
        refreshTime = response.refreshTime;
        cancel = response.cancel;
    }
    //待召集任务列表
    public function updateCallUpList( list : Array ):void{
        callUpList.splice( 0 , callUpList.length );
        for each (var data:Object in list ){
            updateCallUpListItemDataToDic(data);
        }
    }
    private function updateCallUpListItemDataToDic(data:Object):void{
        var pCallUpListData : CCallUpListData = new CCallUpListData();//因为这里可能会陪多条ID一样的任务
        callUpList.push( pCallUpListData );
        pCallUpListData.updateDataByData(data);
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.TASKCALLUP );
        var taskCallUp : TaskCallUp =  pTable.findByPrimaryKey( pCallUpListData.taskId );
        pCallUpListData.taskCallUp = taskCallUp;
    }
    public function getCallUpListItemDataByID( taskId : int ):CCallUpListData{
        var pCallUpListData : CCallUpListData;
        for each( pCallUpListData in callUpList ){
            if( pCallUpListData.taskId == taskId ){
                return pCallUpListData;
                break;
            }
        }
        return  null;
    }
   //所有已使用的英雄
    public function updateUsedHeroList( list : Array ):void{
        usedHeroList.splice( 0 , usedHeroList.length );
        for each (var data:Object in list ){
            usedHeroList.push( int(data));
        }
    }
   //进行中召集任务列表
    public function updateAcceptedCallUpList( list : Array ):void{
        acceptedCallUpList.splice( 0 , acceptedCallUpList.length );
        for each (var data:Object in list ){
            updateAcceptedCallUpListItemDataToDic(data);
        }
    }
    public function updateAcceptedCallUpListItemDataToDic(data:Object):void{
        var pCallUpAcceptedData : CCallUpAcceptedData = new CCallUpAcceptedData();
        acceptedCallUpList.push( pCallUpAcceptedData );
        pCallUpAcceptedData.updateDataByData(data);
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.TASKCALLUP );
        var taskCallUp : TaskCallUp =  pTable.findByPrimaryKey( pCallUpAcceptedData.taskId );
        pCallUpAcceptedData.taskCallUp = taskCallUp;
    }
    public function getAcceptedCallUpListItemDataByTaskId( taskId : int ):CCallUpAcceptedData{
        var pCallUpAcceptedData : CCallUpAcceptedData;
        for each( pCallUpAcceptedData in acceptedCallUpList ){
            if( pCallUpAcceptedData.taskId == taskId ){
                return pCallUpAcceptedData;
                break;
            }
        }
        return  null;
    }
    public function deleteAcceptedCallUpListItem( taskId : int ):void{
        var pCallUpAcceptedData : CCallUpAcceptedData;
        for each( pCallUpAcceptedData in acceptedCallUpList ){
            if( pCallUpAcceptedData.taskId == taskId ){
                acceptedCallUpList.splice( acceptedCallUpList.indexOf( pCallUpAcceptedData ) , 1 );
                break;
            }
        }
    }
    //正在执行任务中的英雄
    public function getAcceptedCallUpHeros() : Array {
        var ary : Array = [];
        var pCallUpAcceptedData : CCallUpAcceptedData;
        for each( pCallUpAcceptedData in acceptedCallUpList ){
            ary = ary.concat( pCallUpAcceptedData.heros );
        }
        return ary;
    }


    ////////////////////////////
    //可领奖数目
    public function get canAwardNum():int{
        var num : int;
        var pCallUpAcceptedData : CCallUpAcceptedData;
        for each( pCallUpAcceptedData in acceptedCallUpList ){
            if( pCallUpAcceptedData.endTime - CTime.getCurrServerTimestamp() <= 0 ){
                num ++;
            }
        }
        return num;
    }


    public function getTeamAdditionByTeamID( teamID : int ):TeamAddition{

        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.TEAMADDITION );
        var ary : Array  = pTable.toArray();
        var teamAddition : TeamAddition;
        for each ( teamAddition in ary ){
            if( teamAddition.teamId == teamID ){
                return teamAddition;
                break;
            }
        }
        return null;
    }
    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }

}
}
