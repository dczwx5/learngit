//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2017/4/18.
 * Time: 10:32
 */
package kof.game.talent {

import kof.game.common.view.CTweenViewHandler;
    import kof.game.talent.talentFacade.CTalentFacade;
    import kof.ui.demo.talentSys.TalentBagUI;
    import kof.ui.demo.talentSys.TalentBatchSellUI;
    import kof.ui.demo.talentSys.TalentSelectUI;
    import kof.ui.demo.talentSys.TalentSellUI;
    import kof.ui.demo.talentSys.TalentTipsUI;
    import kof.ui.demo.talentSys.TalentUI;

    import morn.core.handlers.Handler;

    public class CTalentViewHandler extends CTweenViewHandler {
        private var _closeHandler : Handler = null;
        private var _talentFacade : CTalentFacade = null;
        private var _bViewInitialized : Boolean = false;

        public function CTalentViewHandler() {
            super( false );
        }

        override public function dispose() : void {
            super.dispose();
            if ( _talentFacade ) {
                _talentFacade.dispose();
            }
            _closeHandler = null;
            _talentFacade = null;
        }

        override public function get viewClass() : Array
        {
            return [ TalentBagUI, TalentBatchSellUI, TalentUI, TalentSelectUI, TalentSellUI, TalentTipsUI ];
        }

        override protected function get additionalAssets():Array
        {
            return ["frameclip_talent.swf", "frameclip_talentSmelting.swf"];
        }

        override protected function onAssetsLoadCompleted() : void {
            super.onAssetsLoadCompleted();
            this.onInitializeView();
        }

        override protected function onInitializeView() : Boolean {
            if ( !super.onInitializeView() )
                return false;
            if ( !_bViewInitialized ) {
                _talentFacade = CTalentFacade.getInstance();
                _bViewInitialized = _talentFacade.initTalentView();
                _talentFacade.talentRootUIContainer = uiCanvas;
                _talentFacade.talentAppSystem = system;
                _talentFacade.closeHandler = _closeHandler;
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
            _talentFacade.show();
        }

        public function close() : void {
            _talentFacade.close();
        }

        public function set closeHandler( handler : Handler ) : void {
            _closeHandler = handler;
        }

        public function get closeHandler() : Handler {
            return this._closeHandler;
        }
    }
}
