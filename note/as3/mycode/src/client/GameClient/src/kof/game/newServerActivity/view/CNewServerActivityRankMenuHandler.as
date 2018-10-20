//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/5/15.
 */
package kof.game.newServerActivity.view {


import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import kof.framework.CViewHandler;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.playerTeam.CPlayerTeamSystem;
import kof.game.rank.data.CRankMenuConst;
import kof.ui.master.NewServerActivity.NewServerActivityRankUI;
import kof.ui.master.rank.RankMenuUI;

import morn.core.components.Component;

import morn.core.components.Dialog;

public class CNewServerActivityRankMenuHandler extends CViewHandler {

    private var _rankMenuUI : RankMenuUI;

    private var _rankItemViewUI : Component;

    private var _roleID : int;


    public function CNewServerActivityRankMenuHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    public function show( rankItemViewUI : Component ) : void {
        _rankItemViewUI = rankItemViewUI;
        _roleID = _rankItemViewUI.dataSource._id;
        if ( !_rankMenuUI ) {
            _rankMenuUI = new RankMenuUI();
        }
        _addEventListeners();
        var p : Point = _rankItemViewUI.parent.localToGlobal( new Point( _rankItemViewUI.parent.mouseX, _rankItemViewUI.parent.mouseY ) );
        _rankMenuUI.x = p.x - 30;
        if( p.y + _rankMenuUI.height > system.stage.flashStage.stageHeight ){
            p.y = system.stage.flashStage.stageHeight - _rankMenuUI.height + 10;
        }else{
            _rankMenuUI.y = p.y - 30;
        }

        _rankMenuUI.popupCenter = false;
        uiCanvas.addDialog( _rankMenuUI );
    }
    private function _onMenuSelectedHandler( evt : Event ) : void {
        var selectedIndex : int = _rankMenuUI.menu.selectedIndex;
        if( selectedIndex < 0 )
            return;
        _onMenuCloseHandler();
        var label : String = CRankMenuConst.LABELS[selectedIndex];
        switch( label ){
            case CRankMenuConst.PLAYER_INFO:{

                (system.stage.getSystem( CPlayerTeamSystem) as CPlayerTeamSystem ).showPlayerInfo( _roleID );

                break;
            }
        }

    }

    private function _onMenuCloseHandler( evt : MouseEvent = null) : void {
        if ( _rankMenuUI )
            _rankMenuUI.close( Dialog.CLOSE );
        _removeEventListeners();
    }
    private function _addEventListeners():void{
        _removeEventListeners();
        if( _rankMenuUI ){
            _rankMenuUI.menu.addEventListener( Event.CHANGE, _onMenuSelectedHandler, false, 0, true );
            _rankMenuUI.menu.addEventListener( MouseEvent.ROLL_OUT, _onMenuCloseHandler, false, 0, true );
        }
    }
    private function _removeEventListeners():void{
        if( _rankMenuUI ){
            _rankMenuUI.menu.removeEventListener( Event.CHANGE, _onMenuSelectedHandler );
            _rankMenuUI.menu.removeEventListener( MouseEvent.ROLL_OUT, _onMenuCloseHandler );
        }
    }

    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }

}
}

