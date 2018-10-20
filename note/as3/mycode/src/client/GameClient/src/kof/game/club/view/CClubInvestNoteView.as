//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/7/10.
 */
package kof.game.club.view {

import kof.SYSTEM_ID;
import kof.framework.CViewHandler;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.ui.master.club.ClubInvestNoteUI;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CClubInvestNoteView extends CViewHandler{
    public function CClubInvestNoteView() {
        super(false);
    }
    private var m_Note : ClubInvestNoteUI;
    private var m_isInit : Boolean;
    private var callBack : Function;
    override public function get viewClass() : Array {
        return [ClubInvestNoteUI];
    }
    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }
    override public function dispose() : void {
        super.dispose();
        if( m_Note )
            m_Note.remove();
        m_Note = null;
    }

    //重载初始化界面方法
    override protected function onInitializeView() : Boolean{
        if( !super.onInitializeView() )
            return false;
        if(!m_isInit)
            initialize();
        return m_isInit;
    }

    protected function initialize() : void {
        if ( !m_Note ) {
            m_Note = new ClubInvestNoteUI();
            m_Note.btn_charge.clickHandler = new Handler(_gotoCharge);
            m_Note.btn_close.clickHandler = new Handler(removeDisplay);
            m_Note.btn_no.clickHandler = new Handler(removeDisplay);
        }
        m_isInit = true;
    }

    public function addDisplay(fun : Function) : void {
        callBack = fun;
        this.loadAssetsByView( viewClass, _addDisplay );
    }

    private function _addDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            callLater( _addToDisplay );
        } else {
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }
    private function _addToDisplay() : void {
        if ( !m_Note )  return;
        uiCanvas.addPopupDialog( m_Note );
    }
    public function removeDisplay() : void {
        if( m_Note )
            m_Note.close( Dialog.CLOSE );
    }
    private function _gotoCharge() : void
    {
        var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
        var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
        bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
        if(callBack)
            callBack();
    }
}
}
