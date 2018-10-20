//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/30.
 * 俱乐部创建
 */
package kof.game.club.view {

import flash.events.Event;
import flash.events.FocusEvent;

import kof.SYSTEM_ID;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.club.CClubEvent;
import kof.game.club.CClubHandler;
import kof.game.club.data.CClubConst;
import kof.game.club.data.CClubPath;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.table.ClubConstant;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;
import kof.ui.master.club.ClubCreateUI;
import kof.util.CTextFieldInputUtil;

import morn.core.components.Dialog;

import morn.core.handlers.Handler;

public class CClubCreateViewHandler extends CViewHandler {

    private var _clubCreateUI : ClubCreateUI;

    private var _iconID : int;

    public function CClubCreateViewHandler() {
        super( false );
    }
    override public function get viewClass() : Array {
        return [ ClubCreateUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if( !_clubCreateUI ){
            _clubCreateUI = new ClubCreateUI();

            _clubCreateUI.closeHandler = new Handler( _onClose );
            _clubCreateUI.btn_icon.clickHandler = new Handler( _onClubIconHandler );
            _clubCreateUI.btn_create.clickHandler = new Handler( _onClubCreateHandler );
        }

        return Boolean( _clubCreateUI );
    }
    private function _onClubIconHandler():void{
        _pClubIconViewHandler.addDisplay();
    }
    private function _onClubCreateHandler():void{
        if( _clubCreateUI.txt_name.text == CClubConst.DEFAUL_NAME || _clubCreateUI.txt_name.text.length <= 0 ){
            uiCanvas.showMsgAlert('俱乐部名称不能为空');
            return;
        }
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.CLUBCONSTANT );
        var clubConstant : ClubConstant =  pTable.findByPrimaryKey(1);
        if( _playerData.vipData.vipLv < clubConstant.vipLevelLimit ){
            uiCanvas.showMsgAlert('需达到vip' + clubConstant.vipLevelLimit + '才能创建俱乐部');
            return;
        }

        _pClubHandler.onCreateClubRequest( _clubCreateUI.txt_name.text, _iconID );

        var playerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
        var blueDiamond : int = playerSystem.playerData.currency.blueDiamond;
        var cost:int = clubConstant == null ? 0 : clubConstant.diamondsLimit;
        if ( cost > blueDiamond)
        {
            var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
            var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
            bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
        }
    }

    private function _onClubIconChange( evt: CClubEvent ):void{
        var iconID : int = int( evt.data );
        iconChangeHandler( iconID );
    }
    public function iconChangeHandler( iconID : int ):void{
        _clubCreateUI.img_icon.url =  CClubPath.getClubIconUrByID( iconID );
        _iconID = iconID;
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
        var color1 : String = '';
        var color2 : String = '';
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.CLUBCONSTANT );
        var clubConstant : ClubConstant =  pTable.findByPrimaryKey(1);
        _playerData.teamData.level >= clubConstant.roleLevelLimit ? color1 = '#93ff85' : color1 = '#ff8282';
        _playerData.vipData.vipLv >= clubConstant.vipLevelLimit ? color2 = '#93ff85' : color2 = '#ff8282';

        _clubCreateUI.txt_need.text = "战队等级<font color='" +  color1 +  "'>" + clubConstant.roleLevelLimit + "</font>级\n" +
        "vip<font color='" +  color2 +  "'>" + clubConstant.vipLevelLimit + "</font>级";
        _clubCreateUI.txt_coin.text = String( clubConstant.diamondsLimit );

        iconChangeHandler( 100 );
        uiCanvas.addPopupDialog( _clubCreateUI );
        _addEventListeners();
    }
    public function removeDisplay() : void {
        if ( _clubCreateUI ) {
            _clubCreateUI.close( Dialog.CLOSE );
        }
    }
    private function _onCreateClubSucc( evt : CClubEvent ):void{
        var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.GUILD ) );
        pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, false );

        var str : String = '';
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.CLUBCONSTANT );
        var clubConstant : ClubConstant =  pTable.findByPrimaryKey(1);
        str = "恭喜您创建俱乐部并成为会长。为了俱乐部的发展请您积极上线进行游戏。（连续" + clubConstant.autoAccuseDays
                + "天不上线，将被自动弹劾，失去会长职位。）";
        uiCanvas.showMsgBox( str,okFun);
        function okFun():void{
            //        _pClubHandler.onOpenClubRequest();
            var bundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            var bundle : ISystemBundle =  bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.GUILD));
            bundleCtx.setUserData( bundle, CBundleSystem.ACTIVATED, true );
        }

    }

    private function onTxtFocus( evt : FocusEvent ) : void {
        if( evt.type == FocusEvent.FOCUS_IN ){
            if( _clubCreateUI.txt_name.text == CClubConst.DEFAUL_NAME )
                clearTxtInput();
        }else if( evt.type == FocusEvent.FOCUS_OUT ){
            if( _clubCreateUI.txt_name.text.length <= 0 )
                resetTxtInput();
        }
    }
    private function resetTxtInput() : void {
        _clubCreateUI.txt_name.text = CClubConst.DEFAUL_NAME;
    }
    private function clearTxtInput() : void {
        _clubCreateUI.txt_name.text = "";
    }
    private function onTxtChange( evt :Event ):void{
        checkTxtInput();
    }
    private function checkTxtInput():void{
        if( CTextFieldInputUtil.getTextCount( _clubCreateUI.txt_name.text ) > CClubConst.CLUB_NAME_MAX_CHARS ){
            _clubCreateUI.txt_name.text = CTextFieldInputUtil.getSubTextByLength(  _clubCreateUI.txt_name.text, CClubConst.CLUB_NAME_MAX_CHARS );
            _pCUISystem.showMsgAlert('已超出最大字数限制');
        }
    }
    private function _addEventListeners():void{
        _removeEventListeners();
        system.addEventListener( CClubEvent.CREATE_CLUB_SUCC , _onCreateClubSucc );
        system.addEventListener( CClubEvent.CLUB_ICON_CHANGE_REQUEST , _onClubIconChange );
        _clubCreateUI.txt_name.addEventListener( FocusEvent.FOCUS_IN, onTxtFocus, false, 0, true );
        _clubCreateUI.txt_name.addEventListener( FocusEvent.FOCUS_OUT, onTxtFocus, false, 0, true );
        _clubCreateUI.txt_name.addEventListener( Event.CHANGE, onTxtChange, false, 0, true);
    }
    private function _removeEventListeners():void{
        system.removeEventListener( CClubEvent.CREATE_CLUB_SUCC , _onCreateClubSucc );
        system.removeEventListener( CClubEvent.CLUB_ICON_CHANGE_REQUEST , _onClubIconChange );
        _clubCreateUI.txt_name.removeEventListener( FocusEvent.FOCUS_IN, onTxtFocus );
        _clubCreateUI.txt_name.removeEventListener( FocusEvent.FOCUS_OUT, onTxtFocus );
        _clubCreateUI.txt_name.removeEventListener( Event.CHANGE, onTxtChange);
        resetTxtInput();
    }

    private function _onClose( type : String ) : void {
        switch ( type ) {
            default:
                break;
        }
        _removeEventListeners();
    }
    private function get _pClubIconViewHandler() : CClubIconViewHandler {
        return system.getBean( CClubIconViewHandler ) as CClubIconViewHandler;
    }
    private function get _pClubHandler() : CClubHandler {
        return system.getBean( CClubHandler ) as CClubHandler;
    }
    private function get _pClubListViewHandler() : CClubListViewHandler {
        return system.getBean( CClubListViewHandler ) as CClubListViewHandler;
    }
    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _pCUISystem():CUISystem{
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }

}
}
