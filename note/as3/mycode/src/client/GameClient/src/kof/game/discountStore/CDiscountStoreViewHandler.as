//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/9/11.
 */
package kof.game.discountStore {

import kof.game.KOFSysTags;
import kof.game.activityHall.data.CActivityHallActivityInfo;
import kof.game.activityHall.discountShop.CDiscountShopActivityView;
import kof.game.common.view.CTweenViewHandler;
import kof.ui.master.DiscountShop.DiscountShopUI;

import morn.core.components.Dialog;

import morn.core.handlers.Handler;

public class CDiscountStoreViewHandler extends CTweenViewHandler {

    private var m_pCloseHandler : Handler;
    private var m_bViewInitialized : Boolean;
    private var m_pViewUI : DiscountShopUI;
    private var m_discountShopView : CDiscountShopActivityView;

    public function CDiscountStoreViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [ DiscountShopUI ];
    }

    override protected function get additionalAssets() : Array
    {
        return ["frameclip_item2.swf"];
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
                m_pViewUI = new DiscountShopUI();
//                m_pViewUI.helpBtn.visible = false;
                m_pViewUI.closeBtn.clickHandler = new Handler( _close );
                m_discountShopView = new CDiscountShopActivityView( system, m_pViewUI );//特惠商店

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
            setTweenData( KOFSysTags.DISCOUNT_STORE );
            showDialog( m_pViewUI, false, _onShowEnd);

            m_discountShopView.updateCDTime();
            schedule(1, _onSchedule);
        }
    }

    private function _onShowEnd():void
    {
        var activityInfo:CActivityHallActivityInfo = _helper.getActivityInfo();
        if(activityInfo)
        {
            m_discountShopView.addDisplay(activityInfo);
        }
        else
        {
            m_discountShopView.removeDisplay();
        }
    }

    private function _onSchedule(delta:Number):void
    {
        m_discountShopView.updateCDTime();
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

    private function get _helper():CDiscountStoreHelpHandler
    {
        return system.getHandler(CDiscountStoreHelpHandler) as CDiscountStoreHelpHandler;
    }
}
}
