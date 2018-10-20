//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/7.
 */
package kof.game.club.view.clubview {

import kof.framework.CViewHandler;
import kof.game.club.CClubHandler;
import kof.game.club.CClubManager;
import kof.game.club.data.CClubConst;
import kof.game.club.data.CClubMemberData;
import kof.ui.CUISystem;
import kof.ui.master.club.ClubPostionChangeUI;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CClubPositionChangeViewHandler extends CViewHandler {

    private var _clubPostionChangeUI : ClubPostionChangeUI;
    private var _pClubMemberData : CClubMemberData;
    public function CClubPositionChangeViewHandler() {
        super( false );
    }
    override public function get viewClass() : Array {
        return [ ClubPostionChangeUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if( !_clubPostionChangeUI ){
            _clubPostionChangeUI = new ClubPostionChangeUI();

            _clubPostionChangeUI.closeHandler = new Handler( _onClose );
            _clubPostionChangeUI.btn_ok.clickHandler = new Handler( _onPositionChangeHandler );
        }

        return Boolean( _clubPostionChangeUI );
    }

    public function addDisplay( pClubMemberData : CClubMemberData ) : void {
        _pClubMemberData = pClubMemberData;
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
        var targetPosition : int = _pClubMemberData.position;
        var str : String = '';
        str = "<font color='#fbec2f'>" +  _pClubMemberData.name  + "</font>" + '目前职位为' +
                "<font color='#fbec2f'>" + CClubConst.CLUB_POSITION_STR[_pClubMemberData.position] + "</font>" +
                ',将其职位调整为：';
        _clubPostionChangeUI.txt_tips.text = str;
        _clubPostionChangeUI.btn_1.visible =
                _clubPostionChangeUI.btn_2.visible = true;
        _clubPostionChangeUI.radioGroup.selectedIndex = -1;

        if( _pClubManager.clubPosition == CClubConst.CLUB_POSITION_4 ){
            if( targetPosition == CClubConst.CLUB_POSITION_3 ){
                _clubPostionChangeUI.txt_1.text = CClubConst.CLUB_POSITION_STR[CClubConst.CLUB_POSITION_2];
                _clubPostionChangeUI.txt_2.text = CClubConst.CLUB_POSITION_STR[CClubConst.CLUB_POSITION_1];
            }else if( targetPosition == CClubConst.CLUB_POSITION_2 ){
                _clubPostionChangeUI.txt_1.text = CClubConst.CLUB_POSITION_STR[CClubConst.CLUB_POSITION_3];
                _clubPostionChangeUI.txt_2.text = CClubConst.CLUB_POSITION_STR[CClubConst.CLUB_POSITION_1];
            }else if( targetPosition == CClubConst.CLUB_POSITION_1 ){
                _clubPostionChangeUI.txt_1.text = CClubConst.CLUB_POSITION_STR[CClubConst.CLUB_POSITION_3];
                _clubPostionChangeUI.txt_2.text = CClubConst.CLUB_POSITION_STR[CClubConst.CLUB_POSITION_2];
            }
        } else if( _pClubManager.clubPosition == CClubConst.CLUB_POSITION_3 ){
            if( targetPosition == CClubConst.CLUB_POSITION_2  ){
                _clubPostionChangeUI.txt_1.text = CClubConst.CLUB_POSITION_STR[CClubConst.CLUB_POSITION_1];
                _clubPostionChangeUI.txt_2.text = '';
                _clubPostionChangeUI.btn_2.visible = false;
            }else if( targetPosition == CClubConst.CLUB_POSITION_1 ){
                _clubPostionChangeUI.txt_1.text = CClubConst.CLUB_POSITION_STR[CClubConst.CLUB_POSITION_2];
                _clubPostionChangeUI.txt_2.text = '';
                _clubPostionChangeUI.btn_2.visible = false;
            }
        }

        uiCanvas.addPopupDialog( _clubPostionChangeUI );
        _addEventListeners();
    }
    public function removeDisplay() : void {
        if ( _clubPostionChangeUI ) {
            _clubPostionChangeUI.close( Dialog.CLOSE );
        }
    }

    private function _onPositionChangeHandler():void{
        var index : int = _clubPostionChangeUI.radioGroup.selectedIndex;
        if( index < 0 ){
            _pCUISystem.showMsgAlert('请选择要调整的职位');
            return;
        }
        var position : int = CClubConst.CLUB_POSITION_STR.indexOf(_clubPostionChangeUI['txt_' + ( index + 1 ) ].text);
        _pClubHandler.onUpdateClubPositionRequest( _pClubMemberData.roleID,_pClubManager.selfClubData.id, position );
        _clubPostionChangeUI.close( Dialog.CLOSE );
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

    private function get _pClubHandler() : CClubHandler {
        return system.getBean( CClubHandler ) as CClubHandler;
    }
    private function get _pClubManager(): CClubManager{
        return system.getBean( CClubManager ) as CClubManager;
    }
    private function get _pCUISystem():CUISystem{
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }


}
}
