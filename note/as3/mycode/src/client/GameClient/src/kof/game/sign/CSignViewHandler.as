//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/5/31.
 * Time: 9:51
 */
package kof.game.sign {
    import kof.game.common.view.CTweenViewHandler;
    import kof.game.sign.signFacade.CSignFacade;
    import kof.ui.imp_common.ItemUIUI;
    import kof.ui.master.Sign.SignUI;
    import morn.core.handlers.Handler;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/5/31
     */
    public class CSignViewHandler extends CTweenViewHandler {
        private var _closeHandler : Handler = null;
        private var _signFacade : CSignFacade = null;
        private var _bViewInitialized : Boolean = false;

        public function CSignViewHandler() {
            super( false );
        }

        override public function dispose() : void {
            super.dispose();

            _closeHandler = null;
            if ( _signFacade ) {
                _signFacade.dispose();
            }
            _signFacade = null;
        }

        override public function get viewClass() : Array {
            return [ SignUI , ItemUIUI];
        }

        override protected function onAssetsLoadCompleted() : void {
            super.onAssetsLoadCompleted();
            this.onInitializeView();
        }

        override protected function onInitializeView() : Boolean {
            if ( !super.onInitializeView() )
                return false;

            if ( !_bViewInitialized ) {
                _signFacade = CSignFacade.getInstance();
                _bViewInitialized = _signFacade.initSignView();
                _signFacade.signViewUIContainer = uiCanvas;
                _signFacade.signAppSystem = system;
                _signFacade.closeHandler = _closeHandler;
            }
            return _bViewInitialized;
        }

        public function set closeHandler( handler : Handler ) : void {
            _closeHandler = handler;
        }

        public function get closeHandler() : Handler {
            return this._closeHandler;
        }

        public function show() : void {
            this.loadAssetsByView( viewClass, _showDisplay );
        }

        protected function _showDisplay() : void {
            if ( onInitializeView() ) {
                invalidate();
                callLater( _showView );
            } else {
                // Show warning, error, etc.
                LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
            }
        }

        private function _showView() : void {
            _signFacade.show();
        }

        public function close() : void {
            _signFacade.close();
        }
    }
}
