//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/7/27.
 * Time: 10:58
 */
package kof.game.globalBoss {

import kof.framework.CViewHandler;
import kof.game.common.view.CTweenViewHandler;
import kof.game.globalBoss.view.CWBMainView;
import kof.ui.imp_common.ItemUIUI;
import kof.ui.master.WorldBoss.WBRewardItemUI;
import kof.ui.master.WorldBoss.WorldBossUI;

import morn.core.handlers.Handler;

/**
     * @author yili(guoyiligo@qq.com)
     * 2017/7/27
     */
    public class CWorldBossViewHandler extends CTweenViewHandler {
        private var _bViewInitialized : Boolean = false;
        private var _closeHandler : Handler = null;
        private var _pWBMainView : CWBMainView = null;

        public function CWorldBossViewHandler() {
            super( false );
        }

        override public function dispose() : void {
            super.dispose();
        }

        override public function get viewClass() : Array {
            return [ WorldBossUI, ItemUIUI , WBRewardItemUI];
        }

        override protected function get additionalAssets() : Array {
            return [
                "frameclip_task.swf"
            ];
        }

        override protected function onAssetsLoadCompleted() : void {
            super.onAssetsLoadCompleted();
            this.onInitializeView();
        }

        override protected function onInitializeView() : Boolean {
            if ( !super.onInitializeView() )
                return false;
            if ( !_bViewInitialized ) {
                _pWBMainView = new CWBMainView( uiCanvas );
                _pWBMainView.closeHandler = this._closeHandler;
                _pWBMainView.appSystem = system;
                _bViewInitialized = true;
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
            if(_pWBMainView)
            _pWBMainView.show()
        }

        public function close() : void {
            if(_pWBMainView)
            _pWBMainView.close();
        }

        public function set closeHandler( value : Handler ) : void {
            this._closeHandler = value;
        }
    }
}
