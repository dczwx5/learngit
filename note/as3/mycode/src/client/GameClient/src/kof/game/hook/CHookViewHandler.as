//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/7/17.
 * Time: 10:17
 */
package kof.game.hook {

    import flash.system.System;

    import kof.framework.CViewHandler;
import kof.game.common.view.CTweenViewHandler;
import kof.game.hook.net.CHookNet;
    import kof.game.hook.view.CHookView;
import kof.ui.demo.Bag.QualityBoxUI;
import kof.ui.master.Hook.HookUI;
    import kof.ui.master.hangup.HangUpUI;

    import morn.core.handlers.Handler;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/7/17
     */
    public class CHookViewHandler extends CTweenViewHandler {
        private var _bViewInitialized : Boolean = false;
        private var _pHookView : CHookView = null;

        private var _closeHandler : Handler = null;

        public function CHookViewHandler() {
            super( false );
        }

        override public function dispose() : void {
            super.dispose();
            _closeHandler = null;
            _pHookView.dispose();
            _pHookView = null;
        }

        public function update( delta : Number ) : void {
            if ( _pHookView ) {
                _pHookView.updateAnimation( delta );
            }
        }

        override public function get viewClass() : Array {
            return [ HangUpUI ,QualityBoxUI];
        }

        override protected function onAssetsLoadCompleted() : void {
            super.onAssetsLoadCompleted();
            this.onInitializeView();
        }

        override protected function onInitializeView() : Boolean {
            if ( !super.onInitializeView() )
                return false;
            if ( !_bViewInitialized ) {
                var hookNet : CHookNet = (system.getBean( CHookHandler ) as CHookHandler).hookNet;
                _bViewInitialized = true;
                _pHookView = new CHookView( hookNet );
                _pHookView.uiContainer = uiCanvas;
                _pHookView.closeHandler = this._closeHandler;
                _pHookView.system=system as CHookSystem;
            }
            return _bViewInitialized;
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
            _pHookView.show();
        }

        public function close() : void {
            if(_pHookView){
                _pHookView.close();
            }
        }

        public function set closeHandler( value : Handler ) : void {
            this._closeHandler = value;
        }
    }
}
