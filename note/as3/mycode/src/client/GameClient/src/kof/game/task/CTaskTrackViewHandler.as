//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/2/7.
 */
package kof.game.task {

import kof.framework.CViewHandler;
import kof.game.task.data.CTaskData;
import kof.game.task.data.CTaskType;
import kof.game.task.track.CTaskTrackIIViewHandler;
import kof.game.task.track.CTaskTrackIViewHandler;
import kof.ui.CUISystem;
import kof.ui.master.task.TaskTrackoneUI;

public class CTaskTrackViewHandler extends CViewHandler {

    private var m_taskTrackUI:TaskTrackoneUI;

    public function CTaskTrackViewHandler() {
        super( false );
    }

    override public function get viewClass() : Array {
        return [ TaskTrackoneUI];
    }
    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;
        if ( !m_taskTrackUI ) {
            m_taskTrackUI = new TaskTrackoneUI();
            m_taskTrackUI.btn_show.visible = false;
        }
        initialize();
        return Boolean( m_taskTrackUI );
    }


    protected function initialize() : void {
        updateView();
    }

    public function updateView( evt : CTaskEvent = null ) : void {
        var taskAry : Array = pCTaskManager.getTaskDatasByType( CTaskType.PLOT_TASK );
        //todo
        if( taskAry.length <= 0 ){
            m_taskTrackUI.remove();
            return;
        }
        _pTaskTrackIViewHandler.show( m_taskTrackUI, taskAry[ 0 ] );
    }
    private var _curTaskData : CTaskData;
    public function updateViewII( pTaskData:CTaskData ):void{
        _curTaskData = null;
        _curTaskData = pTaskData;
        if( _curTaskData.plotTask.ID == pCTaskManager.lastPoltTaskID ){
            m_taskTrackUI.remove();
            return;
        }
        onUpdateTaskView();
    }

    private function onUpdateTaskView():void{
        var pCTaskData : CTaskData = pCTaskManager.getPlotTaskFromDoneArray( _curTaskData.plotTask.nextTaskID );
        if( !pCTaskData ){
            callLater( onUpdateTaskView );
//            _pCUISystem.showMsgBox( '剧情任务ID ' + _curTaskData.plotTask.ID + ' 找不到nextTaskID ' );
        } else{
            _pTaskTrackIViewHandler.show( m_taskTrackUI, pCTaskData );
        }

    }

    public function awardInMainCity(evt : CTaskEvent ):void{

    }


    public override function dispose() : void {
        super.dispose();
    }

    private function get pCTaskManager() : CTaskManager {
        return _pCTaskSystem.getBean( CTaskManager ) as CTaskManager;
    }

    private function get _pTaskTrackIViewHandler() : CTaskTrackIViewHandler {
        return system.getBean( CTaskTrackIViewHandler ) as CTaskTrackIViewHandler;
    }

    private function get _pTaskTrackIIViewHandler() : CTaskTrackIIViewHandler {
        return system.getBean( CTaskTrackIIViewHandler ) as CTaskTrackIIViewHandler;
    }
    private function get _pCTaskSystem(): CTaskSystem{
        return system.stage.getSystem( CTaskSystem ) as CTaskSystem ;
    }
    private function get _pCUISystem():CUISystem{
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }
}
}
