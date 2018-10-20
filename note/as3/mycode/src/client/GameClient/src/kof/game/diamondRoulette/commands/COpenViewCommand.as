//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2018/1/22.
 * Time: 10:53
 */
package kof.game.diamondRoulette.commands {

import kof.game.diamondRoulette.models.CRDNetDataManager;

/**
 * @author yili(guoyiligo@qq.com)
 * 2018/1/22
 */
public class COpenViewCommand extends CAbstractCommand{
    public function COpenViewCommand(model:CRDNetDataManager){
        super(model);
    }
    override public function execute() : void{
        this._reciver.diamondRouletteRequest();
    }

}
}
