//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/10/19.
 * Time: 17:47
 */
package kof.game.clubBoss {

import kof.framework.CSystemHandler;
import kof.game.clubBoss.datas.CCBDataManager;
import kof.game.clubBoss.net.CCBNet;

/**
 * @author yili(guoyiligo@qq.com)
 * 2017/10/19
 */
public class CClubBossHandler extends CSystemHandler {
    private var _pcbNet:CCBNet = null;

    public function CClubBossHandler() {
        super();
    }

    public function get cbNet():CCBNet{
        return _pcbNet;
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
        _pcbNet = new CCBNet( networking );
        _pcbNet.cbDataManager = system.getBean( CCBDataManager ) as CCBDataManager;
        _pcbNet.system = system;
        _pcbNet.queryClubBossInfoRequest();
        return true;
    }
}
}
