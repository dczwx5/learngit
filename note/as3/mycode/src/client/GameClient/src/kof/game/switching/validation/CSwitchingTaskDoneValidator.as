//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.switching.validation {

import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.IDatabase;
import kof.game.task.CTaskSystem;
import kof.game.task.data.CTaskData;
import kof.game.task.data.CTaskStateType;
import kof.game.task.data.CTaskType;
import kof.table.BundleEnable;
import kof.table.PlotTask;

/**
 * 功能开启：任务完成验证器
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CSwitchingTaskDoneValidator implements ISwitchingValidation {

    /** @private */
    private var m_pSystemRef : CAppSystem;

    /** Creates a new CSwitchingTaskDoneValidator. */
    public function CSwitchingTaskDoneValidator( pSystemRef : CAppSystem ) {
        super();
        m_pSystemRef = pSystemRef;
    }

    public function dispose() : void {
        m_pSystemRef = null;
    }

    public function evaluate( ... args ) : Boolean {
        var pData : BundleEnable = args[ 0 ] as BundleEnable;
        if ( !pData )
            return true;

        var vStatusQuery : Array = args.length > 1 ? args[ 1 ] as Array : [];
        if ( vStatusQuery.length == 0 )
            vStatusQuery.push( 0 );

        var idTaskDone : int = pData.TaskDoneID;

        if ( idTaskDone == 0 ) {
            vStatusQuery[ 0 ] = -1;
            return true;
        }

        var pTaskSys : CTaskSystem = m_pSystemRef.stage.getSystem( CTaskSystem ) as CTaskSystem;
        if ( !pTaskSys )
            return true;

        vStatusQuery[ 0 ] = 0;
//        var pTaskList : Array = pTaskSys.getTaskDatasByType( CTaskType.PLOT_TASK );
//        if ( pTaskList.length == 0 )
//            return true;

        var state : int = pTaskSys.getTaskStateByTaskID( idTaskDone );
        return CTaskStateType.COMPLETE == state;
    }

    public function getLocaleDesc( pConfigData : Object ) : String {
        var pData : BundleEnable = pConfigData as BundleEnable;
        if ( !pData )
            return null;
        var sTaskDesc : String;

        var pTaskSys : CTaskSystem = m_pSystemRef.stage.getSystem( CTaskSystem ) as CTaskSystem;
        if ( pTaskSys ) {
            var pDatabase : IDatabase = m_pSystemRef.stage.getSystem( IDatabase ) as IDatabase;
            if ( pDatabase ) {
                var pTable : IDataTable = pDatabase.getTable( KOFTableConstants.PLOT_TASK );
                if ( pTable ) {
                    var pTask : PlotTask = pTable.findByPrimaryKey( pData.TaskDoneID );
                    if ( pTask ) {
                        sTaskDesc = pTask.trackRound;
                    }
                }
            }
        }

        if ( !sTaskDesc )
            sTaskDesc = pData.TaskDoneID.toString();
        return "完成主线任务<font color='{}'>" + sTaskDesc + "</font>";
    }

}
}
