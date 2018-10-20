//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/1/10.
 */
package kof.game.task {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundleContext;
import kof.game.player.CPlayerSystem;
import kof.game.player.event.CPlayerEvent;
import kof.game.task.data.CTaskData;

import morn.core.handlers.Handler;

public class CTaskSystem  extends CBundleSystem  {

    private var m_bInitialized : Boolean;

    private var _pCTaskManager : CTaskManager;
    private var _pTaskHandler : CTaskHandler;
    private var _pTaskViewHandler : CTaskViewHandler;
    private var _pTaskActiveItemTipsHandler : CTaskActiveItemTipsHandler;
    private var _pTaskJumpViewHandler : CTaskJumpViewHandler;


    public function CTaskSystem() {
        super();
    }

    public override function dispose() : void {
        super.dispose();

        _pCTaskManager.dispose();
        _pTaskHandler.dispose();
        _pTaskViewHandler.dispose();
        _pTaskActiveItemTipsHandler.dispose();
        _pTaskJumpViewHandler.dispose();

    }
    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        if ( !m_bInitialized ) {
            m_bInitialized = true;

            this.addBean( _pCTaskManager = new CTaskManager() );
            this.addBean( _pTaskHandler = new CTaskHandler() );
            this.addBean( _pTaskViewHandler = new CTaskViewHandler() );
            this.addBean( _pTaskActiveItemTipsHandler = new CTaskActiveItemTipsHandler() );
            this.addBean( _pTaskJumpViewHandler = new CTaskJumpViewHandler() );
        }

        _pTaskViewHandler.closeHandler = new Handler( _onViewClosed );

        addEventListener( CTaskEvent.TASK_INIT ,_onRedPoint );
        addEventListener( CTaskEvent.TASK_UPDATE ,_onRedPoint );
        addEventListener( CTaskEvent.DRAW_DAILY_TASK_ACTIVE_REWARD ,_onRedPoint );

        _playerSystem.addEventListener( CPlayerEvent.PLAYER_TASK ,_onPlayerDataHandler );


        return m_bInitialized;
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.TASK );
    }

    override protected function onBundleStart(ctx:ISystemBundleContext):void
    {
        super.onBundleStart(ctx);

        _onRedPoint();

    }
    private function _onPlayerDataHandler(e:CPlayerEvent):void{
        _onRedPoint();
    }

    //小红点
    private function _onRedPoint( evt : CTaskEvent  = null):void{
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleContext)
        {
            pSystemBundleContext.setUserData(this,CBundleSystem.NOTIFICATION,
                    _pCTaskManager.dailyTaskCanAwardNum > 0 || _pCTaskManager.longLineTaskCanAwardNum > 0 || _pCTaskManager.activeCanAwardNum > 0 );
        }
    }
    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pView : CTaskViewHandler = this.getHandler( CTaskViewHandler ) as CTaskViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CRankingViewHandler isn't instance." );
            return;
        }

        if ( value ) {
            pView.addDisplay();
        } else {
            pView.removeDisplay();
        }
    }

    private function _onViewClosed() : void {
        this.setActivated( false );
    }

    public function getTaskDataByTaskID( taskID : int ) : CTaskData{
        return _pCTaskManager.getTaskDataByTaskID( taskID );
    }
    public function getTaskStateByTaskID( taskID : int ) : int{
        return _pCTaskManager.getTaskStateByTaskID( taskID );
    }
    public function getTaskDatasByType( taskType : int ) : Array {
        return _pCTaskManager.getTaskDatasByType( taskType );
    }
    private function get _playerSystem() : CPlayerSystem {
        return stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _pMainTaskSystem() : CMainTaskSystem {
        return stage.getSystem( CMainTaskSystem ) as CMainTaskSystem;
    }

}
}
