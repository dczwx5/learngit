//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/25.
 */
package kof.game.club {

import QFLib.Foundation.CMap;

import kof.SYSTEM_ID;
import kof.framework.CViewHandler;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.club.data.CClubConst;
import kof.game.club.view.CClubCreateViewHandler;
import kof.game.club.view.CClubFundActiveTipsHandler;
import kof.game.club.view.CClubFundViewHandler;
import kof.game.club.view.CClubIconViewHandler;
import kof.game.club.view.CClubInfoViewHandler;
import kof.game.club.view.CClubInvestNoteView;
import kof.game.club.view.CClubListViewHandler;
import kof.game.club.view.CClubManageWelfareViewHandler;
import kof.game.club.view.CClubRankViewHandler;
import kof.game.club.view.CClubViewHandler;
import kof.game.club.view.CClubWelfareBagViewHandler;
import kof.game.club.view.CClubWorldViewHandler;
import kof.game.club.view.clubgame.CClubGameRewardViewHandler;
import kof.game.club.view.clubgame.CClubGameViewHandler;
import kof.game.club.view.clubview.CClubApplyConditionViewHandler;
import kof.game.club.view.clubview.CClubApplyViewHandler;
import kof.game.club.view.clubview.CClubBaseInfoViewHandler;
import kof.game.club.view.clubview.CClubChangeNameViewHandler;
import kof.game.club.view.clubview.CClubLogViewHandler;
import kof.game.club.view.clubview.CClubMemberCViewHandler;
import kof.game.club.view.clubview.CClubMemberMenuHandler;
import kof.game.club.view.clubview.CClubPositionChangeViewHandler;
import kof.game.club.view.welfarebag.CClubBagSendInfoViewHandler;
import kof.game.club.view.welfarebag.CClubGetWelfareBagLogViewHandler;
import kof.game.club.view.welfarebag.CClubSelfBagLogViewHandler;
import kof.game.club.view.welfarebag.CClubSendWelfareBagLogViewHandler;
import kof.game.club.view.welfarebag.CClubSingleBagLogViewHandler;
import kof.game.club.view.welfarebag.CClubWelfareBagGetViewHandler;
import kof.game.club.view.welfarebag.CClubWelfareBagInfoViewHandler;
import kof.game.club.view.welfarebag.CClubWelfareBagRechargeViewHandler;
import kof.game.club.view.welfarebag.CClubWelfareBagSendViewHandler;
import kof.game.player.CPlayerSystem;
import kof.message.Club.MemberInfoModifyResponse;
import kof.table.ClubUpgradeBasic;
import kof.ui.CUISystem;

import morn.core.handlers.Handler;

public class CClubSystem extends CBundleSystem {
    public function CClubSystem() {
        super();
    }

    private var m_bInitialized : Boolean;

    private var _funcList:CMap;

    private var _pClubManager : CClubManager;
    private var _pClubHandler : CClubHandler;
    private var _pClubListViewHandler : CClubListViewHandler;
    private var _pClubWorldViewHandler : CClubWorldViewHandler;

    private var _pClubInfoViewHandler : CClubInfoViewHandler;
    private var _pClubFundActiveTipsHandler : CClubFundActiveTipsHandler;

    private var _pClubBaseInfoViewHandler : CClubBaseInfoViewHandler;
    private var _pClubLogViewHandler : CClubLogViewHandler;
    private var _pClubMemberCViewHandler : CClubMemberCViewHandler;
    private var _pClubApplyViewHandler : CClubApplyViewHandler;
    private var _pClubApplyConditionViewHandler : CClubApplyConditionViewHandler;
    private var _pClubChangeNameViewHandler : CClubChangeNameViewHandler;
    private var _pClubMemberMenuHandler : CClubMemberMenuHandler;
    private var _pClubPositionChangeViewHandler : CClubPositionChangeViewHandler;


    private var _pClubCreateViewHandler : CClubCreateViewHandler;
    private var _pClubIconViewHandler : CClubIconViewHandler;
    private var _pClubViewHandler : CClubViewHandler;
    private var _pClubRankViewHandler : CClubRankViewHandler;
    private var _pClubManageWelfareViewHandler : CClubManageWelfareViewHandler;
    private var _pClubGetWelfareBagLogViewHandler : CClubGetWelfareBagLogViewHandler;
    private var _pClubBagSendInfoViewHandler : CClubBagSendInfoViewHandler;
    private var _pClubWelfareBagViewHandler : CClubWelfareBagViewHandler;
    private var _pClubWelfareBagInfoViewHandler : CClubWelfareBagInfoViewHandler;
    private var _pClubWelfareBagSendViewHandler : CClubWelfareBagSendViewHandler;
    private var _pClubWelfareBagGetViewHandler : CClubWelfareBagGetViewHandler;
    private var _pClubSendWelfareBagLogViewHandler : CClubSendWelfareBagLogViewHandler;
    private var _pClubSingleBagLogViewHandler : CClubSingleBagLogViewHandler;
    private var _pClubSelfBagLogViewHandler : CClubSelfBagLogViewHandler;
    private var _pClubWelfareBagRechargeViewHandler : CClubWelfareBagRechargeViewHandler;

    private var _pClubFundViewHandler : CClubFundViewHandler;

    private var _pClubGameViewHandler : CClubGameViewHandler;
    private var _pClubGameRewardViewHandler : CClubGameRewardViewHandler;

    private var _investNote : CClubInvestNoteView;
    private var _curView : CViewHandler;

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        if ( !m_bInitialized ) {
            m_bInitialized = true;

            this.addBean( _pClubManager = new CClubManager() );
            this.addBean( _pClubHandler = new CClubHandler() );
            this.addBean( _pClubListViewHandler = new CClubListViewHandler() );
            this.addBean( _pClubWorldViewHandler = new CClubWorldViewHandler() );

            this.addBean( _pClubInfoViewHandler = new CClubInfoViewHandler() );
            this.addBean( _pClubFundActiveTipsHandler = new CClubFundActiveTipsHandler() );

            this.addBean(  _pClubBaseInfoViewHandler = new CClubBaseInfoViewHandler() );
            this.addBean( _pClubLogViewHandler = new CClubLogViewHandler() );
            this.addBean( _pClubMemberCViewHandler = new CClubMemberCViewHandler() );
            this.addBean( _pClubApplyViewHandler = new CClubApplyViewHandler() );
            this.addBean( _pClubApplyConditionViewHandler = new CClubApplyConditionViewHandler() );
            this.addBean( _pClubChangeNameViewHandler = new CClubChangeNameViewHandler());
            this.addBean( _pClubMemberMenuHandler = new CClubMemberMenuHandler());
            this.addBean( _pClubPositionChangeViewHandler = new CClubPositionChangeViewHandler());

            this.addBean( _pClubCreateViewHandler = new CClubCreateViewHandler() );
            this.addBean( _pClubIconViewHandler = new CClubIconViewHandler() );
            this.addBean( _pClubViewHandler = new CClubViewHandler() );
            this.addBean( _pClubRankViewHandler = new CClubRankViewHandler() );
            this.addBean( _pClubManageWelfareViewHandler = new CClubManageWelfareViewHandler() );
            this.addBean( _pClubBagSendInfoViewHandler = new CClubBagSendInfoViewHandler() );
            this.addBean( _pClubWelfareBagViewHandler = new CClubWelfareBagViewHandler() );
            this.addBean( _pClubWelfareBagInfoViewHandler = new CClubWelfareBagInfoViewHandler() );
            this.addBean( _pClubWelfareBagSendViewHandler = new CClubWelfareBagSendViewHandler() );
            this.addBean( _pClubWelfareBagGetViewHandler = new CClubWelfareBagGetViewHandler() );
            this.addBean( _pClubGetWelfareBagLogViewHandler = new CClubGetWelfareBagLogViewHandler() );
            this.addBean( _pClubSendWelfareBagLogViewHandler = new CClubSendWelfareBagLogViewHandler() );
            this.addBean( _pClubSingleBagLogViewHandler = new CClubSingleBagLogViewHandler() );
            this.addBean( _pClubSelfBagLogViewHandler = new CClubSelfBagLogViewHandler() );
            this.addBean( _pClubWelfareBagRechargeViewHandler = new CClubWelfareBagRechargeViewHandler() );

            this.addBean( _pClubFundViewHandler = new CClubFundViewHandler() );

            this.addBean( _pClubGameViewHandler = new CClubGameViewHandler() );
            this.addBean( _pClubGameRewardViewHandler = new CClubGameRewardViewHandler() );
            this.addBean( _investNote = new CClubInvestNoteView() );
            _addEventListeners();
        }

        _pClubListViewHandler.closeHandler = new Handler( _onViewClosed );
        _pClubWorldViewHandler.closeHandler = new Handler( _onViewClosed );

        return m_bInitialized;
    }

    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );
        if ( value ) {
            _pClubHandler.onOpenClubRequest();
        } else {
            removeAllView();
        }
    }

    private function _onViewClosed() : void {
        this.setActivated( false );
        removeAllView();
    }

    private function clubStateHandler( evt : CClubEvent ):void{
        if( _pClubManager.clubState == CClubConst.NOT_IN_CLUB ){
            var pClubListViewHandler : CClubListViewHandler = this.getBean( CClubListViewHandler );
            pClubListViewHandler.addDisplay();
            _curView = pClubListViewHandler;
        }else if( _pClubManager.clubState == CClubConst.IN_CLUB  ){
            var pClubWorldViewHandler : CClubWorldViewHandler = this.getBean( CClubWorldViewHandler );
            pClubWorldViewHandler.addDisplay( );
            _curView = pClubWorldViewHandler;
        }
    }
    //消息更新
    private function _onClubMsgResponse( evt : CClubEvent ):void{
        var type : int = int( evt.data );
        if( type == CClubConst.CLUB_REDBAG_UPDATE  ){
            _pClubHandler.onLuckyBagInfoListRequest( CClubConst.CLUB_BAG_LIST );
            _pClubHandler.onLuckyBagInfoListRequest( CClubConst.USER_BAG_LIST );
        }
    }
    //主界面红点
    //====================add by Lune 0710 start==========================
    private function updateRedPoint(e : CClubEvent) : void
    {
        var bool : Boolean = _pClubManager.clubPosition >= CClubConst.CLUB_POSITION_2;//职位足够
        var hasRewardSign : Boolean = bool && !_pClubManager.getClubRewardSign;
        var hasLuckyBag : Boolean = _pClubManager.playerLuckyBagState || _pClubManager.checkWelBagState;
        var clubUpgradeBasic : ClubUpgradeBasic = _pClubManager.getClubUpgradeBasicByLevel(_pClubManager.clubLevel);
        var hasFreeCount : Boolean;
        if(clubUpgradeBasic)
        {
            hasFreeCount = clubUpgradeBasic.clubGameCounts  > _pClubManager.playGameCounts;
        }
        var isInClub : Boolean = _pClubManager.clubState == CClubConst.IN_CLUB;
        // 主界面图标提示;
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        var pSystemBundle : ISystemBundle = pSystemBundleContext.getSystemBundle( bundleID );
        if ( pSystemBundleContext && pSystemBundle ) {
            pSystemBundleContext.setUserData( this, CBundleSystem.NOTIFICATION, isInClub && (hasRewardSign || hasLuckyBag || hasFreeCount));
        }
        _pClubWorldViewHandler.refreshRedPoint();
    }
    //====================add by Lune 0710 end===========================

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.GUILD );
    }

    public function showClubSubView( type : int ,tab : int = 0):void{
        _pClubWorldViewHandler.showClubSubView( type ,tab );
    }
    public function hideClubSubView( type : int ):void{
        if( type == CClubConst.CLUB_VIEW ){
            _pClubViewHandler.removeDisplay();
        }else if( type == CClubConst.CLUB_RANK ){
            _pClubRankViewHandler.removeDisplay();
        }else if( type == CClubConst.MANAGE_WELFARE ){
            _pClubManageWelfareViewHandler.removeDisplay();
        }else if( type == CClubConst.WELFARE_BAG ){
            _pClubWelfareBagViewHandler.removeDisplay();
        }else if( type == CClubConst.CLUB_FUND ){
            _pClubFundViewHandler.removeDisplay();
        }else if( type == CClubConst.CLUB_SHOP ){
        }else if( type == CClubConst.GUILD_WAR ){
        }else if( type == CClubConst.BA_JIE_JI_LAI_XI ){
        }else if( type == CClubConst.DIAN_FENG_DUI_JUE ){
        }
    }
    public function showGameView() : void {
        _pClubGameViewHandler.addDisplay();
    }

    private function _onModifyResponse( evt : CClubEvent ):void{
        var response:MemberInfoModifyResponse = evt.data as MemberInfoModifyResponse;
        if( response.type == CClubConst.APPLY_OK  ){
            var pSystemBundleCtx : ISystemBundleContext = stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.GUILD ) );
            pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, false );

            _pCUISystem.showMsgBox( response.dataMap.clubName + '通过了您的加入申请，快来俱乐部看看吧',okFun );
            function okFun():void{
                var bundleCtx : ISystemBundleContext = stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
                var bundle : ISystemBundle =  bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.GUILD));
                bundleCtx.setUserData( bundle, CBundleSystem.ACTIVATED, true );
            }
        }
    }

    private function _onClubApplyAndIn( evt : CClubEvent ):void{
        var pSystemBundleCtx : ISystemBundleContext = stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.GUILD ) );
        pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, false );

    }
    private function _addEventListeners() : void {
        this.addEventListener( CClubEvent.OPEN_CLUB_RESPONSE , clubStateHandler, false, 0, true);
        this.addEventListener( CClubEvent.MEMBER_INFO_MODIFY_RESPONSE , _onModifyResponse , false, 0, true );
        this.addEventListener( CClubEvent.CLUB_APPLY_SUCC_AND_IN , _onClubApplyAndIn , false, 0, true );
        this.addEventListener( CClubEvent.CLUB_RED_POINT , updateRedPoint);
        this.addEventListener( CClubEvent.CLUB_MSG_RESPONSE , _onClubMsgResponse );
    }
    private function _removeEventListeners() : void {
        this.removeEventListener( CClubEvent.OPEN_CLUB_RESPONSE , clubStateHandler);
        this.removeEventListener( CClubEvent.MEMBER_INFO_MODIFY_RESPONSE , _onModifyResponse );
        this.removeEventListener( CClubEvent.CLUB_APPLY_SUCC_AND_IN , _onClubApplyAndIn );
        this.removeEventListener( CClubEvent.CLUB_RED_POINT , updateRedPoint);
        this.removeEventListener( CClubEvent.CLUB_MSG_RESPONSE , _onClubMsgResponse );
    }

    public function removeAllView() : void {

        _pClubListViewHandler.removeDisplay();
        _pClubWorldViewHandler.removeDisplay();
        _pClubInfoViewHandler.removeDisplay();
        _pClubApplyConditionViewHandler.removeDisplay();
        _pClubChangeNameViewHandler.removeDisplay();
        _pClubMemberMenuHandler.removeDisplay();
        _pClubPositionChangeViewHandler.removeDisplay();
        _pClubCreateViewHandler.removeDisplay();
        _pClubIconViewHandler.removeDisplay();
        _pClubViewHandler.removeDisplay();
        _pClubRankViewHandler.removeDisplay();
        _pClubManageWelfareViewHandler.removeDisplay();
        _pClubWelfareBagViewHandler.removeDisplay();
        _pClubGetWelfareBagLogViewHandler.removeDisplay();
        _pClubBagSendInfoViewHandler.removeDisplay();
        _pClubSendWelfareBagLogViewHandler.removeDisplay();
        _pClubSingleBagLogViewHandler.removeDisplay();
        _pClubSelfBagLogViewHandler.removeDisplay();
        _pClubFundViewHandler.removeDisplay();
        _pClubGameViewHandler.removeDisplay();
        _pClubGameRewardViewHandler.removeDisplay();
    }


    public override function dispose() : void {
        super.dispose();

        _pClubManager.dispose();
        _pClubHandler.dispose();
        _pClubListViewHandler.dispose();
        _pClubWorldViewHandler.dispose();

        _pClubInfoViewHandler.dispose();
        _pClubBaseInfoViewHandler.dispose();
        _pClubLogViewHandler.dispose();
        _pClubMemberCViewHandler.dispose();
        _pClubApplyViewHandler.dispose();
        _pClubApplyConditionViewHandler.dispose();
        _pClubChangeNameViewHandler.dispose();
        _pClubMemberMenuHandler.dispose();
        _pClubPositionChangeViewHandler.dispose();

        _pClubCreateViewHandler.dispose();
        _pClubIconViewHandler.dispose();
        _pClubViewHandler.dispose();
        _pClubRankViewHandler.dispose();
        _pClubManageWelfareViewHandler.dispose();
        _pClubWelfareBagViewHandler.dispose();
        _pClubWelfareBagInfoViewHandler.dispose();
        _pClubWelfareBagSendViewHandler.dispose();
        _pClubWelfareBagGetViewHandler.dispose();
        _pClubGetWelfareBagLogViewHandler.dispose();
        _pClubBagSendInfoViewHandler.dispose();
        _pClubSendWelfareBagLogViewHandler.dispose();
        _pClubSingleBagLogViewHandler.dispose();
        _pClubSelfBagLogViewHandler.dispose();
        _pClubWelfareBagRechargeViewHandler.dispose();

        _pClubFundViewHandler.dispose();
        _pClubFundActiveTipsHandler.dispose();

        _pClubGameViewHandler.dispose();
        _pClubGameRewardViewHandler.dispose();

        _removeEventListeners();
    }

    private function get _pCUISystem() : CUISystem {
        return stage.getSystem( CUISystem ) as CUISystem;
    }

    private function get _playerSystem() : CPlayerSystem {
        return stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }

}
}
