//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/13.
 */
package kof.game.club.view.welfarebag {

import flash.events.MouseEvent;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;

import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.club.CClubHandler;
import kof.game.club.CClubManager;
import kof.game.club.data.CClubConst;
import kof.table.ClubConstant;
import kof.ui.master.club.ClubWelfareBagSendUI;

import morn.core.handlers.Handler;

public class CClubWelfareBagSendViewHandler extends CViewHandler {

    private var _clubWelfareBagSendUI : ClubWelfareBagSendUI;

    private var _selectedIndex:int;

    public function CClubWelfareBagSendViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }
    public function updateView( clubWelfareBagSendUI : ClubWelfareBagSendUI ):void{
        _clubWelfareBagSendUI = clubWelfareBagSendUI;
        resetAllItem();
        _addEventListeners();

        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.CLUBCONSTANT );
        var clubConstant : ClubConstant =  pTable.findByPrimaryKey(1);
        _clubWelfareBagSendUI.txt_num.text = '今日已发福袋次数：' + _pClubManager.sendBagCounts + '/' + clubConstant.sendPlayerBagTimes;
    }
    private function resetAllItem():void{
        _clubWelfareBagSendUI.img_light_1.visible =
                _clubWelfareBagSendUI.img_light_2.visible =
                        _clubWelfareBagSendUI.img_light_3.visible = false;
        _clubWelfareBagSendUI.eff_get_1.visible =
                _clubWelfareBagSendUI.eff_get_2.visible =
                        _clubWelfareBagSendUI.eff_get_3.visible = false;
        _clubWelfareBagSendUI.eff_baozha_1.visible =
                _clubWelfareBagSendUI.eff_baozha_2.visible =
                        _clubWelfareBagSendUI.eff_baozha_3.visible = false;
    }
    private function _onItemCkHandler( ...args ):void{

        if( args[0] == _clubWelfareBagSendUI.btn_1 ){
            _selectedIndex = 1;
        }else if( args[0] == _clubWelfareBagSendUI.btn_2 ){
            _selectedIndex = 2;
        }else if( args[0] == _clubWelfareBagSendUI.btn_3 ){
            _selectedIndex = 3;
        }

        _pClubBagSendInfoViewHandler.addDisplay( _selectedIndex );
    }
    private function _onLogCkHandler( evt:MouseEvent ):void{
        _pClubSendWelfareBagLogViewHandler.addDisplay( );
    }
    private function _onRollEffHandler( evt : MouseEvent ):void{
        if( evt.currentTarget == _clubWelfareBagSendUI.btn_1 && evt.type == MouseEvent.ROLL_OVER ){
            _clubWelfareBagSendUI.img_light_1.visible = true;
        }else if( evt.currentTarget == _clubWelfareBagSendUI.btn_1 && evt.type == MouseEvent.ROLL_OUT ){
            _clubWelfareBagSendUI.img_light_1.visible = false;
        }else if( evt.currentTarget == _clubWelfareBagSendUI.btn_2 && evt.type == MouseEvent.ROLL_OVER ){
            _clubWelfareBagSendUI.img_light_2.visible = true;
        }else if( evt.currentTarget == _clubWelfareBagSendUI.btn_2 && evt.type == MouseEvent.ROLL_OUT ){
            _clubWelfareBagSendUI.img_light_2.visible = false;
        }else if( evt.currentTarget == _clubWelfareBagSendUI.btn_3 && evt.type == MouseEvent.ROLL_OVER ){
            _clubWelfareBagSendUI.img_light_3.visible = true;
        }else if( evt.currentTarget == _clubWelfareBagSendUI.btn_3 && evt.type == MouseEvent.ROLL_OUT ){
            _clubWelfareBagSendUI.img_light_3.visible = false;
        }
    }
    private function _addEventListeners():void{
        _removeEventListeners();

        _clubWelfareBagSendUI.btn_1.clickHandler = new Handler( _onItemCkHandler ,[ _clubWelfareBagSendUI.btn_1 ]);
        _clubWelfareBagSendUI.btn_2.clickHandler = new Handler( _onItemCkHandler ,[ _clubWelfareBagSendUI.btn_2 ]);
        _clubWelfareBagSendUI.btn_3.clickHandler = new Handler( _onItemCkHandler ,[ _clubWelfareBagSendUI.btn_3 ]);

        _clubWelfareBagSendUI.btn_1.addEventListener( MouseEvent.ROLL_OVER, _onRollEffHandler ,false,0,true );
        _clubWelfareBagSendUI.btn_1.addEventListener( MouseEvent.ROLL_OUT, _onRollEffHandler ,false,0,true);
        _clubWelfareBagSendUI.btn_2.addEventListener( MouseEvent.ROLL_OVER, _onRollEffHandler ,false,0,true);
        _clubWelfareBagSendUI.btn_2.addEventListener( MouseEvent.ROLL_OUT, _onRollEffHandler ,false,0,true);
        _clubWelfareBagSendUI.btn_3.addEventListener( MouseEvent.ROLL_OVER, _onRollEffHandler ,false,0,true);
        _clubWelfareBagSendUI.btn_3.addEventListener( MouseEvent.ROLL_OUT, _onRollEffHandler ,false,0,true);

        _clubWelfareBagSendUI.box_rank.addEventListener( MouseEvent.CLICK, _onLogCkHandler, false, 0, true );
    }
    private function _removeEventListeners():void{
        _clubWelfareBagSendUI.box_rank.removeEventListener( MouseEvent.CLICK, _onLogCkHandler );

        _clubWelfareBagSendUI.btn_1.removeEventListener( MouseEvent.ROLL_OVER, _onRollEffHandler );
        _clubWelfareBagSendUI.btn_1.removeEventListener( MouseEvent.ROLL_OUT, _onRollEffHandler );
        _clubWelfareBagSendUI.btn_2.removeEventListener( MouseEvent.ROLL_OVER, _onRollEffHandler );
        _clubWelfareBagSendUI.btn_2.removeEventListener( MouseEvent.ROLL_OUT, _onRollEffHandler );
        _clubWelfareBagSendUI.btn_3.removeEventListener( MouseEvent.ROLL_OVER, _onRollEffHandler );
        _clubWelfareBagSendUI.btn_3.removeEventListener( MouseEvent.ROLL_OUT, _onRollEffHandler );
    }

    override public function dispose() : void {
        super.dispose();
        _removeEventListeners();
    }

    private function get _pClubHandler() : CClubHandler {
        return system.getBean( CClubHandler ) as CClubHandler;
    }
    private function get _pClubManager() : CClubManager {
        return system.getBean( CClubManager ) as CClubManager;
    }
    private function get _pClubBagSendInfoViewHandler():CClubBagSendInfoViewHandler{
        return system.getBean( CClubBagSendInfoViewHandler ) as CClubBagSendInfoViewHandler;
    }
    private function get _pClubSendWelfareBagLogViewHandler():CClubSendWelfareBagLogViewHandler{
        return system.getBean( CClubSendWelfareBagLogViewHandler ) as CClubSendWelfareBagLogViewHandler;
    }
    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
}
}
