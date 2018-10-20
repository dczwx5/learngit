//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/13.
 * 俱乐部福袋
 */
package kof.game.club.view.welfarebag {

import QFLib.Foundation.CTime;

import flash.events.Event;
import flash.events.MouseEvent;

import kof.data.CDataTable;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.club.CClubEvent;
import kof.game.club.CClubHandler;
import kof.game.club.CClubManager;
import kof.game.club.data.CClubConst;
import kof.game.club.data.CClubConst;
import kof.game.club.data.CClubWelfareBagData;
import kof.game.item.CItemSystem;
import kof.game.item.view.tips.CItemTipsView;
import kof.message.Club.GetLuckyBagResponse;
import kof.table.ClubUpgradeBasic;
import kof.table.DropPackage;
import kof.table.LuckyBagConfig;
import kof.ui.master.club.ClubWelfareBagViewUI;

import morn.core.events.UIEvent;

import morn.core.handlers.Handler;

public class CClubWelfareBagInfoViewHandler extends CViewHandler {

    private var _clubWelfareBagViewUI : ClubWelfareBagViewUI;

    private var _selectedIndex:int;

    private var _effItemIndex:int;

    private var _isShowRequestBagEffing : Boolean;

    private var _isRequestBaging : Boolean;

    public function CClubWelfareBagInfoViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }
    public function updateView( clubWelfareBagViewUI : ClubWelfareBagViewUI ):void{
        _clubWelfareBagViewUI = clubWelfareBagViewUI;
        _clubWelfareBagViewUI.clip_1.visible =
                _clubWelfareBagViewUI.clip_2.visible =
                        _clubWelfareBagViewUI.clip_3.visible = false;
        _clubWelfareBagViewUI.btn_get.visible = false;
        _selectedIndex = 0;
        _effItemIndex = 0;
        resetAllItem();
        stopRequestBagEff();
        stopGotBagEff();
        _isShowRequestBagEffing = false;
        _isRequestBaging = false;
        initUI();
        _addEventListeners();
        _clubWelfareBagViewUI.btn_get.clickHandler = new Handler( _onGetBagHandler );

        _selectedIndex = _pClubManager.clubWelBagIndex;
        if( _selectedIndex > 0 ){
            _effItemIndex = _selectedIndex;
            _clubWelfareBagViewUI['img_light_' + _selectedIndex].visible = true;
            var clubWelfareBagData : CClubWelfareBagData = _pClubManager.getClubSystemBagDataByType( _selectedIndex );
            if( clubWelfareBagData )
                btnStateHandler( clubWelfareBagData );
        }
    }
    public function updateCurItem( ID : String ):void{
        initUI();
        var clubWelfareBagData : CClubWelfareBagData = _pClubManager.getClubSystemBagDataByType( _effItemIndex );
        if( clubWelfareBagData.ID == ID ){
            btnStateHandler( clubWelfareBagData );
        }
    }
    private function _onGetBagHandler():void{
        if( _isRequestBaging )
                return;
        _isShowRequestBagEffing = true;
        _isRequestBaging = true;
        _clubWelfareBagViewUI['box_' + _effItemIndex ].visible = false;
        _clubWelfareBagViewUI['eff_get_' + _effItemIndex].addEventListener( UIEvent.FRAME_CHANGED,onChanged);
        _clubWelfareBagViewUI['eff_get_' + _effItemIndex].visible = true;
        _clubWelfareBagViewUI['eff_get_' + _effItemIndex].gotoAndPlay(0);

        onGetLuckyBagRequest();
    }
    private function onChanged(evt:UIEvent):void{
        if( _clubWelfareBagViewUI['eff_get_' + _effItemIndex].frame >=  _clubWelfareBagViewUI['eff_get_' + _effItemIndex].totalFrame - 150 ){
            _isShowRequestBagEffing = false;
        }
        if( _clubWelfareBagViewUI['eff_get_' + _effItemIndex].frame >=  _clubWelfareBagViewUI['eff_get_' + _effItemIndex].totalFrame - 1) {
            stopRequestBagEff();
        }
    }
    private function stopRequestBagEff():void{
        if( _effItemIndex <= 0 )
                return;
        _clubWelfareBagViewUI['eff_get_' + _effItemIndex].removeEventListener( UIEvent.FRAME_CHANGED,onChanged);
        _clubWelfareBagViewUI['eff_get_' + _effItemIndex].stop();
        _clubWelfareBagViewUI['eff_get_' + _effItemIndex].visible = false;
        _clubWelfareBagViewUI['box_' + _effItemIndex ].visible = true;
    }

    private function onGetLuckyBagRequest():void{
        var clubWelfareBagData : CClubWelfareBagData = _pClubManager.getClubSystemBagDataByType( _selectedIndex );
        _pClubHandler.onGetLuckyBagRequest( CClubConst.CLUB_BAG_LIST , clubWelfareBagData.ID );
    }
    private function onEffAfterResponse():void{
        _clubWelfareBagViewUI['eff_baozha_' + _effItemIndex].addEventListener( UIEvent.FRAME_CHANGED,onChangedII);
        _clubWelfareBagViewUI['eff_baozha_' + _effItemIndex].visible = true;
        _clubWelfareBagViewUI['eff_baozha_' + _effItemIndex].gotoAndPlay(0);
    }
    private function onChangedII(evt:UIEvent):void{
        if( _clubWelfareBagViewUI['eff_baozha_' + _effItemIndex].frame >=  _clubWelfareBagViewUI['eff_baozha_' + _effItemIndex].totalFrame - 1) {
            stopGotBagEff();
            onShowGotBag();
            _isRequestBaging = false;
        }
    }
    private function stopGotBagEff():void{
        if( _effItemIndex <= 0 )
            return;
        _clubWelfareBagViewUI['eff_baozha_' + _effItemIndex].removeEventListener( UIEvent.FRAME_CHANGED,onChangedII);
        _clubWelfareBagViewUI['eff_baozha_' + _effItemIndex].stop();
        _clubWelfareBagViewUI['eff_baozha_' + _effItemIndex].visible = false;
    }
    private function onShowGotBag():void{
        _pClubGetWelfareBagLogViewHandler.addDisplay( _effItemIndex - 1);
    }


    private function initUI():void{
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.LUCKYBAGCONFIG );
        var luckyBagConfig : LuckyBagConfig ;
        var clubWelfareBagData : CClubWelfareBagData;
        var index : int ;
        for( index = CClubConst.BAG_GOLD_TYPE ; index <= CClubConst.BAG_ITEM_TYPE ; index ++ ){
            luckyBagConfig = pTable.findByPrimaryKey( index );
            _clubWelfareBagViewUI['txt_time_' + index ].text = luckyBagConfig.resetTime.replace(',','—');
            clubWelfareBagData = _pClubManager.getClubSystemBagDataByType( index );
            if( !clubWelfareBagData )
                    continue;

            if( clubWelfareBagData.luckyBagState == CClubConst.CLUB_BAG_CAN_GET ){
                _clubWelfareBagViewUI['clip_' + index ].visible = false;
            }else if( clubWelfareBagData.luckyBagState == CClubConst.CLUB_BAG_GOT ){
                _clubWelfareBagViewUI['clip_' + index ].index = 0;
                _clubWelfareBagViewUI['clip_' + index ].visible = true;
            }else if( clubWelfareBagData.luckyBagState == CClubConst.CLUB_BAG_NO_LESS ){
                _clubWelfareBagViewUI['clip_' + index ].index = 1;
                _clubWelfareBagViewUI['clip_' + index ].visible = true;
            }else if( clubWelfareBagData.luckyBagState == CClubConst.CLUB_BAG_NOT_IN_TIME ){
                _clubWelfareBagViewUI['clip_' + index ].visible = false;
            }
        }

        var clubUpgradeBasic : ClubUpgradeBasic;
        var hasGotNum : int;
        pTable = _pCDatabaseSystem.getTable( KOFTableConstants.CLUBUPGRADEBASIC );
        clubUpgradeBasic  =  pTable.findByPrimaryKey( _pClubManager.clubLevel );
        for( index = CClubConst.BAG_GOLD_TYPE ; index <= CClubConst.BAG_ITEM_TYPE ; index ++ ){
            if( index == CClubConst.BAG_GOLD_TYPE ){
                clubWelfareBagData = _pClubManager.getClubSystemBagDataByType( CClubConst.BAG_GOLD_TYPE );
                if( clubWelfareBagData ){
                    _clubWelfareBagViewUI['txt_value_' + index ].text = String( clubWelfareBagData.rewardValue );
                    hasGotNum = clubWelfareBagData.rewardNum;
                    _clubWelfareBagViewUI['txt_num_' + index ].text = hasGotNum + '/' + clubWelfareBagData.totalNum;
                }

            }else if( index == CClubConst.BAG_DIAMONDS_TYPE ){
                clubWelfareBagData = _pClubManager.getClubSystemBagDataByType( CClubConst.BAG_DIAMONDS_TYPE );
                if( clubWelfareBagData ){
                    _clubWelfareBagViewUI['txt_value_' + index ].text = String( clubWelfareBagData.rewardValue );
                    hasGotNum = clubWelfareBagData.rewardNum;
                    _clubWelfareBagViewUI['txt_num_' + index ].text = hasGotNum + '/' + clubWelfareBagData.totalNum;
                }

            }else if( index == CClubConst.BAG_ITEM_TYPE ){
                clubWelfareBagData = _pClubManager.getClubSystemBagDataByType( CClubConst.BAG_ITEM_TYPE );
                if( clubWelfareBagData ){
                    _clubWelfareBagViewUI['txt_value_' + index ].text = String( clubWelfareBagData.rewardNum );
                    hasGotNum = clubWelfareBagData.rewardNum;
                    _clubWelfareBagViewUI['txt_num_' + index ].text = hasGotNum + '/' + clubWelfareBagData.totalNum;
                }

            }
        }


        var packageTable:CDataTable = _pCDatabaseSystem.getTable(KOFTableConstants.DROP_PACKAGE) as CDataTable;
        var packageData:DropPackage = packageTable.findByPrimaryKey( clubUpgradeBasic.systemItemLuckyBag ) as DropPackage;
        _clubWelfareBagViewUI.img_itemTips.toolTip = new Handler( showTips, [ packageData.resourceID1 ] );
    }
    private function showTips( id : int ) : void {
        (system.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView,null,[id]);
    }
    private function _onItemCkHandler( evt : MouseEvent ):void{
        _clubWelfareBagViewUI.img_light_1.visible =
                _clubWelfareBagViewUI.img_light_2.visible =
                        _clubWelfareBagViewUI.img_light_3.visible = false;
        var index : int;
        for( index = CClubConst.BAG_GOLD_TYPE ; index <= CClubConst.BAG_ITEM_TYPE  ; index++ ){
            if( evt.currentTarget == _clubWelfareBagViewUI['box_' + index] ){
                _clubWelfareBagViewUI['img_light_' + index].visible = true;
                _selectedIndex = index;
                if( !_isRequestBaging )
                    _effItemIndex = index;
                break;
            }
        }
        var clubWelfareBagData : CClubWelfareBagData = _pClubManager.getClubSystemBagDataByType( _selectedIndex );
        btnStateHandler( clubWelfareBagData );
    }
    private function btnStateHandler( clubWelfareBagData : CClubWelfareBagData ):void{
        _clubWelfareBagViewUI.btn_get.visible = true;
        if( clubWelfareBagData.luckyBagState == CClubConst.CLUB_BAG_CAN_GET ){
            _clubWelfareBagViewUI.btn_get.disabled = false;
            _clubWelfareBagViewUI.btn_get.label = CClubConst.CLUB_BAG_CAN_GET_STR;
        }else if( clubWelfareBagData.luckyBagState == CClubConst.CLUB_BAG_GOT ){
            _clubWelfareBagViewUI.btn_get.disabled = true;
            _clubWelfareBagViewUI.btn_get.label = CClubConst.CLUB_BAG_GOT_STR;
        }else if( clubWelfareBagData.luckyBagState == CClubConst.CLUB_BAG_NO_LESS ){
            _clubWelfareBagViewUI.btn_get.disabled = true;
            _clubWelfareBagViewUI.btn_get.label = CClubConst.CLUB_BAG_NO_LESS_STR;
        }else if( clubWelfareBagData.luckyBagState == CClubConst.CLUB_BAG_NOT_IN_TIME ){
            _clubWelfareBagViewUI.btn_get.disabled = true;
            _clubWelfareBagViewUI.btn_get.label = CClubConst.CLUB_BAG_NOT_IN_TIME_STR;
        }
    }
    private function resetAllItem():void{
        _clubWelfareBagViewUI.img_light_1.visible =
                _clubWelfareBagViewUI.img_light_2.visible =
                        _clubWelfareBagViewUI.img_light_3.visible = false;
        _clubWelfareBagViewUI.eff_get_1.visible =
                _clubWelfareBagViewUI.eff_get_2.visible =
                        _clubWelfareBagViewUI.eff_get_3.visible = false;
        _clubWelfareBagViewUI.eff_baozha_1.visible =
                _clubWelfareBagViewUI.eff_baozha_2.visible =
                        _clubWelfareBagViewUI.eff_baozha_3.visible = false;
    }
    private function _onLogCkHandler( evt:MouseEvent ):void{
        _pClubGetWelfareBagLogViewHandler.addDisplay( CClubConst.BAG_LOG_GOLD_TYPE);
    }

    private function _getBagResponse( evt : CClubEvent ):void{
        var response:GetLuckyBagResponse = evt.data as GetLuckyBagResponse;
        if( response.type == CClubConst.CLUB_BAG_LIST  ){
            if( _isShowRequestBagEffing == false ){
                onEffAfterResponse();
            }else{
                _clubWelfareBagViewUI.addEventListener(Event.ENTER_FRAME, _onEnHandler );
            }

        }
    }
    private function _onEnHandler( evt : Event ):void{
        if( _isShowRequestBagEffing == false ){
            _clubWelfareBagViewUI.removeEventListener(Event.ENTER_FRAME, _onEnHandler );
            onEffAfterResponse();
        }
    }


    private function _onRollEffHandler( evt : MouseEvent ):void{
        if( evt.currentTarget == _clubWelfareBagViewUI.box_1 && evt.type == MouseEvent.ROLL_OVER ){
            _clubWelfareBagViewUI.img_light_1.visible = true;
        }else if( evt.currentTarget == _clubWelfareBagViewUI.box_1 && evt.type == MouseEvent.ROLL_OUT && _selectedIndex != CClubConst.BAG_GOLD_TYPE ){
            _clubWelfareBagViewUI.img_light_1.visible = false;
        }else if( evt.currentTarget == _clubWelfareBagViewUI.box_2 && evt.type == MouseEvent.ROLL_OVER ){
            _clubWelfareBagViewUI.img_light_2.visible = true;
        }else if( evt.currentTarget == _clubWelfareBagViewUI.box_2 && evt.type == MouseEvent.ROLL_OUT && _selectedIndex != CClubConst.BAG_DIAMONDS_TYPE ){
            _clubWelfareBagViewUI.img_light_2.visible = false;
        }else if( evt.currentTarget == _clubWelfareBagViewUI.box_3 && evt.type == MouseEvent.ROLL_OVER ){
            _clubWelfareBagViewUI.img_light_3.visible = true;
        }else if( evt.currentTarget == _clubWelfareBagViewUI.box_3 && evt.type == MouseEvent.ROLL_OUT && _selectedIndex != CClubConst.BAG_ITEM_TYPE ){
            _clubWelfareBagViewUI.img_light_3.visible = false;
        }
    }
    private function _addEventListeners():void{
        _removeEventListeners();
        _clubWelfareBagViewUI.box_1.addEventListener( MouseEvent.CLICK, _onItemCkHandler, false, 0, true );
        _clubWelfareBagViewUI.box_2.addEventListener( MouseEvent.CLICK, _onItemCkHandler, false, 0, true );
        _clubWelfareBagViewUI.box_3.addEventListener( MouseEvent.CLICK, _onItemCkHandler, false, 0, true );

        _clubWelfareBagViewUI.box_1.addEventListener( MouseEvent.ROLL_OVER, _onRollEffHandler ,false,0,true );
        _clubWelfareBagViewUI.box_1.addEventListener( MouseEvent.ROLL_OUT, _onRollEffHandler ,false,0,true);
        _clubWelfareBagViewUI.box_2.addEventListener( MouseEvent.ROLL_OVER, _onRollEffHandler ,false,0,true);
        _clubWelfareBagViewUI.box_2.addEventListener( MouseEvent.ROLL_OUT, _onRollEffHandler ,false,0,true);
        _clubWelfareBagViewUI.box_3.addEventListener( MouseEvent.ROLL_OVER, _onRollEffHandler ,false,0,true);
        _clubWelfareBagViewUI.box_3.addEventListener( MouseEvent.ROLL_OUT, _onRollEffHandler ,false,0,true);
        
        _clubWelfareBagViewUI.box_log.addEventListener( MouseEvent.CLICK, _onLogCkHandler, false, 0, true );
        _clubWelfareBagViewUI.addEventListener( Event.REMOVED_FROM_STAGE, _onHideHandler, false, 0, true );

        system.addEventListener( CClubEvent.GET_LUCKY_BAG_RESPONSE ,_getBagResponse );
    }
    private function _removeEventListeners():void{
        _clubWelfareBagViewUI.box_1.removeEventListener( MouseEvent.CLICK, _onItemCkHandler );
        _clubWelfareBagViewUI.box_2.removeEventListener( MouseEvent.CLICK, _onItemCkHandler );
        _clubWelfareBagViewUI.box_3.removeEventListener( MouseEvent.CLICK, _onItemCkHandler );
        _clubWelfareBagViewUI.box_log.removeEventListener( MouseEvent.CLICK, _onLogCkHandler );

        _clubWelfareBagViewUI.box_1.removeEventListener( MouseEvent.ROLL_OVER, _onRollEffHandler );
        _clubWelfareBagViewUI.box_1.removeEventListener( MouseEvent.ROLL_OUT, _onRollEffHandler );
        _clubWelfareBagViewUI.box_2.removeEventListener( MouseEvent.ROLL_OVER, _onRollEffHandler );
        _clubWelfareBagViewUI.box_2.removeEventListener( MouseEvent.ROLL_OUT, _onRollEffHandler );
        _clubWelfareBagViewUI.box_3.removeEventListener( MouseEvent.ROLL_OVER, _onRollEffHandler );
        _clubWelfareBagViewUI.box_3.removeEventListener( MouseEvent.ROLL_OUT, _onRollEffHandler );

        _clubWelfareBagViewUI.removeEventListener(Event.ENTER_FRAME, _onEnHandler );

        _clubWelfareBagViewUI.removeEventListener( Event.REMOVED_FROM_STAGE, _onHideHandler );

        system.removeEventListener( CClubEvent.GET_LUCKY_BAG_RESPONSE ,_getBagResponse );
    }
    public function _onHideHandler( evt : Event  = null ):void{
        _removeEventListeners();
        stopRequestBagEff();
        stopGotBagEff();
    }
    override public function dispose() : void {
        super.dispose();
        _removeEventListeners();
    }
    private function get _pClubHandler():CClubHandler{
        return system.getBean(CClubHandler) as CClubHandler;
    }
    private function get _pClubManager():CClubManager{
        return system.getBean(CClubManager) as CClubManager;
    }

    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    private function get _pClubGetWelfareBagLogViewHandler():CClubGetWelfareBagLogViewHandler{
        return system.getBean( CClubGetWelfareBagLogViewHandler ) as CClubGetWelfareBagLogViewHandler;
    }





}
}
