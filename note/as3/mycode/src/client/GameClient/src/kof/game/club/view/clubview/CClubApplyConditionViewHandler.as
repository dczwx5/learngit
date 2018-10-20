//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/2.
 * 俱乐部加入条件改变
 */
package kof.game.club.view.clubview {

import flash.events.Event;

import kof.framework.CViewHandler;
import kof.game.club.CClubHandler;
import kof.game.club.CClubManager;
import kof.game.club.data.CClubConst;
import kof.ui.master.club.ClubApplyConditionUI;

import morn.core.components.Dialog;

import morn.core.handlers.Handler;

public class CClubApplyConditionViewHandler extends CViewHandler {

    private var _clubApplyConditionUI : ClubApplyConditionUI;

    private var _condition : int ;

    private var _levelCondition : int ;

    private static const MIN_LV : int = 1;

    private static const MAX_LV : int = 150;

    public function CClubApplyConditionViewHandler() {
        super( false );
    }
    override public function get viewClass() : Array {
        return [ ClubApplyConditionUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if( !_clubApplyConditionUI ){
            _clubApplyConditionUI = new ClubApplyConditionUI();

            _clubApplyConditionUI.closeHandler = new Handler( _onClose );
            _clubApplyConditionUI.btn_change.clickHandler = new Handler( _onChangeHandler );

            _clubApplyConditionUI.radioGroup_1.selectHandler = new Handler( _onRadioGroupI );
            _clubApplyConditionUI.radioGroup_2.selectHandler = new Handler( _onRadioGroupII );

            _clubApplyConditionUI.btn_left.clickHandler = new Handler( _onPageHandler,[_clubApplyConditionUI.btn_left] );
            _clubApplyConditionUI.btn_right.clickHandler = new Handler( _onPageHandler,[_clubApplyConditionUI.btn_right] );
            _clubApplyConditionUI.txt_lv.restrict = "0-9";
        }

        return Boolean( _clubApplyConditionUI );
    }

    private function _onPageHandler(...args):void{
        var lvCurCondition : int  = int( _clubApplyConditionUI.txt_lv.text );
        switch ( args[0] ){
            case _clubApplyConditionUI.btn_left :{
                if( lvCurCondition <= MIN_LV )
                        return;
                _clubApplyConditionUI.txt_lv.text = String( lvCurCondition - 1 );
                break;
            }
            case _clubApplyConditionUI.btn_right :{
                if( lvCurCondition >= MAX_LV )
                    return;
                _clubApplyConditionUI.txt_lv.text = String( lvCurCondition + 1 );
                break;
            }
        }
    }
    private function _textInputChange( evt : Event ):void{
        if( int( _clubApplyConditionUI.txt_lv.text ) >= MAX_LV )
            _clubApplyConditionUI.txt_lv.text = String( MAX_LV );
        if( int( _clubApplyConditionUI.txt_lv.text ) <= MIN_LV )
            _clubApplyConditionUI.txt_lv.text = String( MIN_LV );
    }
    private function _onRadioGroupI( index : int ):void{
        index
    }
    private function _onRadioGroupII( index : int ):void{
        index
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
        initUI();
        uiCanvas.addPopupDialog( _clubApplyConditionUI );
        _addEventListeners();
    }
    public function removeDisplay() : void {
        if ( _clubApplyConditionUI ) {
            _clubApplyConditionUI.close( Dialog.CLOSE );
        }
    }
    //修改条件  1允许任何人加入 2 允许任何人申请 3 允许任何人加入有等级限制 4允许任何人申请但有等级限制 5不允许任何人加入
    //等级限制 1,2,5,传0  3,4传相应的等级限制
    private function initUI():void{
        _condition = _pClubManager.selfClubData.joinCondition;
        _levelCondition = _pClubManager.selfClubData.levelCondition;
        _clubApplyConditionUI.txt_lv.text = '1';
        switch (_condition){
            case CClubConst.ANYONE_IN :{
                _clubApplyConditionUI.radioGroup_1.selectedIndex = 0;
                _clubApplyConditionUI.radioGroup_2.selectedIndex = 1;
                break;
            }
            case CClubConst.ANYONE_APPLY :{
                _clubApplyConditionUI.radioGroup_1.selectedIndex = 1;
                _clubApplyConditionUI.radioGroup_2.selectedIndex = 1;
                break;
            }
            case CClubConst.ANYONE_IN_AND_LV :{
                _clubApplyConditionUI.radioGroup_1.selectedIndex = 0;
                _clubApplyConditionUI.radioGroup_2.selectedIndex = 0;
                _clubApplyConditionUI.txt_lv.text = String( _levelCondition );
                break;
            }
            case CClubConst.ANYONE_APPLY_AND_LV :{
                _clubApplyConditionUI.radioGroup_1.selectedIndex = 1;
                _clubApplyConditionUI.radioGroup_2.selectedIndex = 0;
                _clubApplyConditionUI.txt_lv.text = String( _levelCondition );
                break;
            }
            case CClubConst.NOONE :{
                _clubApplyConditionUI.radioGroup_1.selectedIndex = 2;
                _clubApplyConditionUI.radioGroup_2.selectedIndex = 1;
                break;
            }
        }
    }

    private function _addEventListeners():void{
        _removeEventListeners();
        _clubApplyConditionUI.txt_lv.addEventListener( Event.CHANGE, _textInputChange );
    }
    private function _removeEventListeners():void{
        _clubApplyConditionUI.txt_lv.removeEventListener( Event.CHANGE, _textInputChange );
    }

    private function _onChangeHandler():void{
        var condition : int;
        var lvCondition : int;
        var conditionSelectedIndex : int = _clubApplyConditionUI.radioGroup_1.selectedIndex;
        var lvSelectedIndex : int = _clubApplyConditionUI.radioGroup_2.selectedIndex;
        if( conditionSelectedIndex == 0 ){
            if( lvSelectedIndex == 0 ){
                condition = CClubConst.ANYONE_IN_AND_LV;
                lvCondition = int( _clubApplyConditionUI.txt_lv.text );
            }else if( lvSelectedIndex == 1 ){
                condition = CClubConst.ANYONE_IN;
                lvCondition = 0;
            }
        }else if( conditionSelectedIndex == 1 ){
            if( lvSelectedIndex == 0 ){
                condition = CClubConst.ANYONE_APPLY_AND_LV;
                lvCondition = int( _clubApplyConditionUI.txt_lv.text );
            }else if( lvSelectedIndex == 1 ){
                condition = CClubConst.ANYONE_APPLY;
                lvCondition = 0;
            }
        }else if( conditionSelectedIndex == 2 ){
            condition = CClubConst.NOONE;
            lvCondition = 0;
        }
        _pClubHandler.onModifyJoinClubConditionRequest( _pClubManager.selfClubData.id,condition,lvCondition );
        _clubApplyConditionUI.close( Dialog.CLOSE );
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
    private function get _pClubManager() : CClubManager {
        return system.getBean( CClubManager ) as CClubManager;
    }
}
}
