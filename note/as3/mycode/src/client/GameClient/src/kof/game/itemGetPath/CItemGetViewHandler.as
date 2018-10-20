//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/8/15.
 * Time: 11:29
 */
package kof.game.itemGetPath {

    import kof.framework.CViewHandler;
    import kof.ui.imp_common.getItemPathUI;

    import morn.core.handlers.Handler;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/8/15
     */
    public class CItemGetViewHandler extends CViewHandler {
        private var _bViewInitialized : Boolean = false;
        private var _pItemGetView : CItemGetView = null;
        private var _pSweepRewardView : CSweepView = null;
        private var _closeHandler : Handler = null;
        private var _itemId : Number = 0;

        public function CItemGetViewHandler( bLoadViewByDefault : Boolean = false ) {
            super( bLoadViewByDefault );
        }

        override public function dispose() : void {
            super.dispose();
        }

        override public function get viewClass() : Array {
            return [ getItemPathUI ];
        }

        override protected function onAssetsLoadCompleted() : void {
            super.onAssetsLoadCompleted();
            this.onInitializeView();
        }

        override protected function onInitializeView() : Boolean {
            if ( !super.onInitializeView() )
                return false;
            if ( !_bViewInitialized ) {
                _pItemGetView = new CItemGetView( uiCanvas );
                _pItemGetView.closeHandler = this._closeHandler;
                _pItemGetView.appSystem = system;
                _bViewInitialized = true;
            }
            return _bViewInitialized;
        }

        public function set closeHandler( value : Handler ) : void {
            this._closeHandler = value;
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
            _pItemGetView.show()
        }

        public function close() : void {
            _pItemGetView.close();
        }

        public function set itemId( value : Number ) : void {
            _itemId = value;
            if ( !_pItemGetView ) {
                this.onInitializeView();
            }
            _pItemGetView.itemId = value;
        }

        public function get itemId():Number{
            return _itemId;
        }
    }
}
