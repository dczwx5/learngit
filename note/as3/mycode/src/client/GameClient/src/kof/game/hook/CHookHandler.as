//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/7/17.
 * Time: 10:17
 */
package kof.game.hook {

    import kof.framework.CSystemHandler;
    import kof.game.hook.net.CHookNet;
    import kof.game.hook.net.CHookNetDataManager;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/7/17
     */
    public class CHookHandler extends CSystemHandler {
        private var _hookNet : CHookNet = null;

        public function CHookHandler() {
            super();
        }

        public function get hookNet() : CHookNet {
            return this._hookNet;
        }

        override public function dispose() : void {
            super.dispose();
            _hookNet = null;
        }

        override protected function onSetup() : Boolean {
            var ret : Boolean = super.onSetup();
            ret = ret && _init();
            return ret;
        }

        private function _init() : Boolean {
            _hookNet = new CHookNet();
            _hookNet.network = networking;
            return true;
        }
    }
}
