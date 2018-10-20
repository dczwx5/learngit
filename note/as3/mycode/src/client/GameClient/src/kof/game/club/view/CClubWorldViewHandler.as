//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/26.
 * 俱乐部主界面（加入俱乐部之后 ）
 */
package kof.game.club.view {

import kof.SYSTEM_ID;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.club.CClubEvent;
import kof.game.club.CClubHandler;
import kof.game.club.CClubManager;
import kof.game.club.data.CClubConst;
import kof.game.club.view.clubgame.CClubGameRewardViewHandler;
import kof.game.club.view.clubgame.CClubGameViewHandler;
import kof.game.club.view.clubview.CClubApplyConditionViewHandler;
import kof.game.club.view.clubview.CClubChangeNameViewHandler;
import kof.game.club.view.clubview.CClubMemberMenuHandler;
import kof.game.club.view.clubview.CClubPositionChangeViewHandler;
import kof.game.club.view.welfarebag.CClubBagSendInfoViewHandler;
import kof.game.club.view.welfarebag.CClubGetWelfareBagLogViewHandler;
import kof.game.club.view.welfarebag.CClubSelfBagLogViewHandler;
import kof.game.club.view.welfarebag.CClubSendWelfareBagLogViewHandler;
import kof.game.club.view.welfarebag.CClubSingleBagLogViewHandler;
import kof.game.clubBoss.CClubBossSystem;
import kof.game.common.view.CTweenViewHandler;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.shop.enum.EShopType;
import kof.message.Club.MemberInfoModifyResponse;
import kof.table.ClubConstant;
import kof.table.ClubUpgradeBasic;
import kof.ui.CUISystem;
import kof.ui.master.club.ClubWorldUI;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CClubWorldViewHandler extends CTweenViewHandler {

    private var m_pCloseHandler : Handler;

    private var _clubWorldUI : ClubWorldUI;

    private var m_bViewInitialized : Boolean;

    public function CClubWorldViewHandler() {
        super( false );
    }
    override public function dispose() : void {
        super.dispose();

        removeDisplay();
        _clubWorldUI = null;
    }

    override public function get viewClass() : Array {
        return [ ClubWorldUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }
    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized ) {
            if ( !_clubWorldUI ) {
                _clubWorldUI = new ClubWorldUI();

                _clubWorldUI.closeHandler = new Handler( _onClose );
                _clubWorldUI.btngrounp.selectHandler = new Handler( _onBtnGronpSelectHandler );

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function showClubSubView( index : int ,tab : int = 0):void{
        _onBtnGronpSelectHandler( index ,tab );
        refreshRedPoint();
    }

    private function _onBtnGronpSelectHandler( index : int ,tab : int = 0):void{
        var pTable : IDataTable;
        var clubConstant : ClubConstant;
        var bundleCtx:ISystemBundleContext;
        var systemBundle:ISystemBundle;
        switch( index ){
            case CClubConst.CLUB_VIEW :{
                _pClubViewHandler.addDisplay();
                break;
            }
            case CClubConst.CLUB_RANK :{
                _pClubRankViewHandler.addDisplay();
                break;
            }
            case CClubConst.MANAGE_WELFARE :{

                pTable = _pCDatabaseSystem.getTable( KOFTableConstants.CLUBCONSTANT );
                clubConstant =  pTable.findByPrimaryKey(1);
                if( _pClubManager.clubLevel < clubConstant.everydayRewardNeedClubLv ){
                    _pCUISystem.showMsgAlert('俱乐部等级要到' + clubConstant.everydayRewardNeedClubLv + '级以上才开放');
                    return;
                }
                if( _pClubManager.clubPosition >= CClubConst.CLUB_POSITION_2 ){
                    _pClubManageWelfareViewHandler.addDisplay();
                }else{
                    _pCUISystem.showMsgAlert('您没权限');
                }
                break;
            }
            case CClubConst.WELFARE_BAG :{

                pTable = _pCDatabaseSystem.getTable( KOFTableConstants.CLUBCONSTANT );
                clubConstant =  pTable.findByPrimaryKey(1);
                if( _pClubManager.clubLevel < clubConstant.luckyBagNeedClubLv ){
                    _pCUISystem.showMsgAlert('俱乐部等级要到' + clubConstant.luckyBagNeedClubLv + '级以上才开放');
                    return;
                }
                _pClubWelfareBagViewHandler.addDisplay( tab );
                break;
            }
            case CClubConst.CLUB_FUND :{
                _pClubFundViewHandler.addDisplay();
                break;
            }
            case CClubConst.CLUB_SHOP :{
                bundleCtx = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
                systemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.MALL));
                bundleCtx.setUserData(systemBundle, "shop_type", [EShopType.SHOP_TYPE_7]);
                bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);

                break;
            }
            case CClubConst.GUILD_WAR :{
                bundleCtx = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
                systemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.GUILDWAR));
//                var currState:Boolean = bundleCtx.getUserData(systemBundle, CBundleSystem.ACTIVATED);
                bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
                break;
            }
            case CClubConst.BA_JIE_JI_LAI_XI :{
                bundleCtx = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
                systemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.CLUB_BOSS));
                bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
                break;
            }
            case CClubConst.DIAN_FENG_DUI_JUE :{
                _pClubGameViewHandler.addDisplay();
                break;
            }
        }

        _clubWorldUI.btngrounp.selectedIndex = -1;
    }
    public function addDisplay( ) : void {
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
    private function _addToDisplay() : void {
        if( _clubWorldUI && _clubWorldUI.parent )
            return;
        setTweenData(KOFSysTags.GUILD);
        showDialog(_clubWorldUI, false, _addToDisplayB);
    }

    private function _addToDisplayB() : void {
        if ( _clubWorldUI ) {
            _addEventListeners();
            //isOpenClub = true 表示已经打开过一次了,不需要再打开了
            if( _pClubManager.needShowClubView && !_pClubManager.isOpenClub ){
                _clubWorldUI.btngrounp.selectedIndex = 0;
                _clubWorldUI.btngrounp.callLater( _onBtnGronpSelectHandler ,[0]);
            }else{
                _clubWorldUI.btngrounp.selectedIndex = -1;
            }
            _pClubHandler.onLuckyBagInfoListRequest( CClubConst.CLUB_BAG_LIST );
            _pClubHandler.onLuckyBagInfoListRequest( CClubConst.USER_BAG_LIST );//打开大厅的时候再次请求一下福袋数据
            system.dispatchEvent(new CClubEvent( CClubEvent.CLUB_WORLD_VIEW_SHOW ));
        }
    }

    public function removeDisplay() : void {
        closeDialog(_removeDisplayB);
    }

    public function _removeDisplayB() : void {
        if ( _clubWorldUI ) {
            _clubWorldUI.close( Dialog.CLOSE );
        }
    }
    //====================add by Lune 0710 start==========================
    public function refreshRedPoint() : void
    {
        if(!_clubWorldUI) return;
        var bool1 : Boolean = _pClubManager.clubPosition >= CClubConst.CLUB_POSITION_2;//职位足够
        _clubWorldUI.red_pt0.visible = bool1 && !_pClubManager.getClubRewardSign;//有职位福利可领
        _clubWorldUI.red_pt4.visible = _pClubManager.playerLuckyBagState || _pClubManager.checkWelBagState;//有免费福袋可领
        var clubUpgradeBasic : ClubUpgradeBasic = _pClubManager.getClubUpgradeBasicByLevel(_pClubManager.clubLevel);
        var bool2 : Boolean;
        if(clubUpgradeBasic)
        {
            bool2 = clubUpgradeBasic.clubGameCounts > _pClubManager.playGameCounts;//有免费摇奖次数
        }
        _clubWorldUI.red_pt7.visible = bool2;
    }
    //====================add by Lune 0710 end==========================
    //退出俱乐部
    private function _onClubExitSucc( evt : CClubEvent ):void{
        _clubWorldUI.close( Dialog.CLOSE );
    }

    private function _onModifyResponse( evt : CClubEvent ):void{
        var response:MemberInfoModifyResponse = evt.data as MemberInfoModifyResponse;
        if( response.type == CClubConst.FIRE && _clubWorldUI.parent ){
            var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.GUILD ) );
            pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, false );


            _pClubInfoViewHandler.removeDisplay();
            _pClubApplyConditionViewHandler.removeDisplay();
            _pClubChangeNameViewHandler.removeDisplay();
            _pClubMemberMenuHandler.removeDisplay();
            _pClubPositionChangeViewHandler.removeDisplay();
            _pClubIconViewHandler.removeDisplay();
            _pClubViewHandler.removeDisplay();
            _pClubRankViewHandler.removeDisplay();
            _pClubManageWelfareViewHandler.removeDisplay();
            _pClubBagSendInfoViewHandler.removeDisplay();
            _pClubWelfareBagViewHandler.removeDisplay();
            _pClubGetWelfareBagLogViewHandler.removeDisplay();
            _pClubSendWelfareBagLogViewHandler.removeDisplay();
            _pClubSingleBagLogViewHandler.removeDisplay();
            _pClubSelfBagLogViewHandler.removeDisplay();
            _pClubFundViewHandler.removeDisplay();
            _pClubGameViewHandler.removeDisplay();
            _pClubGameRewardViewHandler.removeDisplay();

            (system.stage.getSystem(CClubBossSystem) as CClubBossSystem).closeSystem();

            _pCUISystem.showMsgBox('很抱歉，你已被请离俱乐部');
            _pClubManager.clubState = CClubConst.NOT_IN_CLUB;
//            _pClubHandler.onOpenClubRequest();
            var bundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            var bundle : ISystemBundle =  bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.GUILD));
            bundleCtx.setUserData( bundle, CBundleSystem.ACTIVATED, true );
        } else if ( response.type == CClubConst.POSITION_UP || response.type == CClubConst.POSITION_DOWN  ) {
            _pCUISystem.showMsgBox( "您的俱乐部职位已经被调整为 '" + CClubConst.CLUB_POSITION_STR[response.dataMap.position] + "'");
            _pClubHandler.onClubInfoRequest( _pClubManager.selfClubData.id , 1 );
        }
    }
    private function _addEventListeners():void{
        _removeEventListeners();
        system.addEventListener( CClubEvent.CLUB_EXIT_SUCC , _onClubExitSucc );
        system.addEventListener( CClubEvent.MEMBER_INFO_MODIFY_RESPONSE , _onModifyResponse  );
    }
    private function _removeEventListeners():void{
        system.removeEventListener( CClubEvent.CLUB_EXIT_SUCC , _onClubExitSucc );
        system.removeEventListener( CClubEvent.MEMBER_INFO_MODIFY_RESPONSE , _onModifyResponse  );
    }
    private function _onClose( type : String ) : void {
//        if( _clubWorldUI && !_clubWorldUI.parent )
//            return;

        switch ( type ) {
            default:
                if ( this.closeHandler ) {
                    this.closeHandler.execute();
                }
                break;
        }
        _removeEventListeners();

    }
    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }
    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }

    private function get _pClubHandler() : CClubHandler {
        return system.getBean( CClubHandler ) as CClubHandler;
    }
    private function get _pClubManager():CClubManager{
        return system.getBean( CClubManager ) as CClubManager;
    }





    private function get _pCUISystem():CUISystem{
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }
    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }

    private function get _pClubInfoViewHandler():CClubInfoViewHandler{
        return system.getBean( CClubInfoViewHandler ) as CClubInfoViewHandler;
    }

    private function get _pClubApplyConditionViewHandler():CClubApplyConditionViewHandler{
        return system.getBean( CClubApplyConditionViewHandler ) as CClubApplyConditionViewHandler;
    }
    private function get _pClubChangeNameViewHandler():CClubChangeNameViewHandler{
        return system.getBean( CClubChangeNameViewHandler ) as CClubChangeNameViewHandler;
    }
    private function get _pClubMemberMenuHandler():CClubMemberMenuHandler{
        return system.getBean( CClubMemberMenuHandler ) as CClubMemberMenuHandler;
    }
    private function get _pClubPositionChangeViewHandler():CClubPositionChangeViewHandler{
        return system.getBean( CClubPositionChangeViewHandler ) as CClubPositionChangeViewHandler;
    }
    private function get _pClubIconViewHandler():CClubIconViewHandler{
        return system.getBean( CClubIconViewHandler ) as CClubIconViewHandler;
    }
    private function get _pClubViewHandler():CClubViewHandler{
        return system.getBean( CClubViewHandler ) as CClubViewHandler;
    }
    private function get _pClubRankViewHandler():CClubRankViewHandler{
        return system.getBean( CClubRankViewHandler ) as CClubRankViewHandler;
    }
    private function get _pClubManageWelfareViewHandler():CClubManageWelfareViewHandler{
        return system.getBean( CClubManageWelfareViewHandler ) as CClubManageWelfareViewHandler;
    }
    private function get _pClubBagSendInfoViewHandler():CClubBagSendInfoViewHandler{
        return system.getBean( CClubBagSendInfoViewHandler ) as CClubBagSendInfoViewHandler;
    }
    private function get _pClubWelfareBagViewHandler():CClubWelfareBagViewHandler{
        return system.getBean( CClubWelfareBagViewHandler ) as CClubWelfareBagViewHandler;
    }
    private function get _pClubGetWelfareBagLogViewHandler():CClubGetWelfareBagLogViewHandler{
        return system.getBean( CClubGetWelfareBagLogViewHandler ) as CClubGetWelfareBagLogViewHandler;
    }
    private function get _pClubSendWelfareBagLogViewHandler():CClubSendWelfareBagLogViewHandler{
        return system.getBean( CClubSendWelfareBagLogViewHandler ) as CClubSendWelfareBagLogViewHandler;
    }
    private function get _pClubSingleBagLogViewHandler():CClubSingleBagLogViewHandler{
        return system.getBean( CClubSingleBagLogViewHandler ) as CClubSingleBagLogViewHandler;
    }
    private function get _pClubSelfBagLogViewHandler():CClubSelfBagLogViewHandler{
        return system.getBean( CClubSelfBagLogViewHandler ) as CClubSelfBagLogViewHandler;
    }
    private function get _pClubFundViewHandler():CClubFundViewHandler{
        return system.getBean( CClubFundViewHandler ) as CClubFundViewHandler;
    }
    private function get _pClubGameViewHandler():CClubGameViewHandler{
        return system.getBean( CClubGameViewHandler ) as CClubGameViewHandler;
    }
    private function get _pClubGameRewardViewHandler():CClubGameRewardViewHandler{
        return system.getBean( CClubGameRewardViewHandler ) as CClubGameRewardViewHandler;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }



}
}
