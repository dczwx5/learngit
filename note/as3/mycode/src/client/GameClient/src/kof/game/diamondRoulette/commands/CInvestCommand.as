//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2018/2/7.
 * Time: 15:09
 */
package kof.game.diamondRoulette.commands {

import kof.game.diamondRoulette.models.CRDNetDataManager;

/**
 * @author yili(guoyiligo@qq.com)
 * 2018/2/7
 */
public class CInvestCommand extends CAbstractCommand {
    public function CInvestCommand(model:CRDNetDataManager) {
        super(model);
    }

    override public function execute():void{
        this._reciver.diamondRouletteDrawRequest();
    }
}
}
