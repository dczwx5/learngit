//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2018/1/4.
 */
package kof.game.rechargerebate {

import kof.SYSTEM_ID;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.activityHall.CActivityHallDataManager;
import kof.game.activityHall.CActivityHallSystem;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.CSystemBundleContext;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.lobby.CLobbySystem;
import kof.game.lobby.view.CPlayerHeadViewHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.event.CPlayerEvent;

import morn.core.handlers.Handler;

public class CRechargeRebateSystem extends CBundleSystem {

    private var m_bInitialized : Boolean;

    private var _pRechargeRebateManager : CRechargeRebateManager;
    private var _pRechargeRebateHandler : CRechargeRebateHandler;
    private var _pRechargeRebateViewHandler : CRechargeRebateViewHandler;


    public function CRechargeRebateSystem( A_objBundleID : * = null ) {
        super( A_objBundleID );
    }

    override public function dispose() : void {
        super.dispose();

        removeEventListener( CRechargeRebateEvent.RECHARGE_REBATE_INFO_RESPONSE ,_onDataRespone );
        removeEventListener( CRechargeRebateEvent.RECEIVE_REBATE_REWARD_RESPONSE ,_onDataRespone );
        _playerSystem.removeEventListener( CPlayerEvent.PLAYER_ORIGIN_CURRENCY ,_updateData );

        _pRechargeRebateManager.dispose();
        _pRechargeRebateHandler.dispose();
        _pRechargeRebateViewHandler.dispose();
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        if ( !m_bInitialized ) {
            m_bInitialized = true;

            addEventListener( CRechargeRebateEvent.RECHARGE_REBATE_INFO_RESPONSE ,_onDataRespone );
            addEventListener( CRechargeRebateEvent.RECEIVE_REBATE_REWARD_RESPONSE ,_onDataRespone );
            _playerSystem.addEventListener( CPlayerEvent.PLAYER_ORIGIN_CURRENCY ,_updateData );

            this.addBean( _pRechargeRebateManager = new CRechargeRebateManager() );
            this.addBean( _pRechargeRebateHandler = new CRechargeRebateHandler() );
            this.addBean( _pRechargeRebateViewHandler = new CRechargeRebateViewHandler() );

        }

        _pRechargeRebateViewHandler.closeHandler = new Handler( _onViewClosed );

        return m_bInitialized;
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.RECHARGEREBATE );
    }

    override protected function onBundleStart( pCtx : ISystemBundleContext ) : void {
        super.onBundleStart( pCtx );
        if(_activityManager)
            _activityManager.checkHavePreviewData();
    }
    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pView : CRechargeRebateViewHandler = this.getHandler( CRechargeRebateViewHandler ) as CRechargeRebateViewHandler;
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
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.RECHARGEREBATE );
        if( _pRechargeRebateManager.receiveRebateRecord.length >=  pTable.toArray().length ) {
            this.ctx.unregisterSystemBundle( this );
            //用于收集活动开启预览数据
            var args : Object = new Object();
            args.sysID = bundleID;
            args.state = 2;
            args.endTime = 0;
            if(_activityManager)
            {
                _activityManager.updatePreviewDic(args);
                _activityManager.checkHavePreviewData();
            }
            if( _pPlayerHeadViewHandler && _pPlayerHeadViewHandler.viewUI )
                _pPlayerHeadViewHandler.viewUI.btn_rechargeRebate.visible = false;
        }
    }

    private function _updateData( evt : CPlayerEvent ):void {
        _pRechargeRebateManager.fristFlg = true;
        _pRechargeRebateHandler.onRechargeRebateInfoRequest();
    }
    //小红点
    private function _onRedPoint( ):void{
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleContext)
        {
            pSystemBundleContext.setUserData(this,CBundleSystem.NOTIFICATION, _pRechargeRebateManager.isCanGetAward() );

        }
    }

    private function _onDataRespone( evt : CRechargeRebateEvent = null ):void {
        var bundleCtx : ISystemBundleContext = stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var iStateValue : int = bundleCtx.getSystemBundleState( bundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.RECHARGEREBATE ) ) );
        var bundle : ISystemBundle;
        if( iStateValue == CSystemBundleContext.STATE_STOPPED ){
            var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.RECHARGEREBATE );
            if( _pRechargeRebateManager.receiveRebateRecord.length >=  pTable.toArray().length ) {
                if( null == _pRechargeRebateViewHandler.rechargeRebateUI || null == _pRechargeRebateViewHandler.rechargeRebateUI.parent )
                    this.ctx.unregisterSystemBundle( this );//在界面打开的情况下，这里先不要关闭，否则出问题
                if( _pPlayerHeadViewHandler && _pPlayerHeadViewHandler.viewUI )
                    _pPlayerHeadViewHandler.viewUI.btn_rechargeRebate.visible = false;
            }else{
                _onRedPoint();
            }
        }else{
            _onRedPoint();
        }
    }

    private function get _pCDatabaseSystem():CDatabaseSystem{
        return stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    private function get _playerSystem() : CPlayerSystem {
        return stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }

    private function get _pPlayerHeadViewHandler():CPlayerHeadViewHandler{
        return _pLobbySystem.getBean(CPlayerHeadViewHandler) as CPlayerHeadViewHandler;
    }
    private function get _pLobbySystem() : CLobbySystem {
        return stage.getSystem( CLobbySystem ) as CLobbySystem;
    }
    private function get _activityManager() : CActivityHallDataManager
    {
        var _activitySystem : CActivityHallSystem = stage.getSystem(CActivityHallSystem) as CActivityHallSystem;
        if(!_activitySystem) return null;
        return _activitySystem.getBean(CActivityHallDataManager) as CActivityHallDataManager;
    }
}
}
