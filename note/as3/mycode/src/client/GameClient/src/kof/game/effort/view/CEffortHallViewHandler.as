//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
// (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by Leo.Li 2018/5/25
//----------------------------------------------------------------------------------------------------------------------
package kof.game.effort.view {

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.effort.CEffortHallHandler;
import kof.game.effort.CEffortSystem;
import kof.game.common.CLang;
import kof.game.common.CSystemRuleUtil;
import kof.game.common.view.CTweenViewHandler;
import kof.game.effort.data.CEffortConst;
import kof.game.effort.data.CEffortTargetData;
import kof.table.EffortConfig;
import kof.table.EffortTypeRewardConfig;
import kof.ui.master.effortHall.EffortCategorizationUI;
import kof.ui.master.effortHall.EffortHallUI;
import kof.ui.master.effortHall.EffortOverviewUI;
import kof.ui.master.effortHall.EffortRedUI;
import kof.ui.master.effortHall.EffortTotalRewardTipsUI;

import morn.core.handlers.Handler;

/**
 * 成就系统--主界面，即父容器
 * @author Leo.Li
 * @date 2018/5/25
 */
public class CEffortHallViewHandler extends CTweenViewHandler {

    protected var _m_pHallHandler:CEffortHallHandler;

    private var _m_pEffortHallUI:EffortHallUI;

    private var _m_pCloseHandler : Handler;
    private var _m_pCurViewHandler : CEffortPanelBase;
    protected var _m_pTargetTable:IDataTable;
    protected var _m_pConfigTable:IDataTable;
    private var _m_iTabIndex:int;

    public function CEffortHallViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override public function dispose() : void {
        _removeEventListeners();
        super.dispose();
        removeDisplay();
        _m_pEffortHallUI = null;
    }

    override protected function onSetup():Boolean
    {
        var ret : Boolean = super.onSetup();
        _m_pHallHandler = system.getBean(CEffortHallHandler) as CEffortHallHandler;
        var pDatabase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
        _m_pTargetTable = pDatabase.getTable(KOFTableConstants.EFFORT_TARGET_CONFIG);
        _m_pConfigTable = pDatabase.getTable(KOFTableConstants.EFFORT_CONFIG);
        return ret;
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !_m_pEffortHallUI ) {

            //welfareData = (system.getBean(CWelfareHallManager) as CWelfareHallManager).data;

            _m_pEffortHallUI = new EffortHallUI();

            _m_pEffortHallUI.closeHandler = new Handler( _onClose );
            _m_pEffortHallUI.tab.selectHandler = new Handler( _onTabSelectedHandler );

            CSystemRuleUtil.setRuleTips(_m_pEffortHallUI.img_tips, CLang.Get("effort_rule"));

        }

        return _m_pEffortHallUI;
    }

    private function _onTabSelectedHandler( index : int ) : void {
        if( _m_pCurViewHandler )
            _m_pCurViewHandler.removeDisplay();
        _m_pCurViewHandler = ( system as CEffortSystem ).m_aPanelViews[index ] as CEffortPanelBase;
        if( _m_pCurViewHandler )
            _m_pCurViewHandler.addDisplay();
    }

    public function addDisplay( tabIndex :int ) : void {
        _m_iTabIndex = tabIndex;
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    public function get closeHandler() : Handler {
        return _m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        _m_pCloseHandler = value;
    }

    public function updateRedPoint():void
    {
        for(var i:int = 1; i <= CEffortConst.TYPES; i ++)
        {
            _updateRedPoint(i);
        }
    }


    protected function _updateRedPoint( type : int ) : void {
        if ( _m_pEffortHallUI ) {
            var redSum : int = 0;
            for each(var configCfg:EffortConfig in _m_pConfigTable.toArray())
            {
                if(configCfg.type == type)
                {
                    for each(var targetId:int in configCfg.effortTargetId)
                    {
                        var targetCurData : CEffortTargetData = _m_pHallHandler.currentTargetData(targetId);
                        if ( targetCurData.isComplete && targetCurData.obtainTick < 1 ) {
                            redSum++;
                        }
                    }
                }
            }
            var sum : int = _m_pHallHandler.sumTypeEffort( type );
            var curShowTypeCfg : EffortTypeRewardConfig = _m_pHallHandler.calculateCurShowTypeReward( sum, type );
            if ( curShowTypeCfg ) {
                if ( curShowTypeCfg.needPointNum <= sum ) {
                    redSum++;
                }
            }
            _updateSingleRed( _m_pEffortHallUI[ "red" + type ], redSum );
        }
    }

    protected function _updateSingleRed(box:EffortRedUI,num:int):void
    {
        if(num > 0)
        {
            box.visible = true;
            box.txt_red.visible = false;
            box.txt_red.text = num.toString();
        }
        else
        {
            box.visible = false;
        }

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
        setTweenData(KOFSysTags.EFFORT);
        showDialog(_m_pEffortHallUI, false, _addToDisplayB);
        updateRedPoint();
    }
    private function _addToDisplayB() : void {
        if ( _m_pEffortHallUI ) {
            _m_pEffortHallUI.tab.space = _m_pEffortHallUI.tab.space;
            _m_pEffortHallUI.tab.selectedIndex = _m_iTabIndex;
            _m_pEffortHallUI.tab.callLater( _onTabSelectedHandler, [_m_iTabIndex] );
        }
        _addEventListeners();
    }

    public function removeDisplay() : void {
        if ( _m_pCurViewHandler )
        {
            _m_pCurViewHandler.removeDisplay();
        }
        closeDialog();
        _removeEventListeners();
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


    override public function get viewClass() : Array {
        return [ EffortHallUI , EffortCategorizationUI , EffortOverviewUI , EffortTotalRewardTipsUI];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    private function _addEventListeners():void {
    }
    private function _removeEventListeners():void{
    }

    public function get hallUI():EffortHallUI
    {
        return _m_pEffortHallUI;
    }
}
}
