//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/6/17.
 * Time: 16:31
 */
package kof.game.currency.monthAndWeekCard {

import kof.SYSTEM_ID;
import kof.data.CDataTable;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.events.CEventPriority;
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
import kof.game.welfarehall.CWelfareHallEvent;
import kof.game.welfarehall.CWelfareHallManager;
import kof.game.welfarehall.CWelfareHallSystem;
import kof.game.welfarehall.data.WelfareHallConst;
import kof.table.CardMonthConfig;
import kof.table.Currency;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;
import kof.ui.demo.Currency.MonthCardUI;
import kof.ui.master.BargainCard.GoldtipsUI;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

/**
     * @author yili(guoyiligo@qq.com)
     * 2017/6/17
     */
    public class CMonthCardViewHandler extends CViewHandler implements ISystemBundle {
        private var _bViewInitialized : Boolean = false;
        public var _cardUI : MonthCardUI = null;

        private var _tipUI:GoldtipsUI=null;
        private var _isShow : Boolean = false;

        public function CMonthCardViewHandler() {
            super( false );
        }

        override public function dispose() : void {
            super.dispose();
        }

        override public function get viewClass() : Array {
            return [ GoldtipsUI ,MonthCardUI];
        }

        override protected function onSetup() : Boolean {
            var ret : Boolean = super.onSetup();
            ret = ret && _initializeBundle();
            return ret;
        }

        private function _initializeBundle() : Boolean {
            var pSystemBundleContext : ISystemBundleContext = system.stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
            if ( pSystemBundleContext ) {
                pSystemBundleContext.registerSystemBundle( this );
                this.attachEventListeners();
                return true;
            }
            return false;
        }

        override protected function onInitializeView() : Boolean {
            if ( !super.onInitializeView() )
                return false;

            if ( !_bViewInitialized ) {
                _bViewInitialized = true;
                _cardUI = new MonthCardUI();
                _cardUI.closeHandler = new Handler( _onClose );
                _cardUI.okbtn.clickHandler = new Handler( _okbtnFunc );
                _cardUI.cancelbtn.clickHandler = new Handler( _cancelbtnFunc );
                (system.stage.getSystem(CWelfareHallSystem) as CWelfareHallSystem).addEventListener(CWelfareHallEvent.WELFAREHALL_VIEW_CLOSE , _welfrareClose );
                (system.stage.getSystem(CWelfareHallSystem) as CWelfareHallSystem).addEventListener(CWelfareHallEvent.CARDMONTHINFO_RESPONSE , _updateState );
                (system.stage.getSystem(CWelfareHallSystem) as CWelfareHallSystem).addEventListener(CWelfareHallEvent.GETCARDMONTHREWARD_RESPONSE , _updateState );
                _tipUI = new GoldtipsUI();
            }
            return _bViewInitialized;
        }

    protected function _updateState(e:CWelfareHallEvent):void{
        var playerHead : CPlayerHeadViewHandler = system.stage.getSystem( CLobbySystem ).getBean( CPlayerHeadViewHandler ) as CPlayerHeadViewHandler;
        playerHead.invalidateData();
    }

        protected function _welfrareClose(e:CWelfareHallEvent):void{
            var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                pSystemBundleCtx.setUserData( this, "activated", false );
            }
        }

        //后面要做钻石是否够的判断
        public function _okbtnFunc() : void {
            //战队数据
            var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
            var playerData : CPlayerData = playerManager.playerData;
            // 0未购买 1购买
            if ( playerData.monthAndWeekCardData.goldCardState ) {
                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( CLang.Get( "monthAlert" ) );
            } else {
                system.getBean( CMonthCardViewHandler ).dispatchEvent( new CCurrencyEvent( CCurrencyEvent.BUY_WEEK_OR_MONTH_CARD, {
                    type : ECardType.MONTH
                } ) );
            }
        }

        private function _cancelbtnFunc() : void {
            _onClose( Dialog.CLOSE );
        }

        protected function attachEventListeners() : void {
            this.addEventListener( CSystemBundleEvent.BUNDLE_START, _onSystemBundleStart, false, CEventPriority.DEFAULT, true );
            this.addEventListener( CSystemBundleEvent.BUNDLE_STOP, _onSystemBundleStop, false, CEventPriority.DEFAULT, true );
            this.addEventListener( CSystemBundleEvent.USER_DATA, _onSystemBundleUserData, false, CEventPriority.DEFAULT, true );
        }

        protected function detachEventListeners() : void {
            this.removeEventListener( CSystemBundleEvent.BUNDLE_START, _onSystemBundleStart );
            this.removeEventListener( CSystemBundleEvent.BUNDLE_STOP, _onSystemBundleStop );
            this.removeEventListener( CSystemBundleEvent.USER_DATA, _onSystemBundleUserData );
        }

        private function _onSystemBundleStart( event : CSystemBundleEvent ) : void {
            //
        }

        private function _onSystemBundleStop( event : CSystemBundleEvent ) : void {
            //this.enabled = false;
        }

        public function _onSystemBundleUserData( event : CSystemBundleEvent ) : void {
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

        public function _addEventListeners() : void {
            _playerSystem.addEventListener( CPlayerEvent.PLAYER_MONTH_AND_WEEK_CARD, _updateData );
        }

        final private function get _playerSystem() : CPlayerSystem {
            return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem
        }

        [Inline]
        private function _removeEventListeners() : void {
            if ( _playerSystem )
                _playerSystem.removeEventListener( CPlayerEvent.PLAYER_MONTH_AND_WEEK_CARD, _updateData );
        }

        final public function show() : void {
            this.loadAssetsByView( viewClass, _showDisplay );
        }

        protected function _showDisplay() : void {
            if ( onInitializeView() ) {
                invalidate();
            } else {
                // Show warning, error, etc.
                LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
            }
        }

        public function _updateUI() : void {
            if ( _cardUI ) {
                _addEventListeners();
                var talble : CDataTable;
                var pDatabaseSystem : CDatabaseSystem = this.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
                talble = pDatabaseSystem.getTable( KOFTableConstants.CARD_MONTH_CONFIG ) as CDataTable;
                //vip等级
                var cardConfig : CardMonthConfig = talble.findByPrimaryKey( ECardType.MONTH );
                talble = pDatabaseSystem.getTable( KOFTableConstants.CURRENCY ) as CDataTable;
                var currencyConfig : Currency = talble.findByPrimaryKey( cardConfig.currencyID );
                var currencyIcoUrl : String = currencyConfig.source;
                _cardUI.icon.url = ECurrencyIconURL.getIcoUrl( currencyIcoUrl );
                _cardUI.txt1.text = CLang.Get( "buyCard", {v1 : cardConfig.consumeNum} );
                _cardUI.txt2.text = CLang.Get( "buyMonthCard" );
                _cardUI.txt3.text = cardConfig.buyinfo;

                uiCanvas.addDialog( _cardUI );
            }
        }

        protected function _updateData( e : CPlayerEvent ) : void {
            if ( e.type == CPlayerEvent.PLAYER_MONTH_AND_WEEK_CARD ) {
                var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
                if ( pSystemBundleCtx ) {
                    var vCurrent : Boolean = pSystemBundleCtx.getUserData( this, "activated", true );
                    if ( vCurrent ) {
                        //战队数据
                        var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
                        var playerData : CPlayerData = playerManager.playerData;
                        // 0未购买 1购买
                        if ( playerData.monthAndWeekCardData.goldCardState ) {
                            _isShow = true;
                            _onClose( Dialog.CLOSE );
                            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( CLang.Get( "buySuccess" ), CMsgAlertHandler.NORMAL );
                        }
                        var playerHead : CPlayerHeadViewHandler = system.stage.getSystem( CLobbySystem ).getBean( CPlayerHeadViewHandler ) as CPlayerHeadViewHandler;
                        playerHead.invalidateData();
                    }
                }
            }
        }

        override protected function updateData() : void {
            super.updateData();
            _updateUI();
        }

        private function _close() : void {
            _removeEventListeners();
            _cardUI.close();
        }

        public function _onClose( type : String ) : void {
            if ( type == Dialog.CLOSE ) {
                var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
                if ( pSystemBundleCtx ) {
                    this._close();
                    pSystemBundleCtx.setUserData( this, "activated", false );
                }
            }
        }

        public function get bundleID() : * {
            return SYSTEM_ID( KOFSysTags.BUY_MONTH_CARD );
        }


    }
}
