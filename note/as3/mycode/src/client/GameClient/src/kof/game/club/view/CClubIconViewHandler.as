//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/30.
 * 俱乐部标志页面
 */
package kof.game.club.view {

import kof.framework.CViewHandler;
import kof.game.club.CClubEvent;
import kof.game.club.data.CClubPath;
import kof.ui.master.club.ClubIconItemUI;
import kof.ui.master.club.ClubIconUI;

import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CClubIconViewHandler extends CViewHandler {

    private var _clubIocnUI : ClubIconUI;

    public function CClubIconViewHandler() {
        super( false );
    }
    override public function get viewClass() : Array {
        return [ ClubIconUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if( !_clubIocnUI ){
            _clubIocnUI = new ClubIconUI();

            _clubIocnUI.closeHandler = new Handler( _onClose );
            _clubIocnUI.list.renderHandler = new Handler( renderItem );
            _clubIocnUI.list.selectHandler = new Handler( selectItemHandler );
            //tofix
            _clubIocnUI.list.dataSource = ['100','101','102','103','104','105','106','107','108','109','110','111'];
        }

        return Boolean( _clubIocnUI );
    }
    private function renderItem(item:Component, idx:int):void {
        if (!(item is ClubIconItemUI)) {
            return;
        }
        var pClubIconItemUI:ClubIconItemUI = item as ClubIconItemUI;
        if(pClubIconItemUI.dataSource){
            pClubIconItemUI.img.url = CClubPath.getClubIconUrByID( int(pClubIconItemUI.dataSource) );
        }
    }
    private function selectItemHandler( index : int ) : void {
        var pClubIconItemUI : ClubIconItemUI = _clubIocnUI.list.getCell( index ) as ClubIconItemUI;
        if ( !pClubIconItemUI )
            return;
        system.dispatchEvent( new CClubEvent( CClubEvent.CLUB_ICON_CHANGE_REQUEST ,int( pClubIconItemUI.dataSource ) ));
        _clubIocnUI.close( Dialog.CLOSE );
    }

    public function addDisplay() : void {
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
    public function _addToDisplay( ):void {
        uiCanvas.addPopupDialog( _clubIocnUI );
    }
    public function removeDisplay() : void {
        if ( _clubIocnUI ) {
            _clubIocnUI.close( Dialog.CLOSE );
        }
    }
    private function _addEventListeners():void{
        _removeEventListeners();

    }
    private function _removeEventListeners():void{

    }
    private function _onClose( type : String ) : void {
        switch ( type ) {
            default:
                break;
        }
        _removeEventListeners();
    }

}
}
