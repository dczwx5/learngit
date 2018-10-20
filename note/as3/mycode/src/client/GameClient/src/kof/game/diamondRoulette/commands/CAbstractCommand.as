//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2018/1/22.
 * Time: 10:55
 */
package kof.game.diamondRoulette.commands {

import kof.game.diamondRoulette.models.CRDNetDataManager;


/**
 * @author yili(guoyiligo@qq.com)
 * 2018/1/22
 */
public class CAbstractCommand{
    protected var _reciver:CRDNetDataManager = null;
    public function CAbstractCommand(model:CRDNetDataManager) {
        this._reciver = model;
    }

    public function execute():void{

    }
}
}
