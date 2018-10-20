//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/9/20.
 * 福利大厅
 */
package kof.game.welfarehall.view {

import kof.game.KOFSysTags;
import kof.game.common.view.CTweenViewHandler;
import kof.game.welfarehall.CWelfareHallManager;
import kof.game.welfarehall.CWelfareHallSystem;
import kof.game.welfarehall.data.CRechargeWelfareData;
import kof.ui.master.welfareHall.WelfareHallUI;
import morn.core.handlers.Handler;

public class CWelfareHallViewHandler extends CTweenViewHandler {

    private var _welfareHallUI : WelfareHallUI;

    private var m_pCloseHandler : Handler;

    private var _curViewHandler : CWelfarePanelBase;

    private var _tabType : int;

    private var welfareData:CRechargeWelfareData;

    public function CWelfareHallViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }
    override public function dispose() : void {
        super.dispose();
        removeDisplay();
        _welfareHallUI = null;
    }
    override public function get viewClass() : Array {
        return [ WelfareHallUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !_welfareHallUI ) {

            welfareData = (system.getBean(CWelfareHallManager) as CWelfareHallManager).data;

            _welfareHallUI = new WelfareHallUI();

            _welfareHallUI.closeHandler = new Handler( _onClose );
            _welfareHallUI.tab.selectHandler = new Handler( _onTabSelectedHandler );
            _welfareHallUI.img_dian_0.visible = false;
            _welfareHallUI.img_dian_3.visible = false;
        }

        return _welfareHallUI;
    }

    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }

    public function addDisplay( tabType :int ) : void {
        _tabType = tabType;
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            callLater( _addToDisplay );
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }
    private function _addToDisplay() : void {
        setTweenData(KOFSysTags.WELFARE_HALL);
        showDialog(_welfareHallUI, false, _addToDisplayB);
    }
    private function _addToDisplayB() : void {
        if ( _welfareHallUI ) {
            _welfareHallUI.tab.space = _welfareHallUI.tab.space;
            _welfareHallUI.tab.selectedIndex = _tabType;
            _welfareHallUI.tab.callLater( _onTabSelectedHandler, [_tabType] );
            updateRed();
        }
    }

    public function removeDisplay() : void {
        closeDialog();
    }
    private function _onClose( type : String ) : void {
        switch ( type ) {
            default:
                if ( this.closeHandler ) {
                    this.closeHandler.execute();
                }
                break;
        }
    }

    public function get welfareHallUI() : WelfareHallUI {
        return _welfareHallUI;
    }
    public function updateRed():void
    {
        if(_welfareHallUI)
        {
            _welfareHallUI.img_dian_3.visible = _manager.hasRecoveryReward;
        }
    }
    private function _onTabSelectedHandler( index : int ) : void {
        if( _curViewHandler )
            _curViewHandler.removeDisplay();
        _curViewHandler = ( system as CWelfareHallSystem ).panelViewAry[index ] as CWelfarePanelBase;
        if( _curViewHandler )
            _curViewHandler.addDisplay();
    }
    private function get _manager() : CWelfareHallManager
    {
        return system.getBean(CWelfareHallManager) as CWelfareHallManager;
    }
}
}
