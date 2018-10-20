//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/6/19.
 * Time: 16:38
 */
package kof.game.currency.monthAndWeekCard {

import kof.SYSTEM_ID;
import kof.data.CDataTable;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.CSystemBundleEvent;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CLang;
import kof.game.currency.CCurrencyEvent;
import kof.game.currency.enum.ECardType;
import kof.game.currency.enum.ECurrencyIconURL;
import kof.game.lobby.CLobbySystem;
import kof.game.lobby.view.CPlayerHeadViewHandler;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.event.CPlayerEvent;
import kof.table.CardMonthConfig;
import kof.table.Currency;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;

import morn.core.components.Dialog;

/**
     * @author yili(guoyiligo@qq.com)
     * 2017/6/19
     */
    public class CWeekCardViewHandler extends CMonthCardViewHandler {
        private var _isShow : Boolean = false;

        public function CWeekCardViewHandler() {
        }

        override public function get bundleID() : * {
            return SYSTEM_ID( KOFSysTags.BUY_WEEK_CARD );
        }

        override protected function _showDisplay() : void {
            if ( onInitializeView() ) {
                invalidate();
            } else {
                // Show warning, error, etc.
                LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
            }
        }

        override public function _onSystemBundleUserData( event : CSystemBundleEvent ) : void {
            var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                var vCur : Boolean = pSystemBundleCtx.getUserData( this, "activated", true );
                var systemBundle:ISystemBundle = pSystemBundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.BARGAINCARD));
                var vCurrent : Boolean = pSystemBundleCtx.getUserData( systemBundle, "activated", false );
                if(vCur){
                    if(vCurrent){
                        pSystemBundleCtx.setUserData( systemBundle, CBundleSystem.ACTIVATED, false );
                    }else{
                        //pSystemBundleCtx.setUserData(systemBundle, CBundleSystem.WELFARE_HALL_TYPE, [WelfareHallConst.BARGAINCARD]);
                        pSystemBundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
                    }
                }else{
                    if(vCurrent){
                        pSystemBundleCtx.setUserData( systemBundle, CBundleSystem.ACTIVATED, false );
                    }
                }
            }
        }

        override protected function _updateData( e : CPlayerEvent ) : void {
            if ( e.type == CPlayerEvent.PLAYER_MONTH_AND_WEEK_CARD ) {
                var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
                if ( pSystemBundleCtx ) {
                    var vCurrent : Boolean = pSystemBundleCtx.getUserData( this, "activated", true );
                    if ( vCurrent ) {
                        //战队数据
                        var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
                        var playerData : CPlayerData = playerManager.playerData;
                        // 0未购买 1购买
                        if ( playerData.monthAndWeekCardData.silverCardState ) {
                            _isShow = true;
                            _onClose( Dialog.CLOSE );
                            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( CLang.Get( "buySuccess" ), CMsgAlertHandler.NORMAL );
                            var playerHead : CPlayerHeadViewHandler = system.stage.getSystem( CLobbySystem ).getBean( CPlayerHeadViewHandler ) as CPlayerHeadViewHandler;
                            playerHead.invalidateData();
                        }
                    }
                }
            }
        }

        override protected function updateData() : void {
            _updateUI();
        }

        override public function _updateUI() : void {
            //战队数据
            if ( _cardUI ) {
                _addEventListeners();
                var talble : CDataTable;
                var pDatabaseSystem : CDatabaseSystem = this.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
                talble = pDatabaseSystem.getTable( KOFTableConstants.CARD_MONTH_CONFIG ) as CDataTable;
                //vip等级
                var cardConfig : CardMonthConfig = talble.findByPrimaryKey( ECardType.WEEK );
                talble = pDatabaseSystem.getTable( KOFTableConstants.CURRENCY ) as CDataTable;
                var currencyConfig : Currency = talble.findByPrimaryKey( cardConfig.currencyID );
                var currencyIcoUrl : String = currencyConfig.source;
                _cardUI.icon.url = ECurrencyIconURL.getIcoUrl( currencyIcoUrl );
                _cardUI.txt1.text = CLang.Get( "buyCard", {v1 : cardConfig.consumeNum} );
                _cardUI.txt2.text = CLang.Get( "buyWeekCard" );
                _cardUI.txt3.text = cardConfig.buyinfo;
                uiCanvas.addDialog( _cardUI );
            }
        }

        override public function _okbtnFunc() : void {
            //战队数据
            var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
            var playerData : CPlayerData = playerManager.playerData;
            if ( playerData.monthAndWeekCardData.silverCardState ) {
                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( CLang.Get( "weekAlert" ) );
            } else {
                system.getBean( CMonthCardViewHandler ).dispatchEvent( new CCurrencyEvent( CCurrencyEvent.BUY_WEEK_OR_MONTH_CARD, {
                    type : ECardType.WEEK
                } ) );
            }
        }
//
//        override public function updateRedPoint() : Boolean {
//            if(!_isOpenSystem()){
//                return false;
//            }
//            var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
//            var playerData : CPlayerData = playerManager.playerData;
//            //var talble : CDataTable;
//            //var pDatabaseSystem : CDatabaseSystem = this.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
//            //talble = pDatabaseSystem.getTable( KOFTableConstants.CARD_MONTH_CONFIG ) as CDataTable;
//            //vip等级
//            //var cardConfig : CardMonthConfig = talble.findByPrimaryKey( ECardType.WEEK );
//            // 0未购买 1购买
//            if ( playerData.monthAndWeekCardData.silverCardState == 0 ) {
//                //if ( playerData.currency.blueDiamond >= cardConfig.consumeNum ) {
//                    return true;
//                //}
//            }
//            var bool : Boolean = (system.stage.getSystem( CBargainCardSystem ).getBean( CBargainCardManager ) as CBargainCardManager).silverRewardState;
//            return bool;
//        }
//
//        override public function isGray():Boolean{
//            var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
//            var playerData : CPlayerData = playerManager.playerData;
//            // 0未购买 1购买
//            if ( playerData.monthAndWeekCardData.silverCardState == 0 ) {
//                return true;
//            }else{
//                return false;
//            }
//            return true;
//        }
    }
}
