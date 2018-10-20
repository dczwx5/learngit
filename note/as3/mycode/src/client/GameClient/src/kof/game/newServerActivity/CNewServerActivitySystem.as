//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Edison.Weng on 2017/7/25.
 */
package kof.game.newServerActivity {

import QFLib.Foundation.CTime;

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.gameSetting.CGameSettingData;
import kof.game.gameSetting.CGameSettingNetHandler;
import kof.game.gameSetting.CGameSettingSystem;
import kof.game.newServerActivity.event.CNewServerActivityEvent;
import kof.game.newServerActivity.view.CNewServerActivityRankMenuHandler;
import kof.game.newServerActivity.view.CNewServerActivityViewHandler;
import kof.table.SystemIDs;
import kof.ui.master.arena.ArenaAnimationWinUI;

import morn.core.handlers.Handler;

/**
 * 新服活动
 * */
public class CNewServerActivitySystem extends CBundleSystem implements ISystemBundle {

    private var m_bInitialized : Boolean;

    private var m_pNewServerActivityViewHandler : CNewServerActivityViewHandler;
    private var m_pNewServerActivityManager : CNewServerActivityManager;
    private var m_pNewServerActivityHandler : CNewServerActivityHandler;
    private var m_pNewServerActivityRankMenuHandler : CNewServerActivityRankMenuHandler;

    public function CNewServerActivitySystem() {
        super();
    }

    override public function dispose() : void
    {
        super.dispose();

        m_pNewServerActivityViewHandler.dispose();
        m_pNewServerActivityViewHandler = null;

        m_pNewServerActivityManager.dispose();
        m_pNewServerActivityManager = null;

        m_pNewServerActivityHandler.dispose();
        m_pNewServerActivityHandler = null;

        m_pNewServerActivityRankMenuHandler.dispose();
        m_pNewServerActivityRankMenuHandler = null;

        _removeEventListener();
    }

    override public function initialize() : Boolean
    {
        if( !super.initialize() )
            return false;

        if( !m_bInitialized )
        {
            m_bInitialized = true;

            m_pNewServerActivityViewHandler = new CNewServerActivityViewHandler();
            this.addBean( m_pNewServerActivityViewHandler );

            m_pNewServerActivityManager = new CNewServerActivityManager();
            this.addBean( m_pNewServerActivityManager );

            m_pNewServerActivityHandler = new CNewServerActivityHandler();
            this.addBean( m_pNewServerActivityHandler );

            m_pNewServerActivityRankMenuHandler = new CNewServerActivityRankMenuHandler();
            this.addBean( m_pNewServerActivityRankMenuHandler );
        }

        m_pNewServerActivityViewHandler.closeHandler = new Handler( _onViewClosed );

        return m_bInitialized;
    }

    override public function get bundleID() : *
    {
        return SYSTEM_ID( KOFSysTags.NEW_SERVER_ACTIVITY );
    }

    override protected function onActivated( value : Boolean) : void
    {
        super.onActivated( value );

        var pView : CNewServerActivityViewHandler = this.getHandler( CNewServerActivityViewHandler ) as CNewServerActivityViewHandler;

        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CNewServerActivityViewHandler isn't instance." );
            return;
        }

        if ( value ) {
            pView.addDisplay();
        } else {
            pView.removeDisplay();
        }
    }

    protected function _addEventListener() : void
    {
        this.addEventListener( CNewServerActivityEvent.NEW_SERVER_ACTIVITY_TIPS_UPDATE , _updateNewServerActivityRedPoint );
        this.addEventListener( CNewServerActivityEvent.NEWSERVERRANKACTIVITYSTATERESPONSE , _updateNewServerActivityState );
        this.addEventListener( CNewServerActivityEvent.NEW_SERVER_ACTIVITY_DAY_UPDATE , _refreshActivityState );
    }

    protected function _removeEventListener() : void
    {
        this.removeEventListener( CNewServerActivityEvent.NEW_SERVER_ACTIVITY_TIPS_UPDATE , _updateNewServerActivityRedPoint );
        this.removeEventListener( CNewServerActivityEvent.NEWSERVERRANKACTIVITYSTATERESPONSE , _updateNewServerActivityState );
        this.removeEventListener( CNewServerActivityEvent.NEW_SERVER_ACTIVITY_DAY_UPDATE , _refreshActivityState );
    }

    override protected function onBundleStart( ctx : ISystemBundleContext ) : void
    {
        super.onBundleStart( ctx );

        _updateNewServerActivityRedPoint( null );
        _addEventListener();

    }

    private function _updateNewServerActivityRedPoint( e : CNewServerActivityEvent = null ) : void
    {
        // 登陆时主界面图标提示
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        var pSystemBundle : ISystemBundle = pSystemBundleContext.getSystemBundle( SYSTEM_ID( "NEW_SERVER_ACTIVITY" ) );
        if ( pSystemBundleContext && pSystemBundle )
        {

            var gameSettingData:CGameSettingData = _gameSettingSystem.gameSettingData;
            var redPointAry : Array = gameSettingData[CGameSettingData.NewServerActivity ];
            if( redPointAry[ m_pNewServerActivityManager.openSeverDays - 1]  && redPointAry[ m_pNewServerActivityManager.openSeverDays - 1] == true ){
                pSystemBundleContext.setUserData( this,CBundleSystem.NOTIFICATION , false );
            }else{
                pSystemBundleContext.setUserData( this,CBundleSystem.NOTIFICATION , true );
            }

        }
    }
    public function setRedPoint():void{
        var gameSettingData:CGameSettingData = _gameSettingSystem.gameSettingData;
        var redPointAry : Array = gameSettingData[CGameSettingData.NewServerActivity ];
        if(  redPointAry[ m_pNewServerActivityManager.openSeverDays - 1]  && redPointAry[ m_pNewServerActivityManager.openSeverDays - 1] == true ){
            return;
        }

        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        var pSystemBundle : ISystemBundle = pSystemBundleContext.getSystemBundle( SYSTEM_ID( "NEW_SERVER_ACTIVITY" ) );
        if ( pSystemBundleContext && pSystemBundle )
        {
            pSystemBundleContext.setUserData( this,CBundleSystem.NOTIFICATION , false );
        }

        var obj:Object = {};
        var ary : Array = [];
        ary[ m_pNewServerActivityManager.openSeverDays - 1 ] = true;
        obj[CGameSettingData.NewServerActivity] = ary;
        gameSettingData[CGameSettingData.NewServerActivity ] = ary;
        _gameSettingNetHandler.setGameSettingRequest(obj);
    }

    private function _updateNewServerActivityState( evt : CNewServerActivityEvent ):void{
        if( m_pNewServerActivityManager.m_allFinishFlg && ( null == m_pNewServerActivityViewHandler.newServerActivityUI || null == m_pNewServerActivityViewHandler.newServerActivityUI.parent ) ){
            this.ctx.unregisterSystemBundle( this );
        }
    }
    private function _refreshActivityState( evt : CNewServerActivityEvent ):void{
        if( null == m_pNewServerActivityViewHandler.newServerActivityUI || null == m_pNewServerActivityViewHandler.newServerActivityUI.parent ){
            var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
            var pSystemBundle : ISystemBundle = pSystemBundleContext.getSystemBundle( SYSTEM_ID( "NEW_SERVER_ACTIVITY" ) );
            if ( pSystemBundleContext && pSystemBundle )
            {
                pSystemBundleContext.setUserData( this,CBundleSystem.NOTIFICATION , true );
            }
        }
    }
    private function _onViewClosed() : void
    {
        this.setActivated( false );
        if( m_pNewServerActivityManager.m_allFinishFlg ){
            this.ctx.unregisterSystemBundle( this );
        }
    }

    /**
     * 设置系统状态
     */
    public function changeActivityState( bool:Boolean ) : void {
        if(bool)
        {
            this.ctx.startBundle(this);
        }
        else
        {
            if(m_pNewServerActivityViewHandler)
                m_pNewServerActivityViewHandler.removeDisplay();//如果界面开着，就强制关掉
            //this.ctx.stopBundle(this);
            this.ctx.unregisterSystemBundle( this );
        }
    }

    /**
     * 判断是否选择的是第一天的活动
     * **/
    public function isSelectFirstActivity() : Boolean
    {
        var isSelectFirstActivity : Boolean = false;
        if( m_pNewServerActivityViewHandler.selectActivity == 1 )
        {
            isSelectFirstActivity = true;
        }
        return isSelectFirstActivity;
    }
    private function get _gameSettingSystem():CGameSettingSystem{
        return stage.getSystem( CGameSettingSystem ) as CGameSettingSystem;
    }
    private function get _gameSettingNetHandler():CGameSettingNetHandler{
        return _gameSettingSystem.getHandler( CGameSettingNetHandler ) as CGameSettingNetHandler;
    }
}
}
