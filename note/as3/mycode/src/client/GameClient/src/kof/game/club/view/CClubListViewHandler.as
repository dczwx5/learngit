//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/26.
 * 俱乐部大厅 (未加入俱乐部之前)
 */
package kof.game.club.view {

import QFLib.Foundation.CTime;

import flash.events.MouseEvent;

import kof.SYSTEM_ID;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.CSystemBundleContext;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.club.CClubEvent;
import kof.game.club.CClubHandler;
import kof.game.club.CClubManager;
import kof.game.club.data.CClubConst;
import kof.game.club.data.CClubInfoData;
import kof.game.club.data.CClubPath;
import kof.game.common.CLang;
import kof.game.common.CSystemRuleUtil;
import kof.game.common.view.CTweenViewHandler;
import kof.table.ClubUpgradeBasic;
import kof.ui.CUISystem;
import kof.ui.master.club.ClubListItemUI;
import kof.ui.master.club.ClubListUI;

import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CClubListViewHandler extends CTweenViewHandler {

    private var m_pCloseHandler : Handler;

    private var _clubListUI : ClubListUI;

    private var m_bViewInitialized : Boolean;

    public function CClubListViewHandler() {
        super( false );
    }
    override public function dispose() : void {
        super.dispose();

        removeDisplay();
        _clubListUI = null;
    }
    override public function get viewClass() : Array {
        return [ ClubListUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }
    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized ) {
            if ( !_clubListUI ) {
                _clubListUI = new ClubListUI();

                _clubListUI.closeHandler = new Handler( _onClose );
                m_bViewInitialized = true;

                _clubListUI.list.renderHandler = new Handler( renderItem );
                _clubListUI.list.selectHandler = new Handler( selectItemHandler );
                _clubListUI.list.dataSource = [];

                _clubListUI.btn_create.clickHandler = new Handler( _onCreateHandler );
                _clubListUI.btn_quickIn.clickHandler = new Handler( _onQuickInHandler );


                _clubListUI.btn_left.clickHandler = new Handler(_onPageChange,[_clubListUI.btn_left]);
                _clubListUI.btn_right.clickHandler = new Handler(_onPageChange,[_clubListUI.btn_right]);
                _clubListUI.btn_allleft.clickHandler = new Handler(_onPageChange,[_clubListUI.btn_allleft]);
                _clubListUI.btn_allright.clickHandler = new Handler(_onPageChange,[_clubListUI.btn_allright]);

//                _clubListUI.img_tips.toolTip = CClubConst.CLUB_TIPS;
                CSystemRuleUtil.setRuleTips(_clubListUI.img_tips, CLang.Get("club_hall_rule"));
            }
        }

        return m_bViewInitialized;
    }

    private function renderItem(item:Component, idx:int):void {
        if (!(item is ClubListItemUI)) {
            return;
        }
        var pClubListItemUI:ClubListItemUI = item as ClubListItemUI;
        if(pClubListItemUI.dataSource){
             //去掉了
//            pClubListItemUI.clip_rank.visible = pClubListItemUI.dataSource.rank <= 3;
//            if( pClubListItemUI.clip_rank.visible )
//                pClubListItemUI.clip_rank.index = pClubListItemUI.dataSource.rank - 1;
//            pClubListItemUI.txt_rank.visible = pClubListItemUI.dataSource.rank > 3;
//            if( pClubListItemUI.txt_rank.visible )
//                pClubListItemUI.txt_rank.text = String( pClubListItemUI.dataSource.rank );
            pClubListItemUI.img_icon.url = CClubPath.getClubIconUrByID(pClubListItemUI.dataSource.clubSignID);
            pClubListItemUI.txt_name.text = pClubListItemUI.dataSource.name;
            pClubListItemUI.txt_level.text = pClubListItemUI.dataSource.level;
            var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.CLUBUPGRADEBASIC );
            var clubUpgradeBasic : ClubUpgradeBasic =  pTable.findByPrimaryKey( pClubListItemUI.dataSource.level );
            pClubListItemUI.txt_member.text = pClubListItemUI.dataSource.memberCount + '/' + clubUpgradeBasic.memberCountMax ;
            pClubListItemUI.txt_battleValue.num = pClubListItemUI.dataSource.battleValue;
            pClubListItemUI.txt_joinCondition.text = CClubConst.joinConditionStr( pClubListItemUI.dataSource.joinCondition , pClubListItemUI.dataSource.levelCondition );

            pClubListItemUI.btn_apply.disabled = false;
            pClubListItemUI.img_full.visible = false;

            pClubListItemUI.btn_apply.label = '加入';
            if( pClubListItemUI.dataSource.memberCount >= clubUpgradeBasic.memberCountMax ){
                pClubListItemUI.btn_apply.disabled = true;
                pClubListItemUI.img_full.visible = true;
            }else if( pClubListItemUI.dataSource.isApply ){
                pClubListItemUI.btn_apply.disabled = true;
                pClubListItemUI.btn_apply.label = '审核中';
            }

            pClubListItemUI.btn_apply.clickHandler = new Handler( _onItemApplyHandler,[pClubListItemUI.dataSource]);
            pClubListItemUI.txt_name.removeEventListener( MouseEvent.CLICK, _showClubInfoHandler );
            pClubListItemUI.txt_name.addEventListener( MouseEvent.CLICK, _showClubInfoHandler );
        }
    }
    private function selectItemHandler( index : int ) : void {
        var pClubListItemUI : ClubListItemUI = _clubListUI.list.getCell( index ) as ClubListItemUI;
        if ( !pClubListItemUI )
            return;


    }

    private function _onPageChange(...args):void{
        switch ( args[0] ) {
            case _clubListUI.btn_left:{
                if( _pClubManager.curClubListPage <= 1 )
                        return;
                _pClubHandler.onClubInfoListRequest( _pClubManager.curClubListPage - 1 );
                break
            }
            case _clubListUI.btn_right:{
                if( _pClubManager.curClubListPage >= _pClubManager.totalClubListPages )
                    return;
                _pClubHandler.onClubInfoListRequest( _pClubManager.curClubListPage + 1 );
                break
            }
            case _clubListUI.btn_allleft:{
                if( _pClubManager.curClubListPage <= 1 )
                    return;
                _pClubHandler.onClubInfoListRequest( 1 );
                break
            }
            case _clubListUI.btn_allright:{
                if( _pClubManager.curClubListPage >= _pClubManager.totalClubListPages )
                    return;
                _pClubHandler.onClubInfoListRequest( _pClubManager.totalClubListPages );
                break
            }
        }
    }
    private function _onNextJoinClubTime( delta : Number ):void{
        if( CTime.getCurrServerTimestamp() >= _pClubManager.nextJoinClubTime ){
            unschedule( _onNextJoinClubTime );
            _clubListUI.txt_time.visible = _clubListUI.txt_timeT.visible = false;
            return;
        }
        _clubListUI.txt_time.text = CTime.toDurTimeString( _pClubManager.nextJoinClubTime - CTime.getCurrServerTimestamp() );
        _clubListUI.txt_timeT.x = _clubListUI.txt_time.x + _clubListUI.txt_time.textField.textWidth + 3;
        _clubListUI.txt_time.visible = _clubListUI.txt_timeT.visible = true;
    }
    private function _pageBtnDisable():void{
        _clubListUI.btn_left.disabled =
                _clubListUI.btn_allleft.disabled = _pClubManager.curClubListPage <= 1;
        _clubListUI.btn_right.disabled =
                _clubListUI.btn_allright.disabled = _pClubManager.curClubListPage >= _pClubManager.totalClubListPages;
        _clubListUI.txt_page.text = _pClubManager.curClubListPage + '/' + _pClubManager.totalClubListPages;
        if( _pClubManager.totalClubListPages <= 0 )
            _clubListUI.txt_page.text =  '1/1';
    }
    private function _onItemApplyHandler(...args):void{
        var pClubListItemData : CClubInfoData = args[0] as CClubInfoData;
        _pClubHandler.onApplyClubRequest( pClubListItemData.id, CClubConst.SINGLE_APPLY );
    }
    private function _showClubInfoHandler( evt : MouseEvent ):void{
        var pClubListItemUI:ClubListItemUI = evt.currentTarget.parent.parent as ClubListItemUI;
        _pClubInfoViewHandler.addDisplay( pClubListItemUI.dataSource as CClubInfoData );
    }

    private function _onCreateHandler():void{
        _pClubCreateViewHandler.addDisplay();
    }

    private function _onQuickInHandler():void{
        _pClubHandler.onApplyClubRequest('', CClubConst.QUICK_APPLY );
    }

    public function addDisplay() : void {
        this.loadAssetsByView( viewClass, _showDisplay );
    }
    private function _showDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            callLater( _addToDisplay );
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }
    private function _addToDisplay() : void {
        if( _clubListUI && _clubListUI.parent )
            return;
        setTweenData(KOFSysTags.GUILD);
        showDialog(_clubListUI, false, _addToDisplayB);
    }

    private function _addToDisplayB() : void {
        if ( _clubListUI ) {
            _addEventListeners();
            _clubListUI.list.dataSource = _pClubManager.clubList;
            _pageBtnDisable();
//            uiCanvas.addDialog( _clubListUI );

            _clubListUI.txt_time.visible = _clubListUI.txt_timeT.visible = false;
            if( CTime.getCurrServerTimestamp() < _pClubManager.nextJoinClubTime ){
                schedule( 1 , _onNextJoinClubTime );
            }
        }
    }
    public function removeDisplay() : void {
        if (_clubListUI && _clubListUI.parent) {
            closeDialog(_removeDisplayB);
        }

    }
    private function _removeDisplayB() : void {
        if ( _clubListUI ) {
            _clubListUI.close( Dialog.CLOSE );
        }
    }
    private function _onCreateClubSucc( evt : CClubEvent ):void{
        _clubListUI.close( Dialog.CLOSE );
    }
    private function _onClubListUpdate( evt : CClubEvent ):void{
        _clubListUI.list.dataSource = _pClubManager.clubList;
        _pageBtnDisable();
    }
    private function _onClubApplyAndWait( evt : CClubEvent ):void{
        _clubListUI.list.dataSource = _pClubManager.clubList;
        _clubListUI.list.refresh();
    }
    private function _onClubApplyAndIn( evt : CClubEvent ):void{
    }


    private function _addEventListeners() : void {
        _removeEventListeners();
        system.addEventListener( CClubEvent.CREATE_CLUB_SUCC , _onCreateClubSucc );
        system.addEventListener( CClubEvent.CLUB_LIST_RESPONSE , _onClubListUpdate );
        system.addEventListener( CClubEvent.CLUB_APPLY_SUCC_AND_WAITING , _onClubApplyAndWait );
        system.addEventListener( CClubEvent.CLUB_APPLY_SUCC_AND_IN , _onClubApplyAndIn );
    }
    private function _removeEventListeners() : void {
        system.removeEventListener( CClubEvent.CREATE_CLUB_SUCC , _onCreateClubSucc );
        system.removeEventListener(  CClubEvent.CLUB_LIST_RESPONSE , _onClubListUpdate );
        system.removeEventListener( CClubEvent.CLUB_APPLY_SUCC_AND_WAITING , _onClubApplyAndWait );
        system.removeEventListener( CClubEvent.CLUB_APPLY_SUCC_AND_IN , _onClubApplyAndIn );
    }
    private function _onClose( type : String ) : void {

//        if( _clubListUI && !_clubListUI.parent )
//            return;

        switch ( type ) {
            default:
                if ( this.closeHandler ) {
                    this.closeHandler.execute();
                }
                break;
        }
        _removeEventListeners();
        unschedule( _onNextJoinClubTime );
    }
    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }
    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }

    private function get _pClubManager() : CClubManager {
        return system.getBean( CClubManager ) as CClubManager;
    }
    private function get _pClubHandler() : CClubHandler {
        return system.getBean( CClubHandler ) as CClubHandler;
    }
    private function get _pClubInfoViewHandler() : CClubInfoViewHandler {
        return system.getBean( CClubInfoViewHandler ) as CClubInfoViewHandler;
    }
    private function get _pClubCreateViewHandler() : CClubCreateViewHandler {
        return system.getBean( CClubCreateViewHandler ) as CClubCreateViewHandler;
    }

    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    private function get _pCUISystem() : CUISystem {
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }

}
}
