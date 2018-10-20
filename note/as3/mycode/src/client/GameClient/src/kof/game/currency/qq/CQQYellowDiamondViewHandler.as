//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/6/30.
 * Time: 18:28
 */
package kof.game.currency.qq {

    import flash.events.Event;

    import kof.SYSTEM_ID;
    import kof.framework.CViewHandler;
    import kof.framework.events.CEventPriority;
    import kof.game.KOFSysTags;
    import kof.game.bundle.CBundleSystem;
    import kof.game.bundle.CSystemBundleEvent;
    import kof.game.bundle.ISystemBundle;
    import kof.game.bundle.ISystemBundleContext;
import kof.game.common.view.CTweenViewHandler;
import kof.game.currency.CCurrencyEvent;
    import kof.game.currency.qq.data.configData.CQQTableDataManager;
    import kof.game.currency.qq.data.netData.CQQClientDataManager;
    import kof.game.currency.qq.views.CQQYellowView;
    import kof.game.currency.tipview.CTipsViewHandler;
    import kof.ui.CUISystem;
    import kof.ui.imp_common.ItemTipsUI;
    import kof.ui.platform.qq.YellowDiamondUI;

    import morn.core.components.Dialog;

    import morn.core.handlers.Handler;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/6/30
     */
    public class CQQYellowDiamondViewHandler extends CTweenViewHandler implements ISystemBundle {
        private var _yellowDiamondView : CQQYellowView = null;
        private var _bViewInitialized : Boolean = false;

        public function CQQYellowDiamondViewHandler() {
            super( false );
        }

        public function get bundleID() : * {
            return SYSTEM_ID( KOFSysTags.QQ_YELLOW_DIAMOND );
        }

        override public function dispose() : void {
            super.dispose();
            detachEventListeners();
        }

        override public function get viewClass() : Array {
            return [ YellowDiamondUI, ItemTipsUI ];
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
                _yellowDiamondView = new CQQYellowView( system );
                _yellowDiamondView.closeHandler = new Handler( _onClose );
                _yellowDiamondView.uiCanvas = uiCanvas;
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
            var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                CQQTableDataManager.instance.system = system;
                var handler : Handler = new Handler( (system.stage.getSystem( CUISystem ).getHandler( CTipsViewHandler ) as CTipsViewHandler).showQQTips, [ KOFSysTags.QQ_YELLOW_DIAMOND ] );
                pSystemBundleCtx.setUserData( this, CBundleSystem.TIP_HANDLER, handler );
                var bool : Boolean = system.getBean( CQQClientDataManager ).hasGetReward( KOFSysTags.QQ_YELLOW_DIAMOND );
                pSystemBundleCtx.setUserData( this, CBundleSystem.NOTIFICATION, bool );
            }
            system.getBean( CQQClientDataManager ).addEventListener( CCurrencyEvent.UPDATE_QQData, _updateData );
        }

        private function _onSystemBundleStop( event : CSystemBundleEvent ) : void {
            //this.enabled = false;
        }

        private function _onSystemBundleUserData( event : CSystemBundleEvent ) : void {
            var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                var vCurrent : Boolean = pSystemBundleCtx.getUserData( this, CBundleSystem.ACTIVATED, false );
                if ( vCurrent ) {
                    show();
                }
                else {
                    if ( _yellowDiamondView ) {
                        _yellowDiamondView.close();
                    }
                }
            }
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

        private function _updateData( e : Event ) : void {
            var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                var bool : Boolean = (system.getBean( CQQClientDataManager ) as CQQClientDataManager).hasGetReward( KOFSysTags.QQ_YELLOW_DIAMOND );
                pSystemBundleCtx.setUserData( this, CBundleSystem.NOTIFICATION, bool );
                var isShow : Boolean = pSystemBundleCtx.getUserData( this, CBundleSystem.ACTIVATED, true );
                if ( isShow ) {
                    this.invalidateData();
                }
            }
        }

        override protected function updateData() : void {
            super.updateData();
            var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                var vCurrent : Boolean = pSystemBundleCtx.getUserData( this, CBundleSystem.ACTIVATED, false );
                if ( !vCurrent ) {
                    return;
                }
            }
            if ( _yellowDiamondView )
                _yellowDiamondView.update();
        }

        private function _onClose( type : String = null ) : void {
            if ( type == Dialog.CLOSE ) {
                var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
                if ( pSystemBundleCtx ) {
                    pSystemBundleCtx.setUserData( this, CBundleSystem.ACTIVATED, false );
                }
            }
        }
    }
}
