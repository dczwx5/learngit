//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/10/19.
 */
package kof.game.endlessTower {

import kof.game.common.view.CViewManagerHandler;
import kof.game.endlessTower.view.CEndlessTowerBoxTipsView;
import kof.game.endlessTower.view.CEndlessTowerRewardTipsView;

public class CEndlessTowerUIHandler extends CViewManagerHandler {
    public function CEndlessTowerUIHandler()
    {
        super();
    }

    override protected function onSetup() : Boolean
    {
        var ret : Boolean = super.onSetup();

        this.registTips(CEndlessTowerRewardTipsView);
        this.registTips(CEndlessTowerBoxTipsView);

        return ret;
    }
}
}
