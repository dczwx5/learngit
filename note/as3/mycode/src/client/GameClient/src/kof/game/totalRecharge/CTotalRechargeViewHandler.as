//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/9/11.
 */
package kof.game.totalRecharge {

import kof.game.KOFSysTags;
import kof.game.activityHall.CActivityHallDataManager;
import kof.game.activityHall.CActivityHallSystem;
import kof.game.activityHall.chargeActivity.CTotalChargeActivityView;
import kof.game.activityHall.data.CActivityHallActivityInfo;
import kof.game.activityHall.data.CActivityHallActivityType;
import kof.game.activityHall.event.CActivityHallEvent;
import kof.game.common.view.CTweenViewHandler;
import kof.ui.master.TotalCharge.TotalChargeUI;

import morn.core.components.Dialog;

import morn.core.handlers.Handler;

public class CTotalRechargeViewHandler extends CTweenViewHandler {

    private var m_pCloseHandler : Handler;
    private var m_bViewInitialized : Boolean;
    private var m_pViewUI : TotalChargeUI;
    private var m_chargeView : CTotalChargeActivityView;

    public function CTotalRechargeViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [ TotalChargeUI ];
    }

    override protected function get additionalAssets() : Array
    {
        return ["frameclip_item.swf"];
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;
        if ( !m_bViewInitialized ) {
            this.initialize();
        }
        return m_bViewInitialized;
    }

    protected function initialize() : void
    {
        if ( !m_bViewInitialized )
        {
            if ( !m_pViewUI )
            {
                m_pViewUI = new TotalChargeUI();
//                m_pViewUI.helpBtn.visible = false;
                m_pViewUI.closeBtn.clickHandler = new Handler( _close );

                m_chargeView = new CTotalChargeActivityView( system, m_pViewUI );//累计充值界面

                m_bViewInitialized = true;
            }
        }
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
        if ( m_pViewUI )
        {
            setTweenData( KOFSysTags.TOTAL_RECHARGE );
            showDialog( m_pViewUI, false, _onShowEnd);

            m_chargeView.updateCDTime();
            schedule(1, _onSchedule);
        }
    }

    private function _onShowEnd():void
    {
        var activityInfo:CActivityHallActivityInfo = _helper.getActivityInfo();
        if(activityInfo)
        {
            m_chargeView.addDisplay(activityInfo);
        }
        else
        {
            m_chargeView.removeDisplay();
        }
    }

    private function _onSchedule(delta:Number):void
    {
        m_chargeView.updateCDTime();
    }

    public function removeDisplay() : void
    {
        closeDialog( _removeDisplayB );
    }

    private function _removeDisplayB() : void
    {
        if(m_bViewInitialized)
        {
            if ( m_pViewUI && m_pViewUI.parent )
            {
                m_pViewUI.close( Dialog.CLOSE );
            }
        }

        unschedule(_onSchedule);
    }

    private function _close() : void
    {
        if ( m_pCloseHandler )
        {
            m_pCloseHandler.execute();
        }
    }

    public function get closeHandler() : Handler
    {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void
    {
        m_pCloseHandler = value;
    }

    private function get _helper():CTotalRechargeHelperHandler
    {
        return system.getHandler(CTotalRechargeHelperHandler) as CTotalRechargeHelperHandler;
    }
}
}
