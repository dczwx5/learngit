//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2018/1/29.
 */
package kof.game.teaching {

import flash.utils.Dictionary;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.common.CLang;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerHeroData;
import kof.game.switching.CSwitchingSystem;
import kof.game.task.CTaskSystem;
import kof.game.task.data.CTaskStateType;
import kof.table.PlayerLines;
import kof.table.PlotTask;
import kof.table.TeachingContent;

public class CTeachingInstanceManager extends CAbstractHandler {
    private var _teachingDataDic:Dictionary;
    public function CTeachingInstanceManager() {
    }

    public function getTeachingDataByID(id:int):Object{
        if(_teachingDataDic == null) return null;
        return _teachingDataDic[id];
    }

    public function setTeachingData(obj:Object):void{
        if(_teachingDataDic == null){
            _teachingDataDic = new Dictionary();
        }
        _teachingDataDic[obj.ID] = obj;
    }

    public function challengeBool(teachingID:int):Boolean{
        var bool:Boolean = true;
        var data:TeachingContent = getTeachingTableByID(teachingID);
        if(data.CondGrade){
            bool = challengeByLevel(data);
            if(!bool) return false;
        }

        if(data.CondInstanceContentID){
            bool = challengeByInstanceContentID(data);
            if(!bool) return false;
        }

        if(data.CondTaskID){
            bool = challengeByTaskID(data);
            if(!bool) return false;
        }

        if(data.CondTeachingContentID){
            bool = challengeByTeachingContentID(data);
            if(!bool) return false;
        }

        if(data.PlayerID){
            bool = challengeByPlayerID(data);
            if(!bool) return false;
        }
        return bool;
    }

    public function challengeByLevel(data:TeachingContent):Boolean{
        var bool:Boolean = true;
        var level:int = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.teamData.level;
        if(data.CondGrade > level){
            bool = false;
        }
        return bool;
    }

    public function challengeByInstanceContentID(data:TeachingContent):Boolean{
        var bool:Boolean;
        bool = (system.stage.getSystem(CInstanceSystem) as CInstanceSystem).getInstanceByID(data.CondInstanceContentID ).isCompleted;
        return bool;
    }

    public function challengeByTeachingContentID(data:TeachingContent):Boolean{
        var bool:Boolean = true;
        var teaching:Object = getTeachingDataByID(data.CondTeachingContentID);
        if(teaching == null){
            bool = false;
        }
        return bool;
    }

    public function challengeByTaskID(data:TeachingContent):Boolean{
        var bool:Boolean = true;
        var taskData:int = (system.stage.getSystem(CTaskSystem) as CTaskSystem).getTaskStateByTaskID(data.CondTaskID);
        if(taskData < CTaskStateType.FINISH){
            bool = false;
        }
        return bool;
    }
    public function challengeByPlayerID(data:TeachingContent):Boolean{
        var bool:Boolean = true;
        var haveHero:CPlayerHeroData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.heroList.getHero(data.PlayerID);
        if(haveHero == null){
            bool = false;
        }else if( !haveHero.hasData ){
            bool = false;
        }

        return bool;
    }

    private function getTeachingTableByID(id:int):TeachingContent{
        var teachingTable : IDataTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.TEACHINGCONTENT );
        var teachingObj : TeachingContent = teachingTable.findByPrimaryKey(id);
        return teachingObj;
    }

    public function getToolTip(data:TeachingContent):String{
        var toolTipSting:String = "";
        var color:String = "";
        if(data.CondGrade){
            color = challengeByLevel(data) ? CLang.Get("common_color_content_green",{v1:data.CondGrade}) :  CLang.Get("common_color_content_red",{v1:data.CondGrade});
            toolTipSting += CLang.Get("teaching_tips_CondGrade",{v1:color})+"\n";
        }

        if(data.CondInstanceContentID){
            var instanceName:String = getTeachingInstanceDataByID(data.CondInstanceContentID ).name;
            color = challengeByInstanceContentID(data) ? CLang.Get("common_color_content_green",{v1:instanceName}) : CLang.Get("common_color_content_red",{v1:instanceName});
            toolTipSting += CLang.Get("teaching_tips_CondInstanceContentID",{v1:color})+"\n";
        }

        if(data.CondTaskID){
            var taskTable : IDataTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.PLOT_TASK );
            var taskName:String = (taskTable.findByPrimaryKey(data.CondTaskID) as PlotTask).trackRound;
            color = challengeByTaskID(data) ? CLang.Get("common_color_content_green",{v1:taskName}) :  CLang.Get("common_color_content_red",{v1:taskName});
            toolTipSting += CLang.Get("teaching_tips_CondTaskID",{v1:color})+"\n";
        }

        if(data.CondTeachingContentID){
            var teachingName:String = getTeachingInstanceDataByID(getTeachingTableByID(data.CondTeachingContentID ).InstanceContentID).name;
            color = challengeByTeachingContentID(data) ? CLang.Get("common_color_content_green",{v1:teachingName}) :  CLang.Get("common_color_content_red",{v1:teachingName});
            toolTipSting += CLang.Get("teaching_tips_CondTeachingContentID",{v1:color})+"\n";
        }

        if(data.PlayerID){
            var teachingTable : IDataTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.PLAYER_LINES );
            var playerName:String = (teachingTable.findByPrimaryKey(data.PlayerID) as PlayerLines).PlayerName;
            color = challengeByPlayerID(data) ? CLang.Get("common_color_content_green",{v1:playerName}) :  CLang.Get("common_color_content_red",{v1:playerName});
            toolTipSting += CLang.Get("teaching_tips_PlayerID",{v1:color})+"\n";
        }

        return toolTipSting;
    }

    public function showRedPoint(type:int):Boolean{
        var arr:Array = getTeachingType(type);
        for each ( var item:TeachingContent in arr ){
            var data:Object = getTeachingDataByID( item.ID );

            if( data == null && challengeBool(item.ID)){
                return true;
            }

            if( data && !data.isReward ){
                return true;
            }
        }

        return false;
    }

    public function onAllRedPoint():Boolean{
        var switchingSystem:CSwitchingSystem = system.stage.getSystem(CSwitchingSystem) as CSwitchingSystem;
        if(!switchingSystem.isSystemOpen(KOFSysTags.TEACHING))
        {
            return false;
        }

        var bool:Boolean = showRedPoint(1) || showRedPoint(2);
        return bool;
    }

    public function getTeachingType(type:int):Array{
        var teachingTable : IDataTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.TEACHINGCONTENT );
        var teachingArray : Array = teachingTable.findByProperty("TapID",type);
        return teachingArray;
    }

    public function getTeachingInstanceDataByID(instanceID:int) : CChapterInstanceData {
        var pInstanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        return pInstanceSystem.getInstanceByID(instanceID);
    }
}
}
