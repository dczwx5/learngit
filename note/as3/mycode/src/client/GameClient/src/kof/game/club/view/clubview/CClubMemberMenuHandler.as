//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/7.
 */
package kof.game.club.view.clubview {

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import kof.framework.CViewHandler;
import kof.game.club.CClubHandler;
import kof.game.club.CClubManager;
import kof.game.club.data.CClubConst;
import kof.game.club.data.CClubMemberData;
import kof.ui.CUISystem;
import kof.ui.master.club.ClubMemberItemUI;
import kof.ui.master.club.ClubMemberMenuUI;

import morn.core.components.Dialog;

public class CClubMemberMenuHandler extends CViewHandler {

    private var _clubMemberMenuUI : ClubMemberMenuUI;

    private var _pClubMemberItemUI : ClubMemberItemUI;

    public function CClubMemberMenuHandler() {
        super( false );
    }
    override public function get viewClass() : Array {
        return [ ClubMemberMenuUI,ClubMemberItemUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if( !_clubMemberMenuUI ){
            _clubMemberMenuUI = new ClubMemberMenuUI();
            _clubMemberMenuUI.menu.addEventListener(Event.CHANGE,_onMenuSelectedHandler, false, 0, true);
            _clubMemberMenuUI.menu.addEventListener(MouseEvent.ROLL_OUT, _onMenuRollHandler, false, 0, true);
        }

        return Boolean( _clubMemberMenuUI );
    }

    public function addDisplay( pClubMemberItemUI:ClubMemberItemUI ) : void {
        _pClubMemberItemUI = pClubMemberItemUI;
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
        var targetPosition : int = _pClubMemberItemUI.dataSource.position ;
        var labels:String;
        if( _pClubManager.clubPosition == CClubConst.CLUB_POSITION_4 ){
            if( targetPosition == CClubConst.CLUB_POSITION_3 )
                labels =  CClubConst.TRANSFER_CHAIRMEN + ',' + CClubConst.CHANGE_POSITION  + ',' + CClubConst.CLUB_FIRE;
//                labels = CClubConst.CHECK_INFO + ',' + CClubConst.TRANSFER_CHAIRMEN + ',' + CClubConst.CHANGE_POSITION  + ',' + CClubConst.CLUB_FIRE;
            else
                labels =  CClubConst.CHANGE_POSITION  + ',' + CClubConst.CLUB_FIRE;
//                labels = CClubConst.CHECK_INFO +  ',' + CClubConst.CHANGE_POSITION  + ',' + CClubConst.CLUB_FIRE;
        } else if( _pClubManager.clubPosition == CClubConst.CLUB_POSITION_3 ){
            if( targetPosition == CClubConst.CLUB_POSITION_2 || targetPosition == CClubConst.CLUB_POSITION_1 )
                labels =  CClubConst.CHANGE_POSITION  + ',' + CClubConst.CLUB_FIRE;
//                labels = CClubConst.CHECK_INFO +  ',' + CClubConst.CHANGE_POSITION  + ',' + CClubConst.CLUB_FIRE;
        }
        _clubMemberMenuUI.menu.labels = labels;
        var p:Point = _pClubMemberItemUI.parent.localToGlobal(new Point(_pClubMemberItemUI.parent.mouseX,_pClubMemberItemUI.parent.mouseY));
        _clubMemberMenuUI.x = p.x - 40;
        _clubMemberMenuUI.y = p.y - 30;
        _clubMemberMenuUI.popupCenter = false;
        uiCanvas.addPopupDialog( _clubMemberMenuUI );
    }
    public function removeDisplay() : void {
        if ( _clubMemberMenuUI ) {
            _clubMemberMenuUI.close( Dialog.CLOSE );
        }
    }
    private function _onMenuSelectedHandler(evt:Event):void{
        var selectedIndex:int = _clubMemberMenuUI.menu.selectedIndex;
        var label:String = _clubMemberMenuUI.menu.labels.split(",")[selectedIndex];
        var str :String = '';
        if( selectedIndex != -1){
            _clubMemberMenuUI.remove();
            switch ( label ){
                case CClubConst.CHECK_INFO :
                    _pCUISystem.showMsgAlert('查看会员信息（待策划补充文案）');
                    break;
                case CClubConst.TRANSFER_CHAIRMEN :
                    str = "您目前是<font color='#ff8282'>" + _pClubManager.selfClubData.name  + "</font>的" +
                            "<font color='#ff8282'>会长</font>，确定将职位转给<font color='#ff8282'>" +
                            _pClubMemberItemUI.dataSource.name + "</font>吗？成功转让之后你将成为普通会员。";
                    _pCUISystem.showMsgBox( str,onTransfer );
                    function onTransfer():void{
                        _pClubHandler.onUpdateClubPositionRequest( _pClubMemberItemUI.dataSource.roleID,_pClubManager.selfClubData.id,CClubConst.CLUB_POSITION_4 );
                    }
                    break;
                case CClubConst.CHANGE_POSITION :
                    _pClubPositionChangeViewHandler.addDisplay( _pClubMemberItemUI.dataSource as CClubMemberData );
                    break;
                case CClubConst.CLUB_FIRE :
                    str = '你确定将' + _pClubMemberItemUI.dataSource.name + '请离吗?';
                    _pCUISystem.showMsgBox( str,onFire );
                    function onFire():void{
                        _pClubHandler.onKickOutClubRequest( _pClubMemberItemUI.dataSource.roleID,_pClubManager.selfClubData.id );
                    }
                    break;
            }
        }
    }

    private function _onMenuRollHandler(evt:MouseEvent):void{
        if(_clubMemberMenuUI)
            _clubMemberMenuUI.close();
    }

    private function get _pClubHandler(): CClubHandler{
        return system.getBean( CClubHandler ) as CClubHandler;
    }
    private function get _pClubManager(): CClubManager{
        return system.getBean( CClubManager ) as CClubManager;
    }
    private function get _pClubPositionChangeViewHandler(): CClubPositionChangeViewHandler{
        return system.getBean( CClubPositionChangeViewHandler ) as CClubPositionChangeViewHandler;
    }
    private function get _pCUISystem():CUISystem{
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }
}
}
