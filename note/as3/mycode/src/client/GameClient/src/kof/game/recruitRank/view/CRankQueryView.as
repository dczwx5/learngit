//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/5/24.
 */
package kof.game.recruitRank.view {

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import kof.framework.CViewHandler;
import kof.game.playerTeam.CPlayerTeamSystem;
import kof.game.rank.data.CRankMenuConst;
import kof.ui.master.rank.RankMenuUI;

import morn.core.components.Component;

import morn.core.components.Dialog;

public class CRankQueryView extends CViewHandler{

    public function CRankQueryView() {
        super(false);
    }

    private var _rankMenuUI : RankMenuUI;
    private var _roleId : Number;
    public function show( item : Component, roleId:Number ) : void {
        _roleId = roleId;
        if ( !_rankMenuUI ) {
            _rankMenuUI = new RankMenuUI();
        }
        _addEventListeners();
        var p : Point = item.parent.localToGlobal( new Point( item.parent.mouseX, item.parent.mouseY ) );
        _rankMenuUI.x = p.x - 30;
        if( p.y + _rankMenuUI.height > system.stage.flashStage.stageHeight ){
            p.y = system.stage.flashStage.stageHeight - _rankMenuUI.height + 10;
        }else{
            _rankMenuUI.y = p.y - 30;
        }
        _rankMenuUI.popupCenter = false;
        uiCanvas.addDialog( _rankMenuUI );
    }
    private function _onMenuSelectedHandler( evt : Event ) : void
    {
        var selectedIndex : int = _rankMenuUI.menu.selectedIndex;
        if( selectedIndex < 0 )
            return;
        _onMenuCloseHandler();
        var label : String = CRankMenuConst.LABELS[selectedIndex];
        switch( label )
        {
            case CRankMenuConst.PLAYER_INFO:{
                    (system.stage.getSystem( CPlayerTeamSystem) as CPlayerTeamSystem ).showPlayerInfo( _roleId );
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

}
}
