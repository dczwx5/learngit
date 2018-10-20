//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/10/8.
 * Time: 16:17
 */
package kof.game.currency.buyPower {

    import flash.events.Event;
    import flash.events.MouseEvent;
import flash.geom.Point;

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
import kof.game.common.view.CTweenViewHandler;
import kof.game.currency.CCurrencyEvent;
import kof.game.lobby.CLobbySystem;
import kof.game.lobby.view.CPlayerHeadViewHandler;
import kof.game.player.CPlayerManager;
    import kof.game.player.CPlayerSystem;
    import kof.game.player.data.CPlayerData;
    import kof.game.player.event.CPlayerEvent;
    import kof.game.reciprocation.CReciprocalSystem;
    import kof.table.CurrencyVitContype;
    import kof.table.GamePrompt;
    import kof.table.VipPrivilege;
    import kof.ui.CMsgAlertHandler;
    import kof.ui.CUISystem;
    import kof.ui.demo.Currency.BuyPowerUI;
import kof.ui.master.main.HeadUI;

import morn.core.components.Button;
    import morn.core.components.CheckBox;
    import morn.core.components.Dialog;
    import morn.core.components.Label;
    import morn.core.handlers.Handler;

    public class CBuyPowerViewHandler extends CTweenViewHandler implements ISystemBundle {

        private var m_pUI : BuyPowerUI;

        private var isBuyWithZizhuan : Boolean = false;
        private var _bBuyCountIsOK : Boolean = true;
        private var _bCanBuy : Boolean = true;
        private var _currencyType : int = PURPLE_DIAMOND;
        private const PURPLE_DIAMOND : int = 2;
        private const BLUE_DIAMOND : int = 1;

        private var _bViewInitialized : Boolean = false;
        private var _costPurpleNu : int = 0;

        private var _bCanClickBuyBtn : Boolean = true;
        private var _buyedCount : int = 0;
        private var _canBuyTotalCount : int = 0;
        private var _isShow:Boolean = false;

        public function CBuyPowerViewHandler() {
            super( false );
        }

        override public function dispose() : void {
            super.dispose();
            _removeEventListeners();
            detachEventListeners();
            m_pUI = null;
        }

        override public function get viewClass() : Array {
            return [ BuyPowerUI ];
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

        override protected function onAssetsLoadCompleted() : void {
            super.onAssetsLoadCompleted();
            this.onInitializeView();
        }

        override protected function onInitializeView() : Boolean {
            if ( !super.onInitializeView() )
                return false;
            if ( !_bViewInitialized ) {
                _bViewInitialized = true;
                m_pUI = new BuyPowerUI();
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
                if ( vCurrent )
                    show();
                else
                    _close();
            }
        }

        private function get _playerSystem() : CPlayerSystem {
            return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem
        }

        private function _addEventListeners() : void {
            m_pUI.addEventListener( MouseEvent.CLICK, mouseClickFunc, false, 0, true );
            _playerSystem.addEventListener( CPlayerEvent.PLAYER_VIT, _updateData );
        }

        private function _removeEventListeners() : void {
            m_pUI.removeEventListener( MouseEvent.CLICK, mouseClickFunc );
            if ( _playerSystem )
                _playerSystem.removeEventListener( CPlayerEvent.PLAYER_VIT, _updateData );
        }

        private function mouseClickFunc( e : MouseEvent ) : void {
            var target : Object = e.target;
            if ( !("name" in target) ) {
                return;
            }
            switch ( target.name ) {
                case "okBtn":
                    if ( _buyedCount >= _canBuyTotalCount ) {
                        selectPrompt( 210 );
                    } else {
                        if ( _judgeNextCost() ) {
                            (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem).showCostBdDiamondMsgBox( _costPurpleNu, _buyVit );
                        } else {
                            var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
                            var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
                            bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
                            selectPrompt( 204 );
                        }
                    }
                    break;
            }
        }

        private function _judgeNextCost() : Boolean {
            var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
            var playerData : CPlayerData = playerManager.playerData;
            if ( _costPurpleNu <= playerData.currency.purpleDiamond ) {
                return true;
            } else {
                var costDiamond : int = _costPurpleNu - playerData.currency.purpleDiamond;
                if ( costDiamond <= playerData.currency.blueDiamond ) {
                    return true;
                }
            }
            return false;
        }

        private function selectPrompt( id : int ) : void {
            var talble : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = this.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            talble = pDatabaseSystem.getTable( KOFTableConstants.GAME_PROMPT ) as CDataTable;
            var gamePrompt : GamePrompt = talble.findByPrimaryKey( id );
            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( gamePrompt.content );
        }

        private function _buyVit() : void {
            if ( !_bCanClickBuyBtn )return;
            _bCanClickBuyBtn = false;
            system.getBean( CBuyPowerViewHandler ).dispatchEvent( new CCurrencyEvent( CCurrencyEvent.BUY_VIT ) );
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

        private function _updateShow() : void {
            if ( m_pUI ) {
                _addEventListeners();
                //战队数据
                var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
                var heroData : CPlayerData = playerManager.playerData;

                var talble : CDataTable;
                var pDatabaseSystem : CDatabaseSystem = this.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
                talble = pDatabaseSystem.getTable( KOFTableConstants.VIPPRIVILEGE ) as CDataTable;
                //vip等级
                var vipData : VipPrivilege = talble.findByPrimaryKey( heroData.vipData.vipLv );
                var vitToltalCount : int = vipData.phyCountLimit;
                (m_pUI.getChildByName( "txt3" ) as Label).isHtml = true;
                (m_pUI.getChildByName( "txt2" ) as Label).text = 120 + "";//固定数据120体力
                if ( !isNaN( heroData.vitData.buyPhysicalStrengthCount ) ) {
                    (m_pUI.getChildByName( "txt3" ) as Label).text = "<font color = '#e7c764'>（" + CLang.Get( "vit_buy_count" ) + "<font color = '#ff6a6a'>" + heroData.vitData.buyPhysicalStrengthCount + "/" + vitToltalCount + "</font>" + "）" + "</font>";
                    _buyedCount = heroData.vitData.buyPhysicalStrengthCount;
                    _canBuyTotalCount = vitToltalCount;
                    talble = pDatabaseSystem.getTable( KOFTableConstants.CURRENCY_VIT_CONTYPE ) as CDataTable;
                    var physicalStrengthCount : int = heroData.vitData.buyPhysicalStrengthCount + 1;
                    if ( physicalStrengthCount >= talble.toArray().length ) {
                        physicalStrengthCount = talble.toArray().length;
                    }
                    var currencyVit : CurrencyVitContype = talble.findByPrimaryKey( physicalStrengthCount );

                    isBuyWithZizhuan = true;
                    _currencyType = PURPLE_DIAMOND;
                    m_pUI.blue.visible = false;
                    m_pUI.purple.visible = true;
                    (m_pUI.getChildByName( "txt4" ) as Label).text = CLang.Get( "vit_is_buy_by_purple_diamond" );
                    (m_pUI.getChildByName( "remindRadio" ) as CheckBox).visible = false;
                    (m_pUI.getChildByName( "txt1" ) as Label).text = currencyVit.costPurpleDiamondNum + "";
                    _costPurpleNu = currencyVit.costPurpleDiamondNum;

                    if ( heroData.vitData.buyPhysicalStrengthCount >= vitToltalCount ) {
                        _bBuyCountIsOK = false;
                    }
                    else {
                        _bBuyCountIsOK = true;
                    }
                }
                if ( !(m_pUI.getChildByName( "remindRadio" ) as CheckBox).visible ) {
                    var btn : Button = m_pUI.getChildByName( "okBtn" ) as Button;
                    btn.centerX = 0;
                }
                var headView:HeadUI = ((system.stage.getSystem(CLobbySystem) as CLobbySystem).getHandler(CPlayerHeadViewHandler) as CPlayerHeadViewHandler).viewUI;
                var pt:Point =App.stage.localToGlobal(new Point(headView.box_power.x,headView.box_power.y));
                if(!_isShow){
                    _isShow = true;
                    setTweenData(KOFSysTags.BUY_POWER,null,new Point(pt.x,pt.y));//加坐标关闭为窗口回坐标点，否则为全屏中心
                    showDialog(m_pUI);
                }
            }
        }

        private function _uptateUI() : void {
            //战队数据
            var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
            var heroData : CPlayerData = playerManager.playerData;

            var talble : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = this.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            talble = pDatabaseSystem.getTable( KOFTableConstants.VIPPRIVILEGE ) as CDataTable;
            //vip等级
            var vipData : VipPrivilege = talble.findByPrimaryKey( heroData.vipData.vipLv );
            var vitToltalCount : int = vipData.phyCountLimit;
            (m_pUI.getChildByName( "txt3" ) as Label).isHtml = true;
            (m_pUI.getChildByName( "txt3" ) as Label).text = "<font color = '#e7c764'>（" + CLang.Get( "vit_buy_count" ) + "<font color = '#ff6a6a'>" + heroData.vitData.buyPhysicalStrengthCount + "/" + vitToltalCount + "</font>" + "）" + "</font>";
            talble = pDatabaseSystem.getTable( KOFTableConstants.CURRENCY_VIT_CONTYPE ) as CDataTable;
            var physicalStrengthCount : int = heroData.vitData.buyPhysicalStrengthCount + 1;
            if ( physicalStrengthCount >= 30 ) {
                physicalStrengthCount = 30;
            }
            var currencyVit : CurrencyVitContype = talble.findByPrimaryKey( physicalStrengthCount );
            isBuyWithZizhuan = false;
            _currencyType = BLUE_DIAMOND;
            (m_pUI.getChildByName( "txt4" ) as Label).text = CLang.Get( "vit_is_buy_by_blue_diamond" );
            (m_pUI.getChildByName( "remindRadio" ) as CheckBox).visible = true;
            (m_pUI.getChildByName( "txt1" ) as Label).text = currencyVit.costBlueDiamondNum + "";
            m_pUI.blue.visible = true;
            m_pUI.purple.visible = false;
            if ( heroData.currency.blueDiamond < currencyVit.costBlueDiamondNum ) {
                _bCanBuy = false;
            }

            if ( !(m_pUI.getChildByName( "remindRadio" ) as CheckBox).visible ) {
                var btn : Button = m_pUI.getChildByName( "okBtn" ) as Button;
                btn.centerX = 0;
            }
        }
        private function _close() : void {
            closeDialog(_closeB);
        }
        private function _closeB() : void {
            _isShow = false;
            _currencyType = PURPLE_DIAMOND;
            _removeEventListeners();
        }

        private function _onClose( type : String = "" ) : void {
            var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                _currencyType = PURPLE_DIAMOND;
                _removeEventListeners();
                pSystemBundleCtx.setUserData( this, "activated", false );
            }
        }

        private function _updateData( e : Event ) : void {
            var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                var vCurrent : Boolean = pSystemBundleCtx.getUserData( this, "activated", false );
                if ( !vCurrent ) {
                    return;
                }
            }
            if ( e.type == CPlayerEvent.PLAYER_VIT ) {
                if ( !_bCanClickBuyBtn ) {
                    (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( CLang.Get( "buySuccess" ), CMsgAlertHandler.NORMAL );
                }
                _bCanClickBuyBtn = true;
                this.invalidateData();
            }
        }

        override protected function updateData() : void {
            super.updateData();
            if ( _currencyType == BLUE_DIAMOND ) {
                this._uptateUI();
            }
            else {
                this._updateShow();
            }

        }

        public function get bundleID() : * {
            return SYSTEM_ID( KOFSysTags.BUY_POWER );
        }

        public function inverseWindow() : void {
            var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            var vCurrent : Boolean = pSystemBundleCtx.getUserData( this, "activated", false );

            if ( pSystemBundleCtx ) {
                pSystemBundleCtx.setUserData( this, "activated", !vCurrent );
            }
        }
    }
}
