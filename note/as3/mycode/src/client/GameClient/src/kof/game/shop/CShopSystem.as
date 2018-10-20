//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/5/4.
 */
package kof.game.shop {

import kof.SYSTEM_ID;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.platform.EPlatformType;
import kof.game.player.CPlayerSystem;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.reciprocation.popWindow.EPopWindow;
import kof.game.shop.event.CShopEvent;
import kof.game.shop.view.CShopBuyViewHandler;
import kof.game.shop.view.CShopItemTipsViewHandler;
import kof.game.shop.view.CShopRemindViewHandler;
import kof.table.Currency;
import kof.table.Item;
import kof.table.ShopItem;
import kof.ui.CUISystem;

import morn.core.handlers.Handler;

/**
 * 商店系统
 */
public class CShopSystem extends CBundleSystem implements ISystemBundle {

    private var m_bInitialized : Boolean;

    private var _shopManager:CShopManager;
    private var _shopHandler:CShopHandler;
    private var _shopViewHandler:CShopViewHandler;
    private var _shopBuyHandler:CShopBuyViewHandler;
    private var _shopItemTipsHander:CShopItemTipsViewHandler;
    private var _shopRemindHandler:CShopRemindViewHandler;

    public function CShopSystem() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        if ( !m_bInitialized ) {
            m_bInitialized = true;

            this.addBean( _shopManager = new CShopManager() );
            this.addBean( _shopHandler = new CShopHandler());
            this.addBean( _shopViewHandler = new CShopViewHandler());
            this.addBean( _shopBuyHandler = new CShopBuyViewHandler());
            this.addBean( _shopItemTipsHander = new CShopItemTipsViewHandler());
            this.addBean( _shopRemindHandler = new CShopRemindViewHandler());
        }

        var shopView : CShopViewHandler = this.getBean( CShopViewHandler );
        shopView.closeHandler = new Handler( _onViewClosed );

        this._addEventListener();

        return m_bInitialized;
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.MALL );
    }

    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pView : CShopViewHandler = this.getHandler( CShopViewHandler ) as CShopViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CRankingViewHandler isn't instance." );
            return;
        }

        var typeArr : * = ctx.getUserData( this, "shop_type", false );
        var type:int = 0;
        if( typeArr ){
            type = typeArr[0];
        }

        var isHave:Boolean = _shopManager.isHaveShopByType(type);
        if ( value ) {
            if(isHave || type == 0){
                var pPlayerSystem:CPlayerSystem = stage.getSystem(CPlayerSystem) as CPlayerSystem;
                var isTx:Boolean = pPlayerSystem.platform.data.platform == EPlatformType.PLATFORM_TX;
                pView.addDisplay( type,isTx);//如果是腾讯平台
            }else{
                uiSysTem.showMsgAlert("该商店未开启");
                this.setActivated( false );
            }
        } else {
            pView.removeDisplay();
            ctx.setUserData( this, "shop_type", [0] );
        }
    }

    private function _addEventListener() : void {
        this.addEventListener( CShopEvent.SHOP_REMIND_COME, _onShopRemindCome );
    }

    private function _onShopRemindCome( e:CShopEvent ) : void {

        var pReciprocalSystem:CReciprocalSystem = (stage.getSystem( CReciprocalSystem ) as CReciprocalSystem);
        if(pReciprocalSystem){
            pReciprocalSystem.addEventPopWindow( EPopWindow.POP_WINDOW_9, function():void{
                if(_shopRemindHandler){
                    _shopRemindHandler.show();
                }
            });
        }
    }

    private  function _removeEventListener() : void {
        this.removeEventListener( CShopEvent.SHOP_REMIND_COME, _onShopRemindCome );
    }

    private function _onViewClosed() : void {
        ctx.setUserData( this, "shop_type", [0] );
        this.setActivated( false );
    }

    public function getItemTableByID(id:int) : Item{
        var itemTable:IDataTable = (stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.ITEM);
        return itemTable.findByPrimaryKey(id);
    }

    public function getShopItemTableByID(id:int) : ShopItem{
        var itemTable:IDataTable = (stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.SHOP_ITEM);
        return itemTable.findByPrimaryKey(id);
    }

    public function getCurrencyTableByID(id:int) : Currency{
        var itemTable:IDataTable = (stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.CURRENCY);
        return itemTable.findByPrimaryKey(id);
    }

    public function getIconPath(name:String):String
    {
        return "icon/currency/"+name+".png";
    }

    private function get uiSysTem() : CUISystem {
        return stage.getSystem(CUISystem) as CUISystem;
    }
}
}
