//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2018/1/3.
 */
package kof.game.invest {

import kof.SYSTEM_ID;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.activityHall.CActivityHallDataManager;
import kof.game.activityHall.CActivityHallSystem;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.event.CPlayerEvent;
import kof.table.InvestConst;

import morn.core.handlers.Handler;

public class CInvestSystem extends CBundleSystem {

    private var m_bInitialized : Boolean;

    private var _pInvestManager : CInvestManager;
    private var _pInvestHandler : CInvestHandler;
    private var _pInvestViewHandler : CInvestViewHandler;


    public function CInvestSystem( A_objBundleID : * = null ) {
        super( A_objBundleID );
    }

    override public function dispose() : void {
        super.dispose();

        removeEventListener( CInvestEvent.INVEST_INIT_DATA_RESPONSE ,_onDataRespone );
        removeEventListener( CInvestEvent.INVEST_GET_AWARD_RESPONSE ,_onDataRespone );
        removeEventListener( CInvestEvent.INVEST_DATA_RESPONSE ,_onDataRespone );
        _playerSystem.removeEventListener( CPlayerEvent.PLAYER_TEAM ,_updateData );

        _pInvestManager.dispose();
        _pInvestHandler.dispose();
        _pInvestViewHandler.dispose();
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        if ( !m_bInitialized ) {
            m_bInitialized = true;

            addEventListener( CInvestEvent.INVEST_INIT_DATA_RESPONSE ,_onDataRespone );
            addEventListener( CInvestEvent.INVEST_GET_AWARD_RESPONSE ,_onDataRespone );
            addEventListener( CInvestEvent.INVEST_DATA_RESPONSE ,_onDataRespone );
            _playerSystem.addEventListener( CPlayerEvent.PLAYER_TEAM ,_updateData );

            this.addBean( _pInvestManager = new CInvestManager() );
            this.addBean( _pInvestHandler = new CInvestHandler() );
            this.addBean( _pInvestViewHandler = new CInvestViewHandler() );

            _pInvestViewHandler.closeHandler = new Handler( _onViewClosed );

        }


        return m_bInitialized;
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.INVEST );
    }


    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pView : CInvestViewHandler = this.getHandler( CInvestViewHandler ) as CInvestViewHandler;
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

        var pTable : IDataTable;
        pTable = _pCDatabaseSystem.getTable( KOFTableConstants.INVESTCONST );
        var investConst : InvestConst = pTable.findByPrimaryKey( 1 );
        if( _pInvestManager.m_hasPut == false && _playerData.teamData.level > investConst.levelLimit ){
            this.ctx.unregisterSystemBundle( this );
        }else if( _pInvestManager.m_hasPut ){
            pTable = _pCDatabaseSystem.getTable( KOFTableConstants.INVESTREWARDCONFIG );
            if( _pInvestManager.m_infos.length >= pTable.toArray().length ){
                this.ctx.unregisterSystemBundle( this );
            }
        }
    }

    private function _updateData( evt : CPlayerEvent ):void {
        _onDataRespone();
    }

    //小红点
    private function _onRedPoint( ):void{
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleContext)
        {
            pSystemBundleContext.setUserData(this,CBundleSystem.NOTIFICATION, _pInvestManager.isCanGetAward() );

        }
    }

    //活动过期，或者全部领奖，就关闭
    private function _onDataRespone( evt : CInvestEvent = null ):void{
        _onRedPoint();
        if( !_pInvestViewHandler.investUI || ( _pInvestViewHandler.investUI && !_pInvestViewHandler.investUI.parent ) ){
            var pTable : IDataTable;
            pTable = _pCDatabaseSystem.getTable( KOFTableConstants.INVESTCONST );
            var investConst : InvestConst = pTable.findByPrimaryKey( 1 );
            if(  _pInvestManager.m_hasPut == false && _playerData.teamData.level > investConst.levelLimit ){
                this.ctx.unregisterSystemBundle( this );
                updatePreviewActivity();
            }else if( _pInvestManager.m_hasPut ){
                pTable = _pCDatabaseSystem.getTable( KOFTableConstants.INVESTREWARDCONFIG );
                if( _pInvestManager.m_infos.length >= pTable.toArray().length ){
                    this.ctx.unregisterSystemBundle( this );
                    updatePreviewActivity();
                }
            }
        }
    }
    private function updatePreviewActivity() : void
    {
        var args : Object = new Object();
        args.sysID = bundleID;
        args.endTime = 0;
        args.state = 2;
        if(_activityManager)
        {
            _activityManager.updatePreviewDic(args);
            _activityManager.checkHavePreviewData();
        }
    }
    private function get _pCDatabaseSystem():CDatabaseSystem{
        return stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _playerSystem() : CPlayerSystem {
        return stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _activityManager() : CActivityHallDataManager
    {
        var _activitySystem : CActivityHallSystem = stage.getSystem(CActivityHallSystem) as CActivityHallSystem;
        if(!_activitySystem) return null;
        return _activitySystem.getBean(CActivityHallDataManager) as CActivityHallDataManager;
    }
}
}
