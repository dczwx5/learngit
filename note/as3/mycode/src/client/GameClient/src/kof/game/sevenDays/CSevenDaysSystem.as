//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Edison.Weng on 2017/7/24.
 */
package kof.game.sevenDays {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.sevenDays.event.CSevenDaysEvent;
import kof.game.sevenDays.view.CSevenDaysViewHandler;

import morn.core.handlers.Handler;

/**
 * 七天登录
 * */
public class CSevenDaysSystem extends CBundleSystem implements ISystemBundle {

    private var m_bInitialized : Boolean;

    private var m_pSevenDaysViewHandler : CSevenDaysViewHandler;
    private var m_pSevenDaysHandler : CSevenDaysHandler;
    private var m_pSevenDaysManager : CSevenDaysManager;

    public function CSevenDaysSystem() {
        super();
    }

    override public function dispose() : void
    {
        super.dispose();

        m_pSevenDaysViewHandler.dispose();
        m_pSevenDaysViewHandler = null;

        m_pSevenDaysHandler.dispose();
        m_pSevenDaysHandler = null;

        m_pSevenDaysManager.dispose();
        m_pSevenDaysManager = null;

        _removeEventListeners();
    }

    override public function initialize() : Boolean
    {
        if( !super.initialize() )
            return false;

        if( !m_bInitialized )
        {
            m_bInitialized = true;

            m_pSevenDaysViewHandler = new CSevenDaysViewHandler()
            this.addBean( m_pSevenDaysViewHandler );

            m_pSevenDaysHandler = new CSevenDaysHandler()
            this.addBean( m_pSevenDaysHandler );

            m_pSevenDaysManager = new CSevenDaysManager();
            this.addBean( m_pSevenDaysManager );
        }

        m_pSevenDaysViewHandler.closeHandler = new Handler( _onViewClosed );

        //this._addEventListener();

        return m_bInitialized;
    }

    override public function get bundleID() : *
    {
        return SYSTEM_ID( KOFSysTags.SEVEN_DAYS );
    }

    /**
     * 系统开启
     * **/
    override protected function onBundleStart( ctx : ISystemBundleContext ) : void
    {
        super.onBundleStart( ctx );

        _updateSevenDaysRedPoint( null );
        _addEventListener();
    }

    protected function _addEventListener() : void
    {
        this.addEventListener( CSevenDaysEvent.SEVEN_DAYS_SEVER_UPDATE , _updateSevenDaysRedPoint );
        this.addEventListener( CSevenDaysEvent.SEVEN_DAYS_STATE_UPDATE , _updateSevenDaysRedPoint );
    }

    protected function _removeEventListeners() : void
    {
        this.removeEventListener( CSevenDaysEvent.SEVEN_DAYS_SEVER_UPDATE , _updateSevenDaysRedPoint );
        this.removeEventListener( CSevenDaysEvent.SEVEN_DAYS_STATE_UPDATE , _updateSevenDaysRedPoint );
    }

    private function _updateSevenDaysRedPoint( e : CSevenDaysEvent ) : void
    {
        // 主界面图标提示
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        var pSystemBundle : ISystemBundle = pSystemBundleContext.getSystemBundle( SYSTEM_ID( "SEVEN_DAYS" ) );
        if ( pSystemBundleContext && pSystemBundle)
        {
            pSystemBundleContext.setUserData(this,CBundleSystem.NOTIFICATION,m_pSevenDaysManager.canGetReward());
        }
    }

    override protected function onActivated( value : Boolean ) :void
    {
        super.onActivated( value );

        var pView : CSevenDaysViewHandler = this.getHandler( CSevenDaysViewHandler ) as CSevenDaysViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CSevenDaysViewHandler isn't instance." );
            return;
        }

        if ( value ) {
            pView.addDisplay();
        } else {
            pView.removeDisplay();
        }
    }

    private function _onViewClosed() : void
    {
        this.setActivated( false );
    }
}
}
