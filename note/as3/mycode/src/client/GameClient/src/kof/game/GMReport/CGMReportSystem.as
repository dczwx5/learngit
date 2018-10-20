//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/12/9.
 */
package kof.game.GMReport {

import flash.events.Event;

import kof.SYSTEM_ID;
import kof.game.GMReport.Event.CGMReportEvent;
import kof.game.GMReport.view.CDateSelectViewHandler;
import kof.game.GMReport.view.CGMReportDateMenuHandler;
import kof.game.GMReport.view.CGMReportViewHandler;
import kof.game.GMReport.view.CGMSubmitSuccViewHandler;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;

import morn.core.handlers.Handler;

/**
 * GM举报
 * @author sprite (sprite@qifun.com)
 */
public class CGMReportSystem extends CBundleSystem {

    private var m_bInitialized : Boolean;

    private var m_pMainViewHandler:CGMReportViewHandler;
    private var m_pManager:CGMReportManager;
    private var m_pNetHandler:CGMReportNetHandler;

    public function CGMReportSystem( A_objBundleID : * = null )
    {
        super( A_objBundleID );
    }

    override public function initialize() : Boolean
    {
        if ( !super.initialize() )
        {
            return false;
        }

        if ( !m_bInitialized )
        {
            m_bInitialized = true;

            m_pMainViewHandler = new CGMReportViewHandler();
            this.addBean( m_pMainViewHandler );
            m_pMainViewHandler.closeHandler = new Handler( _onViewClosed );

            m_pNetHandler = new CGMReportNetHandler();
            this.addBean( m_pNetHandler );

            m_pManager = new CGMReportManager();
            this.addBean( m_pManager );

            this.addBean( new CGMSubmitSuccViewHandler() );
            this.addBean( new CDateSelectViewHandler() );
            this.addBean( new CGMReportDateMenuHandler() );
        }

        return m_bInitialized;
    }

    override public function get bundleID() : *
    {
        return SYSTEM_ID(KOFSysTags.GMREPORT);
    }

    override protected function onBundleStart(ctx:ISystemBundleContext):void
    {
        super.onBundleStart(ctx);

        _addEventListeners();
    }

    protected function _addEventListeners() : void
    {
        this.addEventListener(CGMReportEvent.ReportSucc, _onReportSuccHandler);
        this.addEventListener(CGMReportEvent.OpenReportWin, _onOpenReportWinHandler);
    }

    protected function _removeEventListeners() : void
    {
        this.removeEventListener(CGMReportEvent.ReportSucc, _onReportSuccHandler);
        this.removeEventListener(CGMReportEvent.OpenReportWin, _onOpenReportWinHandler);
    }

    override protected function onActivated( value : Boolean ) : void
    {
        super.onActivated( value );

        var pView : CGMReportViewHandler = this.getHandler( CGMReportViewHandler ) as CGMReportViewHandler;
        if ( !pView )
        {
            LOG.logErrorMsg( "SystemBundle activated, but the CGMReportViewHandler isn't instance." );
            return;
        }

        if ( value && !pView.isLoading && !pView.isViewShow)
        {
            pView.addDisplay();
        }
        else if(!value)
        {
            var bundleCtx:ISystemBundleContext = stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
            var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.GMREPORT));
            var currState:Boolean = bundleCtx.getUserData(systemBundle,CBundleSystem.ACTIVATED);

            if(pView.isLoading && !currState)
            {
                this.setActivated( true );
            }
            else
            {
                pView.removeDisplay();
            }
        }
    }

    private function _onViewClosed() : void
    {
        this.setActivated( false );
    }

    private function _onReportSuccHandler(e:Event):void
    {
        (getHandler(CGMSubmitSuccViewHandler) as CGMSubmitSuccViewHandler).addDisplay();
    }

    private function _onOpenReportWinHandler(e:CGMReportEvent):void
    {
        if(m_pMainViewHandler && !m_pMainViewHandler.isViewShow)
        {
            var reportData:CGMReportData = e.data as CGMReportData;
//            m_pMainViewHandler.roleName = reportData.playerName;
            m_pMainViewHandler.gmReportData = reportData;
            this.setActivated(true);
        }
        else
        {
            this.setActivated(false);
        }
    }

    override public function dispose() : void
    {
        super.dispose();

        if(m_pMainViewHandler)
        {
            m_pMainViewHandler.dispose();
            m_pMainViewHandler = null;
        }

        if(m_pManager)
        {
            m_pManager.dispose();
            m_pManager = null;
        }

        if(m_pNetHandler)
        {
            m_pNetHandler.dispose();
            m_pNetHandler = null;
        }
    }
}
}
