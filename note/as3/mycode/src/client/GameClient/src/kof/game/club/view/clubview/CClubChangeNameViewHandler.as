//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/5.
 * 修改俱乐部名称
 */
package kof.game.club.view.clubview {

import flash.events.Event;
import flash.events.FocusEvent;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.club.CClubHandler;
import kof.game.club.CClubManager;
import kof.game.club.data.CClubConst;
import kof.game.reciprocation.CReciprocalSystem;
import kof.table.ClubConstant;
import kof.ui.CUISystem;
import kof.ui.master.club.ClubNameChangeUI;
import kof.util.CTextFieldInputUtil;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CClubChangeNameViewHandler extends CViewHandler {

    private var _clubNameChangeUI :ClubNameChangeUI;
    public function CClubChangeNameViewHandler() {
        super( false );
    }
    override public function get viewClass() : Array {
        return [ ClubNameChangeUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if( !_clubNameChangeUI ){
            _clubNameChangeUI = new ClubNameChangeUI();

            _clubNameChangeUI.closeHandler = new Handler( _onClose );
            _clubNameChangeUI.btn_change.clickHandler = new Handler( _onChangeHandler );
        }

        return Boolean( _clubNameChangeUI );
    }

    private function _onChangeHandler():void{
        if( _clubNameChangeUI.txt_name.text == CClubConst.DEFAUL_NAME || _clubNameChangeUI.txt_name.text.length <= 0 ){
            uiCanvas.showMsgAlert('俱乐部名称不能为空');
            return;
        }
        if( _clubNameChangeUI.txt_name.text == _pClubManager.selfClubData.name ){
            uiCanvas.showMsgAlert('俱乐部名称没有改变');
            return;
        }

        uiCanvas.showMsgBox( '需要消耗' + int(_clubNameChangeUI.txt_money.text) + '绑钻，确定继续吗？',okFun,null,true,null,null,true,"COST_BIND_D" );
        function okFun():void{
            (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem).showCostBdDiamondMsgBox( int(_clubNameChangeUI.txt_money.text), buySkill );
        }
        function buySkill():void{
            _pClubHandler.onModifyClubInfoRequest('', _clubNameChangeUI.txt_name.text, 0, CClubConst.CHANGE_NAME );
            _clubNameChangeUI.close( Dialog.CLOSE );
        }


    }
    private function onTxtFocus( evt : FocusEvent ) : void {
        if( evt.type == FocusEvent.FOCUS_IN ){
            if( _clubNameChangeUI.txt_name.text == CClubConst.DEFAUL_NAME )
                clearTxtInput();
        }else if( evt.type == FocusEvent.FOCUS_OUT ){
            if( _clubNameChangeUI.txt_name.text.length <= 0 )
                resetTxtInput();
        }
    }
    private function resetTxtInput() : void {
        _clubNameChangeUI.txt_name.text = CClubConst.DEFAUL_NAME;
    }
    private function clearTxtInput() : void {
        _clubNameChangeUI.txt_name.text = "";
    }
    private function onTxtChange( evt :Event ):void{
        checkTxtInput();
    }
    private function checkTxtInput():void{
        if( CTextFieldInputUtil.getTextCount( _clubNameChangeUI.txt_name.text ) > CClubConst.CLUB_NAME_MAX_CHARS ){
            _clubNameChangeUI.txt_name.text = CTextFieldInputUtil.getSubTextByLength(  _clubNameChangeUI.txt_name.text, CClubConst.CLUB_NAME_MAX_CHARS );
            _pCUISystem.showMsgAlert('已超出最大字数限制');
        }
    }
    private function _addEventListeners():void{
        _removeEventListeners();
        _clubNameChangeUI.txt_name.addEventListener( FocusEvent.FOCUS_IN, onTxtFocus, false, 0, true );
        _clubNameChangeUI.txt_name.addEventListener( FocusEvent.FOCUS_OUT, onTxtFocus, false, 0, true );
        _clubNameChangeUI.txt_name.addEventListener( Event.CHANGE, onTxtChange, false, 0, true);
    }
    private function _removeEventListeners():void{
        _clubNameChangeUI.txt_name.removeEventListener( FocusEvent.FOCUS_IN, onTxtFocus );
        _clubNameChangeUI.txt_name.removeEventListener( FocusEvent.FOCUS_OUT, onTxtFocus );
        _clubNameChangeUI.txt_name.removeEventListener( Event.CHANGE, onTxtChange);
        resetTxtInput();
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
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.CLUBCONSTANT );
        var clubConstant : ClubConstant =  pTable.findByPrimaryKey(1);
        _clubNameChangeUI.txt_money.text = String( clubConstant.modifyClubNameConsumeDiamond ) ;
        uiCanvas.addPopupDialog( _clubNameChangeUI );
        _addEventListeners();
    }
    public function removeDisplay() : void {
        if ( _clubNameChangeUI ) {
            _clubNameChangeUI.close( Dialog.CLOSE );
        }
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
    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    private function get _pClubManager(): CClubManager{
        return system.getBean( CClubManager ) as CClubManager;
    }
    private function get _pCUISystem():CUISystem{
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }
}
}
