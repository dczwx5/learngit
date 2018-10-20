//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.pay.view {

import flash.events.MouseEvent;

import kof.SYSTEM_ID;

import kof.framework.CViewHandler;
import kof.framework.events.CEventPriority;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.CSystemBundleContext;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.pay.IPayViewMediator;
import kof.ui.master.pay.QQOpenAppPayRechargeUI;
import kof.ui.master.pay.QQOpenAppPayUI;

import morn.core.components.Component;
import morn.core.components.List;
import morn.core.handlers.Handler;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public class CQQOpenAppViewHandler extends CViewHandler {

    private var m_pUI : QQOpenAppPayUI;
    private var m_theProductList : List;
    private var m_pCloseHandler : Handler;
    private var m_iVipLevel : int;
    private var m_iVipLevelMax : int;
    private var m_iVipNextLevelCost : int;
    private var m_iVipExp : int;
    private var m_iVipExpMax : int;
    private var m_theProductItemList : Array;

    /** Creates a new CQQOpenAppViewHandler. */
    public function CQQOpenAppViewHandler() {
        super();
    }

    override public function dispose() : void {
        super.dispose();

        m_theProductList = null;
        if ( m_theProductItemList && m_theProductItemList.length )
            m_theProductItemList.splice( 0, m_theProductItemList.length );
        m_theProductItemList = null;
        m_pUI = null;
    }

    override public function get viewClass() : Array {
        return [ QQOpenAppPayUI ];
    }

    override protected virtual function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_pUI ) {
            m_pUI = new QQOpenAppPayUI();

            m_pUI.btn_rechargeRebate.clickHandler = new Handler( _onShowRechargeRebateView );
            m_pUI.closeHandler = new Handler( _onClose );
            m_pUI.btnGetBlueDemaind.addEventListener( MouseEvent.CLICK, button_onMouseClickEventHandler,
                    false, CEventPriority.DEFAULT_HANDLER, true );
            m_pUI.btnVipDetail.addEventListener( MouseEvent.CLICK, button_onMouseClickEventHandler, false,
                    CEventPriority.DEFAULT_HANDLER, true );

            var lstProduct : List = m_pUI.getChildByName( 'lstProduct' ) as List;
            if ( lstProduct ) {
                lstProduct.array = [];
            }

            this.m_theProductList = lstProduct;

            this.m_theProductList.renderHandler = new Handler( product_renderHandler );
        }

        return m_pUI;
    }

    public function addDisplay() : void {
        this.loadAssetsByView( this.viewClass, _addDisplay );
    }

    private function _addDisplay() : void {
        if ( this.onInitializeView() ) {
            this.invalidate();

            //充值返钻 入口
            var bundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            var iStateValue : int = bundleCtx.getSystemBundleState( bundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.RECHARGEREBATE ) ) );
            m_pUI.btn_rechargeRebate.visible = iStateValue == CSystemBundleContext.STATE_STARTED ;

            uiCanvas.addPopupDialog( m_pUI );
        }
    }

    public function removeDisplay() : void {
        if ( m_pUI ) {
            m_pUI.close();
        }
    }

    private function button_onMouseClickEventHandler( event : MouseEvent ) : void {
        var pMediator : IPayViewMediator = system.getHandler( IPayViewMediator ) as IPayViewMediator;
        switch ( event.currentTarget ) {
            case m_pUI.btnGetBlueDemaind: {
                if ( pMediator ) {
                    pMediator.requestPlatformVIP( 1 );
                }
                break;
            }
            case m_pUI.btnVipDetail: {
                if ( pMediator ) {
                    pMediator.requestVIP();
                }
                break;
            }
            default:
                break;
        }
    }

    private function _onClose( type : String ) : void {
        switch ( type ) {
            default:
                if ( this.closeHandler )
                    this.closeHandler.execute();
                break;
        }
    }

    private function product_renderHandler( aDisplayObject : Component, idx : int ) : void {
        var pItem : QQOpenAppPayRechargeUI = aDisplayObject as QQOpenAppPayRechargeUI;
        if ( !pItem )
            return;

        pItem.btnBuy.clickHandler = new Handler( btnBuy_clickHandler, [ idx ] );

        var vItemData : Object = pItem.dataSource;
        if ( vItemData ) {
            pItem.lblProductName.text = vItemData.Name;
            pItem.lblQQCoin.text = "原价：" + int( vItemData.Price / 10 ) + " Q点";
            pItem.lblBlueDemaind.text = "蓝钻：" + int( vItemData.Price * 0.8 / 10 ).toString() + " Q点";

            pItem.lblQQCoin.margin = pItem.lblQQCoin.margin;
            pItem.lblBlueDemaind.margin = pItem.lblBlueDemaind.margin;
            pItem.cilpProduct.index = idx;
        }
    }

    private function btnBuy_clickHandler( idx : int ) : void {
        if ( this.productItemList && ( 0 <= idx < this.productItemList.length ) ) {
            var pItemData : Object = this.productItemList[ idx ];
            var pMediator : IPayViewMediator = system.getHandler( IPayViewMediator ) as IPayViewMediator;
            if ( pMediator ) {
                pMediator.buyProduct( pItemData.ID );
            }
        } else {
            LOG.logErrorMsg( "充值界面配置错误，没有绑定对应的充值数据项！" );
            uiCanvas.showMsgAlert( "充值故障了，请联系客服！" );
        }
    }

    override protected virtual function updateData() : void {
        super.updateData();

        if ( m_pUI ) {

            if ( this.vipLevelMax == this.vipLevel ) {
                m_pUI.boxMaxVipTip.visible = true;
                m_pUI.boxVipTip.visible = false;
            } else {
                m_pUI.boxMaxVipTip.visible = false;
                m_pUI.boxVipTip.visible = true;
            }

            m_pUI.clipVipLevelNum.num = this.vipLevel;
            m_pUI.pgbVipExp.value = Number( this.vipExp / this.vipExpMax );
            m_pUI.txt_pro.text = this.vipExp.toString() + "/" + this.vipExpMax.toString();
            m_pUI.clipVip.index = Math.min( this.vipLevel + 1, this.vipLevelMax );
            m_pUI.txt_cz.text = this.vipNextLevelCost.toString();

            m_theProductList.dataSource = this.productItemList;
        }
    }

    private function _onShowRechargeRebateView():void{

        var bundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var systemBundle : ISystemBundle = bundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.RECHARGEREBATE ) );
        bundleCtx.setUserData( systemBundle, CBundleSystem.ACTIVATED, true );
    }

    override protected virtual function updateDisplay() : void {
        super.updateDisplay();

    }

    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( closeHandler : Handler ) : void {
        m_pCloseHandler = closeHandler;
    }

    public function get vipLevel() : int {
        return m_iVipLevel;
    }

    public function set vipLevel( value : int ) : void {
        if ( m_iVipLevel == value ) return;
        m_iVipLevel = value;
        this.invalidateData();
    }

    public function get vipLevelMax() : int {
        return m_iVipLevelMax;
    }

    public function set vipLevelMax( value : int ) : void {
        if ( m_iVipLevelMax == value ) return;
        m_iVipLevelMax = value;
        this.invalidateData();
    }

    public function get vipNextLevelCost() : int {
        return m_iVipNextLevelCost;
    }

    public function set vipNextLevelCost( value : int ) : void {
        if ( m_iVipNextLevelCost == value ) return;
        m_iVipNextLevelCost = value;
        this.invalidateData();
    }

    public function get vipExp() : int {
        return m_iVipExp;
    }

    public function set vipExp( value : int ) : void {
        if ( m_iVipExp == value ) return;
        m_iVipExp = value;
        this.vipNextLevelCost = this.vipExpMax - this.vipExp;
        this.invalidateData();
    }

    public function get vipExpMax() : int {
        return m_iVipExpMax;
    }

    public function set vipExpMax( value : int ) : void {
        if ( m_iVipExpMax == value ) return;
        m_iVipExpMax = value;
        this.vipNextLevelCost = this.vipExpMax - this.vipExp;
        this.invalidateData();
    }

    public function get productItemList() : Array {
        return m_theProductItemList;
    }

    public function set productItemList( value : Array ) : void {
        m_theProductItemList = value;
        this.invalidateData();
    }

}
}

// vi:ft=as3 ts=4 sw=4 expandtab tw=120
