//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/5/31.
 * Time: 9:50
 */
package kof.game.sign {

    import kof.framework.CSystemHandler;
    import kof.game.sign.signFacade.CSignFacade;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/5/31
     */
    public class CSignHandler extends CSystemHandler {
        private var _signFacade : CSignFacade = null;

        public function CSignHandler() {
            super();
        }

        override public function dispose() : void {
            super.dispose();
            _signFacade = null;
        }

        override protected function onSetup() : Boolean {
            var ret : Boolean = super.onSetup();
            ret = ret && _init();
            return ret;
        }

        private function _init() : Boolean {
            _signFacade = CSignFacade.getInstance();
            _signFacade.initlializeNet();
            _signFacade.netWork = networking;
            _signFacade.signAppSystem = system;
            _signFacade.openSignInSystemRequest();
            return true;
        }
    }
}
