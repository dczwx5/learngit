//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/15.
 * 玩家自己手气记录
 */
package kof.game.club.view.welfarebag {

import flash.utils.Dictionary;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;

import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.club.CClubEvent;
import kof.game.club.CClubHandler;
import kof.game.club.CClubManager;
import kof.game.club.data.CClubConst;
import kof.message.Club.PlayerLuckyBagRecordResponse;
import kof.table.Currency;
import kof.table.Item;
import kof.ui.master.club.ClubSelfWelfareBagLogUI;

import morn.core.components.Dialog;

import morn.core.handlers.Handler;

public class CClubSelfBagLogViewHandler extends CViewHandler {

    private var _clubSelfWelfareBagLogUI : ClubSelfWelfareBagLogUI;

    public function CClubSelfBagLogViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array {
        return [ ClubSelfWelfareBagLogUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !_clubSelfWelfareBagLogUI ) {
            _clubSelfWelfareBagLogUI = new ClubSelfWelfareBagLogUI();
        }

        return Boolean( _clubSelfWelfareBagLogUI );
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
        _addEventListeners();
        _pClubHandler.onPlayerLuckyBagRecordRequest();
        uiCanvas.addPopupDialog( _clubSelfWelfareBagLogUI );
    }
    public function removeDisplay() : void {
        if ( _clubSelfWelfareBagLogUI ) {
            _clubSelfWelfareBagLogUI.close( Dialog.CLOSE );
        }
    }
    private function _onSingleBagRecordResponseHandler( evt :CClubEvent ):void{
    }
    private function _onRecordResponseHandler( evt : CClubEvent ) : void{

        var logList : Array;
        var logObj : Object;
        var str : String = '';
        var date : Date;
        var logDicAry : Array = evt.data as Array;
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.CURRENCY );
        var pTableItem : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.ITEM );
        var currency : Currency;
        var item : Item;
        var reward :  Object;
        for each( logList in logDicAry ){
            date = new Date( logList[0].time );
            str = str + (date.month + 1 ) + '月' + date.date + '日' + '\n';
            for each( logObj in logList ){
                for each( reward in logObj.rewardList ){
                    currency  =  pTable.findByPrimaryKey( reward.ID );
                    if(currency){
                        reward.rewardName = currency.name;
                    }else{
                        item = pTableItem.findByPrimaryKey( reward.ID );
                        if( item ){
                            reward.rewardName = item.name;
                        }
                    }

                }
                str = str + CClubConst.baglogStr( logObj ) + '\n';
            }
            str = str + '\n';
        }
        _clubSelfWelfareBagLogUI.txt_log.text = str;
        _clubSelfWelfareBagLogUI.txt_log.height = _clubSelfWelfareBagLogUI.txt_log.textField.textHeight ;

    }
    private function _addEventListeners():void{
        _removeEventListeners();
        system.addEventListener( CClubEvent.PLAYER_LUCKY_BAG_RECORD_RESPONSE  , _onRecordResponseHandler );
    }
    private function _removeEventListeners():void{
        system.removeEventListener( CClubEvent.PLAYER_LUCKY_BAG_RECORD_RESPONSE  , _onRecordResponseHandler );
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
    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
}
}
