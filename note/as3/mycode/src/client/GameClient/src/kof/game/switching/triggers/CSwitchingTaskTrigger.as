//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.switching.triggers {

import QFLib.Foundation;

import flash.events.Event;

import kof.framework.events.CEventPriority;
import kof.game.switching.ISwitchingTrigger;
import kof.game.task.CTaskEvent;
import kof.game.task.CTaskSystem;

/**
 * 任务触发
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CSwitchingTaskTrigger extends CAbstractSwitchingTrigger implements ISwitchingTrigger {

    public function CSwitchingTaskTrigger() {
        super();
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        var pTaskSys : CTaskSystem = m_pSystemRef.stage.getSystem( CTaskSystem ) as CTaskSystem;
        if ( !pTaskSys ) {
            Foundation.Log.logWarningMsg( "CSwitchingTaskTrigger need CTaskSystem!!!" );
            return false;
        }

        pTaskSys.addEventListener( CTaskEvent.TASK_INIT, _taskSys_onTaskInitEventHandler, false, CEventPriority.DEFAULT, true );
        pTaskSys.addEventListener( CTaskEvent.TASK_FINISH, _taskSys_onTaskFinishedEventHandler, false, CEventPriority.DEFAULT, true );
        pTaskSys.addEventListener( CTaskEvent.TASK_ADD, _taskSys_onTaskAddEventHandler, false, CEventPriority.DEFAULT, true );

        return true;
    }

    /** @private */
    private function _taskSys_onTaskInitEventHandler( event : CTaskEvent ) : void {
        event.currentTarget.removeEventListener( event.type, _taskSys_onTaskInitEventHandler );
        var evt : CSwitchingTriggerEvent = new CSwitchingTriggerEvent( CSwitchingTriggerBridge.EVENT_TRIGGERED );
        evt.isInitPhase = true;
        notifier.dispatchEvent( evt );
    }

    /** @private */
    private function _taskSys_onTaskFinishedEventHandler( event : CTaskEvent ) : void {
        var evt : CSwitchingTriggerEvent = new CSwitchingTriggerEvent( CSwitchingTriggerBridge.EVENT_TRIGGERED );
        notifier.dispatchEvent( evt );
    }

    /** @private */
    private function _taskSys_onTaskAddEventHandler( event : CTaskEvent ) : void {
        if ( event.data && 'plotTask' in event.data && event.data['plotTask'] ) {
            var evt : CSwitchingTriggerEvent = new CSwitchingTriggerEvent( CSwitchingTriggerBridge.EVENT_TRIGGERED );
            notifier.dispatchEvent( evt );
        }
    }

}
}

// vim:ft=as3 tw=120 sw=4 ts=4 expandtab
