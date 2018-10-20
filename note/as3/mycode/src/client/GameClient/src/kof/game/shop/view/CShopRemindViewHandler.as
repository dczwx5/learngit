//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2017/5/4.
 */
package kof.game.shop.view {

import flash.events.MouseEvent;

import kof.framework.CViewHandler;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.reciprocation.popWindow.EPopWindow;
import kof.ui.master.shop.ShopRemindUI;

/**
 * 商店来袭提醒
 */
public class CShopRemindViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;

    private var _shopRemindUI:ShopRemindUI;
    private var _curTime:int = 3;

    public function CShopRemindViewHandler() {
        super( false );
    }

    override public function get viewClass() : Array {
        return [ ShopRemindUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized ) {
            this.initialize();
        }

        return m_bViewInitialized;
    }

    protected function initialize() : void {
        if ( _shopRemindUI == null ) {
            _shopRemindUI = new ShopRemindUI();

            _shopRemindUI.addEventListener( MouseEvent.CLICK, _onClickHandler );

            m_bViewInitialized = true;
        }
    }

    private function _onClickHandler( event : MouseEvent ) : void {
        this.hide();
    }

    public function show():void {

        this.loadAssetsByView( viewClass, _addToDisplay )
    }

    public function hide():void {
        if(_shopRemindUI){
            _shopRemindUI.close();
        }

        this.unschedule( _onCountDown );

        var pReciprocalSystem:CReciprocalSystem = (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem);
        if(pReciprocalSystem){
            pReciprocalSystem.removeEventPopWindow( EPopWindow.POP_WINDOW_9 );
        }
    }

    private function _addToDisplay():void {

        if ( onInitializeView() ) {
            invalidate();
        }

        uiCanvas.addPopupDialog( _shopRemindUI );
        _curTime = 3;
        this.schedule(1, _onCountDown );
    }

    private function _onCountDown( delta : Number ):void {
        _curTime --;
        if( _curTime < 0 ){
            this.hide();
        }
    }

}
}
