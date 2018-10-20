//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/10/8.
 * Time: 11:48
 */
package kof.game.currency.buyMoney {

    import flash.events.MouseEvent;
import flash.geom.Point;

import kof.SYSTEM_ID;
    import kof.data.CDataTable;
    import kof.data.CDatabaseSystem;
    import kof.data.KOFTableConstants;
    import kof.framework.CViewHandler;
    import kof.framework.events.CEventPriority;
    import kof.game.KOFSysTags;
    import kof.game.bundle.CSystemBundleEvent;
    import kof.game.bundle.ISystemBundle;
    import kof.game.bundle.ISystemBundleContext;
    import kof.game.common.CLang;
import kof.game.common.view.CTweenViewHandler;
import kof.game.currency.CCurrencyEvent;
import kof.game.lobby.CLobbySystem;
import kof.game.lobby.view.CPlayerHeadViewHandler;
import kof.game.player.CPlayerManager;
    import kof.game.player.CPlayerSystem;
    import kof.game.player.data.CPlayerData;
    import kof.game.player.event.CPlayerEvent;
    import kof.game.reciprocation.CReciprocalSystem;
    import kof.table.CurrencyGoldContype;
    import kof.table.GamePrompt;
    import kof.table.TeamCoefficient;
    import kof.table.VipPrivilege;
    import kof.ui.CMsgAlertHandler;
    import kof.ui.CUISystem;
    import kof.ui.demo.Currency.BuyMoneyUI;
import kof.ui.master.main.HeadUI;

import morn.core.components.Button;
    import morn.core.components.Dialog;
    import morn.core.components.Label;
    import morn.core.handlers.Handler;

    public class CBuyMoneyViewHandler extends CTweenViewHandler implements ISystemBundle {

        private var m_pUI : BuyMoneyUI;
//    private var m_pMask : Shape;
        private var _bViewInitialized : Boolean = false;
        private var _iBuyGoldCount : int = 10;

        private var _nPlayerPurpleDiamond : Number = 0;

        private var _bCanClickBuyBtn : Boolean = true;

        private var _buyedCount : int = 0;
        private var _canBuyTotalCount : int = 0;
        private var _nucount:int = 0;

        private var _isShow:Boolean = false;

        public function CBuyMoneyViewHandler() {
            super( false );
        }

        override public function dispose() : void {
            super.dispose();
            _removeEventListeners();
            detachEventListeners();
            m_pUI = null;
        }

        override public function get viewClass() : Array {
            return [ BuyMoneyUI ];
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
                m_pUI = new BuyMoneyUI();
                m_pUI.closeHandler = new Handler( _onClose );
            }
            return _bViewInitialized;
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

        private function _onSystemBundleUserData( event : CSystemBundleEvent ) : void {
            var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                var vCurrent : Boolean = pSystemBundleCtx.getUserData( this, "activated", false );
                if ( vCurrent ) {
                    show();
                } else {
                    _close();
                }
            }
        }

        private function _addEventListeners() : void {
            m_pUI.addEventListener( MouseEvent.CLICK, mouseClickFunc, false, 0, true );
            _playerSystem.addEventListener( CPlayerEvent.PLAYER_ORIGIN_CURRENCY, _updateData );
        }

        final private function get _playerSystem() : CPlayerSystem {
            return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem
        }

        private function _removeEventListeners() : void {
            m_pUI.removeEventListener( MouseEvent.CLICK, mouseClickFunc );
            if ( _playerSystem )
                _playerSystem.removeEventListener( CPlayerEvent.PLAYER_ORIGIN_CURRENCY, _updateData );
        }

        private function mouseClickFunc( e : MouseEvent ) : void {
            var target : Object = e.target;
            if ( !("name" in target) ) {
                return;
            }
            var pSystemBundleCtx : ISystemBundleContext = null;
            var pSystemBundle : ISystemBundle = null;
            switch ( target.name ) {
                case "okBtn":
                    if ( _buyedCount >= _canBuyTotalCount ) {
                        selectPrompt( 207 );//点金手次数超过会员等级上限限制
                    } else {
                        if ( !_judgeDiamond( 1 ) ) {
                            pSystemBundleCtx = system.stage.getSystem( ISystemBundleContext ) as
                                    ISystemBundleContext;
                            if ( pSystemBundleCtx ) {
                                pSystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.PAY ) );
                                if ( pSystemBundle ) {
                                    pSystemBundleCtx.setUserData( pSystemBundle, "activated", true );
                                    selectPrompt( 204 );//绑钻加钻石不足
                                }
                            }
                        } else {
                            (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem).showCostBdDiamondMsgBox( _costPurpleDiamond( 1 ), _buyOne );
                        }
                    }
                    break;
                case "buyTenBtn":
                    if ( _buyedCount >= _canBuyTotalCount ) {
                        selectPrompt( 207 );//点金手次数超过会员等级上限限制
                    } else {
                        if ( !_judgeDiamond( _nucount ) ) {
                            pSystemBundleCtx = system.stage.getSystem( ISystemBundleContext ) as
                                    ISystemBundleContext;
                            if ( pSystemBundleCtx ) {
                                pSystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.PAY ) );
                                if ( pSystemBundle ) {
                                    pSystemBundleCtx.setUserData( pSystemBundle, "activated", true );
                                    selectPrompt( 204 );//绑钻加钻石不足
                                }
                            }
                        } else {
                            (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem).showCostBdDiamondMsgBox( _costPurpleDiamond( _iBuyGoldCount ), _buyTen );
                        }
                    }
                    break;
            }
        }

        private function selectPrompt( id : int ) : void {
            var talble : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = this.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            talble = pDatabaseSystem.getTable( KOFTableConstants.GAME_PROMPT ) as CDataTable;
            var gamePrompt : GamePrompt = talble.findByPrimaryKey( id );
            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( gamePrompt.content );
        }

        private function _judgeDiamond( nu : Number ) : Boolean {
            var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
            var playerData : CPlayerData = playerManager.playerData;
            var neetCost : Number = _costPurpleDiamond( nu );
            if ( neetCost - playerData.currency.purpleDiamond <= 0 ) {
                return true;
            } else {
                var needDiamond : Number = neetCost - playerData.currency.purpleDiamond;
                if ( needDiamond <= playerData.currency.blueDiamond ) {
                    return true;
                }
            }
            return false;
        }

        private function _buyOne() : void {
            if ( !_bCanClickBuyBtn )return;
            _bCanClickBuyBtn = false;
            system.getBean( CBuyMoneyViewHandler ).dispatchEvent( new CCurrencyEvent( CCurrencyEvent.BUY_GOLD, {
                count : 1
            } ) );
        }

        private function _buyTen() : void {
            if ( !_bCanClickBuyBtn )return;
            _bCanClickBuyBtn = false;
            system.getBean( CBuyMoneyViewHandler ).dispatchEvent( new CCurrencyEvent( CCurrencyEvent.BUY_GOLD, {
                count : _iBuyGoldCount
            } ) );
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

        private function _updateUI() : void {
            if ( m_pUI ) {
                _addEventListeners();
                //战队数据
                var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
                var playerData : CPlayerData = playerManager.playerData;
//                if ( playerData.vitData.physicalStrength > _currentVit ) {
//                    (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( CLang.Get( "buySuccess" ), CMsgAlertHandler.NORMAL );
//                }
//                _currentVit = (playerData.vitData.physicalStrength;
                _nPlayerPurpleDiamond = playerData.currency.purpleDiamond;
                var talble : CDataTable;
                var pDatabaseSystem : CDatabaseSystem = this.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
                talble = pDatabaseSystem.getTable( KOFTableConstants.VIPPRIVILEGE ) as CDataTable;
                //vip等级
                var vipData : VipPrivilege = talble.findByPrimaryKey( playerData.vipData.vipLv );
                var goldToltalCount : int = vipData.goldCountLimit;
                (m_pUI.getChildByName( "txt3" ) as Label).isHtml = true;
                if ( !isNaN( playerData.currency.buyGoldCount ) ) {
                    (m_pUI.getChildByName( "txt3" ) as Label).text = "<font color = '#e7c764'>（" + CLang.Get( "vit_buy_count" ) + "<font color = '#ff6a6a'>" + playerData.currency.buyGoldCount + "/" + goldToltalCount + "</font>" + "）" + "</font>";
                    _buyedCount = playerData.currency.buyGoldCount;
                    _canBuyTotalCount = goldToltalCount;
                    talble = pDatabaseSystem.getTable( KOFTableConstants.CURRENCY_GOLD_CONTYPE ) as CDataTable;
                    var costPurpleDiamondNu : int = _costPurpleDiamond( 1 );
                    (m_pUI.getChildByName( "txt1" ) as Label).text = costPurpleDiamondNu + "";
                    talble = pDatabaseSystem.getTable( KOFTableConstants.TEAM_COEFFICIENT ) as CDataTable;
                    var teamLv : TeamCoefficient = talble.findByPrimaryKey( playerData.teamData.level );
                    (m_pUI.getChildByName( "txt2" ) as Label).text = teamLv.goldLvc + "";
//                    var nucount : int = 10;//goldToltalCount - playerData.buyGoldCount;
                    _nucount = 10;
                    if ( _canBuyTotalCount - _buyedCount >= 10 ) {
                        _nucount = 10;
                    } else {
                        _nucount = _canBuyTotalCount - _buyedCount;
                    }
                    if ( _nucount == 0 ) {
                        _nucount = 1;
                    }
                    (m_pUI.getChildByName( "buyTenBtn" ) as Button).label = CLang.Get( "buyGold", {v1 : _nucount} );
                    _iBuyGoldCount = _nucount;
                }
                var headView:HeadUI = ((system.stage.getSystem(CLobbySystem) as CLobbySystem).getHandler(CPlayerHeadViewHandler) as CPlayerHeadViewHandler).viewUI;
                var pt:Point =App.stage.localToGlobal(new Point(headView.goldBox.x,headView.goldBox.y));
                if(!_isShow){
                    _isShow = true;
                    setTweenData(KOFSysTags.BUY_MONEY,null,new Point(pt.x,pt.y));
                    showDialog(m_pUI);
                }

            }
        }

        private function _costPurpleDiamond( buyCount : int ) : int {
            var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
            var playerData : CPlayerData = playerManager.playerData;
            var talble : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = this.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            talble = pDatabaseSystem.getTable( KOFTableConstants.CURRENCY_GOLD_CONTYPE ) as CDataTable;
            var currencyGold : CurrencyGoldContype = null;
            var totalDiamond : int = 0;
            for ( var i : int = 1; i <= buyCount; i++ ) {
                currencyGold = talble.findByPrimaryKey( playerData.currency.buyGoldCount + i );
                totalDiamond += currencyGold.costPurpleDiamondNum;
            }
            return totalDiamond;
        }


        private function _updateData( e : CPlayerEvent ) : void {
            var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                var vCurrent : Boolean = pSystemBundleCtx.getUserData( this, "activated", false );
                if ( !vCurrent ) {
                    return;
                }
            }
            if ( e.type == CPlayerEvent.PLAYER_ORIGIN_CURRENCY ) {
                if ( !_bCanClickBuyBtn ) {
                    (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( CLang.Get( "buyMoneySuccess" ), CMsgAlertHandler.NORMAL );
                }
                _bCanClickBuyBtn = true;
                this.invalidateData();
            }
        }

        override protected function updateData() : void {
            super.updateData();
            this._updateUI();
        }

        private function _close() : void {
            closeDialog(_closeB);
        }
        private function _closeB() : void {
            _isShow = false;
            _removeEventListeners();
        }

        private function _onClose( type : String = "" ) : void {
            var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                _removeEventListeners();
                pSystemBundleCtx.setUserData( this, "activated", false );
            }
        }

        public function get bundleID() : * {
            return SYSTEM_ID( KOFSysTags.BUY_MONEY );
        }
    }
}
