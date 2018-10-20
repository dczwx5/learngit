//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/11/28.
 */
package kof.game.club.view.clubgame {

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

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
import kof.game.club.CClubManager;
import kof.game.club.data.CClubConst;
import kof.game.club.view.clubgame.view.ClubGameIcoSprite;
import kof.game.common.CFlyItemUtil;
import kof.game.common.CLang;
import kof.game.common.CRewardUtil;
import kof.game.common.CSystemRuleUtil;
import kof.game.common.view.CViewExternalUtil;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.part.CRewardItemListView;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.reciprocation.CReciprocalSystem;
import kof.table.Bubble;
import kof.table.BuyResetTimesConfig;
import kof.table.ClubUpgradeBasic;
import kof.table.LatticeReward;
import kof.table.SpecialReward;
import kof.ui.master.club.clubgame.ClubGameUI;

import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.events.UIEvent;
import morn.core.handlers.Handler;

public class CClubGameViewHandler extends CViewHandler {

    private var _clubGameUI : ClubGameUI;

    private var _icoSpriteAry : Array;

    private var _cmpCount : int;

    private var _type : int;

    private var _rewardAry : Array;

    private var m_viewExternal : CViewExternalUtil;

    public function CClubGameViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array {
        return [ ClubGameUI ];
    }

    override protected function get additionalAssets() : Array {
        return [
            "frameclip_clubGame.swf"
        ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !_clubGameUI ) {
            _clubGameUI = new ClubGameUI();
            _clubGameUI.btn_play.clickHandler = new Handler( _onPlayHandler );
            _clubGameUI.btn_get.clickHandler = new Handler( _onGetAwardHandler );
            _clubGameUI.btn_bestTurn.clickHandler = new Handler( _onBestTurnHandler );
            _clubGameUI.btn_reward.clickHandler = new Handler( _onRewardViewHandler );
            _clubGameUI.checkBox.clickHandler = new Handler( _onCheckBoxHandler );

            var icoSprite : ClubGameIcoSprite;
            _icoSpriteAry = [];
            var index : int;
            for ( index = 0; index < 6; index++ ) {
                icoSprite = new ClubGameIcoSprite();
                icoSprite.x = 114 * index;
                icoSprite.y = 0;
                icoSprite.cardId = index;
                _clubGameUI.box_ctn.addChild( icoSprite );
                _icoSpriteAry.push( icoSprite );
            }

            m_viewExternal = new CViewExternalUtil( CRewardItemListView, this, _clubGameUI );
            CSystemRuleUtil.setRuleTips( _clubGameUI.img_tips, CLang.Get( "clubgame_rule" ) );
        }

        return Boolean( _clubGameUI );
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

    public function _addToDisplay() : void {
        _addEventListeners();
        _pClubManager.showClubGameViewFlg = true;
        _pClubHandler.onClubGameInfoRequest();
    }

    public function removeDisplay() : void {
        if ( _clubGameUI ) {
            _clubGameUI.close( Dialog.CLOSE );
        }
    }

    private function _onPlayHandler() : void {
        _clubGameUI.btn_play.disabled = true;
        _pClubHandler.onPlayClubGameRequest( ClubGameConst.ALL_TURN );
    }

    private function _onGetAwardHandler() : void {
        _clubGameUI.box_getAward.visible = false;
        _clubGameUI.box_play.visible = true;
        _pClubHandler.onGetClubGameRewardRequest();
        _onTurnNumTxt();
//        _onShowBestPlayer();
//        _onShowReward();
    }

    private function _onBestTurnHandler() : void {

        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.CLUBUPGRADEBASIC );
        var clubUpgradeBasic : ClubUpgradeBasic = pTable.findByPrimaryKey( _pClubManager.clubLevel );

        var buyResetTimesConfig : BuyResetTimesConfig;
        if ( clubUpgradeBasic.clubGameResetCounts - _pClubManager.resetCounts <= 0 ) {
            pTable = _pCDatabaseSystem.getTable( KOFTableConstants.BUYRESETTIMESCONFIG );
            buyResetTimesConfig  = pTable.findByPrimaryKey( _pClubManager.buyResetCounts + 1 );
            uiCanvas.showMsgBox( '重新改转需要消耗绑钻' + buyResetTimesConfig.consumeNums + '，确定继续吗?', okFun,null,true,null,null,true,"COST_BIND_D");
        } else {
            _pClubHandler.onPlayClubGameRequest( ClubGameConst.BEST_TURN );
            _clubGameUI.btn_get.disabled =
                    _clubGameUI.btn_bestTurn.disabled = true;
        }

        function okFun():void{
            (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem).showCostBdDiamondMsgBox( buyResetTimesConfig.consumeNums, onPlayClubGameRequest );

            var playerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
            var diamond : int = playerSystem.playerData.currency.blueDiamond;
            var bindDiamond : int = playerSystem.playerData.currency.purpleDiamond;
            if ( buyResetTimesConfig.consumeNums > (diamond + bindDiamond))
            {
                var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
                var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
                bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
            }
        }
        function onPlayClubGameRequest():void{
            _pClubHandler.onPlayClubGameRequest( ClubGameConst.MONEY_TURN );
            _clubGameUI.btn_get.disabled =
                    _clubGameUI.btn_bestTurn.disabled = true;
        }
    }

    //init
    private function _onClubGameInfoResponseHandler( evt : CClubEvent = null ) : void {
        var isInit : Boolean = true;
        var list : Array = _pClubManager.latticeNumber;
        var i : int;
        var icoSprite : ClubGameIcoSprite;
        if ( list.length > 0 ) {
            for ( i = 0; i < _icoSpriteAry.length; i++ ) {
                icoSprite = _icoSpriteAry[ i ];
                icoSprite.reset();
                icoSprite.initClubGameCardItem( 1, list[ i ] - 1 );
                icoSprite.m__clubGameItemUI.frameclip_tobao.visible =
                        icoSprite.m__clubGameItemUI.franeclip_tobig.visible = false;
                icoSprite.clearFilters();
            }
            isInit = false;
        } else {
            for ( i = 0; i < _icoSpriteAry.length; i++ ) {
                icoSprite = _icoSpriteAry[ i ];
                icoSprite.reset();
                icoSprite.initClubGameCardItem( 1, 5 );
                icoSprite.m__clubGameItemUI.frameclip_tobao.visible =
                        icoSprite.m__clubGameItemUI.franeclip_tobig.visible = false;
                icoSprite.clearFilters();
            }
        }

        _clubGameUI.checkBox.selected = _pClubManager.skipAnimationSetting;
        _clubGameUI.box_getAward.visible = !isInit;
        if( _clubGameUI.box_getAward.visible )
            _pClubManager.isBestGameResult ? _clubGameUI.btn_get.label = '终极奖励' : _clubGameUI.btn_get.label = '见好就收';
        _clubGameUI.box_play.visible = isInit;
        _clubGameUI.btn_play.disabled = _clubGameUI.btn_get.disabled = _clubGameUI.btn_bestTurn.disabled = false;
        _onTurnNumTxt();
        _onShowBestPlayer();
        if( _needToChangeAward ){
            _onShowReward();
        }
        _needToChangeAward = true;
        _clubGameUI.frameclip_line.visible = false;
        _clubGameUI.frameclip_dengS.visible = false;
        _needToChangeAward = true;
        stopLineEff();

//        _clubGameUI.txt_test.text = list.toString();//for test

        if ( !_clubGameUI.parent && _pClubManager.showClubGameViewFlg ){
            _pClubManager.showClubGameViewFlg = false;
            _onShowBubble( 0 );
            uiCanvas.addPopupDialog( _clubGameUI );
        }

    }

    /////////////////////////////////////////////////////
    private function _onTurnNumTxt() : void {

        var pTable : IDataTable;
        pTable = _pCDatabaseSystem.getTable( KOFTableConstants.CLUBUPGRADEBASIC );
        var clubUpgradeBasic : ClubUpgradeBasic = pTable.findByPrimaryKey( _pClubManager.clubLevel );

        _clubGameUI.box_freeTurn.visible =
                _clubGameUI.box_needD.visible =
                        _clubGameUI.btn_bestTurn.disabled =
                                _clubGameUI.btn_play.disabled = false;

        if ( _clubGameUI.box_getAward.visible ) {
            _clubGameUI.txt_free_chang_nums.text = '( ' + ( clubUpgradeBasic.clubGameResetCounts - _pClubManager.resetCounts ) + '/' + clubUpgradeBasic.clubGameResetCounts + ' )';
            _clubGameUI.box_freeTurn.visible = clubUpgradeBasic.clubGameResetCounts - _pClubManager.resetCounts > 0;
            _clubGameUI.box_needD.visible = clubUpgradeBasic.clubGameResetCounts - _pClubManager.resetCounts <= 0;
            _clubGameUI.box_needD.visible ? _clubGameUI.btn_bestTurn.label = '钻石改转' : _clubGameUI.btn_bestTurn.label = '免费改转' ;
            _clubGameUI.btn_bestTurn.disabled = _pClubManager.isBestGameResult;
            _pClubManager.isBestGameResult ? _clubGameUI.btn_get.label = '终极奖励' : _clubGameUI.btn_get.label = '见好就收';
        } else if ( _clubGameUI.box_play.visible ) {
            _clubGameUI.btn_play.disabled = clubUpgradeBasic.clubGameCounts - _pClubManager.playGameCounts <= 0;
            if( clubUpgradeBasic.clubGameCounts - _pClubManager.playGameCounts <= 0 ){
                _clubGameUI.txt_turn_nums.text = '0/' + clubUpgradeBasic.clubGameCounts;
            }else{
                _clubGameUI.txt_turn_nums.text = ( clubUpgradeBasic.clubGameCounts - _pClubManager.playGameCounts ) + '/' + clubUpgradeBasic.clubGameCounts;
            }

        }

        var buyResetTimesConfig : BuyResetTimesConfig;
        pTable = _pCDatabaseSystem.getTable( KOFTableConstants.BUYRESETTIMESCONFIG );
        _clubGameUI.box_lucky.visible = _pClubManager.buyResetCounts > 0;
        if ( _clubGameUI.box_lucky.visible ) {
            buyResetTimesConfig = pTable.findByPrimaryKey( _pClubManager.buyResetCounts );
            if ( buyResetTimesConfig ) {
                _clubGameUI.txt_lucky.text = '幸运提升:+' + buyResetTimesConfig.showLuckyValue;
            } else {
                _clubGameUI.box_lucky.visible = false;
            }
        }
        if( _clubGameUI.btn_bestTurn.label == '钻石改转 ')
            _clubGameUI.btn_bestTurn.disabled = _pClubManager.isBestGameResult || _pClubManager.totalBuyResetCounts >= pTable.toArray().length;
        else if( _clubGameUI.btn_bestTurn.label == '免费改转' )
            _clubGameUI.btn_bestTurn.disabled = _pClubManager.isBestGameResult;

        if ( _clubGameUI.box_needD.visible ) {
            buyResetTimesConfig = pTable.findByPrimaryKey( _pClubManager.buyResetCounts + 1 );
            if ( !buyResetTimesConfig )
                buyResetTimesConfig = pTable.findByPrimaryKey( _pClubManager.buyResetCounts );
            if( buyResetTimesConfig )
                _clubGameUI.txt_need_d.text = buyResetTimesConfig.consumeNums + ' (' + ( pTable.toArray().length - _pClubManager.totalBuyResetCounts ) + '/' + pTable.toArray().length + ')';
        }
    }

    /////////////////////////////////////////////////////
    private var _bubbleIndex : int;

    private function _onShowBubble( delta : Number ) : void {
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.BUBBLE );
        var ary : Array = pTable.toArray();
        _clubGameUI.view_dialog.txt_content.text = ( ary[ _bubbleIndex ] as Bubble ).content;
        _clubGameUI.view_dialog.txt_content.textField.width = 154;
        _clubGameUI.view_dialog.txt_content.width = _clubGameUI.view_dialog.txt_content.textField.textWidth + 35;
        _clubGameUI.view_dialog.txt_content.height = _clubGameUI.view_dialog.txt_content.textField.textHeight + 35;
        _bubbleIndex++;
        if ( _bubbleIndex >= ary.length )
            _bubbleIndex = 0;

        _clubGameUI.view_dialog.visible = true;
        unschedule( _onShowBubble );
        schedule( 3,_onHideBubble );
    }
    private function _onHideBubble( delta : Number ) : void {
        _clubGameUI.view_dialog.visible = false;
        unschedule( _onHideBubble );
        schedule( 5,_onShowBubble );
    }

    /////////////////////////////////////////////////////
    private function _onShowReward() : void {
        var nums : int;
        var dropAry : Array = [];
        for ( var index : int = 0; index < _pClubManager.latticeNumber.length; index++ ) {
            nums = int( _pClubManager.latticeNumber[ index ] );
            if ( nums != 6 ) {
                var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.LATTICEREWARD );
                var latticeReward : LatticeReward = pTable.findByPrimaryKey( 1 );
                dropAry.push( latticeReward.latticeReward[ nums - 1 ] );
            }
        }

        var rewardData : CRewardData;
        var dropID : int;
        var rewardDataList : CRewardListData;
        _rewardAry = [];
        var ary : Array = [];
        for each( dropID in dropAry ) {
            rewardDataList = CRewardUtil.createByDropPackageID( system.stage, dropID );
            for each ( rewardData in rewardDataList.list ) {
                ary.push( rewardData );
            }
        }
        if ( _pClubManager.bestGameResultNum > 0 ) {
            var specialReward : SpecialReward = _pClubManager.getSpecialRewardByNum( _pClubManager.bestGameResultNum );
            rewardDataList = CRewardUtil.createByDropPackageID( system.stage, specialReward.rewardID );
            for each ( rewardData in rewardDataList.list ) {
                ary.push( rewardData );
            }
        }
        for each ( rewardData in ary ) {
            makeRewardList( rewardData );
        }

        m_viewExternal.show();
        rewardDataList = CRewardUtil.createByList( system.stage, _rewardAry );
        ( m_viewExternal.view as CRewardItemListView ).forceAlign = 1;
        ( m_viewExternal.view as CRewardItemListView ).repeatValue = _rewardAry.length;
        ( m_viewExternal.view as CRewardItemListView ).updateLayout();
        m_viewExternal.setData( rewardDataList );
        m_viewExternal.updateWindow();

    }

    private function makeRewardList( rewardData : CRewardData ) : void {
        if ( _rewardAry.length <= 0 ) {
            _rewardAry.push( rewardData );
        } else {
            var rewardD : CRewardData;
            var isSame : Boolean;
            for each ( rewardD in _rewardAry ) {
                if ( rewardD.ID == rewardData.ID ) {
                    rewardD.num += rewardData.num;
                    isSame = true;
                    break;
                }
            }
            if ( !isSame )
                _rewardAry.push( rewardData );
        }
    }

    private function _onShowBestPlayer() : void {
        //bestPlayer
        _clubGameUI.box_bestLucky.visible = _pClubManager.bestPlayerName && _pClubManager.bestPlayerName.length > 0 && _pClubManager.maxBestPlayCounts > 0;
        _clubGameUI.txt_bestLucky.text = '手气最佳：' + _pClubManager.bestPlayerName + '（6个莉安娜' + _pClubManager.maxBestPlayCounts + '次）';
    }

    //摇奖结果返回
    private function _onClubGameResultResponseHandler( evt : CClubEvent ) : void {
        _type = int( evt.data );
        showEff();

        var list : Array = _pClubManager.latticeNumber;
//        _clubGameUI.txt_test.text = list.toString();//for test
    }

    private function showEff() : void {
        var i : int;
        _cmpCount = 0;
        var list : Array = _pClubManager.latticeNumber;
        var oldList : Array = _pClubManager.oldLatticeNumber;
        var turnIndex : int ;
        for ( i = 0; i < _icoSpriteAry.length; i++ ) {
            var icoSprite : ClubGameIcoSprite = _icoSpriteAry[ i ];
            var endIndex : int = list[ i ] - 1;//这个是从0开始
            var oldEndIndex : int = oldList[ i ] - 1;
            if ( _clubGameUI.checkBox.selected ) {
                icoSprite.reset();
                icoSprite.initClubGameCardItem( 1, endIndex );
            } else if ( ( _type == ClubGameConst.BEST_TURN || _type == ClubGameConst.MONEY_TURN ) && oldEndIndex == 5 ) {
                //什么都不做
            } else {
//                icoSprite.doEffect( endIndex );
                icoSprite.doEffect( endIndex , turnIndex * 500 );
                turnIndex ++;
                icoSprite.imgID = endIndex;
                icoSprite.addEventListener( Event.COMPLETE, effOverHandler );
                _cmpCount++;
            }
        }
        if ( _cmpCount <= 0 ) {
            effOverHandler();
        }

    }

    private function effOverHandler( e : Event = null ) : void {
        if( e ){
            var icoSprite : ClubGameIcoSprite = e.currentTarget as ClubGameIcoSprite;
            icoSprite.clearFilters();
            if( icoSprite.imgID == 5 ){
                icoSprite.doBoaEff();
            }
        }


        _cmpCount--;
        if ( _cmpCount <= 0 )//全部转完了
        {
            if ( _type == ClubGameConst.ALL_TURN ) {
                _clubGameUI.box_getAward.visible = true;
                _clubGameUI.box_play.visible = false;
                _clubGameUI.btn_play.disabled = false;
            } else if ( _type == ClubGameConst.BEST_TURN ) {
                _clubGameUI.btn_get.disabled =
                        _clubGameUI.btn_bestTurn.disabled = false;
            } else if ( _type == ClubGameConst.MONEY_TURN ) {
                _clubGameUI.btn_get.disabled =
                        _clubGameUI.btn_bestTurn.disabled = false;
            }

            _pClubManager.oldLatticeNumber = [];
            _pClubManager.oldLatticeNumber = _pClubManager.latticeNumber.concat();

            if( _pClubManager.isBestGameResult && !_clubGameUI.checkBox.selected )
                _onShowBestEff();
            if( _pClubManager.isBestGameResult )
                _clubGameUI.btn_get.label = '终极奖励';



            clearAllFilters();

            _onTurnNumTxt();
            _onShowBestPlayer();
            _onShowReward();

        }


        _clubGameUI.frameclip_dengS.visible = true;
        schedule( 3 , doSEff );
    }
    private function doSEff( delta : Number ):void{
        _clubGameUI.frameclip_dengS.visible = false;
    }

    //见好就收 结果
    private var _needToChangeAward : Boolean = true;
    private function _onGetClubGameRewardResponseHandler( evt : CClubEvent ) : void {
        _needToChangeAward = false;
        _onClubGameInfoResponseHandler( );
        var len : int = _clubGameUI.reward_list.item_list.dataSource.length;
        for ( var i : int = 0; i < len; i++ ) {
            var item : Component = _clubGameUI.reward_list.item_list.getCell( i ) as Component;
            CFlyItemUtil.flyItemToBag( item, item.localToGlobal( new Point() ), system );
        }
    }

    private function _onClubMsgRewardResponseHandler( evt : CClubEvent ):void{
        var type : int = int( evt.data );
        if( _clubGameUI.parent && type == CClubConst.CLUB_LEVEL_UPDATE )
            _pClubHandler.onClubInfoRequest(  _pClubManager.selfClubData.id , 0 );

    }
    private function _onClubInfoUpdateHandler( evt : CClubEvent ):void{
        if( _clubGameUI.parent )
            _pClubHandler.onClubGameInfoRequest();
    }

    private function _onResizeHandler( evt : * ) : void {
        var icoSprite : ClubGameIcoSprite;
        for ( var index : int = 0; index < _icoSpriteAry.length; index++ ) {
            icoSprite = _icoSpriteAry[ index ] as ClubGameIcoSprite;
            icoSprite.onRize();
        }
    }

    private function _onRewardViewHandler() : void {
        _pClubGameRewardViewHandler.addDisplay();
    }

    private function _onCheckBoxHandler() : void {
        if ( _playerData.vipData.vipLv <= 0 ) {
            uiCanvas.showMsgAlert( '开通VIP1即可跳过动画' );
            _clubGameUI.checkBox.selected = false;
            return;
        }

        if ( _clubGameUI.checkBox.selected ) {
            _pClubManager.skipAnimationSetting = 1;
        } else {
            _pClubManager.skipAnimationSetting = 0;
        }
        _pClubHandler.onClubGameSettingRequest( _pClubManager.skipAnimationSetting );
    }

    private function _onMouseDownHandler( evt : MouseEvent ) : void {
        _clubGameUI.addEventListener( MouseEvent.MOUSE_MOVE, _onResizeHandler, false, 0, true );
    }

    private function _onMouseUpHandler( evt : MouseEvent ) : void {
        _clubGameUI.removeEventListener( MouseEvent.MOUSE_MOVE, _onResizeHandler );
    }

    private function _onHideHandler( evt : Event ) : void {
        var i : int;
        for ( i = 0; i < _icoSpriteAry.length; i++ ) {
            var icoSprite : ClubGameIcoSprite = _icoSpriteAry[ i ];
            icoSprite.reset();
        }
    }

    private function _onShowBestEff():void{
        var i : int ;
        for ( i = 0; i < _icoSpriteAry.length; i++ ) {
            var icoSprite : ClubGameIcoSprite = _icoSpriteAry[ i ];
            icoSprite.doBigEff();
        }
        doLineEff();
    }
    //////////////////////////////////
    public function doLineEff():void{
        _clubGameUI.frameclip_line.addEventListener( UIEvent.FRAME_CHANGED,onLineChanged );
        _clubGameUI.frameclip_line.visible = true;
        _clubGameUI.frameclip_line.gotoAndPlay(0);
    }
    private function onLineChanged(evt:UIEvent):void{
        if( _clubGameUI.frameclip_line.frame >=  _clubGameUI.frameclip_line.totalFrame - 1) {
            stopLineEff();
        }
    }
    private function stopLineEff():void{
        _clubGameUI.frameclip_line.removeEventListener( UIEvent.FRAME_CHANGED,onLineChanged );
        _clubGameUI.frameclip_line.stop();
        _clubGameUI.frameclip_line.visible = false;
    }

    private function clearAllFilters():void{
        var i : int;
        for ( i = 0; i < _icoSpriteAry.length; i++ ) {
            var icoSprite : ClubGameIcoSprite = _icoSpriteAry[ i ];
            icoSprite.clearFilters();
        }
    }

    private function _addEventListeners() : void {
        _removeEventListeners();
        system.addEventListener( CClubEvent.CLUB_GAME_INFO_REQUEST, _onClubGameInfoResponseHandler );
        system.addEventListener( CClubEvent.PLAY_CLUB_GAME_RESPONSE, _onClubGameResultResponseHandler );
        system.addEventListener( CClubEvent.GET_CLUBGAME_REWARD_RESPONSE, _onGetClubGameRewardResponseHandler );
        system.addEventListener( CClubEvent.CLUB_MSG_RESPONSE, _onClubMsgRewardResponseHandler );
        system.addEventListener( CClubEvent.CLUB_INFO_RESPONSE, _onClubInfoUpdateHandler );
        system.stage.flashStage.addEventListener( Event.RESIZE, _onResizeHandler, false, 0, true );
        _clubGameUI.addEventListener( MouseEvent.MOUSE_DOWN, _onMouseDownHandler, false, 0, true );
        _clubGameUI.addEventListener( MouseEvent.MOUSE_UP, _onMouseUpHandler, false, 0, true );
        _clubGameUI.addEventListener( Event.REMOVED_FROM_STAGE, _onHideHandler );
    }

    private function _removeEventListeners() : void {
        system.removeEventListener( CClubEvent.CLUB_GAME_INFO_REQUEST, _onClubGameInfoResponseHandler );
        system.removeEventListener( CClubEvent.PLAY_CLUB_GAME_RESPONSE, _onClubGameResultResponseHandler );
        system.removeEventListener( CClubEvent.GET_CLUBGAME_REWARD_RESPONSE, _onGetClubGameRewardResponseHandler );
        system.removeEventListener( CClubEvent.CLUB_MSG_RESPONSE, _onClubMsgRewardResponseHandler );
        system.removeEventListener( CClubEvent.CLUB_INFO_RESPONSE, _onClubInfoUpdateHandler );
        system.stage.flashStage.removeEventListener( Event.RESIZE, _onResizeHandler );
        _clubGameUI.removeEventListener( MouseEvent.MOUSE_DOWN, _onMouseDownHandler );
        _clubGameUI.removeEventListener( MouseEvent.MOUSE_UP, _onMouseUpHandler );
        _clubGameUI.removeEventListener( MouseEvent.MOUSE_MOVE, _onResizeHandler );
        _clubGameUI.removeEventListener( Event.REMOVED_FROM_STAGE, _onHideHandler );
        unschedule( _onShowBubble );
        unschedule( _onHideBubble );
    }

    private function get _pClubHandler() : CClubHandler {
        return system.getBean( CClubHandler ) as CClubHandler;
    }

    private function get _pClubManager() : CClubManager {
        return system.getBean( CClubManager ) as CClubManager;
    }

    private function get _pClubGameRewardViewHandler() : CClubGameRewardViewHandler {
        return system.getBean( CClubGameRewardViewHandler ) as CClubGameRewardViewHandler;
    }

    private function get _pCDatabaseSystem() : CDatabaseSystem {
        return system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
    }

    private function get _itemSystem() : CItemSystem {
        return system.stage.getSystem( CItemSystem ) as CItemSystem;
    }

    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }

    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
}
}
