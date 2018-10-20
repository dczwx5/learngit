//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2018/1/22.
 * Time: 12:25
 */
package kof.game.diamondRoulette {

import kof.framework.CSystemHandler;
import kof.game.diamondRoulette.models.CAbstractModel;
import kof.game.diamondRoulette.models.CRDNetDataManager;

/**
 * @author yili(guoyiligo@qq.com)
 * 2018/1/22
 */
public class CReturnDiamondHandler extends CSystemHandler{
    private var _netDataManager:CRDNetDataManager=null;
    public function CReturnDiamondHandler() {
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected function onSetup():Boolean
    {
        var ret:Boolean = super.onSetup();
        ret = ret&&_init();
        return ret;
    }

    private function _init():Boolean
    {
        _netDataManager = system.getBean(CRDNetDataManager) as CRDNetDataManager;
        _netDataManager.net = networking;
        _netDataManager.initRequest();
        return true;
    }

    public function get model():CRDNetDataManager{
        return _netDataManager;
    }
}
}
