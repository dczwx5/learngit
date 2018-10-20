//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/7/27.
 * Time: 10:59
 */
package kof.game.globalBoss {

    import kof.framework.CSystemHandler;
    import kof.game.globalBoss.datas.CWBDataManager;
    import kof.game.globalBoss.net.CWBNet;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/7/27
     */
    public class CWorldBossHandler extends CSystemHandler {
        private var _pwbNet : CWBNet = null;

        public function CWorldBossHandler() {
            super();
        }

        public function get WBNet() : CWBNet {
            return this._pwbNet;
        }

        override public function dispose() : void {
            super.dispose();
        }

        override protected function onSetup() : Boolean {
            var ret : Boolean = super.onSetup();
            ret = ret && _init();
            return ret;
        }

        private function _init() : Boolean {
            _pwbNet = new CWBNet( networking );
            _pwbNet.WBDataManager = system.getBean( CWBDataManager ) as CWBDataManager;
            _pwbNet.queryWorldBossInfoRequest();
            _pwbNet.queryWorldBossTreasureInfoRequest();
            return true;
        }


    }
}
