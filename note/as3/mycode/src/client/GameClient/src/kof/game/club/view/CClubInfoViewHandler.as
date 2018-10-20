//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/30.
 * 俱乐部信息小界面
 */
package kof.game.club.view {

import flash.display.DisplayObject;

import kof.SYSTEM_ID;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;

import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.bundle.CSystemBundleContext;
import kof.game.bundle.ISystemBundleContext;
import kof.game.club.CClubHandler;
import kof.game.club.CClubManager;
import kof.game.club.data.CClubConst;
import kof.game.club.data.CClubInfoData;
import kof.game.club.data.CClubPath;
import kof.game.player.config.CPlayerPath;
import kof.table.ClubUpgradeBasic;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;
import kof.ui.master.club.ClubInfoUI;

import morn.core.components.Dialog;

import morn.core.handlers.Handler;

public class CClubInfoViewHandler extends CViewHandler {

    private var _clubInfoUI : ClubInfoUI;

    private var _clubInfoData : CClubInfoData;

    public function CClubInfoViewHandler() {
        super( false );
    }
    override public function get viewClass() : Array {
        return [ ClubInfoUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if( !_clubInfoUI ){
            _clubInfoUI = new ClubInfoUI();

            _clubInfoUI.closeHandler = new Handler( _onClose );
            _clubInfoUI.btn_apply.clickHandler = new Handler( applyHandler );

        }

        return Boolean( _clubInfoUI );
    }
    public function addDisplay( clubInfoData : CClubInfoData ) : void {
        _clubInfoData = clubInfoData;
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
        if( !_clubInfoData )
            return;
        _clubInfoUI.txt_name.text = '名称：' +  _clubInfoData.name ;
        _clubInfoUI.txt_level.text = '等级：' +  _clubInfoData.level ;
        _clubInfoUI.txt_rank.text = '排名：' +  _clubInfoData.rank ;
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.CLUBUPGRADEBASIC );
        var clubUpgradeBasic : ClubUpgradeBasic =  pTable.findByPrimaryKey( _clubInfoData.level );

        _clubInfoUI.txt_num.text = '会员：' +  _clubInfoData.memberCount + '/' + clubUpgradeBasic.memberCountMax ;
        _clubInfoUI.txt_battleValue.text = '总战力：' +  _clubInfoData.battleValue ;
        _clubInfoUI.img_icon.url = CClubPath.getBigClubIconUrByID( _clubInfoData.clubSignID );

        _clubInfoUI.txt_Pname.text = '名称：' +  _clubInfoData.chairmanInfo.name ;
        _clubInfoUI.txt_Plevel.text = '等级：' +  _clubInfoData.chairmanInfo.level ;
        _clubInfoUI.txt_PbattleValue.text = '战斗力：' +  _clubInfoData.chairmanInfo.battleValue ;
        _clubInfoUI.chairmanInfo.icon_image.url = CPlayerPath.getUIHeroIconBigPath( _clubInfoData.chairmanInfo.headID );
        _clubInfoUI.chairmanInfo.star_list.visible = false;
        _clubInfoUI.chairmanInfo.lv_txt.visible = false;
        _clubInfoUI.chairmanInfo.level_frame_img.visible = false;

        var pMaskDisplayObject : DisplayObject = _clubInfoUI.chairmanInfo.hero_icon_mask;
        if ( pMaskDisplayObject ) {
            _clubInfoUI.chairmanInfo.icon_image.cacheAsBitmap = true;
            pMaskDisplayObject.cacheAsBitmap = true;
            _clubInfoUI.chairmanInfo.icon_image.mask = pMaskDisplayObject;
        }

        _clubInfoUI.btn_apply.visible = _pClubManager.clubState == CClubConst.NOT_IN_CLUB;
        _onBuffTips();
        uiCanvas.addPopupDialog( _clubInfoUI );
    }
    public function removeDisplay() : void {
        if ( _clubInfoUI ) {
            _clubInfoUI.close( Dialog.CLOSE );
        }
    }

    private function _addEventListeners():void{
        _removeEventListeners();

    }
    private function _removeEventListeners():void{

    }

    private function applyHandler():void{
        var bundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var iStateValue : int = bundleCtx.getSystemBundleState( bundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.GUILD ) ) );
        if( iStateValue == CSystemBundleContext.STATE_STOPPED ){
            _pCUISystem.showMsgAlert('很抱歉，您的战队等级不足，俱乐部暂未开放')
        }else{
            _pClubHandler.onApplyClubRequest( _clubInfoData.id, CClubConst.SINGLE_APPLY );
            _clubInfoUI.close( Dialog.CLOSE );
        }
    }
    private function _onBuffTips():void{
        var clubUpgradeBasic : ClubUpgradeBasic = _pClubManager.getClubUpgradeBasicByLevel( _clubInfoData.level  );
        var nextUpgradeBasic : ClubUpgradeBasic = _pClubManager.getClubUpgradeBasicByLevel( _clubInfoData.level  + 1 );
        if(nextUpgradeBasic)
        {
            _clubInfoUI.box_buff.toolTip =
                    "<font color='#FFA500'>----" + _pClubManager.clubLevel + "级俱乐部buff----\n</font>" +
                    "<font color='#00FA9A'>          生命+" + clubUpgradeBasic.buffPropertyValue[0] + "\n" +
                    "          攻击+" + clubUpgradeBasic.buffPropertyValue[1] + "\n" +
                    "          防御+" + clubUpgradeBasic.buffPropertyValue[2] + "\n</font>" +
                    "\n" +
                    "<font color='#FFA500'>----下一级属性预览----\n</font>" +
                    "<font color='#00FA9A'>          生命+" + nextUpgradeBasic.buffPropertyValue[0] + "\n" +
                    "          攻击+" + nextUpgradeBasic.buffPropertyValue[1] + "\n" +
                    "          防御+" + nextUpgradeBasic.buffPropertyValue[2] + "\n</font>" +
                    "<font color='#FFA500'>----buff对全员生效----</font>";
        }
        else
        {
            _clubInfoUI.box_buff.toolTip = "<font color='#FFA500'>----" + _pClubManager.clubLevel + "级俱乐部buff----\n</font>" +
                    "<font color='#00FA9A'>          生命+" + clubUpgradeBasic.buffPropertyValue[0] + "\n" +
                    "          攻击+" + clubUpgradeBasic.buffPropertyValue[1] + "\n" +
                    "          防御+" + clubUpgradeBasic.buffPropertyValue[2] + "\n</font>" +
                    "\n" +
                    "<font color='#FFA500'>已达到最高俱乐部等级\n</font>" +
                    "<font color='#FFA500'>----buff对全员生效----</font>";
        }
    }
    private function _onClose( type : String ) : void {
        switch ( type ) {
            default:
                break;
        }
        _removeEventListeners();
    }
    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    private function get _pClubManager(): CClubManager{
        return system.getBean( CClubManager ) as CClubManager;
    }
    private function get _pClubHandler() : CClubHandler {
        return system.getBean( CClubHandler ) as CClubHandler;
    }
    private function get _pCUISystem():CUISystem{
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }
}
}
