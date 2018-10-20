//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/09/03.
 */
package kof.game.gemenRecharge {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CLogUtil;
import kof.game.common.view.CTweenViewHandler;
import kof.ui.master.GemenRecharge.GemenRechargeUI;
import morn.core.handlers.Handler;

public class CGemenRechargeViewHandler extends CTweenViewHandler {

    private var m_bViewInitialized : Boolean;

    private var m_pView : GemenRechargeUI;
    private var m_pCloseHandler : Handler;

    public function CGemenRechargeViewHandler() {
        super( false );
    }

    override public function get viewClass() : Array
    {
        return [ GemenRechargeUI];
    }

    override protected function onAssetsLoadCompleted() : void
    {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean
    {
        if( !super.onInitializeView() )
            return false;
        if( !m_bViewInitialized )
        {
            this.initialize();
        }
        return m_bViewInitialized;
    }

    protected function initialize() : void
    {
        if( !m_pView )
        {
            m_pView = new GemenRechargeUI();
            m_pView.closeHandler = new Handler( _close );
            m_pView.btn_recharge.clickHandler = new Handler(_onRecharge);
            m_bViewInitialized = true;
        }
    }

    public function get closeHandler() : Handler
    {
        return m_pCloseHandler;
    }

    private function _close(type : String) : void
    {
        switch ( type ) {
            default:
                if ( this.closeHandler ) {
                    this.closeHandler.execute();
                }
                break;
        }
    }

    public function set closeHandler( value : Handler ) : void
    {
        m_pCloseHandler = value;
    }
    public function addDisplay() : void
    {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void
    {
        if ( onInitializeView() )
        {
            invalidate();
            callLater( _addToDisplay );
        }
        else
        {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _addToDisplay() : void
    {
        if ( onInitializeView() ) {
            invalidate();
            if ( m_pView )
            {
                showDialog(m_pView);
                if(_manager.qrBmpWX)
                    m_pView.img_qrcode.bitmapData = _manager.qrBmpWX;
                else //如果没有缓存到，重新请求
                {
                    App.log.warn( "wx_qrcode 加载失败,重新加载" );
                }
            }
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }
    public function removeDisplay() : void {
        closeDialog();
    }

    private function _onRecharge():void{
        var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
        var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
        bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);

        CLogUtil.recordLinkLog(system, 10021);
    }
    private function get _system() : CGemenRechargeSystem
    {
        return system as CGemenRechargeSystem;
    }
    private function get _manager() : CGemenRechargeManager
    {
        return _system.getBean( CGemenRechargeManager) as CGemenRechargeManager;
    }
}
}
