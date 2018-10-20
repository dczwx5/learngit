//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/20.
 * 任务小助手
 *
 */
package kof.game.task {

import kof.SYSTEM_ID;
import kof.framework.events.CEventPriority;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.CSystemBundleContext;
import kof.game.bundle.CSystemBundleEvent;
import kof.game.bundle.ISystemBundleContext;
import kof.game.task.data.CTaskData;
import kof.game.task.track.CTaskTrackIIViewHandler;
import kof.game.task.track.CTaskTrackIViewHandler;
import kof.ui.master.peakpk.peakPKReceiveInviteUI;

import spine.Bone;

public class CMainTaskSystem extends CBundleSystem {
    private var m_bInitialized : Boolean;

    private var _pTaskTrackViewHandler : CTaskTrackViewHandler;
    private var _pDailyTaskTrackViewHandler : CDailyTaskTrackViewHandler;
    private var _pTaskTrackIViewHandler : CTaskTrackIViewHandler;
    private var _pTaskTrackIIViewHandler : CTaskTrackIIViewHandler;
    private var _pPlotTaskRewardViewHandler : CPlotTaskRewardViewHandler;
    private var _pPlotTaskDoneViewHandler : CPlotTaskDoneViewHandler;
    private var _pTaskRewardTipsView : CTaskRewardTipsView;

    public function CMainTaskSystem( A_objBundleID : * = null ) {
        super( A_objBundleID );
    }
    public override function dispose() : void {
        super.dispose();

        if ( _pTaskTrackViewHandler )
            _pTaskTrackViewHandler.dispose();
        if ( _pDailyTaskTrackViewHandler )
            _pDailyTaskTrackViewHandler.dispose();
        if( _pTaskTrackIViewHandler )
            _pTaskTrackIViewHandler.dispose();
        if( _pTaskTrackIIViewHandler )
            _pTaskTrackIIViewHandler.dispose();
        if( _pPlotTaskRewardViewHandler)
            _pPlotTaskRewardViewHandler.dispose();
        if( _pPlotTaskDoneViewHandler )
            _pPlotTaskDoneViewHandler.dispose();
        if( _pTaskRewardTipsView )
            _pTaskRewardTipsView.dispose();

    }
    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        var ret : Boolean = true;

        ret = ret && addBean(_pTaskTrackViewHandler = new CTaskTrackViewHandler( ));
        ret = ret && addBean(_pDailyTaskTrackViewHandler = new CDailyTaskTrackViewHandler( ));
        ret = ret && addBean(_pTaskTrackIViewHandler = new CTaskTrackIViewHandler( ));
        ret = ret && addBean(_pTaskTrackIIViewHandler = new CTaskTrackIIViewHandler());
        ret = ret && addBean(_pPlotTaskRewardViewHandler = new CPlotTaskRewardViewHandler());
        ret = ret && addBean(_pPlotTaskDoneViewHandler = new CPlotTaskDoneViewHandler());
        ret = ret && addBean(_pTaskRewardTipsView = new CTaskRewardTipsView());

//        _pCTaskSystem.addEventListener( CTaskEvent.PLOT_TASK_UPDATE, updateView );
//        _pCTaskSystem.addEventListener( CTaskEvent.TASK_INIT, updateView );
        _pCTaskSystem.addEventListener( CTaskEvent.TASK_UPDATE, updateDailyTaskView );
        _pCTaskSystem.addEventListener( CTaskEvent.TASK_INIT, updateDailyTaskView );

        var pSystemBundleCtx : ISystemBundleContext = stage.getSystem( ISystemBundleContext ) as
                ISystemBundleContext;
        if ( pSystemBundleCtx ) {
            pSystemBundleCtx.addEventListener( CSystemBundleEvent.BUNDLE_START, onSystemBundleStateChangedHandler, false,
                    CEventPriority.DEFAULT, true );
        }

        return ret;
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.MAIN_TASK );
    }
    override protected function onBundleStart( ctx : ISystemBundleContext ) : void {
        var pView : CTaskTrackViewHandler = this.getBean( CTaskTrackViewHandler );
        pView.loadAssetsByView( pView.viewClass );
    }

    public function onSystemBundleStateChangedHandler( event : CSystemBundleEvent = null ) : void {
        var bundleCtx : ISystemBundleContext = stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var iStateValue : int = bundleCtx.getSystemBundleState( bundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.TASK ) ) );
        if( iStateValue == CSystemBundleContext.STATE_STARTED ){
            updateDailyTaskView();
        }
    }


    private function _onViewClosed() : void {
        this.setActivated( false );
    }

//    public function updateView( evt : CTaskEvent ) : void {
//        _pTaskTrackViewHandler.updateView( );
//    }
    public function updateViewII( pTaskData:CTaskData ) : void {
        _pTaskTrackViewHandler.updateViewII( pTaskData );
    }
    public function updateDailyTaskView( evt : CTaskEvent = null ) : void {
        _pDailyTaskTrackViewHandler.addDisplay( );
    }

    private function get _pCTaskSystem(): CTaskSystem{
        return stage.getSystem( CTaskSystem ) as CTaskSystem ;
    }
}
}
