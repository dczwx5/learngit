//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/19.
 */
package kof.game.taskcallup {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.systemnotice.CSystemNoticeConst;
import kof.game.systemnotice.CSystemNoticeSystem;
import kof.game.taskcallup.view.CTaskCallUpInfoViewHandler;
import kof.game.taskcallup.view.CTaskCallUpLoveViewHandler;
import kof.game.taskcallup.view.CTaskCallUpSetViewHandler;
import kof.game.taskcallup.view.CTaskCallUpTeamViewHandler;
import kof.game.taskcallup.view.CTaskCallUpViewHandler;

import morn.core.handlers.Handler;

public class CTaskCallUpSystem extends CBundleSystem {

    private var m_bInitialized : Boolean;

    private var _pTaskCallUpManager : CTaskCallUpManager;

    private var _pTaskCallUpHandler : CTaskCallUpHandler;

    private var _pTaskCallUpViewHandler : CTaskCallUpViewHandler;

    private var _pTaskCallUpInfoViewHandler : CTaskCallUpInfoViewHandler;

    private var _pTaskCallUpSetViewHandler : CTaskCallUpSetViewHandler;

    private var _pTaskCallUpLoveViewHandler : CTaskCallUpLoveViewHandler;

    private var _pTaskCallUpTeamViewHandler : CTaskCallUpTeamViewHandler;

    public function CTaskCallUpSystem( A_objBundleID : * = null ) {
        super( A_objBundleID );
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        if ( !m_bInitialized ) {
            m_bInitialized = true;

            this.addBean( _pTaskCallUpManager = new CTaskCallUpManager() );
            this.addBean( _pTaskCallUpHandler = new CTaskCallUpHandler() );
            this.addBean( _pTaskCallUpViewHandler = new CTaskCallUpViewHandler() );
            this.addBean( _pTaskCallUpInfoViewHandler = new CTaskCallUpInfoViewHandler() );
            this.addBean( _pTaskCallUpSetViewHandler = new CTaskCallUpSetViewHandler() );
            this.addBean( _pTaskCallUpLoveViewHandler = new CTaskCallUpLoveViewHandler() );
            this.addBean( _pTaskCallUpTeamViewHandler = new CTaskCallUpTeamViewHandler() );

        }

        _pTaskCallUpViewHandler.closeHandler = new Handler( _onViewClosed );

        addEventListener( CTaskCallUpEvent.TASK_CALL_UP_UPDATE ,_onRedPoint );
        addEventListener( CTaskCallUpEvent.TASK_CALL_UP_REFRESH ,_onRedPoint );
        addEventListener( CTaskCallUpEvent.TASK_CALL_UP_CAN_REWARD ,_onRedPoint );

        return m_bInitialized;
    }

    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pView : CTaskCallUpViewHandler = this.getHandler( CTaskCallUpViewHandler ) as CTaskCallUpViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CRankingViewHandler isn't instance." );
            return;
        }

        if ( value ) {
            pView.addDisplay();
            _pSystemNoticeSystem.hideIcon( CSystemNoticeConst.SYSTEM_TASKCALLUP );
        } else {
            pView.removeDisplay();
            onSystemNotice();
            removeAllView();
        }

    }

    override protected function onBundleStart(ctx:ISystemBundleContext):void
    {
        super.onBundleStart(ctx);

        _onRedPoint();

    }
    //小红点
    private function _onRedPoint( evt : CTaskCallUpEvent = null ):void{

        var show : Boolean;
        show = evt && evt.type == CTaskCallUpEvent.TASK_CALL_UP_CAN_REWARD ;
        onSystemNotice( show );

        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleContext)
        {
            pSystemBundleContext.setUserData(this,CBundleSystem.NOTIFICATION, _pTaskCallUpManager.canAwardNum > 0 || show );

        }
    }

    public function onSystemNotice( show : Boolean = false ):void{
        //通知小图标
        if( _pTaskCallUpManager.canAwardNum > 0 || show ){
            var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
            if ( pSystemBundleContext)
            {
                var pSystemBundle : ISystemBundle = pSystemBundleContext.getSystemBundle( SYSTEM_ID( KOFSysTags.SYSTEM_NOTICE ) );
                pSystemBundleContext.setUserData( pSystemBundle, CBundleSystem.NOTICE_ARGS,[CSystemNoticeConst.SYSTEM_TASKCALLUP]);
                pSystemBundleContext.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, true );
            }
        }else{
            _pSystemNoticeSystem.hideIcon( CSystemNoticeConst.SYSTEM_TASKCALLUP );
        }
    }

    private function _onViewClosed() : void {
        this.setActivated( false );
    }
    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.TASKCALLUP );
    }
    public function removeAllView() : void {
        _pTaskCallUpViewHandler.removeDisplay();
        _pTaskCallUpInfoViewHandler.removeDisplay();
        _pTaskCallUpSetViewHandler.removeDisplay();
        _pTaskCallUpLoveViewHandler.removeDisplay();
        _pTaskCallUpTeamViewHandler.removeDisplay();
    }
    public override function dispose() : void {
        super.dispose();

        _pTaskCallUpManager.dispose();
        _pTaskCallUpHandler.dispose();
        _pTaskCallUpViewHandler.dispose();
        _pTaskCallUpInfoViewHandler.dispose();
        _pTaskCallUpSetViewHandler.dispose();
        _pTaskCallUpLoveViewHandler.dispose();
        _pTaskCallUpTeamViewHandler.dispose();

        removeEventListener( CTaskCallUpEvent.TASK_CALL_UP_UPDATE ,_onRedPoint );
        removeEventListener( CTaskCallUpEvent.TASK_CALL_UP_REFRESH ,_onRedPoint );
        removeEventListener( CTaskCallUpEvent.TASK_CALL_UP_CAN_REWARD ,_onRedPoint );

    }
    private function get _pSystemNoticeSystem():CSystemNoticeSystem{
        return stage.getSystem( CSystemNoticeSystem ) as CSystemNoticeSystem
    }
}
}
