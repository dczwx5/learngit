//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/26.
 * 俱乐部管理者福利
 */
package kof.game.club.view {

import flash.geom.Point;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.club.CClubEvent;
import kof.game.club.CClubHandler;
import kof.game.club.CClubManager;
import kof.game.club.data.CClubConst;
import kof.game.common.CFlyItemUtil;
import kof.game.common.view.CViewExternalUtil;
import kof.game.item.view.part.CRewardItemListView;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.table.ClubUpgradeBasic;
import kof.ui.IUICanvas;
import kof.ui.master.club.ClubManageWelfareUI;

import morn.core.components.Component;

import morn.core.components.Dialog;

import morn.core.handlers.Handler;

public class CClubManageWelfareViewHandler extends CViewHandler {

    private var _clubManageWelfareUI : ClubManageWelfareUI;

    private var m_viewExternal:CViewExternalUtil;

    private var TITLE_ARY : Array = ['会长专属福利','副会长专属福利','理事专属福利'];

    public function CClubManageWelfareViewHandler() {
        super( false );
    }
    override public function get viewClass() : Array {
        return [ ClubManageWelfareUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if( !_clubManageWelfareUI ){
            _clubManageWelfareUI = new ClubManageWelfareUI();

            _clubManageWelfareUI.closeHandler = new Handler( _onClose );
            _clubManageWelfareUI.btn_ok.clickHandler = new Handler( _onGetRewardHandler );
        }
        return Boolean( _clubManageWelfareUI );
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
        uiCanvas.addPopupDialog( _clubManageWelfareUI );
        _addEventListeners();
    }
    public function removeDisplay() : void {
        if ( _clubManageWelfareUI ) {
            _clubManageWelfareUI.close( Dialog.CLOSE );
        }
    }
    private function initUI():void{

        var str : String = ''
        str = _playerData.teamData.name + '你好，为感谢你对' + _pClubManager.selfClubData.name +
                '俱乐部做出的辛劳付出，您在职期间每天可领取以下专属福利一份，俱乐部等级越高福利越丰厚哦';
        _clubManageWelfareUI.txt_tips.text = str;
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.CLUBUPGRADEBASIC );
        var clubUpgradeBasic : ClubUpgradeBasic =  pTable.findByPrimaryKey( _pClubManager.clubLevel );
        var rewardId : int;
        if( clubUpgradeBasic && _pClubManager.clubPosition >= CClubConst.CLUB_POSITION_2 ){
            if( _pClubManager.clubPosition == CClubConst.CLUB_POSITION_4 ){
                rewardId = clubUpgradeBasic.everydayReward[0];
                _clubManageWelfareUI.clip_title.index = 0;
                _clubManageWelfareUI.txt_title.text = TITLE_ARY[0];
            } else if( _pClubManager.clubPosition == CClubConst.CLUB_POSITION_3 ){
                rewardId = clubUpgradeBasic.everydayReward[1];
                _clubManageWelfareUI.clip_title.index = 1;
                _clubManageWelfareUI.txt_title.text = TITLE_ARY[1];
            } else if( _pClubManager.clubPosition == CClubConst.CLUB_POSITION_2 ){
                rewardId = clubUpgradeBasic.everydayReward[2];
                _clubManageWelfareUI.clip_title.index = 2;
                _clubManageWelfareUI.txt_title.text = TITLE_ARY[2];
            }

            m_viewExternal = new CViewExternalUtil(CRewardItemListView, this, _clubManageWelfareUI);
            m_viewExternal.show();
            m_viewExternal.setData( rewardId );
            m_viewExternal.updateWindow();
        }
        _onRewardStateHandler();
    }
    private function _onRewardStateHandler( evt : CClubEvent = null):void{
        _clubManageWelfareUI.btn_ok.disabled = _pClubManager.getClubRewardSign;
        //

        if( evt && _clubManageWelfareUI.reward_list.item_list.dataSource ){
            var len:int = _clubManageWelfareUI.reward_list.item_list.dataSource.length;
            for(var i:int = 0; i < len; i++)
            {
                var item:Component =  _clubManageWelfareUI.reward_list.item_list.getCell(i) as Component;
                CFlyItemUtil.flyItemToBag(item, item.localToGlobal(new Point()), system);
            }
        }
    }
    private function _onGetRewardHandler():void{
        _pClubHandler.onGetOfficerWelfareRequest();
    }
    private function _addEventListeners():void{
        _removeEventListeners();
        system.addEventListener( CClubEvent.GET_OFFICER_WELFARE_RESPONSE ,_onRewardStateHandler );
    }
    private function _removeEventListeners():void{
        system.removeEventListener( CClubEvent.GET_OFFICER_WELFARE_RESPONSE ,_onRewardStateHandler );
    }
    private function _onClose( type : String ) : void {
        switch ( type ) {
            default:
                break;
        }
        _removeEventListeners();
    }
    private function get _pClubHandler(): CClubHandler{
        return system.getBean( CClubHandler ) as CClubHandler;
    }
    private function get _pClubManager(): CClubManager{
        return system.getBean( CClubManager ) as CClubManager;
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }

}
}
