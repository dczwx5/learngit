//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.activityTreasure {

import QFLib.Interface.IUpdatable;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.activityTreasure.data.CActivityTreasureTaskData;
import kof.game.activityTreasure.data.CDartsPointData;
import kof.game.activityTreasure.data.CTreasureBoxData;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.switching.CSwitchingSystem;
import kof.game.switching.validation.CSwitchingValidatorSeq;
import kof.table.Activity;
import kof.table.ActivityTreasureBox;
import kof.table.ActivityTreasureRepository;
import kof.table.ActivityTreasureTask;

public class CActivityTreasureManager extends CAbstractHandler implements IUpdatable {

    public var curActivityId : int = 0;
    public var curActivityState : int = 0;
    public var startTime : Number = 0.0;
    public var endTime : Number = 0.0;
    private var m_dateHelper : Date = new Date();

    /**
     * 活动配置表
     */
    private var _activityTable : IDataTable;
    /**
     * 宝箱配置表
     */
    private var _activityTreasureBoxTable : IDataTable;
    /**
     * 苦无获取任务途径配置表
     */
    private var _activityTreasureTaskTable : IDataTable;
    /**
     * 苦无射中奖励配置表
     */
    private var _activityTreasureRepositoryTable : IDataTable;

    /**
     * 当前苦无数量
     */
    public var dartsNum : int = 0;
    /**
     * 当前苦无板子状态数组。数组一共16个元素，每个元素都为一个CDartsPointData
     */
    public var dartsBoardStateArr : Array = [];
    /**
     * 宝箱数组，数组中每个元素都为一个CTreasureBoxData
     */
    public var treasureBoxArr : Array = [];
    /**
     * 横向宝箱数组，数组中每个元素都为一个CTreasureBoxData，取值于treasureBoxArr前四项
     */
    private var hTreasureBoxArr : Array;
    /**
     * 纵向宝箱数组，数组中每个元素都为一个CTreasureBoxData，取值于treasureBoxArr后四项
     */
    private var vTreasureBoxArr : Array;
    /**
     * 任务数组，数组中每个元素都为一个CActivityTreasureTaskData
     */
    public var taskDataArr : Array = [];

    private var m_pValidater : CActivityTreasureValidater;

    private var m_pTrigger : CActivityTreasureTrigger;

    public function CActivityTreasureManager() {
        super();
    }

    public override function dispose() : void {
        super.dispose();
        m_pTrigger.dispose();
        m_pValidater.dispose();
    }

    protected override function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        _activityTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.ACTIVITY );
        _activityTreasureBoxTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.ACTIVITY_TREASURE_BOX );
        _activityTreasureTaskTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.ACTIVITY_TREASURE_TASK );
        _activityTreasureRepositoryTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.ACTIVITY_TREASURE_REPOSITORY );

        //苦无靶子初始化
        for ( var k : int = 1; k <= 16; k++ ) {
            dartsBoardStateArr.push( new CDartsPointData( k ) );
        }

        //福袋初始化
        var tempArr : Array = _activityTreasureBoxTable.toArray();
        for ( var i : int = 0; i < tempArr.length; i++ ) {
            var activityTreasureBox : ActivityTreasureBox = tempArr[ i ] as ActivityTreasureBox;
            treasureBoxArr.push( new CTreasureBoxData( activityTreasureBox.ID ) );
        }

        //任务数据初始化
        var tempArr2 : Array = _activityTreasureTaskTable.toArray();
        for ( var j : int = 0; j < tempArr2.length; j++ ) {
            var activityTreasureTask : ActivityTreasureTask = tempArr2[ j ] as ActivityTreasureTask;
            taskDataArr.push( new CActivityTreasureTaskData( activityTreasureTask.ID ) );
        }

        var switchingSystem : CSwitchingSystem = system.stage.getSystem( CSwitchingSystem ) as CSwitchingSystem;
        m_pValidater = new CActivityTreasureValidater( _system );
        switchingSystem.addValidator( m_pValidater );
        m_pTrigger = new CActivityTreasureTrigger();
        switchingSystem.addTrigger( m_pTrigger );

        closeActivity();//活动开放才开启

        return ret;
    }

    public function openActivity() : void {
//        m_pValidater.valid = true;
//        m_pTrigger.notifyUpdated();
//        _system.openSystem();

        if((system.stage.getSystem(CSwitchingSystem) as CSwitchingSystem).isSystemOpen(KOFSysTags.ACTIVITY_TREASURE))
        {
            return;
        }

        m_pValidater.valid = true;
//        m_pTrigger.notifyUpdated();

        var pValidators : CSwitchingValidatorSeq = system.getHandler( CSwitchingValidatorSeq ) as CSwitchingValidatorSeq;
        if ( pValidators )
        {
            if ( pValidators.evaluate() )// 验证所有开启条件是否已达成
            {
                var vResult : Vector.<String> = pValidators.listResultAsTags();
                if ( vResult && vResult.length )
                {
                    if(vResult.indexOf(KOFSysTags.ACTIVITY_TREASURE) != -1)
                    {
                        var pSystemBundleContext : ISystemBundleContext = system.stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
                        if ( pSystemBundleContext ) {
                            pSystemBundleContext.startBundle( system as ISystemBundle );
                        }
                    }
                }
            }
        }
    }

    public function closeActivity() : void {
        m_pValidater.valid = false;
        m_pTrigger.notifyUpdated();
        _system.closeSystem();
    }

    public function getVTreasureBoxArr() : Array {
        if ( !hTreasureBoxArr ) {
            hTreasureBoxArr = [];
        }
        hTreasureBoxArr.splice( 0 );
        if ( treasureBoxArr && treasureBoxArr.length >= 8 ) {
            hTreasureBoxArr.push( treasureBoxArr[ 0 ], treasureBoxArr[ 1 ], treasureBoxArr[ 2 ], treasureBoxArr[ 3 ] );
        }
        return hTreasureBoxArr;
    }

    public function getHTreasureBoxArr() : Array {
        if ( !vTreasureBoxArr ) {
            vTreasureBoxArr = [];
        }
        vTreasureBoxArr.splice( 0 );
        if ( treasureBoxArr && treasureBoxArr.length >= 8 ) {
            vTreasureBoxArr.push( treasureBoxArr[ 4 ], treasureBoxArr[ 5 ], treasureBoxArr[ 6 ], treasureBoxArr[ 7 ] );
        }
        return vTreasureBoxArr;
    }

    public function update( delta : Number ) : void {

    }

    /**
     * 根据指定的宝箱Id获取对应的宝箱配置信息
     * @param boxId
     * @return
     */
    public function getActivityTreasureBoxCfgInfoById( boxId : int ) : ActivityTreasureBox {
        return _activityTreasureBoxTable.findByPrimaryKey( boxId ) as ActivityTreasureBox;
    }

    /**
     * 根据指定的任务Id获取对应的任务配置信息
     * @param taskId
     * @return
     */
    public function getActivityTreasureTaskCfgInfoById( taskId : int ) : ActivityTreasureTask {
        return _activityTreasureTaskTable.findByPrimaryKey( taskId ) as ActivityTreasureTask;
    }

    /**
     * 根据指定的奖励Id获取对应的任务配置信息
     * @param rewardId
     * @return
     */
    public function getActivityTreasureRepositoryCfgInfoById( rewardId : int ) : ActivityTreasureRepository {
        return _activityTreasureRepositoryTable.findByPrimaryKey( rewardId ) as ActivityTreasureRepository;
    }

    public function getActivityTreasureRepositoryTable() : IDataTable {
        return _activityTreasureRepositoryTable;
    }

    public function getActivityTreasureBoxTable() : IDataTable {
        return _activityTreasureBoxTable;
    }

    public function getActivityTreasureTaskTable() : IDataTable {
        return _activityTreasureTaskTable;
    }

    public function getActivityType( activityId : int ) : int {
        var activityConfig : Activity = getActivity( activityId );
        if ( activityConfig ) {
            return activityConfig.type;
        }
        else {
            return 0;
        }
    }

    public function getActivity( activityId : int ) : Activity {
        return _activityTable.findByPrimaryKey( activityId ) as Activity;
    }

    public function getMonthDateTimeByTime( time : Number ) : String {
        m_dateHelper.setTime( time );
        return "#1月#2日#3时".replace( "#1", m_dateHelper.month + 1 ).replace( "#2", m_dateHelper.date ).replace( "#3", m_dateHelper.hours );
    }

    private function get _system() : CActivityTreasureSystem {
        return system as CActivityTreasureSystem;
    }
}
}
